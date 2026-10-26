import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/wallet_model.dart';

/// Online-only by design (docs/mobile-api-reference.md "Wallet" rule 1) —
/// nothing here is queued for offline sync.
class WalletRepository {
  WalletRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<WalletModel> getWallet() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.wallet);
      return WalletModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// [type] is a [WalletTransactionType.apiValue] or null for "all".
  Future<WalletTransactionsPage> getTransactions({String? type, int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.walletTransactions, queryParameters: {
        'type': ?type,
        'page': page,
        'per_page': perPage,
      });
      return WalletTransactionsPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<WalletLookupModel> lookup(String accountNumber) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.walletLookup, data: {'account_number': accountNumber});
      return WalletLookupModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Re-send the SAME [idempotencyKey] when retrying after a timeout — the
  /// server returns the original transfer instead of moving money twice.
  Future<WalletTransferModel> transfer({
    required String toAccountNumber,
    required double amount,
    String? note,
    required String pin,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.walletTransfer, data: {
        'to_account_number': toAccountNumber,
        'amount': amount.round(),
        if (note != null && note.isNotEmpty) 'note': note,
        'pin': pin,
        'idempotency_key': idempotencyKey,
      });
      return WalletTransferModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<WalletTransferModel> getTransfer(int id) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.walletTransfers}/$id');
      return WalletTransferModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<WalletTransactionModel> topup({
    required int portfolioId,
    required double amount,
    String? description,
    required String pin,
  }) => _move(ApiEndpoints.walletTopup, portfolioId: portfolioId, amount: amount, description: description, pin: pin);

  Future<WalletTransactionModel> withdraw({
    required int portfolioId,
    required double amount,
    String? description,
    required String pin,
  }) => _move(ApiEndpoints.walletWithdraw, portfolioId: portfolioId, amount: amount, description: description, pin: pin);

  Future<WalletTransactionModel> _move(
    String path, {
    required int portfolioId,
    required double amount,
    String? description,
    required String pin,
  }) async {
    try {
      final response = await _apiClient.dio.post(path, data: {
        'finance_portfolio_id': portfolioId,
        'amount': amount.round(),
        if (description != null && description.isNotEmpty) 'description': description,
        'pin': pin,
      });
      return WalletTransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
