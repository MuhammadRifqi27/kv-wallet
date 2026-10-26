import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/storage/notification_history_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/list_states.dart';

/// Read-only log of budget notifications this device has shown — lets the
/// user revisit one after it's gone from the OS tray. See
/// docs/ide-improvement-fitur-existing.txt BAGIAN G #43.
class NotificationHistoryPage extends ConsumerWidget {
  const NotificationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(notificationHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.notificationHistoryAppBarTitle)),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => scrollableCenter(
          ListErrorState(
            message: error.toString(),
            onRetry: () async => ref.invalidate(notificationHistoryProvider),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return scrollableCenter(
              ListEmptyState(
                icon: Icons.notifications_none_rounded,
                title: l10n.notificationHistoryEmptyTitle,
                subtitle: l10n.notificationHistoryEmptySubtitle,
              ),
            );
          }
          final locale = ref.watch(effectiveLocaleProvider);
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _HistoryTile(entry: entries[index], locale: locale),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.locale});

  final NotificationHistoryEntry entry;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(entry.body, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Text(_formatTimestamp(entry.shownAt), style: TextStyle(color: AppColors.textDisabled, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} $hour:$minute';
  }
}
