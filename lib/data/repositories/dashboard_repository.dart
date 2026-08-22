import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  DashboardRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<DashboardModel> getDashboard() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.dashboard);
      return DashboardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
