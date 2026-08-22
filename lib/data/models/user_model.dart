class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.avatarUrl,
    this.moneyManagementPermissions = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
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
  final List<String> moneyManagementPermissions;

  bool hasPermission(String permission) => moneyManagementPermissions.contains(permission);
}
