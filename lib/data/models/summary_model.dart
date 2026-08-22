import '../../core/utils/json_parsing.dart';
import 'named_amount.dart';

/// Shape confirmed against a full real API response (previous versions of
/// this file were guesses — several fields were wrong or missing entirely:
/// `category_summary` items use a `total` key, monthly trend lives under
/// `chart_data` (with an already-formatted `label` like "Jan 2026"), smart
/// advisor tips are under `advice`, and there's no month-comparison object
/// at all — `total_income`/`total_expense`/`net_profit` are what's actually
/// returned instead.
class SummaryModel {
  const SummaryModel({
    required this.month,
    required this.year,
    required this.totalNetWorth,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.assetAllocation,
    required this.categorySummary,
    required this.monthlyTrend,
    required this.advice,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      month: json['month'] as int? ?? DateTime.now().month,
      year: json['year'] as int? ?? DateTime.now().year,
      totalNetWorth: parseDouble(json['total_net_worth']),
      totalIncome: parseDouble(json['total_income']),
      totalExpense: parseDouble(json['total_expense']),
      netProfit: parseDouble(json['net_profit']),
      assetAllocation: parseList(json['asset_allocation'])
          .map((item) => NamedAmount.fromJson(item as Map<String, dynamic>))
          .toList(),
      categorySummary: parseList(json['category_summary'])
          .map((item) => NamedAmount.fromJson(item as Map<String, dynamic>))
          .toList(),
      monthlyTrend: parseList(json['chart_data'])
          .map((item) => MonthlyTrendPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
      advice: parseList(json['advice']).map((tip) => tip.toString()).toList(),
    );
  }

  final int month;
  final int year;
  final double totalNetWorth;
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final List<NamedAmount> assetAllocation;
  final List<NamedAmount> categorySummary;
  final List<MonthlyTrendPoint> monthlyTrend;
  final List<String> advice;
}

class MonthlyTrendPoint {
  const MonthlyTrendPoint({required this.label, required this.income, required this.expense});

  factory MonthlyTrendPoint.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendPoint(
      label: (json['label'] as String?) ?? parseLabel(json, ['month']),
      income: parseDouble(json['income']),
      expense: parseDouble(json['expense']),
    );
  }

  final String label;
  final double income;
  final double expense;
}
