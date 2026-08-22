import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';

/// Free-form key-value settings (see
/// docs/flutter-mobile-app-development-guide.txt BAGIAN 4 & 6). Only
/// `payroll_start_day` is used by this app so far — its value is either an
/// `int` (1-31) or the literal string `"last"` (end of month).
class SettingsRepository {
  SettingsRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.settings);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> updateSettings(Map<String, dynamic> values) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.settings, data: values);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
