import 'membership_plan_model.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.avatarUrl,
    this.hasPin = false,
    this.isApproved = false,
    this.isPaidMember = false,
    this.membershipPlan,
    this.moneyManagementPermissions = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      hasPin: json['has_pin'] as bool? ?? false,
      isPaidMember: json['is_paid_member'] as bool? ?? false,
      membershipPlan: json['membership_plan'] != null
          ? MembershipPlanRef.fromJson(json['membership_plan'] as Map<String, dynamic>)
          : null,
      moneyManagementPermissions: (json['money_management_permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  final int id;
  final String name;
  final String email;
  final String? username;
  final String? avatarUrl;
  final bool hasPin;
  final bool isApproved;
  final bool isPaidMember;
  final MembershipPlanRef? membershipPlan;
  final List<String> moneyManagementPermissions;

  bool hasPermission(String permission) => moneyManagementPermissions.contains(permission);

  UserModel copyWith({bool? hasPin, bool? isPaidMember, MembershipPlanRef? membershipPlan}) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      username: username,
      avatarUrl: avatarUrl,
      hasPin: hasPin ?? this.hasPin,
      isApproved: isApproved,
      isPaidMember: isPaidMember ?? this.isPaidMember,
      membershipPlan: membershipPlan ?? this.membershipPlan,
      moneyManagementPermissions: moneyManagementPermissions,
    );
  }
}
