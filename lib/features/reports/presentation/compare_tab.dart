import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/report_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/month_period_selector.dart';
import '../application/report_controller.dart';
import 'report_common.dart';

class CompareTab extends ConsumerWidget {
  const CompareTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final async = ref.watch(compareReportProvider);
    final compareWith = ref.watch(reportCompareWithProvider);

    String cycleLabel(CompareCycle cycle) => '${monthNameShort(cycle.month, locale)} ${cycle.year}';

    return ReportTabView(
      value: async,
      onRefresh: () => ref.refresh(compareReportProvider.future),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReportPeriodHeader(),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final picked = await pickMonthYear(context, compareWith ?? ref.read(reportPeriodProvider));
              if (picked != null) {
                ref.read(reportCompareWithProvider.notifier).state = DateTime(picked.year, picked.month);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.compare_arrows_rounded, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${l10n.rptCmpCompareWith}: '
                      '${compareWith == null ? l10n.rptCmpDefaultPrev : '${monthName(compareWith.month, locale)} ${compareWith.year}'}',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  if (compareWith != null)
                    InkWell(
                      onTap: () => ref.read(reportCompareWithProvider.notifier).state = null,
                      child: Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      builder: (report) => [
        Row(
          children: [
            Expanded(
              child: _CycleBadge(
                tag: 'A',
                label: cycleLabel(report.a),
                range: formatCycleRange(report.a.start, report.a.end, locale),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CycleBadge(
                tag: 'B',
                label: cycleLabel(report.b),
                range: formatCycleRange(report.b.start, report.b.end, locale),
                highlighted: true,
              ),
            ),
          ],
        ),
        ReportSectionTitle(l10n.rptCmpMetrics),
        _MetricCard(label: l10n.summaryIncomeLabel, metric: report.income, higherIsBetter: true),
        const SizedBox(height: 8),
        _MetricCard(label: l10n.summaryExpenseLabel, metric: report.expense, higherIsBetter: false),
        const SizedBox(height: 8),
        _MetricCard(label: l10n.rptCfNet, metric: report.net, higherIsBetter: true),
        const SizedBox(height: 8),
        _MetricCard(label: l10n.rptCmpSavingsRate, metric: report.savingsRate, higherIsBetter: true, percent: true),
        if (report.categories.isNotEmpty) ...[
          ReportSectionTitle(l10n.rptCmpCategories),
          for (final category in report.categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MetricCard(label: category.name ?? '-', metric: category, higherIsBetter: false, compact: true),
            ),
        ],
      ],
    );
  }
}

class _CycleBadge extends StatelessWidget {
  const _CycleBadge({required this.tag, required this.label, required this.range, this.highlighted = false});

  final String tag;
  final String label;
  final String range;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: highlighted ? AppColors.primary : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$tag · $label', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
          const SizedBox(height: 3),
          Text(range, style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
        ],
      ),
    );
  }
}

/// A vs B for one metric, with the server's `diff`/`diff_pct`.
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.metric,
    required this.higherIsBetter,
    this.percent = false,
    this.compact = false,
  });

  final String label;
  final CompareMetric metric;
  final bool higherIsBetter;
  final bool percent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    String fmt(double value) => percent ? formatPercent(value, locale) : formatRupiah(value);

    return ReportCard(
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary)),
              ),
              DeltaChip(diff: metric.diff, pct: metric.diffPct, higherIsBetter: higherIsBetter),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('A  ${fmt(metric.a)}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ),
              Expanded(
                child: Text(
                  'B  ${fmt(metric.b)}',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
