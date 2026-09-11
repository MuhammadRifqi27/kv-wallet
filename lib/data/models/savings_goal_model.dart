import '../../core/utils/json_parsing.dart';

enum SavingsGoalStatus { active, achieved, archived }

SavingsGoalStatus _parseStatus(Object? value) => switch (value) {
      'achieved' => SavingsGoalStatus.achieved,
      'archived' => SavingsGoalStatus.archived,
      _ => SavingsGoalStatus.active,
    };

/// `GET /money-management/savings-goals` response — see
/// docs/mobile-api-reference.md "Savings Goals".
class SavingsGoalsSummaryModel {
  const SavingsGoalsSummaryModel({
    required this.activeCount,
    required this.achievedCount,
    required this.goals,
  });

  factory SavingsGoalsSummaryModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalsSummaryModel(
      activeCount: json['active_count'] as int? ?? 0,
      achievedCount: json['achieved_count'] as int? ?? 0,
      goals: parseList(json['goals']).map((item) => SavingsGoalModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  final int activeCount;
  final int achievedCount;
  final List<SavingsGoalModel> goals;
}

/// One row inside [SavingsGoalsSummaryModel.goals]. `savedAmount`,
/// `progressPercent` and `status` are always server-computed from the
/// contribution ledger — never sent back up in create/update requests, see
/// docs/mobile-api-reference.md point 1-2 under "Savings Goals".
class SavingsGoalModel {
  const SavingsGoalModel({
    required this.id,
    required this.name,
    this.purpose,
    this.portfolioId,
    this.portfolioName,
    required this.targetAmount,
    this.targetDate,
    required this.savedAmount,
    required this.progressPercent,
    required this.remainingAmount,
    required this.isOverAllocated,
    required this.status,
    this.icon,
    this.color,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    final portfolio = json['portfolio'];
    return SavingsGoalModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '-',
      purpose: json['purpose'] as String?,
      portfolioId: portfolio is Map ? portfolio['id'] as int? : null,
      portfolioName: portfolio is Map ? portfolio['name'] as String? : null,
      targetAmount: parseDouble(json['target_amount']),
      targetDate: parseDate(json['target_date']),
      savedAmount: parseDouble(json['saved_amount']),
      progressPercent: parseDouble(json['progress_percent']),
      remainingAmount: parseDouble(json['remaining_amount']),
      isOverAllocated: json['is_over_allocated'] as bool? ?? false,
      status: _parseStatus(json['status']),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  final int id;
  final String name;
  final String? purpose;
  final int? portfolioId;
  final String? portfolioName;
  final double targetAmount;
  final DateTime? targetDate;
  final double savedAmount;
  final double progressPercent;
  final double remainingAmount;
  final bool isOverAllocated;
  final SavingsGoalStatus status;
  final String? icon;
  final String? color;

  double get progress => (progressPercent / 100).clamp(0, 1);
}

enum SavingsGoalEntryType {
  contribution,
  withdrawal;

  String get apiValue => this == withdrawal ? 'withdrawal' : 'contribution';
}

/// One row of `GET /money-management/savings-goals/{id}/contributions`.
class SavingsGoalContributionModel {
  const SavingsGoalContributionModel({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    this.note,
    this.portfolioId,
    this.portfolioName,
  });

  factory SavingsGoalContributionModel.fromJson(Map<String, dynamic> json) {
    final portfolio = json['portfolio'];
    return SavingsGoalContributionModel(
      id: json['id'] as int,
      type: json['type'] == 'withdrawal' ? SavingsGoalEntryType.withdrawal : SavingsGoalEntryType.contribution,
      date: parseDate(json['date']) ?? DateTime.now(),
      amount: parseDouble(json['amount']),
      note: json['note'] as String?,
      portfolioId: portfolio is Map ? portfolio['id'] as int? : null,
      portfolioName: portfolio is Map ? portfolio['name'] as String? : null,
    );
  }

  final int id;
  final SavingsGoalEntryType type;
  final DateTime date;
  final double amount;
  final String? note;
  final int? portfolioId;
  final String? portfolioName;
}
