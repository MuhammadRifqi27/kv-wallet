import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/btc_tracking_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListEmptyState, ListErrorState;
import '../application/btc_tracking_controller.dart';

/// Combined feed from `GET /btc-tracking/activity` — entries logged
/// directly here (`isFromTransfer: false`, editable/deletable) mixed with
/// rows that came from a crypto-tagged Transfer Antar Akun
/// (`isFromTransfer: true`, view-only — manage those from Transfer instead,
/// per docs/mobile-api-reference.md).
class BtcActivityPage extends ConsumerWidget {
  const BtcActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(btcActivityControllerProvider);
    final controller = ref.read(btcActivityControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.investActivityHistoryLabel)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/investment/entry-form'),
        backgroundColor: AppColors.primary,
        tooltip: l10n.investRecordProfitLossTooltip,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: activityAsync.when(
          loading: () => scrollableCenter(const AppLoadingIndicator()),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : l10n.investActivityLoadError,
              onRetry: controller.refresh,
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return scrollableCenter(
                ListEmptyState(
                  icon: Icons.history_rounded,
                  title: l10n.investActivityEmptyTitle,
                  subtitle: l10n.investActivityEmptySubtitle,
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _ActivityTile(item: items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.item});

  final BtcActivityItem item;

  Color _colorFor(String type) => switch (type) {
        'deposit' || 'profit' => AppColors.success,
        'withdrawal' || 'loss' => AppColors.error,
        _ => AppColors.primary,
      };

  String _labelFor(AppLocalizations l10n, String type) => switch (type) {
        'deposit' => l10n.investLabelDeposit,
        'withdrawal' => l10n.investLabelWithdrawal,
        'profit' => l10n.investLabelProfit,
        'loss' => l10n.investLabelLoss,
        'transfer' => l10n.investLabelTransfer,
        _ => type,
      };

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.investDeleteEntryDialogTitle),
        content: Text(l10n.investDeleteEntryDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.investCancelButton)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.investDeleteButton, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(btcActivityControllerProvider.notifier).removeEntry(item.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final color = _colorFor(item.type);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.currency_bitcoin_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.asset} · ${_labelFor(l10n, item.type)}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    formatLocalizedDateShort(item.date, Localizations.localeOf(context)),
                    if (item.portfolioName != null) item.portfolioName!,
                    if (item.isFromTransfer) l10n.investFromTransferSuffix,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupiah(item.amount),
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          if (item.isFromTransfer)
            IconButton(
              icon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 18),
              tooltip: l10n.investManageFromTransferTooltip,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.investFromTransferSnackbar)),
              ),
            )
          else ...[
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 18),
              onPressed: () => context.push('/investment/entry-form', extra: item),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 18),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}
