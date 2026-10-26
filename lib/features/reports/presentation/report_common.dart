import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/cycle_period_filter_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../application/report_controller.dart';

/// Server percentages are plain numbers with up to 2 decimals (`91.52` =
/// 91,52%) — shown as-is (never recomputed, docs §5), only trimming trailing
/// zeros and using the locale's decimal separator.
String formatPercent(double value, Locale locale) {
  var text = value.toStringAsFixed(2);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  if (locale.languageCode != 'en') text = text.replaceAll('.', ',');
  return '$text%';
}

String formatSignedPercent(double value, Locale locale) => '${value > 0 ? '+' : ''}${formatPercent(value, locale)}';

String formatSignedRupiah(double value) => '${value > 0 ? '+' : value < 0 ? '-' : ''}${formatRupiah(value.abs())}';

/// "30 Sep 2026 – 30 Okt 2026" from the response's `start`/`end` — the
/// payroll cycle is NOT the calendar month, so this is what to display
/// (docs §1), never a guess from the month name.
String formatCycleRange(DateTime? start, DateTime? end, Locale locale) {
  if (start == null || end == null) return '';
  return '${formatLocalizedDate(start, locale)} – ${formatLocalizedDate(end, locale)}';
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class ReportSectionTitle extends StatelessWidget {
  const ReportSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
      ),
    );
  }
}

/// Label above a value, used in grids of headline numbers.
class ReportStat extends StatelessWidget {
  const ReportStat({super.key, required this.label, required this.value, this.color, this.caption});

  final String label;
  final String value;
  final Color? color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(caption!, style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
          ],
        ],
      ),
    );
  }
}

/// Two [ReportStat]s side by side (or three, via [children]).
class ReportStatRow extends StatelessWidget {
  const ReportStatRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

/// Green/red change chip. [higherIsBetter] flips the color (expense going up
/// is bad) — the server sends no color (docs, compare). A null [pct] means
/// there was no baseline, shown as "Baru"/"New" instead of a fake 0%.
class DeltaChip extends StatelessWidget {
  const DeltaChip({super.key, required this.diff, required this.pct, required this.higherIsBetter});

  final double diff;
  final double? pct;
  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final flat = diff == 0;
    final good = diff > 0 ? higherIsBetter : !higherIsBetter;
    final color = flat ? AppColors.textSecondary : (good ? AppColors.success : AppColors.error);
    final text = pct == null ? l10n.rptCmpNewLabel : formatSignedPercent(pct!, locale);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            flat ? Icons.remove_rounded : (diff > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
            size: 11,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// One "label ........ value" line.
class ReportRow extends StatelessWidget {
  const ReportRow({super.key, required this.label, required this.value, this.valueColor, this.bold = false});

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Month/cycle selector shared by the month-keyed tabs, with the real cycle
/// dates (from the response) underneath once loaded.
class ReportPeriodHeader extends ConsumerWidget {
  const ReportPeriodHeader({super.key, this.rangeText});

  final String? rangeText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CyclePeriodFilterBar(
          period: period,
          onChanged: (value) => ref.read(reportPeriodProvider.notifier).state = DateTime(value.year, value.month),
        ),
        if (rangeText != null && rangeText!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(rangeText!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ],
    );
  }
}

/// `‹ 2026 ›` stepper for the year-keyed tabs (Tahunan, Pajak).
class ReportYearStepper extends ConsumerWidget {
  const ReportYearStepper({super.key, this.rangeText});

  final String? rangeText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    void shift(int delta) =>
        ref.read(reportPeriodProvider.notifier).state = DateTime(period.year + delta, period.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: period.year > 2000 ? () => shift(-1) : null,
            ),
            Text(
              '${period.year}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: period.year < 2100 ? () => shift(1) : null,
            ),
          ],
        ),
        if (rangeText != null && rangeText!.isNotEmpty)
          Center(child: Text(rangeText!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
      ],
    );
  }
}

/// Scaffold for one report tab: pull-to-refresh list with a [header]
/// (period selector) that stays put while [value] loads/errors, then the
/// [builder]'s children. Data is rendered exactly as returned.
class ReportTabView<T> extends StatelessWidget {
  const ReportTabView({
    super.key,
    required this.value,
    required this.onRefresh,
    required this.header,
    required this.builder,
  });

  final AsyncValue<T> value;
  final Future<void> Function() onRefresh;
  final Widget header;
  final List<Widget> Function(T data) builder;

  Future<void> _safeRefresh() async {
    try {
      await onRefresh();
    } catch (_) {
      // The error state is rendered from `value`; nothing to rethrow here.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _safeRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          header,
          const SizedBox(height: 12),
          ...value.when(
            loading: () => [const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: AppLoadingIndicator())],
            error: (error, _) => [
              ListErrorState(
                message: error is ApiException ? error.message : l10n.rptLoadError,
                onRetry: _safeRefresh,
              ),
            ],
            data: builder,
          ),
        ],
      ),
    );
  }
}

/// A named data series for [ReportLineChart].
class ReportLine {
  const ReportLine({required this.values, required this.color});

  final List<double> values;
  final Color color;
}

/// Line chart over evenly spaced [labels] (index on the x axis). Values are
/// drawn exactly as given. [referenceY] draws a dashed horizontal line (the
/// savings-rate target).
class ReportLineChart extends StatelessWidget {
  const ReportLineChart({
    super.key,
    required this.labels,
    required this.lines,
    this.referenceY,
    this.height = 200,
    this.percentAxis = false,
  });

  final List<String> labels;
  final List<ReportLine> lines;
  final double? referenceY;
  final double height;

  /// Axis shows `20%` instead of compact Rupiah.
  final bool percentAxis;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final step = (labels.length / 6).ceil().clamp(1, 1 << 30);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => Text(
                  percentAxis ? '${value.toStringAsFixed(0)}%' : formatCompactRupiah(value, locale),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (value != index.toDouble() || index < 0 || index >= labels.length || index % step != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[index], style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
                  );
                },
              ),
            ),
          ),
          extraLinesData: referenceY == null
              ? null
              : ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: referenceY!,
                    color: AppColors.accent,
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                  ),
                ]),
          lineBarsData: [
            for (final line in lines)
              LineChartBarData(
                spots: [for (var i = 0; i < line.values.length; i++) FlSpot(i.toDouble(), line.values[i])],
                isCurved: false,
                color: line.color,
                barWidth: 2.5,
                dotData: FlDotData(show: line.values.length <= 14),
              ),
          ],
        ),
      ),
    );
  }
}

/// Simple single-series bar chart (category totals per cycle).
class ReportBarChart extends StatelessWidget {
  const ReportBarChart({super.key, required this.labels, required this.values, this.color, this.height = 190});

  final List<String> labels;
  final List<double> values;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final barColor = color ?? AppColors.primary;
    final step = (labels.length / 6).ceil().clamp(1, 1 << 30);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => Text(
                  formatCompactRupiah(value, locale),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length || index % step != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[index].split(' ').first,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    color: barColor,
                    width: values.length > 8 ? 10 : 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ReportLegendDot extends StatelessWidget {
  const ReportLegendDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
      ],
    );
  }
}
