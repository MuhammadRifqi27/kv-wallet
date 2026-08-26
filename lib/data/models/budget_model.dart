import '../../core/utils/json_parsing.dart';

/// Shape confirmed against a real API response — `GET
/// /money-management/budgets` returns ONE summary object (not a bare list
/// like earlier guessed), same month/year/cycle_start_date/cycle_end_date
/// convention as DashboardModel, with per-category budgets nested in
/// `categories`.
class BudgetSummaryModel {
  const BudgetSummaryModel({
    required this.month,
    required this.year,
    required this.cycleStartDate,
    required this.cycleEndDate,
    required this.incomePool,
    required this.totalBudget,
    required this.totalSpent,
    required this.categories,
  });

  factory BudgetSummaryModel.fromJson(Map<String, dynamic> json) {
    return BudgetSummaryModel(
      month: json['month'] as int? ?? DateTime.now().month,
      year: json['year'] as int? ?? DateTime.now().year,
      cycleStartDate: parseDate(json['cycle_start_date']),
      cycleEndDate: parseDate(json['cycle_end_date']),
      incomePool: parseDouble(json['income_pool']),
      totalBudget: parseDouble(json['total_budget']),
      totalSpent: parseDouble(json['total_spent']),
      categories: parseList(json['categories'])
          .map((item) => BudgetCategoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int month;
  final int year;
  final DateTime? cycleStartDate;
  final DateTime? cycleEndDate;
  final double incomePool;
  final double totalBudget;
  final double totalSpent;
  final List<BudgetCategoryItem> categories;
}

/// One row inside [BudgetSummaryModel.categories]. Only the parent object's
/// shape has been confirmed against a real response so far — this nested
/// item's exact field names haven't, so a few plausible keys are tried
/// defensively (mirrors how `top_expenses`/`recent_transactions` items were
/// figured out for DashboardModel).
class BudgetCategoryItem {
  const BudgetCategoryItem({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.spent,
  });

  factory BudgetCategoryItem.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryItem(
      categoryId: json['finance_category_id'] as int? ?? json['category_id'] as int? ?? 0,
      categoryName: parseLabel(json, ['finance_category', 'category', 'category_name', 'name']),
      amount: parseDouble(json['amount'] ?? json['budget'] ?? json['budget_amount']),
      spent: parseDouble(json['spent'] ?? json['spent_amount'] ?? json['actual_amount'] ?? json['actual']),
    );
  }

  final int categoryId;
  final String categoryName;
  final double amount;
  final double spent;

  double get progress => amount <= 0 ? 0 : (spent / amount).clamp(0, 1);
  bool get isOverBudget => spent > amount;
}
