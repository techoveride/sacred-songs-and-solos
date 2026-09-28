import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:hymn_book/model/db_helper.dart';
import 'package:hymn_book/model/globals.dart' as globals;
import 'package:hymn_book/model/hymn.dart';
import '../state/hymns_notifier.dart';

GlobalKey<HymnListingState> hymnGKey = GlobalKey();

class HymnListing extends StatefulWidget {
  final ValueChanged<Hymns>? hymnSelectedCallback;
  final Hymns? hymnSelected;

  const HymnListing({
    Key? key,
    required this.hymnSelectedCallback,
    this.hymnSelected,
  }) : super(key: key);

  @override
  HymnListingState createState() => HymnListingState();
}

class HymnListingState extends State<HymnListing> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Hymns> _hymnList = [];
  bool _isLoading = true;
  String _currentSort = 'number';
  String _currentQuery = '';

  final ScrollController _scrollControl = ScrollController();
  static const double _itemExtent = 64.0;

  @override
  void initState() {
    super.initState();
    HymnsNotifier.instance.addListener(_onHymnsChanged);
    loadHymns();
  }

  @override
  void dispose() {
    HymnsNotifier.instance.removeListener(_onHymnsChanged);
    _scrollControl.dispose();
    super.dispose();
  }

  void _onHymnsChanged() {
    if (mounted) {
      refreshList();
    }
  }

  Future<void> loadHymns() async {
    setState(() => _isLoading = true);
    final hymns = await _dbHelper.getHymnsList(sortBy: _currentSort);
    if (mounted) {
      setState(() {
        _hymnList = hymns;
        _isLoading = false;
      });
    }
  }

  Future<void> refreshList() async {
    if (_currentQuery.isNotEmpty) {
      onSearchedItem(_currentQuery);
    } else {
      await loadHymns();
    }
  }

  void onSearchedItem(String value) async {
    _currentQuery = value.trim();
    if (_currentQuery.isEmpty) {
      await loadHymns();
      return;
    }

    final results = await _dbHelper.searchHymns(_currentQuery);
    if (mounted) {
      setState(() {
        _hymnList = results;
      });
    }
  }

  void onSearchExit(String value) {
    _currentQuery = '';
    loadHymns();
  }

  void sortByTitle() async {
    _currentSort = 'title';
    if (_currentQuery.isNotEmpty) {
      setState(() {
        _hymnList.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      });
    } else {
      await loadHymns();
    }
  }

  void sortByNumber() async {
    _currentSort = 'number';
    if (_currentQuery.isNotEmpty) {
      setState(() {
        _hymnList.sort((a, b) => a.id.compareTo(b.id));
      });
    } else {
      await loadHymns();
    }
  }

  String titleCase(String title) {
    if (title.isEmpty) return title;
    return title.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hymnList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _currentQuery.isNotEmpty
                    ? "No hymns found matching '$_currentQuery'"
                    : "No hymns available",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DraggableScrollbar.arrows(
        alwaysVisibleScrollThumb: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.only(right: 4.0),
        labelTextBuilder: (double offset) => Text(
          "${(offset ~/ _itemExtent) + 1}",
          style: const TextStyle(color: Colors.white),
        ),
        controller: _scrollControl,
        child: ListView.builder(
          controller: _scrollControl,
          itemCount: _hymnList.length,
          itemExtent: _itemExtent,
          itemBuilder: (_, index) {
            final hymn = _hymnList[index];
            final bool isSelected = widget.hymnSelected?.id == hymn.id;

            return Card(
              elevation: isSelected ? 6.0 : 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: isSelected
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2.0,
                      )
                    : BorderSide.none,
              ),
              color: isSelected
                  ? Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.12)
                  : null,
              margin:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
              child: ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    hymn.isUserComposed ? "CUSTOM" : indexOptimiser(hymn.id),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: hymn.isUserComposed ? 11.0 : 15.0,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                title: Text(
                  titleCase(hymn.title.trim()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15.0,
                  ),
                ),
                subtitle: hymn.isUserComposed
                    ? const Text("User Composed Song",
                        style: TextStyle(fontSize: 12))
                    : (hymn.author != null && hymn.author!.isNotEmpty
                        ? Text(
                            hymn.author!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          )
                        : null),
                trailing: hymn.favorite == 1
                    ? const Icon(Icons.favorite,
                        color: Colors.redAccent, size: 20)
                    : null,
                selected: isSelected,
                onTap: () async {
                  widget.hymnSelectedCallback?.call(hymn);
                  if (globals.isPlaying) await globals.player.stop();
                  if (!hymn.isUserComposed) {
                    globals.load(
                      hymn.id.toString(),
                      tuneSource: hymn.tune,
                      hymnId: hymn.id,
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

String indexOptimiser(int id) {
  if (id.toString().length == 1) {
    return "000$id";
  } else if (id.toString().length == 2) {
    return "00$id";
  } else if (id.toString().length == 3) {
    return "0$id";
  } else {
    return id.toString();
  }
}
