import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/named_amount.dart';
import '../../../data/models/summary_model.dart';
import '../../../shared/widgets/month_period_selector.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListErrorState;
import '../application/summary_controller.dart';

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
          MonthPeriodSelector(
            period: period,
            onChanged: (value) => ref.read(selectedSummaryPeriodProvider.notifier).state = value,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refresh,
              child: summaryAsync.when(
                loading: () => scrollableCenter(const CircularProgressIndicator(color: AppColors.primary)),
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

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.summary});

  final SummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _NetWorthCard(amount: summary.totalNetWorth),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Pemasukan',
                value: formatRupiah(summary.totalIncome),
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Pengeluaran',
                value: formatRupiah(summary.totalExpense),
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Untung Bersih',
                value: formatRupiah(summary.netProfit),
                color: summary.netProfit >= 0 ? AppColors.primary : AppColors.error,
              ),
            ),
          ],
        ),
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
  const _NetWorthCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
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
          const Text('Total Kekayaan Bersih', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            formatRupiah(amount),
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

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
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ],
      ),
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
    Color(0xFF6366F1),
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
