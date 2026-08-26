import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/budget_model.dart';

final selectedBudgetPeriodProvider = StateProvider<DateTime>((ref) => DateTime.now());

final budgetControllerProvider =
    AsyncNotifierProvider<BudgetController, BudgetSummaryModel>(BudgetController.new);

class BudgetController extends AsyncNotifier<BudgetSummaryModel> {
  /// Categories already notified as over-budget this session (key:
  /// "categoryId-month-year") — in-memory only, resets on app restart, so
  /// a category doesn't re-notify every time this page happens to reload.
  /// See docs/flutter-notifications-plan.txt BAGIAN 2.2.
  final Set<String> _notifiedOverBudgetKeys = {};

  @override
  Future<BudgetSummaryModel> build() async {
    final period = ref.watch(selectedBudgetPeriodProvider);
    final summary = await ref.read(budgetRepositoryProvider).getBudgets(month: period.month, year: period.year);
    _notifyOverBudgetCategories(summary);
    return summary;
  }

  Future<void> refresh() async {
    final period = ref.read(selectedBudgetPeriodProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final summary = await ref.read(budgetRepositoryProvider).getBudgets(month: period.month, year: period.year);
      _notifyOverBudgetCategories(summary);
      return summary;
    });
  }

  /// Left un-guarded (unlike [refresh]) so the calling form can catch
  /// [ApiException] itself and show field-level validation errors.
  Future<void> addBudget({required int categoryId, required double amount}) async {
    final period = ref.read(selectedBudgetPeriodProvider);
    await ref.read(budgetRepositoryProvider).createBudget(
          categoryId: categoryId,
          amount: amount,
          month: period.month,
          year: period.year,
        );
    await refresh();
  }

  void _notifyOverBudgetCategories(BudgetSummaryModel summary) {
    for (final category in summary.categories) {
      if (!category.isOverBudget) continue;
      final key = '${category.categoryId}-${summary.month}-${summary.year}';
      if (_notifiedOverBudgetKeys.add(key)) {
        ref.read(notificationServiceProvider).showBudgetExceededNotification(
              categoryId: category.categoryId,
              categoryName: category.categoryName,
              spent: category.spent,
              amount: category.amount,
              month: summary.month,
              year: summary.year,
            );
      }
    }
  }
}
