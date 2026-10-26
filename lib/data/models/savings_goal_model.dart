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

enum SavingsGoalMemberStatus { active, pending, left }

SavingsGoalMemberStatus _parseMemberStatus(Object? value) => switch (value) {
      'pending' => SavingsGoalMemberStatus.pending,
      'left' => SavingsGoalMemberStatus.left,
      _ => SavingsGoalMemberStatus.active,
    };

/// One entry of a shared goal's `members[]` — see
/// docs/mobile-api-reference.md "Tabungan Bersama". `members[0]` is always
/// the owner. Never carries account/portfolio data of that person.
class SavingsGoalMember {
  const SavingsGoalMember({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.isOwner,
    required this.status,
    required this.contributedAmount,
    required this.contributionPercent,
  });

  factory SavingsGoalMember.fromJson(Map<String, dynamic> json) {
    return SavingsGoalMember(
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      avatarUrl: json['avatar_url'] as String?,
      isOwner: json['role'] == 'owner',
      status: _parseMemberStatus(json['status']),
      contributedAmount: parseDouble(json['contributed_amount']),
      contributionPercent: parseDouble(json['contribution_percent']),
    );
  }

  final int userId;
  final String name;
  final String? avatarUrl;
  final bool isOwner;
  final SavingsGoalMemberStatus status;
  final double contributedAmount;
  final double contributionPercent;
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
    this.isShared = false,
    this.isOwner = true,
    this.ownerName,
    this.myContribution = 0,
    this.members = const [],
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    final portfolio = json['portfolio'];
    final owner = json['owner'];
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
      isShared: json['is_shared'] as bool? ?? false,
      // Personal goals (and responses from an older server) have no `role`
      // — the user is the sole owner.
      isOwner: json['role'] != 'member',
      ownerName: owner is Map ? owner['name'] as String? : null,
      myContribution: parseDouble(json['my_contribution']),
      members: parseList(json['members']).map((e) => SavingsGoalMember.fromJson(e as Map<String, dynamic>)).toList(),
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

  /// Shared-goal fields (docs "Tabungan Bersama"). [isOwner] is the role of
  /// the logged-in user, not of any member.
  final bool isShared;
  final bool isOwner;
  final String? ownerName;
  final double myContribution;
  final List<SavingsGoalMember> members;

  /// Members who count as people on the goal (hides declined/expired
  /// invitations that the server already dropped, and `left` rows only
  /// shown for their contribution).
  List<SavingsGoalMember> get activeMembers =>
      members.where((m) => m.status == SavingsGoalMemberStatus.active).toList();

  double get progress => (progressPercent / 100).clamp(0, 1);
}

/// Prefilled draft for creating a new goal — e.g. from the Emergency Fund
/// Calculator's "Buat Goal Dana Darurat" CTA. Distinct from
/// [SavingsGoalModel], which always represents a goal that already exists
/// on the server (has an `id`, server-computed `savedAmount`/
/// `progressPercent`/`status`). Passed as `state.extra` to the
/// `/savings-goals/form` route alongside [SavingsGoalModel] — see
/// app_router.dart's builder for how the two are told apart.
class SavingsGoalDraft {
  const SavingsGoalDraft({required this.name, required this.targetAmount, this.icon, this.color});

  final String name;
  final double targetAmount;
  final String? icon;
  final String? color;
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
    this.contributorName,
    this.isMine = true,
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
      contributorName: json['contributor'] is Map ? (json['contributor'] as Map)['name'] as String? : null,
      isMine: json['is_mine'] as bool? ?? true,
    );
  }

  final int id;
  final SavingsGoalEntryType type;
  final DateTime date;
  final double amount;
  final String? note;
  final int? portfolioId;
  final String? portfolioName;

  /// Shared goals only: who logged this row, and whether that is the
  /// logged-in user (only own rows may be deleted).
  final String? contributorName;
  final bool isMine;
}

/// One pending invitation — `GET /money-management/savings-goals/invitations`.
/// [id] is the INVITATION id, not the goal id.
class SavingsGoalInvitationModel {
  const SavingsGoalInvitationModel({
    required this.id,
    required this.goalId,
    required this.goalName,
    this.purpose,
    required this.targetAmount,
    this.icon,
    this.color,
    required this.ownerName,
    required this.invitedByName,
    this.expiresAt,
  });

  factory SavingsGoalInvitationModel.fromJson(Map<String, dynamic> json) {
    final goal = json['goal'] is Map<String, dynamic> ? json['goal'] as Map<String, dynamic> : const <String, dynamic>{};
    final owner = json['owner'] is Map ? json['owner'] as Map : const {};
    final invitedBy = json['invited_by'] is Map ? json['invited_by'] as Map : const {};
    return SavingsGoalInvitationModel(
      id: json['id'] as int,
      goalId: goal['id'] as int? ?? 0,
      goalName: goal['name'] as String? ?? '-',
      purpose: goal['purpose'] as String?,
      targetAmount: parseDouble(goal['target_amount']),
      icon: goal['icon'] as String?,
      color: goal['color'] as String?,
      ownerName: owner['name'] as String? ?? '-',
      invitedByName: invitedBy['name'] as String? ?? '-',
      expiresAt: parseDate(json['expires_at']),
    );
  }

  final int id;
  final int goalId;
  final String goalName;
  final String? purpose;
  final double targetAmount;
  final String? icon;
  final String? color;
  final String ownerName;
  final String invitedByName;
  final DateTime? expiresAt;
}
