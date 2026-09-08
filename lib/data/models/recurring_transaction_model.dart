import '../../core/utils/json_parsing.dart';
import 'transaction_model.dart';

enum RecurringFrequency { daily, weekly, monthly, yearly }

extension RecurringFrequencyLabel on RecurringFrequency {
  String get label => switch (this) {
        RecurringFrequency.daily => 'Harian',
        RecurringFrequency.weekly => 'Mingguan',
        RecurringFrequency.monthly => 'Bulanan',
        RecurringFrequency.yearly => 'Tahunan',
      };

  /// Value sent to `POST /money-management/recurring` — matches the enum
  /// name already (`daily`/`weekly`/`monthly`/`yearly`).
  String get apiValue => name;

  static RecurringFrequency fromApi(String? value) {
    return RecurringFrequency.values.firstWhere(
      (f) => f.apiValue == value,
      orElse: () => RecurringFrequency.monthly,
    );
  }
}

/// Template for auto-generated transactions (see
/// docs/money-management-alur-bisnis-database.txt "TRANSAKSI BERULANG").
///
/// ⚠️ Field names here are **best-guess**, mirrored from the documented
/// request body (`docs/mobile-api-reference.md` doesn't have a confirmed
/// sample response for this endpoint, unlike Dashboard/Budget/Transaksi
/// which were fixed after testing against real payloads — see
/// docs/flutter-dashboard-summary-transaksi-troubleshooting-log.txt).
/// Adjust the key names below once tested against a real response.
class RecurringTransactionModel {
  const RecurringTransactionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.categoryName,
    this.portfolioId,
    this.portfolioName,
    this.nextDate,
    this.description,
  });

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final portfolio = json['portfolio'] as Map<String, dynamic>?;
    return RecurringTransactionModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: (json['finance_category_id'] ?? json['category_id']) as int? ?? 0,
      categoryName: category?['name'] as String?,
      portfolioId: (json['finance_investment_id'] ?? json['investment_id']) as int?,
      portfolioName: portfolio?['account_name'] as String?,
      amount: parseDouble(json['amount']),
      frequency: RecurringFrequencyLabel.fromApi(json['frequency'] as String?),
      startDate: parseDate(json['start_date']) ?? DateTime.now(),
      nextDate: parseDate(json['next_date']),
      description: json['description'] as String?,
    );
  }

  final int id;
  final String name;
  final TransactionType type;
  final int categoryId;
  final String? categoryName;
  final int? portfolioId;
  final String? portfolioName;
  final double amount;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? nextDate;
  final String? description;
}
