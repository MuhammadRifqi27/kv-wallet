import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/transfer_model.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../portfolio/application/portfolio_list_controller.dart';

final transferListControllerProvider =
    AsyncNotifierProvider<TransferListController, List<TransferModel>>(TransferListController.new);

/// Full CRUD. A transfer moves balance between two of the user's own
/// portfolios, so every mutation also refreshes
/// [portfolioListControllerProvider] (account balances) and
/// [dashboardControllerProvider] (net worth + recent activity) — both are
/// server-computed and won't reflect the change otherwise.
class TransferListController extends AsyncNotifier<List<TransferModel>> {
  @override
  Future<List<TransferModel>> build() {
    return ref.read(transferRepositoryProvider).getTransfers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(transferRepositoryProvider).getTransfers());
  }

  Future<void> _syncRelatedData() async {
    await ref.read(portfolioListControllerProvider.notifier).refresh();
    await ref.read(dashboardControllerProvider.notifier).refresh();
  }

  /// Left un-guarded (unlike [refresh]) so the calling form can catch
  /// [ApiException] itself and show field-level validation errors.
  Future<void> addTransfer({
    required DateTime date,
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String? description,
  }) async {
    await ref.read(transferRepositoryProvider).createTransfer(
          date: date,
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          amount: amount,
          description: description,
        );
    await refresh();
    await _syncRelatedData();
  }

  Future<void> editTransfer({
    required int id,
    required DateTime date,
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String? description,
  }) async {
    await ref.read(transferRepositoryProvider).updateTransfer(
          id: id,
          date: date,
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          amount: amount,
          description: description,
        );
    await refresh();
    await _syncRelatedData();
  }

  Future<void> removeTransfer(int id) async {
    await ref.read(transferRepositoryProvider).deleteTransfer(id);
    await refresh();
    await _syncRelatedData();
  }
}
