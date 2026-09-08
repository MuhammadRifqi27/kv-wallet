import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  DashboardRepository({required this._apiClient});

  final ApiClient _apiClient;

  /// Null [month]/[year] means "current payroll cycle" (backend default).
  Future<DashboardModel> getDashboard({int? month, int? year}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.dashboard,
        queryParameters: month != null && year != null ? {'month': month, 'year': year} : null,
      );
      return DashboardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
