import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../savings_goals/application/savings_goal_controller.dart';

/// Result of averaging `SummaryModel.monthlyTrend` for the Emergency Fund
/// Calculator — see docs/plan-dev/kalkulator-dana-darurat-plan.txt BAGIAN 1.
class EmergencyFundData {
  const EmergencyFundData({required this.averageExpense, required this.monthsUsed});

  final double averageExpense;
  final int monthsUsed;

  /// Below this, the average isn't representative enough to show as-is —
  /// the page falls back to manual input instead (plan doc BAGIAN 1.2/2.3).
  static const minMonthsForAverage = 2;

  bool get isDataSufficient => monthsUsed >= minMonthsForAverage;
}

/// Averages the *current* month's trailing expense trend regardless of
/// whatever period the Summary tab itself is showing (unlike
/// `summaryControllerProvider`, which follows `selectedSummaryPeriodProvider`)
/// — the calculator always wants "up to now", not whatever month the user
/// last browsed to on the Summary tab. Months with no recorded expense are
/// excluded so a brand-new account doesn't drag the average down to
/// something unrepresentative.
final emergencyFundDataProvider = FutureProvider.autoDispose<EmergencyFundData>((ref) async {
  final now = DateTime.now();
  final summary = await ref.watch(summaryRepositoryProvider).getSummary(month: now.month, year: now.year);
  final expenses = summary.monthlyTrend.map((point) => point.expense).where((expense) => expense > 0).toList();
  if (expenses.isEmpty) return const EmergencyFundData(averageExpense: 0, monthsUsed: 0);
  final average = expenses.reduce((a, b) => a + b) / expenses.length;
  return EmergencyFundData(averageExpense: average, monthsUsed: expenses.length);
});

/// Best-effort match for an existing "dana darurat" savings goal, so the
/// calculator can show progress instead of just a bare recommendation (plan
/// doc BAGIAN 1.4) — reuses the goal list already fetched for the Savings
/// Goals tab rather than a new endpoint.
final emergencyFundExistingGoalProvider = Provider.autoDispose<SavingsGoalModel?>((ref) {
  final goals = ref.watch(savingsGoalControllerProvider).valueOrNull?.goals ?? const <SavingsGoalModel>[];
  for (final goal in goals) {
    final haystack = '${goal.name} ${goal.purpose ?? ''}'.toLowerCase();
    if (haystack.contains('darurat')) return goal;
  }
  return null;
});
