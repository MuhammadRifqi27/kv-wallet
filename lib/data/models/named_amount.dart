import '../../core/utils/json_parsing.dart';

/// Shared by several Dashboard/Summary sections that are just a label + a
/// number, under different keys depending on the endpoint: `amount`
/// (generic), `value` (asset_allocation), `total` (category_summary/
/// top_expenses/income_breakdown, sometimes as a numeric string like
/// `"500000.00"` — `parseDouble` handles that), or `balance` (liquid_accounts).
class NamedAmount {
  const NamedAmount({required this.name, required this.amount});

  factory NamedAmount.fromJson(Map<String, dynamic> json) {
    return NamedAmount(
      name: parseLabel(json, ['category', 'category_name', 'name']),
      amount: parseDouble(json['amount'] ?? json['value'] ?? json['total'] ?? json['balance']),
    );
  }

  final String name;
  final double amount;
}
