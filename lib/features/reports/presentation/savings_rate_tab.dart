import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/report_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/filter_pill_bar.dart';
import '../application/report_controller.dart';
import 'report_common.dart';

class SavingsRateTab extends ConsumerWidget {
  const SavingsRateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final async = ref.watch(savingsRateReportProvider);
    final cycles = ref.watch(reportSavingsCyclesProvider);

    return ReportTabView(
      value: async,
      onRefresh: () => ref.refresh(savingsRateReportProvider.future),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReportPeriodHeader(),
          const SizedBox(height: 10),
          FilterPillBar(
            pills: [
              for (final option in const [3, 6, 12])
                FilterPillSpec(
                  label: l10n.rptCyclesOption(option),
                  selected: cycles == option,
                  onTap: () => ref.read(reportSavingsCyclesProvider.notifier).state = option,
                ),
            ],
          ),
        ],
      ),
      builder: (report) {
        final onTarget = report.currentRate >= report.target;
        return [
          ReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.rptSrCurrent, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatPercent(report.currentRate, locale),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: onTarget ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (report.rateChange != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          l10n.rptSrChangePoints(formatSignedPercent(report.rateChange!, locale).replaceAll('%', '')),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: report.rateChange! >= 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(l10n.rptSrFormula, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ReportStatRow(children: [
            ReportStat(
              label: l10n.rptSrPrevious,
              value: report.previousRate == null ? '-' : formatPercent(report.previousRate!, locale),
            ),
            ReportStat(label: l10n.rptSrAverage, value: formatPercent(report.averageRate, locale)),
            ReportStat(label: l10n.rptSrTargetLabel, value: formatPercent(report.target, locale)),
          ]),
          const SizedBox(height: 10),
          ReportCard(
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: AppColors.accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.rptSrOnTarget(report.monthsOnTarget, report.monthsCounted),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          ReportSectionTitle(l10n.rptSrSeriesTitle),
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
                        ReportLegendDot(color: AppColors.primary, label: l10n.rptSrCurrent),
                        const SizedBox(width: 12),
                        ReportLegendDot(color: AppColors.accent, label: l10n.rptSrTargetLabel),
                      ],
                    ),
                  ),
                ),
                ReportLineChart(
                  labels: [for (final point in report.series) point.label.split(' ').first],
                  lines: [ReportLine(values: [for (final point in report.series) point.rate], color: AppColors.primary)],
                  referenceY: report.target,
                  percentAxis: true,
                ),
              ],
            ),
          ),
          if (report.best != null) ...[
            const SizedBox(height: 12),
            _HighlightCard(title: l10n.rptSrBest, point: report.best!, color: AppColors.success),
          ],
          if (report.worst != null) ...[
            const SizedBox(height: 10),
            _HighlightCard(title: l10n.rptSrWorst, point: report.worst!, color: AppColors.error),
          ],
        ];
      },
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.title, required this.point, required this.color});

  final String title;
  final SavingsRatePoint point;
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
                Text(point.label, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${formatRupiah(point.income)} → ${formatRupiah(point.expense)}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Text(
            formatPercent(point.rate, locale),
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
