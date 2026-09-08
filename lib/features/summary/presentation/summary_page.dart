import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/named_amount.dart';
import '../../../data/models/summary_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/cycle_period_filter_bar.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListErrorState;
import '../application/summary_controller.dart';

/// Percent change from [previous] to [current]. Null when [previous] is 0 —
/// "infinite % change" isn't a meaningful badge, so that case just shows no
/// comparison instead.
double? _percentChange(double current, double previous) {
  if (previous == 0) return null;
  return (current - previous) / previous.abs() * 100;
}

class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryControllerProvider);
    final controller = ref.read(summaryControllerProvider.notifier);
    final period = ref.watch(selectedSummaryPeriodProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ringkasan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: CyclePeriodFilterBar(
              period: period,
              onChanged: (value) => ref.read(selectedSummaryPeriodProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refresh,
              child: summaryAsync.when(
                loading: () => scrollableCenter(const AppLoadingIndicator()),
                error: (error, _) => scrollableCenter(
                  ListErrorState(
                    message: error is ApiException ? error.message : 'Gagal memuat ringkasan.',
                    onRetry: controller.refresh,
                  ),
                ),
                data: (summary) => _SummaryBody(summary: summary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBody extends ConsumerWidget {
  const _SummaryBody({required this.summary});

  final SummaryModel summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previous = ref.watch(previousMonthSummaryProvider).valueOrNull;
    final savingsRate = summary.totalIncome > 0 ? (summary.netProfit / summary.totalIncome * 100) : null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _NetWorthCard(
          amount: summary.totalNetWorth,
          previousAmount: previous?.totalNetWorth,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Pemasukan',
                value: formatRupiah(summary.totalIncome),
                color: AppColors.success,
                percentChange: previous != null ? _percentChange(summary.totalIncome, previous.totalIncome) : null,
                // Income going up is good.
                higherIsBetter: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Pengeluaran',
                value: formatRupiah(summary.totalExpense),
                color: AppColors.error,
                percentChange: previous != null ? _percentChange(summary.totalExpense, previous.totalExpense) : null,
                // Expense going up is bad.
                higherIsBetter: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Untung Bersih',
                value: formatRupiah(summary.netProfit),
                color: summary.netProfit >= 0 ? AppColors.primary : AppColors.error,
                percentChange: previous != null ? _percentChange(summary.netProfit, previous.netProfit) : null,
                higherIsBetter: true,
              ),
            ),
          ],
        ),
        if (savingsRate != null) ...[
          const SizedBox(height: 10),
          _SavingsRateCard(rate: savingsRate),
        ],
        const SizedBox(height: 16),
        const _BudgetHealthCard(),
        if (summary.assetAllocation.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionTitle('Alokasi Aset'),
          const SizedBox(height: 10),
          _ChartCard(child: _BreakdownChart(items: summary.assetAllocation)),
        ],
        if (summary.categorySummary.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionTitle('Breakdown Pengeluaran'),
          const SizedBox(height: 10),
          _ChartCard(child: _BreakdownChart(items: summary.categorySummary)),
        ],
        if (summary.monthlyTrend.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionTitle('Tren Pemasukan vs Pengeluaran'),
          const SizedBox(height: 10),
          _ChartCard(child: _MonthlyTrendChart(points: summary.monthlyTrend)),
        ],
        if (summary.advice.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionTitle('Smart Advisor'),
          const SizedBox(height: 10),
          for (final tip in summary.advice) ...[
            _AdvisorTile(tip: tip),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary));
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard({required this.amount, this.previousAmount});

  final double amount;
  final double? previousAmount;

  @override
  Widget build(BuildContext context) {
    final delta = previousAmount != null ? amount - previousAmount! : null;

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
          Text(
            'Total Kekayaan Bersih',
            style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            formatRupiah(amount),
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          if (delta != null && delta != 0) ...[
            const SizedBox(height: 6),
            Text(
              '${delta > 0 ? '+' : '-'} ${formatRupiah(delta.abs())} dari bulan lalu',
              style: TextStyle(
                color: AppColors.primaryDark.withValues(alpha: 0.65),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.percentChange,
    this.higherIsBetter = true,
  });

  final String label;
  final String value;
  final Color color;

  /// From [_percentChange] — null when there's no prior-month figure to
  /// compare against (fetch failed/still loading, or previous was 0).
  final double? percentChange;

  /// Whether a positive change is good news for this metric (income) or bad
  /// news (expense) — flips the badge's color, not its arrow direction.
  final bool higherIsBetter;

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
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
          if (percentChange != null) ...[
            const SizedBox(height: 4),
            _ChangeBadge(percentChange: percentChange!, higherIsBetter: higherIsBetter),
          ],
        ],
      ),
    );
  }
}

/// "▲ 12% dari bulan lalu" style badge — green when the direction of change
/// is good for this metric, red when bad, gray for ~0%.
class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.percentChange, required this.higherIsBetter});

  final double percentChange;
  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final isFlat = percentChange.abs() < 0.5;
    final isGood = percentChange > 0 ? higherIsBetter : !higherIsBetter;
    final color = isFlat ? AppColors.textSecondary : (isGood ? AppColors.success : AppColors.error);
    final icon = isFlat
        ? Icons.remove_rounded
        : (percentChange > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            '${percentChange.abs().toStringAsFixed(0)}% vs lalu',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SavingsRateCard extends StatelessWidget {
  const _SavingsRateCard({required this.rate});

  /// Net profit as a percentage of total income — can be negative when
  /// expenses exceeded income this period.
  final double rate;

  @override
  Widget build(BuildContext context) {
    final color = rate >= 0 ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.savings_outlined, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Rasio Menabung',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          Text(
            '${rate.toStringAsFixed(0)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// Cross-links to the Budget feature — how many categories are over budget
/// this period, using [summaryBudgetHealthProvider] (a period-matched fetch,
/// not the Budget tab's own controller — see that provider's doc comment).
/// Silently hides itself on loading/error since it's supplementary info,
/// not core to the Summary page.
class _BudgetHealthCard extends ConsumerWidget {
  const _BudgetHealthCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(summaryBudgetHealthProvider);

    return budgetAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        if (summary.categories.isEmpty) return const SizedBox.shrink();

        final overBudgetCount = summary.categories.where((c) => c.isOverBudget).length;
        final allOk = overBudgetCount == 0;
        final color = allOk ? AppColors.success : AppColors.error;

        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.push('/budget'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(
                      allOk ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      allOk
                          ? 'Semua kategori masih dalam budget'
                          : '$overBudgetCount dari ${summary.categories.length} kategori melebihi budget',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.textPrimary),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shared by "Alokasi Aset" (assetAllocation) and "Breakdown Pengeluaran"
/// (categorySummary) — both are just a list of {name, amount}.
class _BreakdownChart extends StatelessWidget {
  const _BreakdownChart({required this.items});

  final List<NamedAmount> items;

  static const _palette = [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    AppColors.error,
    Color(0xFFE2B4BD),
    Color(0xFF0EA5A4),
  ];

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: [
                for (var i = 0; i < items.length; i++)
                  PieChartSectionData(
                    value: items[i].amount,
                    color: _palette[i % _palette.length],
                    title: '',
                    radius: 42,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final percentage = total > 0 ? (item.amount / total * 100) : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: _palette[index % _palette.length], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MonthlyTrendChart extends StatelessWidget {
  const _MonthlyTrendChart({required this.points});

  final List<MonthlyTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _LegendDot(color: AppColors.success, label: 'Pemasukan'),
            SizedBox(width: 14),
            _LegendDot(color: AppColors.error, label: 'Pengeluaran'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      formatCompactRupiah(value),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) return const SizedBox.shrink();
                      // "Jan 2026" -> "Jan" — the full label overflows the
                      // chart card when there are several months to show.
                      final shortLabel = points[index].label.split(' ').first;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          shortLabel,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].income)],
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].expense)],
                  isCurved: true,
                  color: AppColors.error,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
      ],
    );
  }
}

class _AdvisorTile extends StatelessWidget {
  const _AdvisorTile({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tip, style: const TextStyle(color: AppColors.primaryDark, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
