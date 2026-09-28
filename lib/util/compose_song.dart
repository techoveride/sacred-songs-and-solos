import 'package:flutter/material.dart';
import 'package:hymn_book/model/db_helper.dart';
import 'package:hymn_book/model/hymn.dart';
import 'package:hymn_book/util/hymn_listing.dart';
import '../state/hymns_notifier.dart';

class ComposeSong extends StatefulWidget {
  final Hymns? existingHymn;

  const ComposeSong({Key? key, this.existingHymn}) : super(key: key);

  @override
  State<ComposeSong> createState() => _ComposeSongState();
}

class _ComposeSongState extends State<ComposeSong> {
  final _formKey = GlobalKey<FormState>();
  final titleNode = FocusNode();
  final authorNode = FocusNode();
  final tuneNode = FocusNode();
  final lyricNode = FocusNode();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _tuneController;
  late TextEditingController _lyricController;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingHymn?.title ?? '');
    _authorController = TextEditingController(text: widget.existingHymn?.author ?? '');
    _tuneController = TextEditingController(text: widget.existingHymn?.tune ?? '');
    _lyricController = TextEditingController(text: widget.existingHymn?.lyric ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _tuneController.dispose();
    _lyricController.dispose();
    titleNode.dispose();
    authorNode.dispose();
    tuneNode.dispose();
    lyricNode.dispose();
    super.dispose();
  }

  Future<void> _saveSong() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.existingHymn != null) {
        final updatedHymn = widget.existingHymn!.copyWith(
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          tune: _tuneController.text.trim(),
          lyric: _lyricController.text.trim(),
        );
        await _dbHelper.updateCustomHymn(updatedHymn);
      } else {
        final newHymn = Hymns(
          id: 0, // Auto-assigned by saveCustomHymn
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          tune: _tuneController.text.trim(),
          lyric: _lyricController.text.trim(),
          isCustom: 1,
        );
        await _dbHelper.saveCustomHymn(newHymn);
      }

      hymnGKey.currentState?.refreshList();
      HymnsNotifier.instance.notifyHymnsChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingHymn != null
                ? "Composed song updated successfully!"
                : "Composed song saved successfully!"),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving song: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final isEditing = widget.existingHymn != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Composed Song" : "Compose Your Song"),
        centerTitle: true,
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.music_note),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _titleController,
                  focusNode: titleNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).requestFocus(authorNode),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter a song title";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "e.g. Joy to the World",
                    labelText: "Song Title *",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _authorController,
                  focusNode: authorNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).requestFocus(tuneNode),
                  decoration: InputDecoration(
                    hintText: "e.g. Isaac Watts",
                    labelText: "Author / Composer (Optional)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _tuneController,
                  focusNode: tuneNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).requestFocus(lyricNode),
                  decoration: InputDecoration(
                    hintText: "e.g. Antioch",
                    labelText: "Tune / Meter (Optional)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: _lyricController,
                  focusNode: lyricNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter the hymn lyrics";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter the stanzas and chorus here...",
                    labelText: "Lyrics *",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSong,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isEditing ? "Update Song" : "Save Composed Song",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
