import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/report_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/filter_pill_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../application/report_controller.dart';
import 'report_common.dart';

class CategoryTab extends ConsumerWidget {
  const CategoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final async = ref.watch(categoryReportProvider);
    final cycles = ref.watch(reportCategoryCyclesProvider);
    final report = async.valueOrNull;

    return ReportTabView(
      value: async,
      onRefresh: () => ref.refresh(categoryReportProvider.future),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportPeriodHeader(rangeText: report == null ? null : formatCycleRange(report.start, report.end, locale)),
          const SizedBox(height: 10),
          if (report != null && report.options.isNotEmpty) ...[
            _CategoryPicker(report: report),
            const SizedBox(height: 10),
          ],
          FilterPillBar(
            pills: [
              for (final option in const [3, 6, 12])
                FilterPillSpec(
                  label: l10n.rptCyclesOption(option),
                  selected: cycles == option,
                  onTap: () => ref.read(reportCategoryCyclesProvider.notifier).state = option,
                ),
            ],
          ),
        ],
      ),
      builder: (data) {
        // `category: null` = the user has no categories at all (docs §3).
        if (data.category == null) {
          return [
            ListEmptyState(
              icon: Icons.category_outlined,
              title: l10n.rptCatNoCategoryTitle,
              subtitle: l10n.rptCatNoCategorySubtitle,
            ),
          ];
        }
        final isExpense = data.category!.type != 'income';
        return [
          ReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.rptCatTotal, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(data.currentTotal),
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(l10n.rptCatCount(data.currentCount), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(width: 8),
                    if (data.changePct != null)
                      DeltaChip(diff: data.currentTotal - data.previousTotal, pct: data.changePct, higherIsBetter: !isExpense),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ReportStatRow(children: [
            ReportStat(label: l10n.rptCatPrevious, value: formatRupiah(data.previousTotal)),
            ReportStat(label: l10n.rptCatAverage, value: formatRupiah(data.average)),
            ReportStat(label: l10n.rptCatShare, value: formatPercent(data.sharePct, locale)),
          ]),
          if (data.series.isNotEmpty) ...[
            ReportSectionTitle(l10n.rptCatSeries),
            ReportCard(
              padding: const EdgeInsets.fromLTRB(8, 18, 16, 10),
              child: ReportBarChart(
                labels: [for (final point in data.series) point.label],
                values: [for (final point in data.series) point.total],
                color: isExpense ? AppColors.error : AppColors.success,
              ),
            ),
          ],
          if (data.topTransactions.isNotEmpty) ...[
            ReportSectionTitle(l10n.rptCatTop),
            for (final tx in data.topTransactions) _TransactionTile(tx: tx),
          ],
          if (data.frequent.isNotEmpty) ...[
            ReportSectionTitle(l10n.rptCatFrequent),
            for (final item in data.frequent)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReportCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        l10n.rptCatFrequentLine(item.count, formatRupiah(item.total)),
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          ReportSectionTitle(l10n.rptCatAll),
          if (data.transactions.isEmpty)
            Text(l10n.rptCatNoTx, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
          else
            for (final tx in data.transactions) _TransactionTile(tx: tx),
        ];
      },
    );
  }
}

class _CategoryPicker extends ConsumerWidget {
  const _CategoryPicker({required this.report});

  final CategoryReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (context) => _OptionsSheet(options: report.options, selectedId: report.category?.id),
        );
        if (picked != null) ref.read(reportCategoryIdProvider.notifier).state = picked;
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
            Icon(Icons.category_outlined, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${l10n.rptCatSelect}: ${report.category?.name ?? '-'}',
                style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _OptionsSheet extends StatelessWidget {
  const _OptionsSheet({required this.options, required this.selectedId});

  final List<ReportCategoryOption> options;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.rptCatSelect,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(option.name, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      trailing: option.id == selectedId ? Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                      onTap: () => Navigator.of(context).pop(option.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});

  final CategoryTransaction tx;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Padding(
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
                    tx.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.date == null ? '-' : formatLocalizedDate(tx.date!, locale)} · ${tx.account}',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatRupiah(tx.amount),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
