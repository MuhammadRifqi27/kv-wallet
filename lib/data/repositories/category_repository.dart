import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/category_model.dart';

/// Read-only — categories are managed by admin via the web app, not from
/// mobile. Response bodies here are bare JSON (no `{"data": ...}` envelope),
/// confirmed against the real API.
class CategoryRepository {
  CategoryRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<List<CategoryModel>> getCategories({CategoryType? type}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.categories,
        queryParameters: type != null ? {'type': type.name} : null,
      );
      final list = response.data as List<dynamic>;
      return list.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
