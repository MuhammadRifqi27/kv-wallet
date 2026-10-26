import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/json_parsing.dart';
import '../models/friend_model.dart';

/// Online-only (docs/mobile-api-reference.md "Teman") — nothing is queued
/// for offline sync.
class FriendRepository {
  FriendRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<String> getMyUsername() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.friendsMe);
      final data = response.data;
      final inner = data is Map && data['data'] is Map ? data['data'] as Map : data as Map;
      return inner['username'] as String? ?? '';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<FriendsListModel> getFriends() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.friends);
      return FriendsListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// [incoming] false -> requests the user sent that are still pending.
  Future<List<FriendRequestModel>> getRequests({required bool incoming}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.friendRequests,
        queryParameters: {'direction': incoming ? 'incoming' : 'outgoing'},
      );
      final data = response.data;
      final list = data is Map ? parseList(data['data']) : parseList(data);
      return list.map((e) => FriendRequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<FriendLookupModel> lookup(String username) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.friendsLookup, data: {'username': username});
      return FriendLookupModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Returns true when the request was auto-accepted because the other
  /// side had already sent one (`status: "accepted"`).
  Future<bool> sendRequest(String username) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.friendRequests, data: {'username': username});
      final data = response.data;
      final inner = data is Map && data['data'] is Map ? data['data'] as Map : const {};
      return inner['status'] == 'accepted';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> acceptRequest(int id) => _post('${ApiEndpoints.friendRequests}/$id/accept');

  Future<void> declineRequest(int id) => _post('${ApiEndpoints.friendRequests}/$id/decline');

  Future<void> cancelRequest(int id) => _delete('${ApiEndpoints.friendRequests}/$id');

  Future<void> removeFriend(int userId) => _delete('${ApiEndpoints.friends}/$userId');

  Future<void> _post(String path) async {
    try {
      await _apiClient.dio.post(path);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> _delete(String path) async {
    try {
      await _apiClient.dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
