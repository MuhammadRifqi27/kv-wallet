import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/summary_model.dart';

/// Only month/year matter here — day is ignored.
final selectedSummaryPeriodProvider = StateProvider<DateTime>((ref) => DateTime.now());

final summaryControllerProvider = AsyncNotifierProvider<SummaryController, SummaryModel>(SummaryController.new);

class SummaryController extends AsyncNotifier<SummaryModel> {
  @override
  Future<SummaryModel> build() {
    final period = ref.watch(selectedSummaryPeriodProvider);
    return ref.read(summaryRepositoryProvider).getSummary(month: period.month, year: period.year);
  }

  Future<void> refresh() async {
    final period = ref.read(selectedSummaryPeriodProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(summaryRepositoryProvider).getSummary(month: period.month, year: period.year),
    );
  }
}

/// Previous month's summary, fetched purely for the "vs bulan lalu"
/// comparison badges — kept as a separate `autoDispose` read instead of
/// folding into [SummaryController] so a slow/failed fetch here can't block
/// the main summary from showing. `.valueOrNull` on the UI side means no
/// badge rather than an error state.
final previousMonthSummaryProvider = FutureProvider.autoDispose<SummaryModel>((ref) {
  final period = ref.watch(selectedSummaryPeriodProvider);
  final previous = DateTime(period.year, period.month - 1);
  return ref.read(summaryRepositoryProvider).getSummary(month: previous.month, year: previous.year);
});

/// Budget status for the same period as the summary — a separate fetch
/// (not [budgetControllerProvider]) on purpose: that controller's period is
/// driven by the Budget tab's own selector and would show the wrong month
/// here if the user had navigated it independently.
final summaryBudgetHealthProvider = FutureProvider.autoDispose<BudgetSummaryModel>((ref) {
  final period = ref.watch(selectedSummaryPeriodProvider);
  return ref.read(budgetRepositoryProvider).getBudgets(month: period.month, year: period.year);
});
