import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/summary_model.dart';

class SummaryRepository {
  SummaryRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<SummaryModel> getSummary({required int month, required int year}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.summary,
        queryParameters: {'month': month, 'year': year},
      );
      return SummaryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
