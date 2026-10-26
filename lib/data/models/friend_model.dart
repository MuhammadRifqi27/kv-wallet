import '../../core/utils/json_parsing.dart';

/// One accepted friend — `GET /money-management/friends`. Only these four
/// fields ever reach the app (docs/mobile-api-reference.md "Teman"): never
/// e-mail, wallet account number or balances.
class FriendModel {
  const FriendModel({
    required this.userId,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.since,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? '-',
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      since: parseDate(json['since']),
    );
  }

  final int userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final DateTime? since;
}

class FriendsMeta {
  const FriendsMeta({this.friendsCount = 0, this.incomingPending = 0, this.outgoingPending = 0});

  factory FriendsMeta.fromJson(Map<String, dynamic> json) {
    return FriendsMeta(
      friendsCount: json['friends_count'] as int? ?? 0,
      incomingPending: json['incoming_pending'] as int? ?? 0,
      outgoingPending: json['outgoing_pending'] as int? ?? 0,
    );
  }

  final int friendsCount;
  final int incomingPending;
  final int outgoingPending;
}

/// `GET /money-management/friends`.
class FriendsListModel {
  const FriendsListModel({required this.friends, this.meta = const FriendsMeta()});

  factory FriendsListModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    return FriendsListModel(
      friends: parseList(json['data']).map((e) => FriendModel.fromJson(e as Map<String, dynamic>)).toList(),
      meta: meta is Map<String, dynamic> ? FriendsMeta.fromJson(meta) : const FriendsMeta(),
    );
  }

  final List<FriendModel> friends;
  final FriendsMeta meta;
}

/// The other party of a request (sender for `incoming`, target for
/// `outgoing`).
class FriendRequestModel {
  const FriendRequestModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : const <String, dynamic>{};
    return FriendRequestModel(
      id: json['id'] as int,
      userId: user['user_id'] as int? ?? 0,
      name: user['name'] as String? ?? '-',
      username: user['username'] as String? ?? '',
      avatarUrl: user['avatar_url'] as String?,
      createdAt: parseDate(json['created_at']),
    );
  }

  final int id;
  final int userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final DateTime? createdAt;
}

enum FriendRelationship {
  none,
  friends,
  pendingOutgoing,
  pendingIncoming;

  static FriendRelationship parse(Object? value) => switch (value) {
        'friends' => FriendRelationship.friends,
        'pending_outgoing' => FriendRelationship.pendingOutgoing,
        'pending_incoming' => FriendRelationship.pendingIncoming,
        _ => FriendRelationship.none,
      };
}

/// `POST /money-management/friends/lookup` — step 1 of adding a friend.
class FriendLookupModel {
  const FriendLookupModel({
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.relationship,
  });

  factory FriendLookupModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    return FriendLookupModel(
      name: data['name'] as String? ?? '-',
      username: data['username'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
      relationship: FriendRelationship.parse(data['relationship']),
    );
  }

  final String name;
  final String username;
  final String? avatarUrl;
  final FriendRelationship relationship;
}
