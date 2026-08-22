enum InvestmentType { crypto, stock, other }

extension InvestmentTypeLabel on InvestmentType {
  String get label => switch (this) {
        InvestmentType.crypto => 'Crypto',
        InvestmentType.stock => 'Saham',
        InvestmentType.other => 'Bank',
      };
}

/// Global catalog of banks/exchanges/brokers — not a user's own account
/// (that's `finance_portfolios`, out of scope here). Read-only in this app;
/// admin manages the catalog via the web app.
class InvestmentModel {
  const InvestmentModel({
    required this.id,
    required this.name,
    required this.type,
    this.code,
    this.description,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: InvestmentType.values.byName(json['type'] as String),
      code: json['code'] as String?,
      description: json['description'] as String?,
    );
  }

  final int id;
  final String name;
  final InvestmentType type;
  final String? code;
  final String? description;
}
