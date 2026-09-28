import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hymn_book/model/webview.dart';
import 'package:share_plus/share_plus.dart';

class SupportUs extends StatelessWidget {
  const SupportUs({super.key});

  static const String flutterWaveGateWay = "https://flutterwave.com/pay/yakubububamagc";
  static const String payPalGateWay = "https://www.paypal.com/myaccount/transfer/homepage";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Us"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: <Widget>[
          // Hero Vision Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.secondaryContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Our Vision & Purpose",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\"Sing praises to God, sing praises; sing praises unto our King, sing praises.\"\n— Psalm 47:6",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We believe Christian hymns carry profound spiritual depth that enriches personal worship and unites congregational singing. Time spent singing and meditating on hymns reaps eternal blessings for individuals, families, and churches worldwide.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "WAYS TO PARTNER & SUPPORT",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          // 1. Contribute Tunes
          _buildActionCard(
            context: context,
            icon: Icons.library_music_rounded,
            iconColor: Colors.deepPurple,
            title: "Contribute Melodies & Tunes",
            description: "Have a MIDI file, audio recording, or piano tune for hymns that lack audio in the app? Share it with us to help Christians worldwide learn every hymn!",
            buttonLabel: "Send a Tune / Melody",
            buttonIcon: Icons.upload_file_outlined,
            onPressed: () => _emailTuneContribution(),
          ),
          const SizedBox(height: 12),

          // 2. Financial Donation (Flutterwave)
          _buildActionCard(
            context: context,
            icon: Icons.credit_card_outlined,
            iconColor: Colors.orange[800]!,
            title: "Donate via Flutterwave",
            description: "Support server maintenance, database updates, and continuous app development. Supports debit cards, bank transfers, and mobile money.",
            buttonLabel: "Donate with Flutterwave",
            buttonIcon: Icons.open_in_new,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaymentWebView(url: flutterWaveGateWay),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // 3. PayPal Donation
          _buildActionCard(
            context: context,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: Colors.blue[800]!,
            title: "Donate via PayPal",
            description: "For international supporters and partners who prefer donating securely through PayPal.",
            buttonLabel: "Donate with PayPal",
            buttonIcon: Icons.payment,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaymentWebView(url: payPalGateWay),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // 4. Church Custom App Requests
          _buildActionCard(
            context: context,
            icon: Icons.church_outlined,
            iconColor: Colors.teal,
            title: "Custom Church Hymn App",
            description: "Would you like a specialized, branded hymn book or liturgy application built for your denomination, church, diocese, or choir? Reach out to discuss!",
            buttonLabel: "Inquire About Custom Apps",
            buttonIcon: Icons.handshake_outlined,
            onPressed: () => _emailCustomAppInquiry(),
          ),
          const SizedBox(height: 12),

          // 5. Share with Friends & Fellowship
          _buildActionCard(
            context: context,
            icon: Icons.share_rounded,
            iconColor: Colors.indigo,
            title: "Share Sacred Songs & Solos",
            description: "The easiest way to support us for free! Tell your choir, church members, and fellowship groups about the app.",
            buttonLabel: "Share App with Others",
            buttonIcon: Icons.share,
            onPressed: () {
              Share.share(
                "I use Sacred Songs & Solos (+Tunes) for worship and choir singing. Download it here: https://hymnestry.techoveridehub.com/",
                subject: "Sacred Songs & Solos Hymn Book App",
              );
            },
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              "May the Lord abundantly bless your worship and praise!",
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.hintColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String buttonLabel,
    required IconData buttonIcon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onPressed,
                icon: Icon(buttonIcon, size: 18),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _emailTuneContribution() async {
    final Email email = Email(
      body: 'Hi Hymnestry Team!\n\nI would like to contribute a melody/tune for Hymn #:\nTune Name:\n(Please attach the audio or MIDI file to this email)\n\nThank you!',
      subject: 'Hymn Tune Contribution - Sacred Songs & Solos',
      recipients: ['hymnestryteam@outlook.com'],
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      debugPrint("Tune email error: $e");
    }
  }

  Future<void> _emailCustomAppInquiry() async {
    final Email email = Email(
      body: 'Hi Hymnestry Team!\n\nI am interested in a custom hymn book app for:\nOrganization / Church Name:\nLocation / Country:\nDetails:\n\nLooking forward to hearing from you!',
      subject: 'Custom Hymn App Inquiry - Hymnestry',
      recipients: ['hymnestryteam@outlook.com'],
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      debugPrint("Custom app email error: $e");
    }
  }
}
