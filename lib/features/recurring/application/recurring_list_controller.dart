import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/recurring_transaction_model.dart';
import '../../../data/models/transaction_model.dart';

final recurringListControllerProvider =
    AsyncNotifierProvider<RecurringListController, List<RecurringTransactionModel>>(RecurringListController.new);

class RecurringListController extends AsyncNotifier<List<RecurringTransactionModel>> {
  @override
  Future<List<RecurringTransactionModel>> build() {
    return ref.read(recurringRepositoryProvider).getRecurring();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(recurringRepositoryProvider).getRecurring());
  }

  /// Left un-guarded (unlike [refresh]) so the calling form can catch
  /// [ApiException] itself and show field-level validation errors.
  Future<void> addRecurring({
    required String name,
    required TransactionType type,
    required int categoryId,
    required int portfolioId,
    required RecurringFrequency frequency,
    required DateTime startDate,
    required double amount,
    String? description,
  }) async {
    await ref.read(recurringRepositoryProvider).createRecurring(
          name: name,
          type: type,
          categoryId: categoryId,
          portfolioId: portfolioId,
          frequency: frequency,
          startDate: startDate,
          amount: amount,
          description: description,
        );
    await refresh();
  }

  Future<void> editRecurring({
    required int id,
    required String name,
    required TransactionType type,
    required int categoryId,
    required int portfolioId,
    required RecurringFrequency frequency,
    required DateTime startDate,
    required double amount,
    String? description,
  }) async {
    await ref.read(recurringRepositoryProvider).updateRecurring(
          id: id,
          name: name,
          type: type,
          categoryId: categoryId,
          portfolioId: portfolioId,
          frequency: frequency,
          startDate: startDate,
          amount: amount,
          description: description,
        );
    await refresh();
  }

  Future<void> removeRecurring(int id) async {
    await ref.read(recurringRepositoryProvider).deleteRecurring(id);
    await refresh();
  }
}
