import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/filter_pill_bar.dart';
import '../../auth/application/auth_controller.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListEmptyState, ListErrorState;
import '../application/transaction_list_controller.dart';

/// "Transaksi Berulang" is a premium-only feature (see
/// docs/flutter-navbar-permission-gating-plan.txt — granted by the
/// `recurring` permission). Mirrors the "locked tile" UX used for Transfer
/// Antar Akun in portfolio_list_page.dart: always tappable, but a user
/// without the permission gets bounced to the upgrade screen instead.
void _openRecurring(BuildContext context, WidgetRef ref) {
  final user = ref.read(authControllerProvider).user;
  if (user?.hasPermission('recurring') ?? false) {
    context.push('/transactions/recurring');
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).txnFeatureRequiresUpgrade)),
  );
  context.push('/profile/membership');
}

class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListControllerProvider);
    final controller = ref.read(transactionListControllerProvider.notifier);
    final searchQuery = ref.watch(transactionSearchQueryProvider);
    final l10n = AppLocalizations.of(context);
    // Kept alive inside MainShell's IndexedStack — see AppColors' class doc
    // + MainShell's note on why this needs an explicit watch.
    ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.txnListTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SearchField(),
                const SizedBox(height: 12),
                const _DateFilterBar(),
                const SizedBox(height: 8),
                const _TypeFilterBar(),
                const SizedBox(height: 12),
                _RecurringMenuTile(onTap: () => _openRecurring(context, ref)),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refresh,
              child: transactionsAsync.when(
                loading: () => scrollableCenter(const AppLoadingIndicator()),
                error: (error, _) => scrollableCenter(
                  ListErrorState(
                    message: error is ApiException ? error.message : l10n.txnListLoadError,
                    onRetry: controller.refresh,
                  ),
                ),
                data: (result) {
                  if (result.transactions.isEmpty) {
                    return scrollableCenter(
                      ListEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.txnListEmptyTitle,
                        subtitle: l10n.txnListEmptySubtitle,
                      ),
                    );
                  }

                  final filtered = filterTransactionsByQuery(result.transactions, searchQuery);
                  if (filtered.isEmpty) {
                    return scrollableCenter(
                      ListEmptyState(
                        icon: Icons.search_off_rounded,
                        title: l10n.txnListNoResultsTitle,
                        subtitle: l10n.txnListNoResultsSubtitle,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SummaryRow(result: result),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TransactionTile(transaction: filtered[index - 1]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Client-side search box — see [transactionSearchQueryProvider]. Keeps its
/// own [TextEditingController] (rather than rebuilding from provider state
/// on every keystroke) so the cursor position isn't disturbed while typing.
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final _controller = TextEditingController(text: ref.read(transactionSearchQueryProvider));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(transactionSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = ref.watch(transactionSearchQueryProvider).isNotEmpty;

    return TextField(
      controller: _controller,
      onChanged: (value) => ref.read(transactionSearchQueryProvider.notifier).state = value,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        hintText: AppLocalizations.of(context).txnSearchHint,
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
        suffixIcon: hasQuery
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                onPressed: _clear,
              )
            : null,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.result});

  final TransactionListResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            label: l10n.txnIncomeLabel,
            value: formatRupiah(result.totalIncome),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: l10n.txnExpenseLabel,
            value: formatRupiah(result.totalExpense),
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: l10n.txnNetBalanceLabel,
            value: formatRupiah(result.netBalance),
            color: result.netBalance >= 0 ? AppColors.primary : AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.transaction});

  final TransactionModel transaction;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.txnDeleteDialogTitle),
        content: Text(l10n.txnDeleteDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.txnCommonCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.txnCommonDelete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(transactionListControllerProvider.notifier).removeTransaction(transaction.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.error;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

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
            child: Icon(
              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.categoryName ?? l10n.txnCategoryFallbackName(transaction.categoryId),
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    formatLocalizedDateShort(transaction.date, locale),
                    if (transaction.portfolioName != null && transaction.portfolioName != '-')
                      transaction.portfolioName!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/transactions/form', extra: transaction);
              } else if (value == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(l10n.txnCommonEdit)),
              PopupMenuItem(value: 'delete', child: Text(l10n.txnCommonDelete)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Entry point for "Transaksi Berulang" — a full menu tile instead of a
/// bare AppBar icon (same lesson learned from Transfer Antar Akun in
/// portfolio_list_page.dart: an icon-only button was too easy to miss).
class _RecurringMenuTile extends StatelessWidget {
  const _RecurringMenuTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.autorenew_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.txnRecurringMenuTileTitle,
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      l10n.txnRecurringMenuTileSubtitle,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date shortcuts (+ a custom range picker) — replaces having no date
/// filter at all. A horizontal chip row instead of a dropdown so the common
/// cases ("bulan ini", "bulan lalu") are one tap, not two. "Bulan Ini"/
/// "Bulan Lalu" resolve to the real payroll cycle, not the 1st–end of the
/// calendar month — see [resolveTransactionDateRange].
class _DateFilterBar extends ConsumerWidget {
  const _DateFilterBar();

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final existing = ref.read(transactionCustomRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: existing != null
          ? DateTimeRange(start: existing.start, end: existing.end)
          : DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
    );
    if (picked == null) return;

    ref.read(transactionCustomRangeProvider.notifier).state = DateRange(start: picked.start, end: picked.end);
    ref.read(transactionDateShortcutProvider.notifier).state = TransactionDateShortcut.custom;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcut = ref.watch(transactionDateShortcutProvider);
    final customRange = ref.watch(transactionCustomRangeProvider);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    void select(TransactionDateShortcut value) => ref.read(transactionDateShortcutProvider.notifier).state = value;

    final customLabel = shortcut == TransactionDateShortcut.custom && customRange != null
        ? '${formatLocalizedDateShort(customRange.start, locale)} - ${formatLocalizedDateShort(customRange.end, locale)}'
        : l10n.txnPickDateLabel;

    return FilterPillBar(
      pills: [
        FilterPillSpec(
          label: l10n.txnFilterAll,
          selected: shortcut == TransactionDateShortcut.all,
          onTap: () => select(TransactionDateShortcut.all),
        ),
        FilterPillSpec(
          label: l10n.txnFilterThisMonth,
          selected: shortcut == TransactionDateShortcut.thisMonth,
          onTap: () => select(TransactionDateShortcut.thisMonth),
        ),
        FilterPillSpec(
          label: l10n.txnFilterLastMonth,
          selected: shortcut == TransactionDateShortcut.lastMonth,
          onTap: () => select(TransactionDateShortcut.lastMonth),
        ),
        FilterPillSpec(
          label: l10n.txnFilterLast7Days,
          selected: shortcut == TransactionDateShortcut.last7Days,
          onTap: () => select(TransactionDateShortcut.last7Days),
        ),
        FilterPillSpec(
          label: l10n.txnFilterLast30Days,
          selected: shortcut == TransactionDateShortcut.last30Days,
          onTap: () => select(TransactionDateShortcut.last30Days),
        ),
        FilterPillSpec(
          icon: Icons.calendar_today_outlined,
          label: customLabel,
          selected: shortcut == TransactionDateShortcut.custom,
          onTap: () => _pickCustomRange(context, ref),
        ),
      ],
    );
  }
}

/// Compact pill toggle for Semua/Pemasukan/Pengeluaran — replaces the old
/// full-width 3-way SegmentedButton, which stretched the whole row for what
/// is really just a secondary filter.
class _TypeFilterBar extends ConsumerWidget {
  const _TypeFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeFilter = ref.watch(transactionTypeFilterProvider);
    final l10n = AppLocalizations.of(context);

    void select(TransactionType? value) => ref.read(transactionTypeFilterProvider.notifier).state = value;

    return FilterPillBar(
      pills: [
        FilterPillSpec(label: l10n.txnFilterAll, selected: typeFilter == null, onTap: () => select(null)),
        FilterPillSpec(
          label: l10n.txnIncomeLabel,
          selected: typeFilter == TransactionType.income,
          onTap: () => select(TransactionType.income),
        ),
        FilterPillSpec(
          label: l10n.txnExpenseLabel,
          selected: typeFilter == TransactionType.expense,
          onTap: () => select(TransactionType.expense),
        ),
      ],
    );
  }
}
