import '../../core/utils/json_parsing.dart';

enum TransactionType { income, expense }

/// Shape confirmed against a real API response. Note the confusingly named
/// `finance_investment_id` column: per
/// docs/money-management-alur-bisnis-database.txt it's actually a foreign
/// key to `finance_portfolios` (a user's own account), not the investment
/// catalog — named `portfolioId` here instead to avoid that confusion.
/// `amount` comes back as a numeric string (e.g. `"13000.00"`); `category`/
/// `portfolio` are nested objects (`portfolio` uses `account_name`, not `name`).
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.date,
    required this.type,
    required this.categoryId,
    required this.amount,
    this.categoryName,
    this.portfolioId,
    this.portfolioName,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final portfolio = json['portfolio'] as Map<String, dynamic>?;
    return TransactionModel(
      id: json['id'] as int,
      date: parseDate(json['date']) ?? DateTime.now(),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: (json['category_id'] ?? json['finance_category_id']) as int? ?? 0,
      categoryName: category?['name'] as String?,
      portfolioId: (json['investment_id'] ?? json['finance_investment_id']) as int?,
      portfolioName: portfolio?['account_name'] as String?,
      amount: parseDouble(json['amount']),
      description: json['description'] as String?,
    );
  }

  final int id;
  final DateTime date;
  final TransactionType type;
  final int categoryId;
  final String? categoryName;
  final int? portfolioId;
  final String? portfolioName;
  final double amount;
  final String? description;
}

/// `GET /transactions` returns the page of transactions alongside totals
/// for the *whole filtered result set* (not just this page) under a
/// sibling `summary` key: `{"data": {...paginator...}, "summary": {...}}`.
class TransactionListResult {
  const TransactionListResult({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });

  factory TransactionListResult.fromResponse(Object? responseData) {
    final transactions = parseListResponse(responseData)
        .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
    final summary = responseData is Map ? responseData['summary'] as Map<String, dynamic>? : null;
    return TransactionListResult(
      transactions: transactions,
      totalIncome: parseDouble(summary?['total_income']),
      totalExpense: parseDouble(summary?['total_expense']),
      netBalance: parseDouble(summary?['net_balance']),
    );
  }

  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
}
