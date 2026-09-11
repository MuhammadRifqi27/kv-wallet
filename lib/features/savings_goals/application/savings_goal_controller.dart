import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/savings_goal_model.dart';

final savingsGoalControllerProvider =
    AsyncNotifierProvider<SavingsGoalController, SavingsGoalsSummaryModel>(SavingsGoalController.new);

/// Per-goal contribution ledger, keyed by goal id — kept separate from
/// [SavingsGoalController] (same split as BudgetController/CategoryList)
/// since it's fetched on demand from the detail page, not with the list.
final savingsGoalContributionsProvider =
    FutureProvider.family<List<SavingsGoalContributionModel>, int>((ref, goalId) {
  return ref.watch(savingsGoalRepositoryProvider).getContributions(goalId);
});

class SavingsGoalController extends AsyncNotifier<SavingsGoalsSummaryModel> {
  @override
  Future<SavingsGoalsSummaryModel> build() {
    return ref.read(savingsGoalRepositoryProvider).getSavingsGoals();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(savingsGoalRepositoryProvider).getSavingsGoals());
  }

  /// Left un-guarded (unlike [refresh]) so the calling form can catch
  /// [ApiException] itself and show field-level validation errors.
  Future<void> addGoal({
    required String name,
    String? purpose,
    int? financePortfolioId,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) async {
    await ref.read(savingsGoalRepositoryProvider).createSavingsGoal(
          name: name,
          purpose: purpose,
          financePortfolioId: financePortfolioId,
          targetAmount: targetAmount,
          targetDate: targetDate,
          icon: icon,
          color: color,
        );
    await refresh();
  }

  Future<void> editGoal({
    required int id,
    required String name,
    String? purpose,
    int? financePortfolioId,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) async {
    await ref.read(savingsGoalRepositoryProvider).updateSavingsGoal(
          id: id,
          name: name,
          purpose: purpose,
          financePortfolioId: financePortfolioId,
          targetAmount: targetAmount,
          targetDate: targetDate,
          icon: icon,
          color: color,
        );
    await refresh();
  }

  Future<void> removeGoal(int id) async {
    await ref.read(savingsGoalRepositoryProvider).deleteSavingsGoal(id);
    await refresh();
  }

  Future<void> archiveGoal(int id) async {
    await ref.read(savingsGoalRepositoryProvider).archiveSavingsGoal(id);
    await refresh();
  }

  /// Contribution/withdrawal mutations live here (not on a separate
  /// controller) because they change the parent goal's `saved_amount` /
  /// `progress_percent` / `status` — every call refreshes both the ledger
  /// for [goalId] and this goal list, same "_syncRelatedData" idea as
  /// BtcActivityController.
  Future<void> addContribution({
    required int goalId,
    required SavingsGoalEntryType type,
    required DateTime date,
    required double amount,
    int? financePortfolioId,
    String? note,
  }) async {
    await ref.read(savingsGoalRepositoryProvider).addContribution(
          goalId: goalId,
          type: type,
          date: date,
          amount: amount,
          financePortfolioId: financePortfolioId,
          note: note,
        );
    ref.invalidate(savingsGoalContributionsProvider(goalId));
    await refresh();
  }

  Future<void> removeContribution({required int goalId, required int contributionId}) async {
    await ref.read(savingsGoalRepositoryProvider).deleteContribution(goalId: goalId, contributionId: contributionId);
    ref.invalidate(savingsGoalContributionsProvider(goalId));
    await refresh();
  }
}
