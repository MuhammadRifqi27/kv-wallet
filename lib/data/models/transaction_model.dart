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
///
/// [currentPage]/[hasMorePages] come from that same paginator envelope
/// (`current_page`/`last_page`, one level inside the `data` key) — without
/// them, the client had no way to know more pages existed at all, so
/// `getTransactions()` without an explicit `page` silently always returned
/// only page 1 forever, with the [totalIncome]/[totalExpense]/[netBalance]
/// summary (computed server-side across every page) making it look like the
/// visible list was the whole picture. See
/// docs/ide-improvement-fitur-existing.txt BAGIAN A #5.
class TransactionListResult {
  const TransactionListResult({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.currentPage,
    required this.hasMorePages,
  });

  factory TransactionListResult.fromResponse(Object? responseData) {
    final transactions = parseListResponse(responseData)
        .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
    final summary = responseData is Map ? responseData['summary'] as Map<String, dynamic>? : null;
    final paginator = responseData is Map ? responseData['data'] : null;
    final currentPage = paginator is Map ? ((paginator['current_page'] as num?)?.toInt() ?? 1) : 1;
    final lastPage = paginator is Map ? ((paginator['last_page'] as num?)?.toInt() ?? currentPage) : currentPage;
    return TransactionListResult(
      transactions: transactions,
      totalIncome: parseDouble(summary?['total_income']),
      totalExpense: parseDouble(summary?['total_expense']),
      netBalance: parseDouble(summary?['net_balance']),
      currentPage: currentPage,
      hasMorePages: currentPage < lastPage,
    );
  }

  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int currentPage;
  final bool hasMorePages;

  /// Used by "load more" — grows the visible list with [next]'s
  /// transactions while keeping THIS result's summary totals (server-
  /// computed once across the whole filtered set, not per-page, so they
  /// don't need to change) and adopting [next]'s pagination cursor.
  TransactionListResult appendPage(TransactionListResult next) {
    return TransactionListResult(
      transactions: [...transactions, ...next.transactions],
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: netBalance,
      currentPage: next.currentPage,
      hasMorePages: next.hasMorePages,
    );
  }
}
