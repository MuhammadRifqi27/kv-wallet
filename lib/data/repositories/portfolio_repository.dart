import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/portfolio_model.dart';

/// Full CRUD — unlike Kategori/Provider Investasi, a portfolio is the
/// user's own account/wallet, not shared admin-controlled master data.
class PortfolioRepository {
  PortfolioRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<List<PortfolioModel>> getPortfolios() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.portfolios);
      final list = response.data as List<dynamic>;
      return list.map((json) => PortfolioModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PortfolioModel> createPortfolio({
    required int financeInvestmentId,
    required String accountName,
    required bool isInvestmentAccount,
    String? accountNumber,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.portfolios, data: {
        'finance_investment_id': financeInvestmentId,
        'account_name': accountName,
        'account_number': accountNumber,
        'description': description,
        'account_investment': isInvestmentAccount,
      });
      return PortfolioModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PortfolioModel> updatePortfolio({
    required int id,
    required int financeInvestmentId,
    required String accountName,
    required bool isInvestmentAccount,
    String? accountNumber,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.put('${ApiEndpoints.portfolios}/$id', data: {
        'finance_investment_id': financeInvestmentId,
        'account_name': accountName,
        'account_number': accountNumber,
        'description': description,
        'account_investment': isInvestmentAccount,
      });
      return PortfolioModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Server rejects with 400 if the account already has transaction history
  /// (see docs/flutter-mobile-app-development-guide.txt MASTER DATA >
  /// PORTFOLIO) — surfaced as [ApiException.message] like any other error.
  Future<void> deletePortfolio(int id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.portfolios}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
