import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/dashboard_model.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardModel>(DashboardController.new);

class DashboardController extends AsyncNotifier<DashboardModel> {
  @override
  Future<DashboardModel> build() {
    return ref.read(dashboardRepositoryProvider).getDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(dashboardRepositoryProvider).getDashboard());
  }
}
