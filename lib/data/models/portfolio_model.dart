/// A user's own account/wallet — created against a provider from the
/// `finance_investments` catalog ([InvestmentModel]). Unlike Kategori/
/// Provider Investasi, this is the user's own data and stays fully
/// editable from mobile.
class PortfolioModel {
  const PortfolioModel({
    required this.id,
    required this.financeInvestmentId,
    required this.accountName,
    required this.isInvestmentAccount,
    this.accountNumber,
    this.description,
    this.balance,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'] as int,
      financeInvestmentId: json['finance_investment_id'] as int,
      accountName: json['account_name'] as String,
      accountNumber: json['account_number'] as String?,
      description: json['description'] as String?,
      isInvestmentAccount: json['account_investment'] as bool? ?? false,
      balance: (json['balance'] as num?)?.toDouble(),
    );
  }

  final int id;
  final int financeInvestmentId;
  final String accountName;
  final String? accountNumber;
  final String? description;
  final bool isInvestmentAccount;

  /// Always computed server-side (never stored) — see
  /// docs/money-management-alur-bisnis-database.txt "CATATAN PENTING".
  /// Null until the API confirms the exact field name/shape.
  final double? balance;
}
