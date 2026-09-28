import 'package:flutter/material.dart';
import 'package:hymn_book/model/db_helper.dart';
import 'package:hymn_book/model/hymn.dart';
import 'package:hymn_book/util/compose_song.dart';
import 'package:hymn_book/util/hymn_details.dart';
import 'package:hymn_book/util/hymn_listing.dart';
import '../state/hymns_notifier.dart';
import 'app_dialog.dart';

class AddedSong extends StatefulWidget {
  const AddedSong({Key? key}) : super(key: key);

  @override
  State<AddedSong> createState() => _AddedSongState();
}

class _AddedSongState extends State<AddedSong> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Hymns> _composedSongs = [];
  bool _isLoading = true;
  Hymns? _selectedSong;

  static const int tabletBreakpoint = 600;

  @override
  void initState() {
    super.initState();
    loadComposedSongs();
  }

  Future<void> loadComposedSongs() async {
    setState(() => _isLoading = true);
    final songs = await _dbHelper.getHymnsList(customOnly: true);
    if (mounted) {
      setState(() {
        _composedSongs = songs;
        _isLoading = false;
        if (_selectedSong == null && songs.isNotEmpty) {
          _selectedSong = songs.first;
        } else if (songs.isEmpty) {
          _selectedSong = null;
        }
      });
    }
  }

  void _confirmDelete(Hymns hymn) {
    showAppDialog(
      context: context,
      builder: (ctx) => AppDialog(
        icon: Icons.delete_outline,
        iconColor: Colors.redAccent,
        title: "Delete Composed Song?",
        subtitle: "Are you sure you want to delete '${hymn.title}'? This action cannot be undone.",
        content: const SizedBox(height: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _dbHelper.deleteCustomHymn(hymn.id);
              hymnGKey.currentState?.refreshList();
              HymnsNotifier.instance.notifyHymnsChanged();
              await loadComposedSongs();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("'${hymn.title}' deleted")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Composed Songs"),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.queue_music),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _composedSongs.isEmpty
              ? _buildEmptyView()
              : isTablet
                  ? _buildTabletView()
                  : _buildMobileList(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'composeFab',
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ComposeSong()),
          );
          if (res == true) {
            await loadComposedSongs();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "No Composed Songs Yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Write your own hymns and spiritual songs!\nTap the + button below to compose a new song.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      itemCount: _composedSongs.length,
      itemBuilder: (context, index) {
        final hymn = _composedSongs[index];
        return Card(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              hymn.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: hymn.author != null && hymn.author!.isNotEmpty
                ? Text("By: ${hymn.author}")
                : const Text("Custom Song"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit,
                      color: Colors.blueAccent, size: 20),
                  tooltip: "Edit",
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ComposeSong(existingHymn: hymn)),
                    );
                    if (res == true) loadComposedSongs();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  tooltip: "Delete",
                  onPressed: () => _confirmDelete(hymn),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HymnDetails(
                    isInTabletLayout: false,
                    hymns: hymn,
                    onFavoriteChanged: loadComposedSongs,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabletView() {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Material(
            elevation: 4.0,
            child: ListView.builder(
              itemCount: _composedSongs.length,
              itemBuilder: (context, index) {
                final hymn = _composedSongs[index];
                final isSelected = _selectedSong?.id == hymn.id;
                return Card(
                  elevation: isSelected ? 4.0 : 1.0,
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.12)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: isSelected
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2)
                        : BorderSide.none,
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 3.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text("${index + 1}"),
                    ),
                    title: Text(hymn.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: hymn.author != null
                        ? Text(hymn.author!, maxLines: 1)
                        : null,
                    selected: isSelected,
                    onTap: () {
                      setState(() => _selectedSong = hymn);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Flexible(
          flex: 4,
          child: _selectedSong != null
              ? HymnDetails(
                  isInTabletLayout: true,
                  hymns: _selectedSong!,
                  onFavoriteChanged: loadComposedSongs,
                )
              : const Center(child: Text("Select a composed song to view")),
        ),
      ],
    );
  }
}
