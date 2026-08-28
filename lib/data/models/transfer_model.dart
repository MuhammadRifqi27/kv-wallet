import '../../core/utils/json_parsing.dart';

/// A transfer between two of the user's own portfolios/accounts — backend
/// stores this as two linked `finance_transactions` rows (`type: "transfer"`,
/// one negative in the source account, one positive in the destination) but
/// `GET /money-management/transfers` lists only the "outbound" row per
/// transfer, see docs/money-management-alur-bisnis-database.txt BAGIAN 3.
///
/// Shape confirmed against a real API response (2026-08-28) — turns out
/// this endpoint returns a raw `finance_transactions` row, not the
/// `from_account_id`/`to_account_id`/nested-`from_account` shape the
/// (unverified) mobile dev guide had guessed. `amount` comes back as a
/// signed numeric string (negative = outbound row) — take `.abs()`.
///
/// IMPORTANT — field names here are deliberately kept identical to this
/// *response's* JSON keys (`finance_investment_id`, not `from_account_id`)
/// so nothing needs translating in your head while reading this file. The
/// *request* side ([TransferRepository.createTransfer]) genuinely uses
/// different key names (`from_account_id`/`to_account_id`, confirmed from a
/// validation error) for the same two accounts — that split is a backend
/// quirk, not something to "fix" by renaming one side to match the other.
class TransferModel {
  const TransferModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.financeInvestmentId,
    required this.toFinanceInvestmentId,
    this.portfolioName,
    this.destinationPortfolioName,
    this.description,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    final portfolio = json['portfolio'] as Map<String, dynamic>?;
    final destinationPortfolio = json['destination_portfolio'] as Map<String, dynamic>?;
    return TransferModel(
      id: json['id'] as int,
      date: parseDate(json['date']) ?? DateTime.now(),
      amount: parseDouble(json['amount']).abs(),
      financeInvestmentId: json['finance_investment_id'] as int? ?? 0,
      toFinanceInvestmentId: json['to_finance_investment_id'] as int? ?? 0,
      portfolioName: portfolio?['account_name'] as String?,
      destinationPortfolioName: destinationPortfolio?['account_name'] as String?,
      description: json['description'] as String?,
    );
  }

  final int id;
  final DateTime date;
  final double amount;

  /// Source account — from `finance_investment_id`. Confusingly named on
  /// the backend (it's a portfolio/account id, not an investment catalog
  /// id — same quirk `TransactionModel.portfolioId` works around), but kept
  /// as-is here to match the response JSON key exactly.
  final int financeInvestmentId;

  /// Destination account — from `to_finance_investment_id`.
  final int toFinanceInvestmentId;

  /// From nested `portfolio.account_name` (source account's display name).
  final String? portfolioName;

  /// From nested `destination_portfolio.account_name`.
  final String? destinationPortfolioName;

  final String? description;
}
