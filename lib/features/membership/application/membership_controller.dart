import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/membership_status_model.dart';

final membershipPlansProvider = FutureProvider.autoDispose<List<MembershipPlan>>((ref) {
  return ref.read(membershipRepositoryProvider).getPlans();
});

final membershipStatusProvider = FutureProvider.autoDispose<MembershipStatus>((ref) {
  return ref.read(membershipRepositoryProvider).getStatus();
});

class SelectPlanState {
  const SelectPlanState({this.isLoading = false, this.error});

  final bool isLoading;
  final ApiException? error;

  SelectPlanState copyWith({bool? isLoading, ApiException? error, bool clearError = false}) {
    return SelectPlanState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final selectPlanControllerProvider =
    StateNotifierProvider.autoDispose<SelectPlanController, SelectPlanState>((ref) {
  return SelectPlanController(ref);
});

class SelectPlanController extends StateNotifier<SelectPlanState> {
  SelectPlanController(this._ref) : super(const SelectPlanState());

  final Ref _ref;

  Future<bool> selectPlan(int planId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref.read(membershipRepositoryProvider).selectPlan(planId);
      _ref.invalidate(membershipStatusProvider);
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }
}
