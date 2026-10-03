import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/globals.dart' as globals;
import '../state/purchase_notifier.dart';
import 'app_dialog.dart';

/// Shows the Pro Upgrade dialog offering In-App Purchase to remove ads and unlock Pro status.
Future<void> showProUpgradeDialog(BuildContext context) {
  return showAppDialog(
    context: context,
    builder: (dialogCtx) => const ProUpgradeDialogContent(),
  );
}

class ProUpgradeDialogContent extends StatelessWidget {
  const ProUpgradeDialogContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: PurchaseNotifier.instance,
      builder: (context, _) {
        final notifier = PurchaseNotifier.instance;
        final isPro = notifier.isPro;
        final isLoading = notifier.isLoading;

        if (isPro) {
          return AppDialog(
            icon: Icons.verified,
            iconColor: Colors.amber[700],
            title: "Pro Member Active",
            subtitle: "Thank you for your generous support!",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars_rounded, color: Colors.amber[800], size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "You have lifetime Pro access enabled. All advertisements are permanently disabled.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Done"),
              ),
            ],
          );
        }

        return AppDialog(
          icon: Icons.workspace_premium,
          iconColor: Colors.amber[700],
          title: "Upgrade to Pro",
          subtitle: "Remove all ads and support the ministry",
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _buildFeatureRow(
                icon: Icons.block,
                title: "100% Ad-Free Experience",
                subtitle: "Enjoy uninterrupted worship without banners or full-screen ads.",
                context: context,
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(
                icon: Icons.bolt,
                title: "Faster & Lighter",
                subtitle: "Zero ad data usage, lighter battery footprint, and instant page loading.",
                context: context,
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(
                icon: Icons.all_inclusive,
                title: "Lifetime Purchase",
                subtitle: "Pay once, enjoy forever. Can be restored anytime on new devices.",
                context: context,
              ),
              if (notifier.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.onErrorContainer, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notifier.errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => launchUrl(
                      Uri.parse(globals.PRIVACY_POLICY_URL),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      "Privacy Policy",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("•", style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => launchUrl(
                      Uri.parse(globals.TERMS_OF_USE_URL),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      "Terms of Use (EULA)",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => notifier.restorePurchases(),
              child: const Text("Restore Purchases"),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      final success = await notifier.buyPro();
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(
                isLoading ? "Processing..." : "Get Pro (${notifier.formattedPrice})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
