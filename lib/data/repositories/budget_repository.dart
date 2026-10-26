import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/budget_model.dart';
import '../models/budget_recommendation_model.dart';

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

  Future<BudgetRecommendations> getRecommendations({required int month, required int year}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.budgetRecommendations,
        queryParameters: {'month': month, 'year': year},
      );
      return BudgetRecommendations.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Sends category ids only — the server recomputes each suggestion at
  /// apply time and ignores any client amount. Returns how many budgets were
  /// actually saved, which can be fewer than [categoryIds] (ids without a
  /// suggestion are skipped silently).
  Future<int> applyRecommendations({
    required int month,
    required int year,
    required List<int> categoryIds,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.budgetRecommendations,
        data: {'month': month, 'year': year, 'category_ids': categoryIds},
      );
      final body = response.data;
      final data = body is Map && body['data'] is Map ? body['data'] as Map : const {};
      return (data['saved'] as num?)?.toInt() ?? 0;
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
