import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hymn_book/model/globals.dart' as globals;

class ReportBug extends StatefulWidget {
  const ReportBug({super.key});

  @override
  State<ReportBug> createState() => _ReportBugState();
}

class _ReportBugState extends State<ReportBug> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = "Bug / Crash";
  bool _isSending = false;

  final List<String> _categories = [
    "Bug / Crash",
    "Audio / Tune Issue",
    "Lyric Typo / Error",
    "Feature Suggestion",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String platformName = Platform.isAndroid
        ? "Android"
        : Platform.isIOS
            ? "iOS"
            : "Mobile";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report an Issue"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: <Widget>[
            // Header Info Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: colorScheme.errorContainer.withValues(alpha: 0.25),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bug_report_outlined, color: colorScheme.onErrorContainer, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Help Us Improve",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Encountered a crash, typo, or audio problem? Let us know so we can fix it promptly.",
                            style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Issue Category
            Text(
              "ISSUE CATEGORY",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Brief Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Short Summary",
                hintText: "e.g., Hymn #42 stanza 2 typo, Audio cuts off",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please provide a brief summary";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Detailed Description",
                hintText: "Describe what happened, the hymn number, or steps to reproduce the issue...",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.description_outlined),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please provide a description of the issue";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Auto-diagnostics Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: theme.hintColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Device diagnostic data ($platformName • App v${globals.app_version.isNotEmpty ? globals.app_version : '1.2.1'}) will be automatically attached to help us debug.",
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSending ? null : _submitReport,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSending ? "Preparing Email..." : "Submit Report via Email",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSending = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final platform = Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Other";
    final appVer = globals.app_version.isNotEmpty ? globals.app_version : "1.2.1";

    final emailBody = """
Category: $_selectedCategory
Title: $title

Description:
$description

----------------------------------------
System Diagnostics:
Platform: $platform
App Version: $appVer
Night Mode: ${globals.nightMode}
Active Theme: ${globals.currentThemeKey}
Timestamp: ${DateTime.now().toIso8601String()}
----------------------------------------
""";

    final Email email = Email(
      body: emailBody,
      subject: '[$_selectedCategory] $title',
      recipients: ['hymnestryteam@outlook.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email client launched! Please tap send to deliver your report."),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open email app: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
