import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/transaction_model.dart';

/// Full CRUD — a transaction is the user's own data, not shared master data.
class TransactionRepository {
  TransactionRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<TransactionListResult> getTransactions({
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.transactions,
        queryParameters: {
          if (type != null) 'type': type.name,
          if (startDate != null) 'start_date': DateFormat('yyyy-MM-dd').format(startDate),
          if (endDate != null) 'end_date': DateFormat('yyyy-MM-dd').format(endDate),
        },
      );
      return TransactionListResult.fromResponse(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TransactionModel> createTransaction({
    required DateTime date,
    required TransactionType type,
    required int categoryId,
    required double amount,
    int? portfolioId,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.transactions,
        data: {
          'date': DateFormat('yyyy-MM-dd').format(date),
          'type': type.name,
          'category_id': categoryId,
          'investment_id': portfolioId,
          'amount': amount,
          'description': description,
        },
      );
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TransactionModel> updateTransaction({
    required int id,
    required DateTime date,
    required TransactionType type,
    required int categoryId,
    required double amount,
    int? portfolioId,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiEndpoints.transactions}/$id',
        data: {
          'date': DateFormat('yyyy-MM-dd').format(date),
          'type': type.name,
          'category_id': categoryId,
          'investment_id': portfolioId,
          'amount': amount,
          'description': description,
        },
      );
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.transactions}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
