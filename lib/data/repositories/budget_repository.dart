import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  BudgetRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<BudgetSummaryModel> getBudgets({required int month, required int year}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.budgets,
        queryParameters: {'month': month, 'year': year},
      );
      return BudgetSummaryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> createBudget({
    required int categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.budgets, data: {
        'finance_category_id': categoryId,
        'amount': amount,
        'month': month,
        'year': year,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
