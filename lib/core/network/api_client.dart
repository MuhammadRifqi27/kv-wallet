import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

/// Thin Dio wrapper that auto-attaches the Sanctum bearer token and
/// notifies [onUnauthorized] whenever the server responds 401, so callers
/// can force a logout without this layer depending on routing.
class ApiClient {
  ApiClient({required SecureStorageService storage, this.onUnauthorized})
      : dio = Dio(BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await storage.deleteToken();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('[Dio] $o'),
      ));
    }
  }

  final Dio dio;
  final void Function()? onUnauthorized;
}
