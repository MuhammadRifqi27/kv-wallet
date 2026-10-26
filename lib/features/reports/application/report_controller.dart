import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/report_model.dart';
import '../../summary/application/summary_controller.dart';

/// Month/year picked on the Reports page — seeded from the Summary period so
/// opening Laporan from Ringkasan lands on the same cycle. Day is ignored.
/// `autoDispose`: leaving the page resets the selection and drops every
/// cached report below, so nothing stale outlives the screen (or the user —
/// see user_data_reset.dart).
final reportPeriodProvider = StateProvider.autoDispose<DateTime>((ref) {
  final summary = ref.read(selectedSummaryPeriodProvider);
  return DateTime(summary.year, summary.month);
});

/// Savings-rate window; API default is 12.
final reportSavingsCyclesProvider = StateProvider.autoDispose<int>((ref) => 12);

/// Cycle to compare against; null = the cycle right before the main one.
final reportCompareWithProvider = StateProvider.autoDispose<DateTime?>((ref) => null);

/// Category report selection; null id = server picks the biggest expense.
final reportCategoryIdProvider = StateProvider.autoDispose<int?>((ref) => null);
final reportCategoryCyclesProvider = StateProvider.autoDispose<int>((ref) => 6);

final cashFlowReportProvider = FutureProvider.autoDispose<CashFlowReport>((ref) {
  final period = ref.watch(reportPeriodProvider);
  return ref.read(reportRepositoryProvider).getCashFlow(month: period.month, year: period.year);
});

final savingsRateReportProvider = FutureProvider.autoDispose<SavingsRateReport>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final cycles = ref.watch(reportSavingsCyclesProvider);
  return ref.read(reportRepositoryProvider).getSavingsRate(month: period.month, year: period.year, cycles: cycles);
});

final compareReportProvider = FutureProvider.autoDispose<CompareReport>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final compareWith = ref.watch(reportCompareWithProvider);
  return ref.read(reportRepositoryProvider).getCompare(
        month: period.month,
        year: period.year,
        compareMonth: compareWith?.month,
        compareYear: compareWith?.year,
      );
});

final categoryReportProvider = FutureProvider.autoDispose<CategoryReport>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final categoryId = ref.watch(reportCategoryIdProvider);
  final cycles = ref.watch(reportCategoryCyclesProvider);
  return ref.read(reportRepositoryProvider).getCategory(
        month: period.month,
        year: period.year,
        categoryId: categoryId,
        cycles: cycles,
      );
});

final unexpectedExpensesReportProvider = FutureProvider.autoDispose<UnexpectedExpensesReport>((ref) {
  final period = ref.watch(reportPeriodProvider);
  return ref.read(reportRepositoryProvider).getUnexpectedExpenses(month: period.month, year: period.year);
});

/// Keyed on year only, so changing the month elsewhere doesn't refetch.
final yearInReviewReportProvider = FutureProvider.autoDispose<YearInReviewReport>((ref) {
  final year = ref.watch(reportPeriodProvider.select((period) => period.year));
  return ref.read(reportRepositoryProvider).getYearInReview(year: year);
});

final taxReportControllerProvider =
    AsyncNotifierProvider.autoDispose<TaxReportController, TaxReport>(TaxReportController.new);

class TaxReportController extends AutoDisposeAsyncNotifier<TaxReport> {
  @override
  Future<TaxReport> build() {
    final year = ref.watch(reportPeriodProvider.select((period) => period.year));
    return ref.read(reportRepositoryProvider).getTax(year: year);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// The POST response replaces the tab state directly (docs §3 — no second
  /// request). Left un-guarded so the UI can show the [ApiException].
  Future<void> saveCategories(List<int> categoryIds) async {
    final year = ref.read(reportPeriodProvider).year;
    final updated = await ref.read(reportRepositoryProvider).saveTaxCategories(year: year, categoryIds: categoryIds);
    state = AsyncData(updated);
  }
}
