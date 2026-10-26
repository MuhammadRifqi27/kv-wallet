import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/list_states.dart';
import '../application/report_controller.dart';
import 'report_common.dart';

class CashFlowTab extends ConsumerWidget {
  const CashFlowTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final async = ref.watch(cashFlowReportProvider);

    return ReportTabView(
      value: async,
      onRefresh: () => ref.refresh(cashFlowReportProvider.future),
      header: ReportPeriodHeader(rangeText: async.valueOrNull == null ? null : formatCycleRange(async.value!.start, async.value!.end, locale)),
      builder: (report) => [
        ReportStatRow(children: [
          ReportStat(label: l10n.rptCfOpening, value: formatRupiah(report.openingBalance)),
          ReportStat(label: l10n.rptCfClosing, value: formatRupiah(report.closingBalance)),
        ]),
        const SizedBox(height: 10),
        ReportStatRow(children: [
          ReportStat(label: l10n.summaryIncomeLabel, value: formatRupiah(report.totalIncome), color: AppColors.success),
          ReportStat(label: l10n.summaryExpenseLabel, value: formatRupiah(report.totalExpense), color: AppColors.error),
          ReportStat(
            label: l10n.rptCfNet,
            value: formatSignedRupiah(report.net),
            color: report.net >= 0 ? AppColors.primary : AppColors.error,
          ),
        ]),
        // Shown whenever non-zero so opening + net + other = closing still
        // adds up on screen (docs §3 cash-flow).
        if (report.otherMovements != 0) ...[
          const SizedBox(height: 10),
          ReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReportRow(label: l10n.rptCfOther, value: formatSignedRupiah(report.otherMovements), bold: true),
                Text(l10n.rptCfOtherHint, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
              ],
            ),
          ),
        ],
        if (report.rows.isEmpty)
          ListEmptyState(
            icon: Icons.swap_vert_rounded,
            title: l10n.rptCfEmptyTitle,
            subtitle: l10n.rptCfEmptySubtitle,
          )
        else ...[
          ReportSectionTitle(l10n.rptCfBalanceChart),
          ReportCard(
            padding: const EdgeInsets.fromLTRB(8, 18, 16, 10),
            child: ReportLineChart(
              labels: [for (final row in report.rows) row.date == null ? '' : formatLocalizedDateShort(row.date!, locale)],
              lines: [ReportLine(values: [for (final row in report.rows) row.balance], color: AppColors.primary)],
            ),
          ),
          ReportSectionTitle(l10n.rptCfDailyTitle),
          for (final row in report.rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReportCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.date == null ? '-' : formatLocalizedDate(row.date!, locale),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+${formatRupiah(row.income)}  ·  -${formatRupiah(row.expense)}',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatRupiah(row.balance),
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        Text(
                          formatSignedRupiah(row.net),
                          style: TextStyle(
                            color: row.net >= 0 ? AppColors.success : AppColors.error,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
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
