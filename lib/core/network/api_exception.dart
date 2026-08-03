import 'package:dio/dio.dart';

/// Normalizes Dio errors into the shapes the backend actually returns
/// (see docs/flutter-mobile-app-development-guide.txt BAGIAN 5):
/// 401 -> force logout, 403 -> permission/approval message, 422 -> field errors.
class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.fieldErrors});

  factory ApiException.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (statusCode == 422 && data is Map && data['errors'] is Map) {
      final rawErrors = (data['errors'] as Map).cast<String, dynamic>();
      final fieldErrors = rawErrors.map(
        (key, value) => MapEntry(key, (value as List).map((e) => e.toString()).toList()),
      );
      return ApiException(
        message: data['message'] as String? ?? 'Data yang dikirim tidak valid.',
        statusCode: statusCode,
        fieldErrors: fieldErrors,
      );
    }

    if (data is Map && data['message'] is String) {
      return ApiException(message: data['message'] as String, statusCode: statusCode);
    }
    if (data is Map && data['error'] is String) {
      return ApiException(message: data['error'] as String, statusCode: statusCode);
    }

    switch (statusCode) {
      case 401:
        return ApiException(message: 'Sesi berakhir, silakan login kembali.', statusCode: statusCode);
      case 404:
        return ApiException(message: 'Fitur ini belum tersedia di server.', statusCode: statusCode);
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

  String? errorFor(String field) => fieldErrors?[field]?.first;

  @override
  String toString() => message;
}
