import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/budget_recommendation_model.dart';

final selectedBudgetPeriodProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Suggestions for the period currently selected on the Budget page.
/// `autoDispose` so leaving the screen drops them — they're recomputed from
/// the latest transactions every time it opens.
final budgetRecommendationsProvider = FutureProvider.autoDispose<BudgetRecommendations>((ref) {
  final period = ref.watch(selectedBudgetPeriodProvider);
  return ref.read(budgetRepositoryProvider).getRecommendations(month: period.month, year: period.year);
});

final budgetControllerProvider =
    AsyncNotifierProvider<BudgetController, BudgetSummaryModel>(BudgetController.new);

class BudgetController extends AsyncNotifier<BudgetSummaryModel> {
  /// Categories already notified as over-budget this session (key:
  /// "categoryId-month-year") — in-memory only, resets on app restart, so
  /// a category doesn't re-notify every time this page happens to reload.
  /// See docs/flutter-notifications-plan.txt BAGIAN 2.2.
  final Set<String> _notifiedOverBudgetKeys = {};

  /// Same in-memory-only dedup as [_notifiedOverBudgetKeys], but for the
  /// >=80%-used early warning. See [BudgetCategoryItem.isNearLimit] and
  /// docs/ide-improvement-fitur-existing.txt BAGIAN G #41.
  final Set<String> _notifiedNearLimitKeys = {};

  @override
  Future<BudgetSummaryModel> build() async {
    final period = ref.watch(selectedBudgetPeriodProvider);
    final summary = await ref.read(budgetRepositoryProvider).getBudgets(month: period.month, year: period.year);
    _notifyOverBudgetCategories(summary);
    _notifyNearLimitCategories(summary);
    return summary;
  }

  Future<void> refresh() async {
    final period = ref.read(selectedBudgetPeriodProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final summary = await ref.read(budgetRepositoryProvider).getBudgets(month: period.month, year: period.year);
      _notifyOverBudgetCategories(summary);
      _notifyNearLimitCategories(summary);
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

  /// Applies server-side suggestions for [categoryIds] to the selected
  /// period, then reloads the budget list. Returns the number actually saved
  /// (may be lower than requested). Un-guarded so the screen can show the
  /// [ApiException].
  Future<int> applyRecommendations(List<int> categoryIds) async {
    final period = ref.read(selectedBudgetPeriodProvider);
    final saved = await ref.read(budgetRepositoryProvider).applyRecommendations(
          month: period.month,
          year: period.year,
          categoryIds: categoryIds,
        );
    await refresh();
    return saved;
  }

  void _notifyOverBudgetCategories(BudgetSummaryModel summary) {
    if (!ref.read(budgetNotificationsEnabledProvider)) return;
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
              locale: ref.read(effectiveLocaleProvider),
            );
      }
    }
  }

  void _notifyNearLimitCategories(BudgetSummaryModel summary) {
    if (!ref.read(budgetNotificationsEnabledProvider)) return;
    for (final category in summary.categories) {
      if (!category.isNearLimit) continue;
      final key = '${category.categoryId}-${summary.month}-${summary.year}';
      if (_notifiedNearLimitKeys.add(key)) {
        ref.read(notificationServiceProvider).showBudgetNearLimitNotification(
              categoryId: category.categoryId,
              categoryName: category.categoryName,
              spent: category.spent,
              amount: category.amount,
              month: summary.month,
              year: summary.year,
              locale: ref.read(effectiveLocaleProvider),
            );
      }
    }
  }
}
