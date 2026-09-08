import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/dashboard_model.dart';

/// Null means "current payroll cycle" — the app's original default before
/// this filter existed. Only set once the user actually picks a period, so
/// nothing changes for anyone who doesn't touch it.
final selectedDashboardPeriodProvider = StateProvider<DateTime?>((ref) => null);

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardModel>(DashboardController.new);

class DashboardController extends AsyncNotifier<DashboardModel> {
  @override
  Future<DashboardModel> build() {
    final period = ref.watch(selectedDashboardPeriodProvider);
    return ref.read(dashboardRepositoryProvider).getDashboard(month: period?.month, year: period?.year);
  }

  Future<void> refresh() async {
    final period = ref.read(selectedDashboardPeriodProvider);
    // Best-effort — Dashboard doesn't call GET /recurring itself (that's
    // what normally processes due templates into real transactions, see
    // RecurringRepository.getRecurring), so nudge it here too per
    // docs/flutter-mobile-app-development-guide.txt: "panggil endpoint ini
    // ... saat pull-to-refresh Dashboard, supaya transaksi berulang yang
    // jatuh tempo langsung muncul." Runs before the dashboard fetch so a
    // just-processed transaction shows up in this same refresh.
    await ref.read(recurringRepositoryProvider).processDue();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).getDashboard(month: period?.month, year: period?.year),
    );
  }
}
