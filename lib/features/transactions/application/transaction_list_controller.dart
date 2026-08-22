import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/transaction_model.dart';

/// Null means "all types".
final transactionTypeFilterProvider = StateProvider<TransactionType?>((ref) => null);

final transactionListControllerProvider =
    AsyncNotifierProvider<TransactionListController, TransactionListResult>(TransactionListController.new);

/// Full CRUD — a transaction is the user's own data.
class TransactionListController extends AsyncNotifier<TransactionListResult> {
  @override
  Future<TransactionListResult> build() {
    final type = ref.watch(transactionTypeFilterProvider);
    return ref.read(transactionRepositoryProvider).getTransactions(type: type);
  }

  Future<void> refresh() async {
    final type = ref.read(transactionTypeFilterProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(transactionRepositoryProvider).getTransactions(type: type));
  }

  /// Left un-guarded (unlike [refresh]) so the calling form can catch
  /// [ApiException] itself and show field-level validation errors.
  Future<void> addTransaction({
    required DateTime date,
    required TransactionType type,
    required int categoryId,
    required double amount,
    int? portfolioId,
    String? description,
  }) async {
    await ref.read(transactionRepositoryProvider).createTransaction(
          date: date,
          type: type,
          categoryId: categoryId,
          amount: amount,
          portfolioId: portfolioId,
          description: description,
        );
    await refresh();
  }

  Future<void> editTransaction({
    required int id,
    required DateTime date,
    required TransactionType type,
    required int categoryId,
    required double amount,
    int? portfolioId,
    String? description,
  }) async {
    await ref.read(transactionRepositoryProvider).updateTransaction(
          id: id,
          date: date,
          type: type,
          categoryId: categoryId,
          amount: amount,
          portfolioId: portfolioId,
          description: description,
        );
    await refresh();
  }

  Future<void> removeTransaction(int id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    await refresh();
  }
}
