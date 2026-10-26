import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Shared loading/empty/error state widgets for list-shaped pages — moved
/// here from category_list_page.dart (where they were originally defined
/// "just for" that page but ended up imported by 14 other feature pages via
/// a `show` clause) so the dependency is a proper shared widget instead of
/// one feature page reaching into another's presentation file. See
/// docs/ide-improvement-fitur-existing.txt BAGIAN E #36.

/// Wraps content in a scrollable container so `RefreshIndicator`'s pull
/// gesture keeps working even on the loading/error/empty states.
Widget scrollableCenter(Widget child) {
  return LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(child: child),
      ),
    ),
  );
}

class ListEmptyState extends StatelessWidget {
  const ListEmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class ListErrorState extends StatelessWidget {
  const ListErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: Text(l10n.investRetryButton)),
        ],
      ),
    );
  }
}
