import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Displays a uniform Material 3 dialog with smooth cubic scale-and-fade animation.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, anim1, anim2) => builder(dialogContext),
    transitionBuilder: (dialogContext, anim1, anim2, child) {
      final curved = CurvedAnimation(
        parent: anim1,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: child,
        ),
      );
    },
  );
}

/// Displays a platform-adaptive confirmation dialog (CupertinoAlertDialog on iOS/macOS, AlertDialog on others).
Future<bool?> showAdaptiveConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = "Confirm",
  String cancelText = "Cancel",
  bool isDestructive = false,
}) {
  final isApple = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
  if (isApple) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(content),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(cancelText),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            isDefaultAction: !isDestructive,
            child: Text(confirmText),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text(cancelText),
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        FilledButton(
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          child: Text(confirmText),
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
}

/// Displays an exit confirmation dialog. Returns true if user chose to exit, false otherwise.
/// Never triggers on iOS per Apple App Store Guideline 2.5.8.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  if (!kIsWeb && Platform.isIOS) {
    return false;
  }
  final shouldExit = await showAppDialog<bool>(
    context: context,
    builder: (dialogCtx) => AppDialog(
      icon: Icons.exit_to_app,
      title: "Exit App?",
      subtitle: "Are you sure you want to exit the Hymn Book?",
      content: const SizedBox(height: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(false),
          child: const Text("Stay"),
        ),
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          onPressed: () => Navigator.of(dialogCtx).pop(true),
          child: const Text("Exit"),
        ),
      ],
    ),
  );
  return shouldExit ?? false;
}

/// Uniform Material Dialog widget that respects the active theme design.
class AppDialog extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry contentPadding;
  final double maxWidth;

  const AppDialog({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.content,
    this.actions,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
    this.maxWidth = 420,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = iconColor ?? theme.colorScheme.primary;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Dialog(
          elevation: 6,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: primary, size: 26),
                      ),
                    ],
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // Content Body
              Flexible(
                child: Padding(
                  padding: contentPadding,
                  child: content,
                ),
              ),

              // Action Buttons
              if (actions != null && actions!.isNotEmpty) ...[
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A uniform selectable item inside an AppDialog
class AppOptionCard<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final ValueChanged<T> onSelected;

  const AppOptionCard({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    this.leading,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onSelected(value),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : theme.dividerColor.withValues(alpha: 0.2),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                        color: isSelected ? primary : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primary, size: 20)
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: theme.disabledColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
