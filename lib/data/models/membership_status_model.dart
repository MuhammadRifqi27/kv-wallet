import 'membership_plan_model.dart';

/// Shared response shape for `POST /membership/select-plan` and
/// `GET /membership/status`.
class MembershipStatus {
  const MembershipStatus({
    required this.appRoleCode,
    required this.isPaidMember,
    this.membershipExpiresAt,
    this.membershipPlan,
  });

  factory MembershipStatus.fromJson(Map<String, dynamic> json) {
    return MembershipStatus(
      appRoleCode: json['app_role_code'] as String,
      isPaidMember: json['is_paid_member'] as bool,
      membershipExpiresAt: json['membership_expires_at'] != null
          ? DateTime.parse(json['membership_expires_at'] as String)
          : null,
      membershipPlan: json['membership_plan'] != null
          ? MembershipPlanRef.fromJson(json['membership_plan'] as Map<String, dynamic>)
          : null,
    );
  }

  final String appRoleCode;
  final bool isPaidMember;
  final DateTime? membershipExpiresAt;
  final MembershipPlanRef? membershipPlan;

  /// True when a plan was selected but is still awaiting admin verification.
  bool get isPendingVerification => !isPaidMember && membershipPlan != null;
}
