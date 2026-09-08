import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/json_parsing.dart';
import '../models/btc_tracking_model.dart';

class BtcTrackingRepository {
  BtcTrackingRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<BtcOverview> getOverview() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.btcTracking);
      return BtcOverview.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<BtcActivityItem>> getActivity() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.btcTrackingActivity);
      return parseListResponse(response.data)
          .map((json) => BtcActivityItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `financeInvestmentId` here is a Portfolio id (must belong to the user
  /// and be a crypto-type account) — same confusing naming as elsewhere in
  /// this API, see TransferModel's note.
  Future<void> createEntry({
    required int portfolioId,
    required String asset,
    required DateTime date,
    required BtcEntryType type,
    required double amount,
    String? description,
  }) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.btcTracking, data: {
        'finance_investment_id': portfolioId,
        'asset': asset,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'type': type.apiValue,
        'amount': amount,
        'description': description,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// No `portfolioId` here — the target account can't be changed on edit
  /// (delete + recreate instead), matching the API.
  Future<void> updateEntry({
    required int id,
    required String asset,
    required DateTime date,
    required BtcEntryType type,
    required double amount,
    String? description,
  }) async {
    try {
      await _apiClient.dio.put('${ApiEndpoints.btcTracking}/$id', data: {
        'asset': asset,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'type': type.apiValue,
        'amount': amount,
        'description': description,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.btcTracking}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
