import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/btc_tracking_model.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../portfolio/application/portfolio_list_controller.dart';

final btcOverviewControllerProvider =
    AsyncNotifierProvider<BtcOverviewController, BtcOverview>(BtcOverviewController.new);

class BtcOverviewController extends AsyncNotifier<BtcOverview> {
  @override
  Future<BtcOverview> build() {
    return ref.read(btcTrackingRepositoryProvider).getOverview();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(btcTrackingRepositoryProvider).getOverview());
  }
}

final btcActivityControllerProvider =
    AsyncNotifierProvider<BtcActivityController, List<BtcActivityItem>>(BtcActivityController.new);

/// CRUD for `source_type: "investment"` entries only — `transfer`-sourced
/// rows in the feed are managed from Transfer Antar Akun instead (see
/// BtcActivityItem.isFromTransfer). Every mutation here changes an account
/// balance, so it also refreshes the overview, Portfolio, and Dashboard —
/// same "_syncRelatedData" pattern as TransferListController.
class BtcActivityController extends AsyncNotifier<List<BtcActivityItem>> {
  @override
  Future<List<BtcActivityItem>> build() {
    return ref.read(btcTrackingRepositoryProvider).getActivity();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(btcTrackingRepositoryProvider).getActivity());
  }

  Future<void> _syncRelatedData() async {
    await ref.read(btcOverviewControllerProvider.notifier).refresh();
    await ref.read(portfolioListControllerProvider.notifier).refresh();
    await ref.read(dashboardControllerProvider.notifier).refresh();
  }

  /// Left un-guarded (unlike [refresh]) so the calling form can catch
  /// [ApiException] itself and show field-level validation errors.
  Future<void> addEntry({
    required int portfolioId,
    required String asset,
    required DateTime date,
    required BtcEntryType type,
    required double amount,
    String? description,
  }) async {
    await ref.read(btcTrackingRepositoryProvider).createEntry(
          portfolioId: portfolioId,
          asset: asset,
          date: date,
          type: type,
          amount: amount,
          description: description,
        );
    await refresh();
    await _syncRelatedData();
  }

  Future<void> editEntry({
    required int id,
    required String asset,
    required DateTime date,
    required BtcEntryType type,
    required double amount,
    String? description,
  }) async {
    await ref.read(btcTrackingRepositoryProvider).updateEntry(
          id: id,
          asset: asset,
          date: date,
          type: type,
          amount: amount,
          description: description,
        );
    await refresh();
    await _syncRelatedData();
  }

  Future<void> removeEntry(int id) async {
    await ref.read(btcTrackingRepositoryProvider).deleteEntry(id);
    await refresh();
    await _syncRelatedData();
  }
}
