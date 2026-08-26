import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';

class PinRepository {
  PinRepository({required this._apiClient});

  final ApiClient _apiClient;

  /// First-time PIN setup — no `current_pin` needed.
  Future<void> setPin({required String pin, required String pinConfirmation}) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.pin, data: {
        'pin': pin,
        'pin_confirmation': pinConfirmation,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Changing an existing PIN — backend requires proof of the old one.
  Future<void> changePin({
    required String currentPin,
    required String pin,
    required String pinConfirmation,
  }) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.pin, data: {
        'current_pin': currentPin,
        'pin': pin,
        'pin_confirmation': pinConfirmation,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> verifyPin({required String pin}) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.verifyPin, data: {'pin': pin});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
