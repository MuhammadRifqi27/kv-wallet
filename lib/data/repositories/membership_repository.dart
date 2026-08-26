import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/membership_plan_model.dart';
import '../models/membership_status_model.dart';

class MembershipRepository {
  MembershipRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<List<MembershipPlan>> getPlans() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.membershipPlans);
      final list = _unwrapList(response.data);
      return list.map((json) => MembershipPlan.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Gagal membaca data plan dari server: $e');
    }
  }

  /// Records the user's plan choice — does NOT grant access by itself, admin
  /// still has to verify the manual transfer before `is_paid_member` flips.
  Future<MembershipStatus> selectPlan(int planId) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.membershipSelectPlan, data: {
        'membership_plan_id': planId,
      });
      return MembershipStatus.fromJson(_unwrapMap(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Gagal membaca respons server: $e');
    }
  }

  Future<MembershipStatus> getStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.membershipStatus);
      return MembershipStatus.fromJson(_unwrapMap(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Gagal membaca status membership: $e');
    }
  }
}

/// Some backend endpoints wrap the payload in a Laravel API Resource
/// envelope (`{"data": ...}`), others return it bare — money-management
/// endpoints happen to be bare (see category_repository.dart) but that's
/// not guaranteed for every route, so handle both shapes defensively.
List<dynamic> _unwrapList(dynamic data) {
  if (data is List) return data;
  if (data is Map && data['data'] is List) return data['data'] as List<dynamic>;
  throw FormatException('Bentuk response tidak dikenali (harus berupa list): ${data.runtimeType}');
}

Map<String, dynamic> _unwrapMap(dynamic data) {
  if (data is Map<String, dynamic> && data['data'] is Map) return data['data'] as Map<String, dynamic>;
  if (data is Map<String, dynamic>) return data;
  throw FormatException('Bentuk response tidak dikenali (harus berupa object): ${data.runtimeType}');
}
