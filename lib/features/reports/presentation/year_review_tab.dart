import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/report_model.dart';
import '../../../l10n/app_localizations.dart';
import '../application/report_controller.dart';
import 'report_common.dart';

class YearReviewTab extends ConsumerWidget {
  const YearReviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final async = ref.watch(yearInReviewReportProvider);
    final report = async.valueOrNull;

    return ReportTabView(
      value: async,
      onRefresh: () => ref.refresh(yearInReviewReportProvider.future),
      header: ReportYearStepper(rangeText: report == null ? null : formatCycleRange(report.start, report.end, locale)),
      builder: (data) => [
        ReportStatRow(children: [
          ReportStat(label: l10n.summaryIncomeLabel, value: formatRupiah(data.totalIncome), color: AppColors.success),
          ReportStat(label: l10n.summaryExpenseLabel, value: formatRupiah(data.totalExpense), color: AppColors.error),
        ]),
        const SizedBox(height: 10),
        ReportStatRow(children: [
          ReportStat(
            label: l10n.rptCfNet,
            value: formatSignedRupiah(data.net),
            color: data.net >= 0 ? AppColors.primary : AppColors.error,
          ),
          ReportStat(label: l10n.summarySavingsRateTitle, value: formatPercent(data.savingsRate, locale)),
        ]),
        const SizedBox(height: 10),
        ReportStat(label: l10n.rptYrAvgExpense, value: formatRupiah(data.averageMonthlyExpense)),
        ReportSectionTitle(l10n.rptYrMonthly),
        ReportCard(
          padding: const EdgeInsets.fromLTRB(8, 18, 16, 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReportLegendDot(color: AppColors.success, label: l10n.summaryIncomeLabel),
                      const SizedBox(width: 12),
                      ReportLegendDot(color: AppColors.error, label: l10n.summaryExpenseLabel),
                    ],
                  ),
                ),
              ),
              ReportLineChart(
                labels: [for (final month in data.months) month.label],
                lines: [
                  ReportLine(values: [for (final month in data.months) month.income], color: AppColors.success),
                  ReportLine(values: [for (final month in data.months) month.expense], color: AppColors.error),
                ],
              ),
            ],
          ),
        ),
        if (data.bestMonth != null) ...[
          const SizedBox(height: 12),
          _MonthHighlight(title: l10n.rptYrBest, month: data.bestMonth!, color: AppColors.success),
        ],
        if (data.worstMonth != null) ...[
          const SizedBox(height: 10),
          _MonthHighlight(title: l10n.rptYrWorst, month: data.worstMonth!, color: AppColors.error),
        ],
        if (data.biggestExpense != null) ...[
          const SizedBox(height: 10),
          ReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.rptYrBiggest, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.biggestExpense!.description,
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      formatRupiah(data.biggestExpense!.amount),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.biggestExpense!.date == null ? '-' : formatLocalizedDate(data.biggestExpense!.date!, locale)}'
                  ' · ${data.biggestExpense!.category}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
        if (data.topExpenses.isNotEmpty) ...[
          ReportSectionTitle(l10n.rptYrTopExpenses),
          _NamedTotals(items: data.topExpenses, color: AppColors.error),
        ],
        if (data.topIncome.isNotEmpty) ...[
          ReportSectionTitle(l10n.rptYrTopIncome),
          _NamedTotals(items: data.topIncome, color: AppColors.success),
        ],
        // No budget set all year -> the whole section is hidden (docs §3).
        if (data.budget.hasData) ..._budgetSection(context, data.budget),
      ],
    );
  }

  List<Widget> _budgetSection(BuildContext context, YearBudget budget) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    // Months with no budget (`categories == 0`) are skipped, not "0% used".
    final budgeted = budget.months.where((month) => month.categories > 0).toList();

    return [
      ReportSectionTitle(l10n.rptYrBudgetTitle),
      ReportCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rptYrBudgetTotals(formatRupiah(budget.totalSpent), formatRupiah(budget.totalBudget)),
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.rptYrBudgetMonthsOver(budget.monthsOver, budget.monthsWithBudget),
              style: TextStyle(
                color: budget.monthsOver > 0 ? AppColors.error : AppColors.success,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      for (final month in budgeted)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ReportCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(month.label, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    Text(
                      l10n.rptYrBudgetUsed(formatPercent(month.usedPct, locale).replaceAll('%', '')),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: month.usedPct > 100 ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (month.usedPct / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.background,
                    color: month.usedPct > 100 ? AppColors.error : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.rptYrBudgetTotals(formatRupiah(month.spent), formatRupiah(month.budget)),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ),
      if (budget.overItems.isNotEmpty) ...[
        ReportSectionTitle(l10n.rptYrOverItems),
        for (final item in budget.overItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ReportCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.month} · ${item.category}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    l10n.rptYrOverBy(formatRupiah(item.over), formatPercent(item.overPct, locale).replaceAll('%', '')),
                    style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
      ],
      if (budget.overCategories.isNotEmpty) ...[
        ReportSectionTitle(l10n.rptYrOverCategories),
        for (final category in budget.overCategories)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ReportCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    l10n.rptYrOverTimes(category.times, formatRupiah(category.totalOver)),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    ];
  }
}

class _MonthHighlight extends StatelessWidget {
  const _MonthHighlight({required this.title, required this.month, required this.color});

  final String title;
  final YearMonthPoint month;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return ReportCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                const SizedBox(height: 2),
                Text(month.label, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${formatRupiah(month.income)} → ${formatRupiah(month.expense)}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatSignedRupiah(month.net), style: TextStyle(fontWeight: FontWeight.w800, color: color)),
              Text(formatPercent(month.rate, locale), style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NamedTotals extends StatelessWidget {
  const _NamedTotals({required this.items, required this.color});

  final List<NamedTotal> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ReportCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(formatRupiah(item.total), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
