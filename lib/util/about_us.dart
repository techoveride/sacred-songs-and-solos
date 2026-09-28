import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hymn_book/model/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String appVersion = globals.app_version.isNotEmpty
        ? globals.app_version
        : "1.2.1";

    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: <Widget>[
          // Header Hero Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Image.asset(
                    'images/main_logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Sacred Songs & Solos",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "+Tunes & Melodies Edition",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Version $appVersion",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "A worship companion crafted for Christians worldwide to sing praises unto the Almighty God in church, at home, and in fellowship.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Mission & Purpose
          Text(
            "OUR MISSION",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.music_note_rounded, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Hymnestry is dedicated to preserving Christian hymnody by combining traditional lyrics with accessible audio tunes, encouraging active participation in congregational and family worship.",
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Connect & Links
          Text(
            "CONNECT & CHANNELS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildLinkTile(
                  iconWidget: const Icon(Icons.language, color: Colors.blueAccent),
                  title: "Official Website",
                  subtitle: "hymnestry.techoveridehub.com",
                  onTap: () => _launchURL("https://hymnestry.techoveridehub.com"),
                ),
                const Divider(height: 1, indent: 56),
                _buildLinkTile(
                  iconWidget: const Icon(Icons.email_outlined, color: Colors.redAccent),
                  title: "Contact Hymnestry Team",
                  subtitle: "hymnestryteam@outlook.com",
                  onTap: () => _emailIntent(),
                ),
                const Divider(height: 1, indent: 56),
                _buildLinkTile(
                  iconWidget: const Icon(Icons.code, color: Colors.deepPurple),
                  title: "GitHub Repository",
                  subtitle: "github.com/techoveride/sacred-songs-and-solos",
                  onTap: () => _launchURL("https://github.com/techoveride/sacred-songs-and-solos"),
                ),
                const Divider(height: 1, indent: 56),
                _buildLinkTile(
                  iconWidget: const Icon(Icons.business_center_outlined, color: Colors.blue),
                  title: "LinkedIn Profile",
                  subtitle: "Yakubu Buba (TechOveride)",
                  onTap: () => _launchURL("https://www.linkedin.com/in/yakubu-buba-techoveride"),
                ),
                const Divider(height: 1, indent: 56),
                _buildLinkTile(
                  iconWidget: const Icon(Icons.facebook, color: Colors.indigo),
                  title: "Facebook Page",
                  subtitle: "facebook.com/TechOveride",
                  onTap: () => _launchURL("https://web.facebook.com/TechOveride"),
                ),
                const Divider(height: 1, indent: 56),
                _buildLinkTile(
                  iconWidget: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
                  title: "X (formerly Twitter)",
                  subtitle: "@techoveride",
                  onTap: () => _launchURL("https://twitter.com/techoveride"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Copyright & Footer
          Center(
            child: Column(
              children: [
                Text(
                  "© 2026 Hymnestry Apps • TechOveride",
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 4),
                Text(
                  "All traditional hymn lyrics are in public domain.",
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: theme.hintColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _buildLinkTile({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: iconWidget,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Future<void> _emailIntent() async {
    final Email email = Email(
      body: 'Hi Hymnestry Team!\n\n',
      subject: 'Inquiry / Contact - Sacred Songs & Solos',
      recipients: ['hymnestryteam@outlook.com'],
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      debugPrint("Email sender error: $e");
    }
  }

  Future<void> _launchURL(String myUrl) async {
    final Uri url = Uri.parse(myUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }
}
