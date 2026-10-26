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
import '../../../shared/widgets/filter_pill_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../application/wallet_controller.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 300) {
        ref.read(walletTransactionsControllerProvider.notifier).loadMore();
      }
    });
    // Always re-pull on entry: the balance on screen may be a stale cached
    // value from the Profile card (docs "Wallet" rule 1 — online-only).
    Future.microtask(() => ref.read(walletControllerProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(walletControllerProvider.notifier).refresh(),
      ref.read(walletTransactionsControllerProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final walletAsync = ref.watch(walletControllerProvider);
    final txAsync = ref.watch(walletTransactionsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.wltPageTitle)),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: walletAsync.when(
          loading: () => scrollableCenter(const AppLoadingIndicator()),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : l10n.wltCardLoadError,
              onRetry: _refresh,
            ),
          ),
          data: (wallet) => ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _BalanceCard(wallet: wallet),
              const SizedBox(height: 16),
              if (wallet.isFrozen) ...[
                _FrozenBanner(message: l10n.wltFrozenBanner),
                const SizedBox(height: 16),
              ],
              _ActionRow(enabled: !wallet.isFrozen),
              const SizedBox(height: 16),
              _LimitsCard(limits: wallet.limits),
              const SizedBox(height: 24),
              Text(
                l10n.wltHistoryTitle,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              const _TypeFilterBar(),
              const SizedBox(height: 12),
              ..._buildTransactions(context, txAsync),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTransactions(BuildContext context, AsyncValue<WalletTransactionsState> txAsync) {
    final l10n = AppLocalizations.of(context);
    return txAsync.when(
      loading: () => [const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: AppLoadingIndicator())],
      error: (error, _) => [
        ListErrorState(
          message: error is ApiException ? error.message : l10n.wltHistoryLoadError,
          onRetry: ref.read(walletTransactionsControllerProvider.notifier).refresh,
        ),
      ],
      data: (state) {
        if (state.items.isEmpty) {
          return [
            ListEmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.wltHistoryEmptyTitle,
              subtitle: l10n.wltHistoryEmptySubtitle,
            ),
          ];
        }
        return [
          for (final item in state.items)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: _TransactionTile(transaction: item)),
          if (state.isLoadingMore)
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: AppLoadingIndicator()),
        ];
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet});

  final WalletModel wallet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onPrimary = AppColors.onPrimary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.wltCardTitle, style: TextStyle(color: onPrimary.withValues(alpha: 0.8), fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            formatRupiah(wallet.balance),
            style: TextStyle(color: onPrimary, fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.wltAccountNumberLabel,
            style: TextStyle(color: onPrimary.withValues(alpha: 0.8), fontSize: 11.5),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  wallet.formattedAccountNumber,
                  style: TextStyle(color: onPrimary, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
              ),
              IconButton(
                tooltip: l10n.wltCardCopyAccountNumber,
                icon: Icon(Icons.copy_rounded, color: onPrimary, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: wallet.accountNumber));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.wltCopiedAccountNumber)));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrozenBanner extends StatelessWidget {
  const _FrozenBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 12.5))),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.send_rounded,
            label: l10n.wltActionTransfer,
            onTap: enabled ? () => context.push('/wallet/transfer') : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.add_card_rounded,
            label: l10n.wltActionTopup,
            onTap: enabled ? () => context.push('/wallet/topup') : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.account_balance_outlined,
            label: l10n.wltActionWithdraw,
            onTap: enabled ? () => context.push('/wallet/withdraw') : null,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LimitsCard extends StatelessWidget {
  const _LimitsCard({required this.limits});

  final WalletLimits limits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final used = limits.dailyLimit <= 0 ? 0.0 : (limits.sentToday / limits.dailyLimit).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.wltLimitsTitle,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.wltLimitPerTransaction(formatRupiah(limits.minTransfer), formatRupiah(limits.maxTransfer)),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: used,
              minHeight: 6,
              backgroundColor: AppColors.background,
              color: used >= 0.9 ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.wltLimitRemainingToday(formatRupiah(limits.remainingToday), formatRupiah(limits.dailyLimit)),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TypeFilterBar extends ConsumerWidget {
  const _TypeFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(walletTransactionsControllerProvider).valueOrNull?.type;
    final controller = ref.read(walletTransactionsControllerProvider.notifier);

    FilterPillSpec pill(String label, WalletTransactionType? type) =>
        FilterPillSpec(label: label, selected: selected == type, onTap: () => controller.setType(type));

    return FilterPillBar(
      pills: [
        pill(l10n.wltFilterAll, null),
        pill(l10n.wltFilterTransferOut, WalletTransactionType.transferOut),
        pill(l10n.wltFilterTransferIn, WalletTransactionType.transferIn),
        pill(l10n.wltFilterTopup, WalletTransactionType.topupFromPortfolio),
        pill(l10n.wltFilterWithdraw, WalletTransactionType.withdrawToPortfolio),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final WalletTransactionModel transaction;

  String _title(AppLocalizations l10n) {
    final name = transaction.transfer?.counterparty.name ?? '-';
    return switch (transaction.type) {
      WalletTransactionType.transferOut => l10n.wltTxnTransferOut(name),
      WalletTransactionType.transferIn => l10n.wltTxnTransferIn(name),
      WalletTransactionType.topupFromPortfolio => l10n.wltTxnTopup,
      WalletTransactionType.withdrawToPortfolio => l10n.wltTxnWithdraw,
      WalletTransactionType.reversal => l10n.wltTxnReversal,
      WalletTransactionType.adjustment => l10n.wltTxnAdjustment,
    };
  }

  IconData get _icon => switch (transaction.type) {
        WalletTransactionType.transferOut => Icons.north_east_rounded,
        WalletTransactionType.transferIn => Icons.south_west_rounded,
        WalletTransactionType.topupFromPortfolio => Icons.add_card_rounded,
        WalletTransactionType.withdrawToPortfolio => Icons.account_balance_outlined,
        WalletTransactionType.reversal => Icons.undo_rounded,
        WalletTransactionType.adjustment => Icons.tune_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final color = transaction.isIncoming ? AppColors.success : AppColors.textPrimary;
    final transfer = transaction.transfer;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: transfer == null ? null : () => context.push('/wallet/transfers/${transfer.id}', extra: transfer),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (transaction.isIncoming ? AppColors.success : AppColors.textSecondary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: 18, color: transaction.isIncoming ? AppColors.success : AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatLocalizedDate(transaction.createdAt.toLocal(), locale)} • '
                      '${l10n.wltTxnBalanceAfter(formatRupiah(transaction.balanceAfter))}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${transaction.isIncoming ? '+' : '-'}${formatRupiah(transaction.amount)}',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
