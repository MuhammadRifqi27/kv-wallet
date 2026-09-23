import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/payroll_cycle_provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../budget/application/budget_controller.dart';

/// Null means "all types".
final transactionTypeFilterProvider = StateProvider<TransactionType?>((ref) => null);

/// Free-text search over the currently-loaded transactions — client-side
/// only (no backend `search`/`q` param documented for `GET /transactions`),
/// same scope limitation the date/type filters above already have: it only
/// searches whatever page the server returned for the current date/type
/// filter, not the user's entire history. Empty string means "no search".
final transactionSearchQueryProvider = StateProvider<String>((ref) => '');

/// Matches on category name, description/note, and account name — the
/// fields actually shown on each [_TransactionTile] row, so a match always
/// explains itself visually once found.
List<TransactionModel> filterTransactionsByQuery(List<TransactionModel> transactions, String query) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return transactions;

  return transactions.where((transaction) {
    return (transaction.categoryName?.toLowerCase().contains(trimmed) ?? false) ||
        (transaction.description?.toLowerCase().contains(trimmed) ?? false) ||
        (transaction.portfolioName?.toLowerCase().contains(trimmed) ?? false);
  }).toList();
}

/// Framework-agnostic stand-in for Flutter's `DateTimeRange` — kept out of
/// this application-layer file so it doesn't need a `material.dart` import.
/// [end] is inclusive.
class DateRange {
  const DateRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}

enum TransactionDateShortcut { all, thisMonth, lastMonth, last7Days, last30Days, custom }

/// Defaults to `all` — the app's original unfiltered behavior — so nothing
/// changes for anyone who doesn't touch the new date filter.
final transactionDateShortcutProvider = StateProvider<TransactionDateShortcut>((ref) => TransactionDateShortcut.all);

/// Only meaningful when [transactionDateShortcutProvider] is `custom`.
final transactionCustomRangeProvider = StateProvider<DateRange?>((ref) => null);

/// Resolves a shortcut into concrete start/end dates. Null return means "no
/// date filter" (the `all` shortcut).
///
/// `thisMonth`/`lastMonth` resolve against the real payroll cycle (via
/// [payrollCycleProvider]) so they match what Dashboard/Budget/Ringkasan
/// consider "this month" — which usually isn't the 1st–end of the calendar
/// month. `last7Days`/`last30Days` are plain rolling calendar windows; no
/// cycle concept applies to those.
Future<DateRange?> resolveTransactionDateRange(Ref ref, TransactionDateShortcut shortcut, DateRange? custom) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (shortcut) {
    case TransactionDateShortcut.all:
      return null;
    case TransactionDateShortcut.thisMonth:
      final cycle = await ref.read(payrollCycleProvider(DateTime(now.year, now.month)).future);
      return DateRange(start: cycle.start, end: cycle.end);
    case TransactionDateShortcut.lastMonth:
      final lastMonth = DateTime(now.year, now.month - 1);
      final cycle = await ref.read(payrollCycleProvider(lastMonth).future);
      return DateRange(start: cycle.start, end: cycle.end);
    case TransactionDateShortcut.last7Days:
      return DateRange(start: today.subtract(const Duration(days: 6)), end: today);
    case TransactionDateShortcut.last30Days:
      return DateRange(start: today.subtract(const Duration(days: 29)), end: today);
    case TransactionDateShortcut.custom:
      return custom;
  }
}

final transactionListControllerProvider =
    AsyncNotifierProvider<TransactionListController, TransactionListResult>(TransactionListController.new);

/// Whether [TransactionListController.loadMore] currently has a request in
/// flight — kept separate from the main [AsyncNotifier] state so "load more"
/// can show its own small footer spinner without flashing the whole list
/// back to the big top-level loading state that `state = AsyncLoading()`
/// (in [TransactionListController.refresh]) would cause.
final transactionLoadingMoreProvider = StateProvider<bool>((ref) => false);

/// Full CRUD — a transaction is the user's own data.
class TransactionListController extends AsyncNotifier<TransactionListResult> {
  @override
  Future<TransactionListResult> build() async {
    final type = ref.watch(transactionTypeFilterProvider);
    final range = await resolveTransactionDateRange(
      ref,
      ref.watch(transactionDateShortcutProvider),
      ref.watch(transactionCustomRangeProvider),
    );
    return ref.read(transactionRepositoryProvider).getTransactions(
          type: type,
          startDate: range?.start,
          endDate: range?.end,
        );
  }

  Future<void> refresh() async {
    final type = ref.read(transactionTypeFilterProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final range = await resolveTransactionDateRange(
        ref,
        ref.read(transactionDateShortcutProvider),
        ref.read(transactionCustomRangeProvider),
      );
      return ref.read(transactionRepositoryProvider).getTransactions(
            type: type,
            startDate: range?.start,
            endDate: range?.end,
          );
    });
  }

  /// Fetches the next page for the CURRENT filters and appends it onto the
  /// already-loaded list (see [TransactionListResult.appendPage]) — this is
  /// what lets the list actually reach transactions beyond page 1 at all,
  /// see docs/ide-improvement-fitur-existing.txt BAGIAN A #5. No-op if
  /// there's no result yet, no further page, or a load is already in
  /// flight. Failures are swallowed: the already-loaded list stays intact
  /// and the user can just tap "load more" again to retry.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages) return;
    if (ref.read(transactionLoadingMoreProvider)) return;

    ref.read(transactionLoadingMoreProvider.notifier).state = true;
    try {
      final type = ref.read(transactionTypeFilterProvider);
      final range = await resolveTransactionDateRange(
        ref,
        ref.read(transactionDateShortcutProvider),
        ref.read(transactionCustomRangeProvider),
      );
      final nextPage = await ref.read(transactionRepositoryProvider).getTransactions(
            type: type,
            startDate: range?.start,
            endDate: range?.end,
            page: current.currentPage + 1,
          );
      final latest = state.valueOrNull;
      if (latest != null) state = AsyncData(latest.appendPage(nextPage));
    } catch (_) {
      // Ignored — see doc comment above.
    } finally {
      ref.read(transactionLoadingMoreProvider.notifier).state = false;
    }
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
    if (type == TransactionType.expense) {
      // Re-check budget immediately so a newly-crossed limit gets a
      // notification right away, not just next time the Budget tab
      // happens to reload (see docs/flutter-notifications-plan.txt).
      await ref.read(budgetControllerProvider.notifier).refresh();
    }
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
    if (type == TransactionType.expense) {
      await ref.read(budgetControllerProvider.notifier).refresh();
    }
  }

  Future<void> removeTransaction(int id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    await refresh();
  }
}
