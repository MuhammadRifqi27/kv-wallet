import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/wallet_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/wallet_controller.dart';

/// Receipt for one transfer. Opened with the [WalletTransferModel] as route
/// `extra` right after sending / from a history row; falls back to fetching
/// `GET /wallet/transfers/{id}` when there's no extra (e.g. restored route).
class WalletTransferReceiptPage extends ConsumerWidget {
  const WalletTransferReceiptPage({super.key, required this.transferId, this.transfer});

  final int transferId;
  final WalletTransferModel? transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loaded = transfer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.wltReceiptTitle)),
      body: SafeArea(
        child: loaded != null
            ? _Receipt(transfer: loaded)
            : ref.watch(walletTransferDetailProvider(transferId)).when(
                  loading: () => const AppLoadingIndicator(),
                  error: (error, _) => Center(
                    child: ListErrorState(
                      message: error is ApiException ? error.message : l10n.wltReceiptLoadError,
                      onRetry: () async => ref.invalidate(walletTransferDetailProvider(transferId)),
                    ),
                  ),
                  data: (data) => _Receipt(transfer: data),
                ),
      ),
    );
  }
}

class _Receipt extends StatelessWidget {
  const _Receipt({required this.transfer});

  final WalletTransferModel transfer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final local = transfer.createdAt.toLocal();
    final time = '${formatLocalizedDate(local, locale)}, '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final completed = transfer.status == 'completed';

    Widget row(String label, String value, {bool copyable = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 120, child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
                ),
              ),
              if (copyable)
                InkWell(
                  onTap: () => Clipboard.setData(ClipboardData(text: value)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (completed ? AppColors.success : AppColors.accent).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed ? Icons.check_rounded : Icons.schedule_rounded,
                size: 34,
                color: completed ? AppColors.success : AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              transfer.isOutgoing ? l10n.wltReceiptSuccess : l10n.wltReceiptReceivedHeader,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              formatRupiah(transfer.amount),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              row(transfer.isOutgoing ? l10n.wltReceiptRecipient : l10n.wltReceiptSender, transfer.counterparty.name),
              if (transfer.counterparty.accountNumber.isNotEmpty)
                row(l10n.wltReceiptAccount, transfer.counterparty.accountNumber),
              row(l10n.wltReceiptAmount, formatRupiah(transfer.amount)),
              if (transfer.note != null && transfer.note!.isNotEmpty) row(l10n.wltReceiptNote, transfer.note!),
              row(l10n.wltReceiptDate, time),
              row(l10n.wltReceiptReference, transfer.referenceNo, copyable: true),
              row(l10n.wltReceiptStatus, completed ? l10n.wltReceiptStatusCompleted : transfer.status),
              if (transfer.balanceAfter != null) row(l10n.wltReceiptBalanceAfter, formatRupiah(transfer.balanceAfter!)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.wltReceiptDone,
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ],
    );
  }
}
