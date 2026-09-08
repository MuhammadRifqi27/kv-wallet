import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/password_reset_ticket_model.dart';
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

  /// Partial update — only non-null fields are sent, the rest are left
  /// untouched server-side. Avatar isn't handled here (no UI for it yet).
  Future<UserModel> updateProfile({String? name, String? username, String? email}) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.profile, data: {
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (email != null) 'email': email,
      });
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// For a user who's still logged in and knows their current password —
  /// not the same as [requestPasswordReset] below (admin-mediated, for
  /// users who can't log in at all).
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.changePassword, data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Submits a password-reset ticket for an admin to process manually — see
  /// docs/password-reset-request-flow.md. `phone` is required (admin's only
  /// way to reach the user back).
  Future<PasswordResetTicket> requestPasswordReset({
    required String identifier,
    required String phone,
    String? note,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.passwordResetRequest, data: {
        'identifier': identifier,
        'phone': phone,
        if (note != null && note.isNotEmpty) 'note': note,
      });
      return PasswordResetTicket.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Polls the latest ticket status for an identifier — `pending` until an
  /// admin clicks "Proses" in the web panel, then `processed` (or
  /// `rejected`). `processed` only means the admin generated the link, not
  /// that the user has finished resetting their password yet.
  Future<PasswordResetTicket> passwordResetRequestStatus({required String identifier}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.passwordResetRequestStatus,
        queryParameters: {'identifier': identifier},
      );
      return PasswordResetTicket.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
