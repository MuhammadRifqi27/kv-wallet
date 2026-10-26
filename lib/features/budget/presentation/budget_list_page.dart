import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/budget_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/cycle_period_filter_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../application/budget_controller.dart';

class BudgetListPage extends ConsumerWidget {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetControllerProvider);
    final controller = ref.read(budgetControllerProvider.notifier);
    final period = ref.watch(selectedBudgetPeriodProvider);
    // Kept alive inside MainShell's IndexedStack — see AppColors' class doc
    // + MainShell's note on why this needs an explicit watch.
    ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.txnBudgetListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded),
            tooltip: l10n.brcTitle,
            onPressed: () => context.push('/budget/recommendations'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/budget/form'),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: CyclePeriodFilterBar(
              period: period,
              onChanged: (value) => ref.read(selectedBudgetPeriodProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refresh,
              child: budgetAsync.when(
                loading: () => scrollableCenter(const AppLoadingIndicator()),
                error: (error, _) => scrollableCenter(
                  ListErrorState(
                    message: error is ApiException ? error.message : l10n.txnBudgetListLoadError,
                    onRetry: controller.refresh,
                  ),
                ),
                data: (summary) => _BudgetBody(summary: summary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetBody extends StatelessWidget {
  const _BudgetBody({required this.summary});

  final BudgetSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (summary.categories.isEmpty) {
      // See docs/ide-improvement-fitur-existing.txt BAGIAN E #31 — was a
      // bare Text, now consistent with every other list page's empty state.
      return scrollableCenter(
        ListEmptyState(
          icon: Icons.calculate_outlined,
          title: l10n.txnBudgetListEmptyTitle,
          subtitle: l10n.txnBudgetListEmptyMessage,
        ),
      );
    }

    // ListView.builder, not a plain ListView + `for` loop — categories are a
    // user-grown collection (one per budgeted category), not a small fixed
    // set. See docs/ide-improvement-fitur-existing.txt BAGIAN F #38. Header
    // content (summary card + section label + hint) is index 0.
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      itemCount: summary.categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(summary: summary),
              const SizedBox(height: 16),
              Text(
                l10n.txnBudgetPerCategoryLabel,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.txnBudgetTapToEditHint,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _BudgetCategoryCard(item: summary.categories[index - 1]),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final BudgetSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final overBudget = summary.totalSpent > summary.totalBudget;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.txnBudgetTotalLabel, style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            formatRupiah(summary.totalBudget),
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.totalBudget <= 0 ? 0 : (summary.totalSpent / summary.totalBudget).clamp(0, 1),
              minHeight: 6,
              backgroundColor: AppColors.primaryDark.withValues(alpha: 0.15),
              color: overBudget ? AppColors.error : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.txnBudgetUsedAmount(formatRupiah(summary.totalSpent)),
            style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  const _BudgetCategoryCard({required this.item});

  final BudgetCategoryItem item;

  @override
  Widget build(BuildContext context) {
    final overBudget = item.isOverBudget;
    final barColor = overBudget ? AppColors.error : AppColors.primary;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/budget/form', extra: item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.categoryName,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    formatRupiah(item.amount),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 16),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  color: barColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                overBudget
                    ? l10n.txnBudgetCategoryOverBudget(formatRupiah(item.spent))
                    : l10n.txnBudgetCategoryUsedOfTotal(formatRupiah(item.spent), formatRupiah(item.amount)),
                style: TextStyle(color: overBudget ? AppColors.error : AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
