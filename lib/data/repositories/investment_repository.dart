import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/investment_model.dart';

/// Read-only — provider investasi (bank/exchange/broker) is managed by
/// admin via the web app, not from mobile.
class InvestmentRepository {
  InvestmentRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<List<InvestmentModel>> getInvestments() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.investments);
      final list = response.data as List<dynamic>;
      return list.map((json) => InvestmentModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
