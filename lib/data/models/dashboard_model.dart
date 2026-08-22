import '../../core/utils/json_parsing.dart';
import 'named_amount.dart';

/// Shape confirmed against a full real API response — several fields were
/// wrong or missing in earlier guesses: cash/investment totals are
/// `total_liquid_cash`/`total_investment_value` (not `total_cash_balance`/
/// `total_investment_balance`), income/expense are `income_pool`/
/// `monthly_expense`, top categories are `top_expenses`, and there's a full
/// `portfolios` list (every account, cash + investment) that wasn't
/// accounted for at all. `recent_transactions` items nest `category`
/// (`name`) and `portfolio` (`account_name`, not `name`) objects, and
/// `amount` can be a signed numeric string (transfers carry +/- legs).
class DashboardModel {
  const DashboardModel({
    required this.month,
    required this.year,
    required this.cycleStartDate,
    required this.cycleEndDate,
    required this.totalNetWorth,
    required this.totalLiquidCash,
    required this.totalInvestmentValue,
    required this.incomePool,
    required this.incomeBreakdown,
    required this.monthlyExpense,
    required this.netProfit,
    required this.topExpenses,
    required this.portfolios,
    required this.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      month: json['month'] as int? ?? DateTime.now().month,
      year: json['year'] as int? ?? DateTime.now().year,
      cycleStartDate: parseDate(json['cycle_start_date']),
      cycleEndDate: parseDate(json['cycle_end_date']),
      totalNetWorth: parseDouble(json['total_net_worth']),
      totalLiquidCash: parseDouble(json['total_liquid_cash']),
      totalInvestmentValue: parseDouble(json['total_investment_value']),
      incomePool: parseDouble(json['income_pool']),
      incomeBreakdown: parseList(json['income_breakdown'])
          .map((item) => NamedAmount.fromJson(item as Map<String, dynamic>))
          .toList(),
      monthlyExpense: parseDouble(json['monthly_expense']),
      netProfit: parseDouble(json['net_profit']),
      topExpenses: parseList(json['top_expenses'])
          .map((item) => NamedAmount.fromJson(item as Map<String, dynamic>))
          .toList(),
      portfolios: parseList(json['portfolios'])
          .map((item) => DashboardPortfolioItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentTransactions: parseList(json['recent_transactions'])
          .map((item) => RecentTransactionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int month;
  final int year;
  final DateTime? cycleStartDate;
  final DateTime? cycleEndDate;
  final double totalNetWorth;
  final double totalLiquidCash;
  final double totalInvestmentValue;
  final double incomePool;
  final List<NamedAmount> incomeBreakdown;
  final double monthlyExpense;
  final double netProfit;
  final List<NamedAmount> topExpenses;
  final List<DashboardPortfolioItem> portfolios;
  final List<RecentTransactionItem> recentTransactions;
}

class DashboardPortfolioItem {
  const DashboardPortfolioItem({
    required this.portfolioId,
    required this.name,
    required this.balance,
    required this.isInvestment,
    this.investmentName,
    this.investmentCode,
  });

  factory DashboardPortfolioItem.fromJson(Map<String, dynamic> json) {
    return DashboardPortfolioItem(
      portfolioId: json['portfolio_id'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      investmentName: json['investment'] as String?,
      investmentCode: json['investment_code'] as String?,
      balance: parseDouble(json['balance']),
      isInvestment: json['is_investment'] as bool? ?? false,
    );
  }

  final int portfolioId;
  final String name;
  final String? investmentName;
  final String? investmentCode;
  final double balance;
  final bool isInvestment;
}

class RecentTransactionItem {
  const RecentTransactionItem({
    required this.date,
    required this.isIncome,
    required this.categoryName,
    required this.amount,
    this.portfolioName,
    this.description,
  });

  factory RecentTransactionItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final portfolio = json['portfolio'] as Map<String, dynamic>?;
    final signedAmount = parseDouble(json['amount']);
    final type = json['type'] as String?;
    return RecentTransactionItem(
      date: parseDate(json['date']) ?? DateTime.now(),
      isIncome: type == 'income' || (type == 'transfer' && signedAmount > 0),
      categoryName: category?['name'] as String? ?? '-',
      portfolioName: portfolio?['account_name'] as String?,
      amount: signedAmount.abs(),
      description: json['description'] as String?,
    );
  }

  final DateTime date;
  final bool isIncome;
  final String categoryName;
  final String? portfolioName;
  final double amount;
  final String? description;
}
