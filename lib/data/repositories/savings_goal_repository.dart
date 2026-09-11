import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/savings_goal_model.dart';

class SavingsGoalRepository {
  SavingsGoalRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<SavingsGoalsSummaryModel> getSavingsGoals() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.savingsGoals);
      return SavingsGoalsSummaryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SavingsGoalModel> createSavingsGoal({
    required String name,
    String? purpose,
    int? financePortfolioId,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.savingsGoals, data: {
        'name': name,
        'purpose': purpose,
        'finance_portfolio_id': financePortfolioId,
        'target_amount': targetAmount,
        'target_date': targetDate != null ? DateFormat('yyyy-MM-dd').format(targetDate) : null,
        'icon': icon,
        'color': color,
      });
      return SavingsGoalModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Body must be sent in full — `PUT` isn't a partial update (see
  /// docs/mobile-api-reference.md).
  Future<SavingsGoalModel> updateSavingsGoal({
    required int id,
    required String name,
    String? purpose,
    int? financePortfolioId,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) async {
    try {
      final response = await _apiClient.dio.put('${ApiEndpoints.savingsGoals}/$id', data: {
        'name': name,
        'purpose': purpose,
        'finance_portfolio_id': financePortfolioId,
        'target_amount': targetAmount,
        'target_date': targetDate != null ? DateFormat('yyyy-MM-dd').format(targetDate) : null,
        'icon': icon,
        'color': color,
      });
      return SavingsGoalModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Permanently deletes the goal *and* its whole contribution history —
  /// use [archiveSavingsGoal] instead to just stop counting it without
  /// losing the history.
  Future<void> deleteSavingsGoal(int id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.savingsGoals}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// One-way from mobile — there's no un-archive endpoint (see
  /// docs/mobile-api-reference.md).
  Future<SavingsGoalModel> archiveSavingsGoal(int id) async {
    try {
      final response = await _apiClient.dio.post('${ApiEndpoints.savingsGoals}/$id/archive');
      return SavingsGoalModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<SavingsGoalContributionModel>> getContributions(int goalId) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.savingsGoals}/$goalId/contributions');
      final list = response.data as List<dynamic>;
      return list.map((json) => SavingsGoalContributionModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `financePortfolioId` left `null` here always sends the key as an
  /// explicit `null` (rather than omitting it), which the backend treats as
  /// "deliberately not recorded to any account" for this row — same
  /// end-result as the goal's own default account when the caller instead
  /// passes the goal's `portfolioId` through explicitly, see
  /// docs/mobile-api-reference.md's note on this field.
  Future<void> addContribution({
    required int goalId,
    required SavingsGoalEntryType type,
    required DateTime date,
    required double amount,
    int? financePortfolioId,
    String? note,
  }) async {
    try {
      await _apiClient.dio.post('${ApiEndpoints.savingsGoals}/$goalId/contributions', data: {
        'type': type.apiValue,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'amount': amount,
        'finance_portfolio_id': financePortfolioId,
        'note': note,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteContribution({required int goalId, required int contributionId}) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.savingsGoals}/$goalId/contributions/$contributionId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
