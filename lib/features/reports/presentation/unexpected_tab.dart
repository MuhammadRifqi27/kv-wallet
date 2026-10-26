import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/list_states.dart';
import '../application/report_controller.dart';
import 'report_common.dart';

class UnexpectedTab extends ConsumerWidget {
  const UnexpectedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final async = ref.watch(unexpectedExpensesReportProvider);
    final report = async.valueOrNull;

    return ReportTabView(
      value: async,
      onRefresh: () => ref.refresh(unexpectedExpensesReportProvider.future),
      header: ReportPeriodHeader(rangeText: report == null ? null : formatCycleRange(report.start, report.end, locale)),
      builder: (data) => [
        // How it's calculated — the three numbers come from the response.
        Text(
          l10n.rptUxHow(formatPercent(data.factor, locale).replaceAll('%', ''), data.baselineCycles, data.minSamples),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        if (data.items.isEmpty)
          ListEmptyState(
            icon: Icons.verified_outlined,
            title: l10n.rptUxEmptyTitle,
            subtitle: l10n.rptUxEmptySubtitle,
          )
        else ...[
          ReportStatRow(children: [
            ReportStat(label: l10n.rptUxTotalFlagged, value: formatRupiah(data.totalFlagged), color: AppColors.error),
            ReportStat(label: l10n.rptUxAnalyzedLabel, value: '${data.categoriesAnalyzed}'),
          ]),
          const SizedBox(height: 12),
          for (final item in data.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReportCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          formatRupiah(item.amount),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.date == null ? '-' : formatLocalizedDate(item.date!, locale)} · ${item.category}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.rptUxRatio(formatPercent(item.ratio, locale).replaceAll('%', '')),
                            style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.rptUxAverage(formatRupiah(item.categoryAverage)),
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
