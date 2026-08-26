import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({required this._apiClient, required this._storage});

  final ApiClient _apiClient;
  final SecureStorageService _storage;

  Future<UserModel> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.login, data: {
        'login': login,
        'password': password,
        'device_name': deviceName,
      });
      final token = response.data['token'] as String;
      await _storage.saveToken(token);
      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Self-registration — auto-login, no admin approval wall (see
  /// docs/pin-and-membership-plan-api-reference.md). PIN is set separately
  /// right after, via [PinRepository.setPin].
  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String deviceName,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.register, data: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'device_name': deviceName,
      });
      final token = response.data['token'] as String;
      await _storage.saveToken(token);
      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.logout);
    } on DioException {
      // Ignore transport errors on logout — proceed to clear local token anyway.
    } finally {
      await _storage.deleteToken();
    }
  }

  Future<UserModel?> currentUser() async {
    final token = await _storage.readToken();
    if (token == null) return null;
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      throw ApiException.fromDioException(e);
    }
  }
}
