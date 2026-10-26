import '../../core/utils/json_parsing.dart';

/// One category's suggestion from `GET /budgets/recommendations` — see
/// docs/mobile-api-budget-recomendation.md. All figures are server-computed.
class BudgetRecommendationItem {
  const BudgetRecommendationItem({
    required this.categoryId,
    required this.categoryName,
    required this.averageSpent,
    required this.sharePercent,
    required this.currentBudget,
    required this.suggestedBudget,
    this.suggestedPercent,
    required this.overspentCycles,
    required this.limited,
  });

  factory BudgetRecommendationItem.fromJson(Map<String, dynamic> json) => BudgetRecommendationItem(
        categoryId: json['category_id'] as int? ?? 0,
        categoryName: json['category_name'] as String? ?? '-',
        averageSpent: parseDouble(json['average_spent']),
        sharePercent: parseDouble(json['share_percent']),
        currentBudget: parseDouble(json['current_budget']),
        suggestedBudget: parseDouble(json['suggested_budget']),
        suggestedPercent: parseDoubleOrNull(json['suggested_percent']),
        overspentCycles: json['overspent_cycles'] as int? ?? 0,
        limited: json['limited'] as bool? ?? false,
      );

  final int categoryId;
  final String categoryName;

  /// Average spend per cycle over the last [BudgetRecommendations.cycles].
  final double averageSpent;

  /// Average share of income, in percent (`13.5` = 13,5%).
  final double sharePercent;

  /// 0 = no budget saved for this cycle yet.
  final double currentBudget;
  final double suggestedBudget;

  /// Null when this cycle has no income yet.
  final double? suggestedPercent;
  final int overspentCycles;

  /// True = the suggestion was held at [currentBudget] (not raised) because
  /// the category exceeded its budget before.
  final bool limited;

  bool get hasCurrentBudget => currentBudget > 0;

  /// Applying a suggestion equal to the current budget changes nothing.
  bool get changesBudget => suggestedBudget != currentBudget;
}

class BudgetRecommendations {
  const BudgetRecommendations({
    required this.items,
    required this.basis,
    required this.incomePool,
    required this.cycles,
  });

  factory BudgetRecommendations.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    return BudgetRecommendations(
      items: parseList(data['items'])
          .whereType<Map<String, dynamic>>()
          .map(BudgetRecommendationItem.fromJson)
          .toList(),
      basis: data['basis'] == 'nominal' ? RecommendationBasis.nominal : RecommendationBasis.percentage,
      incomePool: parseDouble(data['income_pool']),
      cycles: data['cycles'] as int? ?? 3,
    );
  }

  /// Already sorted by `suggested_budget`, largest first.
  final List<BudgetRecommendationItem> items;
  final RecommendationBasis basis;

  /// Total income of the selected cycle (base for `percentage`).
  final double incomePool;
  final int cycles;
}

enum RecommendationBasis {
  /// Average share of income × this cycle's income.
  percentage,

  /// This cycle has no income yet — plain average nominal spend.
  nominal,
}
