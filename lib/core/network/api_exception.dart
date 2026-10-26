import 'package:dio/dio.dart';

/// Normalizes Dio errors into the shapes the backend actually returns
/// (see docs/flutter-mobile-app-development-guide.txt BAGIAN 5):
/// 401 -> force logout, 403 -> permission/approval message, 422 -> field errors.
///
/// Wallet endpoints additionally return a stable business-error `code`
/// (`INSUFFICIENT_BALANCE`, `PIN_LOCKED`, ...) and, for `PIN_LOCKED`, a
/// `retry_after` in seconds — see docs/mobile-api-reference.md "Wallet".
/// UI logic should branch on [code], never on the translated [message].
class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.fieldErrors, this.code, this.retryAfter});

  factory ApiException.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final code = data is Map && data['code'] is String ? data['code'] as String : null;
    final retryAfter = data is Map && data['retry_after'] is num ? (data['retry_after'] as num).toInt() : null;

    if (statusCode == 422 && data is Map && data['errors'] is Map) {
      final rawErrors = (data['errors'] as Map).cast<String, dynamic>();
      final fieldErrors = rawErrors.map(
        (key, value) => MapEntry(key, (value as List).map((e) => e.toString()).toList()),
      );
      return ApiException(
        message: data['message'] as String? ?? 'Data yang dikirim tidak valid.',
        statusCode: statusCode,
        fieldErrors: fieldErrors,
        code: code,
        retryAfter: retryAfter,
      );
    }

    if (data is Map && data['message'] is String) {
      return ApiException(
        message: data['message'] as String,
        statusCode: statusCode,
        code: code,
        retryAfter: retryAfter,
      );
    }
    if (data is Map && data['error'] is String) {
      return ApiException(message: data['error'] as String, statusCode: statusCode, code: code);
    }

    switch (statusCode) {
      case 401:
        return ApiException(message: 'Sesi berakhir, silakan login kembali.', statusCode: statusCode);
      case 404:
        return ApiException(message: 'Fitur ini belum tersedia di server.', statusCode: statusCode);
      case 429:
        return ApiException(message: 'Terlalu banyak percobaan. Coba lagi sebentar lagi.', statusCode: statusCode);
      default:
        return ApiException(
          message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          statusCode: statusCode,
        );
    }
  }

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  /// Stable machine-readable business-error code (wallet endpoints only).
  final String? code;

  /// Seconds until a `423 PIN_LOCKED` lock expires.
  final int? retryAfter;

  /// True when the request never got a usable HTTP response (timeout, no
  /// connectivity) — the one case where a wallet transfer's outcome is
  /// unknown and the caller should retry with the SAME idempotency key.
  bool get isNetworkError => statusCode == null;

  String? errorFor(String field) => fieldErrors?[field]?.first;

  @override
  String toString() => message;
}
