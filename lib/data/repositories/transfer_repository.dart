import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/json_parsing.dart';
import '../models/transfer_model.dart';

/// Full CRUD. Confirmed against real request/response traffic (2026-08-28).
/// `fromAccountId`/`toAccountId` below are named to match this *request's*
/// JSON keys (`from_account_id`/`to_account_id`, confirmed from a
/// validation error) — the response side ([TransferModel]) genuinely uses
/// different keys (`finance_investment_id`/`to_finance_investment_id`) for
/// the same two accounts. That split is a backend quirk, not a typo — see
/// [TransferModel]'s IMPORTANT note before "fixing" either side to match
/// the other.
class TransferRepository {
  TransferRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<List<TransferModel>> getTransfers() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.transfers);
      return parseListResponse(response.data)
          .map((json) => TransferModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TransferModel> createTransfer({
    required DateTime date,
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.transfers, data: {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount,
        'description': description,
      });
      return TransferModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `id` is the "outbound" row's id (the one `GET /transfers` lists) — the
  /// server syncs its paired "inbound" row on the destination account
  /// automatically, per docs/flutter-mobile-app-development-guide.txt.
  Future<TransferModel> updateTransfer({
    required int id,
    required DateTime date,
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.put('${ApiEndpoints.transfers}/$id', data: {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount,
        'description': description,
      });
      return TransferModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteTransfer(int id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.transfers}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
