import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/report_model.dart';

/// Online-only (docs/mobile-api-report.md §1) — no offline queue.
class ReportRepository {
  ReportRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<T> _get<T>(
    String path,
    Map<String, dynamic> query,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      final response = await _apiClient.dio.get(path, queryParameters: query);
      return parse(unwrapReport(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<CashFlowReport> getCashFlow({required int month, required int year}) =>
      _get(ApiEndpoints.reportCashFlow, {'month': month, 'year': year}, CashFlowReport.fromJson);

  Future<SavingsRateReport> getSavingsRate({required int month, required int year, required int cycles}) => _get(
        ApiEndpoints.reportSavingsRate,
        {'month': month, 'year': year, 'cycles': cycles},
        SavingsRateReport.fromJson,
      );

  /// Without `compare_*` the server compares against the cycle before
  /// [month]/[year].
  Future<CompareReport> getCompare({
    required int month,
    required int year,
    int? compareMonth,
    int? compareYear,
  }) =>
      _get(
        ApiEndpoints.reportCompare,
        {
          'month': month,
          'year': year,
          'compare_month': ?compareMonth,
          'compare_year': ?compareYear,
        },
        CompareReport.fromJson,
      );

  /// Without [categoryId] the server picks the biggest expense category.
  Future<CategoryReport> getCategory({
    required int month,
    required int year,
    int? categoryId,
    required int cycles,
  }) =>
      _get(
        ApiEndpoints.reportCategory,
        {'month': month, 'year': year, 'category_id': ?categoryId, 'cycles': cycles},
        CategoryReport.fromJson,
      );

  Future<UnexpectedExpensesReport> getUnexpectedExpenses({required int month, required int year}) => _get(
        ApiEndpoints.reportUnexpectedExpenses,
        {'month': month, 'year': year},
        UnexpectedExpensesReport.fromJson,
      );

  Future<YearInReviewReport> getYearInReview({required int year}) =>
      _get(ApiEndpoints.reportYearInReview, {'year': year}, YearInReviewReport.fromJson);

  Future<TaxReport> getTax({required int year}) => _get(ApiEndpoints.reportTax, {'year': year}, TaxReport.fromJson);

  /// Overwrites the whole selection (send the full list, `[]` clears) and
  /// returns the same shape as [getTax] for [year].
  Future<TaxReport> saveTaxCategories({required int year, required List<int> categoryIds}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.reportTaxCategories,
        data: {'year': year, 'category_ids': categoryIds},
      );
      return TaxReport.fromJson(unwrapReport(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
