import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/json_parsing.dart';
import '../models/recurring_transaction_model.dart';
import '../models/transaction_model.dart';

class RecurringRepository {
  RecurringRepository({required this._apiClient});

  final ApiClient _apiClient;

  /// Also processes any due template into a real transaction as a side
  /// effect of the call — see [ApiEndpoints.recurring]'s doc comment.
  Future<List<RecurringTransactionModel>> getRecurring() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.recurring);
      return parseListResponse(response.data)
          .map((json) => RecurringTransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `finance_investment_id` is required by this endpoint — unlike regular
  /// transactions, a recurring template always needs a target account.
  Future<void> createRecurring({
    required String name,
    required TransactionType type,
    required int categoryId,
    required int portfolioId,
    required RecurringFrequency frequency,
    required DateTime startDate,
    required double amount,
    String? description,
  }) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.recurring, data: {
        'name': name,
        'type': type.name,
        'finance_category_id': categoryId,
        'finance_investment_id': portfolioId,
        'amount': amount,
        'frequency': frequency.apiValue,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'description': description,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Body is the same shape as [createRecurring] — this isn't a partial
  /// update, every field is sent again. See docs/mobile-api-reference.md
  /// for the `next_date` side-effect nuance (only shifts if the template
  /// hasn't been processed yet).
  Future<void> updateRecurring({
    required int id,
    required String name,
    required TransactionType type,
    required int categoryId,
    required int portfolioId,
    required RecurringFrequency frequency,
    required DateTime startDate,
    required double amount,
    String? description,
  }) async {
    try {
      await _apiClient.dio.put('${ApiEndpoints.recurring}/$id', data: {
        'name': name,
        'type': type.name,
        'finance_category_id': categoryId,
        'finance_investment_id': portfolioId,
        'amount': amount,
        'frequency': frequency.apiValue,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'description': description,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteRecurring(int id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.recurring}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Best-effort trigger for screens that don't call [getRecurring] itself
  /// (Dashboard) but still want due templates processed promptly. Doesn't
  /// throw — a background maintenance call failing shouldn't block the
  /// screen that triggered it.
  Future<void> processDue() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.recurringProcess);
    } on DioException {
      // Ignore — this is a nice-to-have nudge, not a critical path. The
      // Recurring page's own GET call processes due items regardless.
    }
  }
}
