import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';

final payrollSettingsControllerProvider =
    AsyncNotifierProvider<PayrollSettingsController, Object?>(PayrollSettingsController.new);

/// Holds `payroll_start_day` — either an `int` (1-31) or the literal string
/// `"last"` (end of month). The only master-data setting editable from
/// mobile; everything else under Settings is admin/web-only.
class PayrollSettingsController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async {
    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    return settings['payroll_start_day'];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      return settings['payroll_start_day'];
    });
  }

  /// Left un-guarded so the calling form can catch [ApiException] itself.
  Future<void> updatePayrollStartDay(Object value) async {
    await ref.read(settingsRepositoryProvider).updateSettings({'payroll_start_day': value});
    await refresh();
  }
}
