import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../savings_goals/application/savings_goal_controller.dart';

/// Averaged income/expense + current net worth for the FIRE/retirement
/// projection — see docs/plan-dev/kalkulator-pensiun-fire-plan.txt BAGIAN 1.
/// Mirrors `EmergencyFundData`'s shape/reasoning (same "average over
/// recorded months, exclude empty ones" approach), plus `currentNetWorth`
/// as the projection's starting balance.
class RetirementData {
  const RetirementData({
    required this.averageMonthlyIncome,
    required this.averageMonthlyExpense,
    required this.monthsUsed,
    required this.currentNetWorth,
  });

  final double averageMonthlyIncome;
  final double averageMonthlyExpense;
  final int monthsUsed;
  final double currentNetWorth;

  /// Below this, the averages aren't representative enough to project from
  /// — the page falls back to manual income/expense input instead.
  static const minMonthsForAverage = 2;

  bool get isDataSufficient => monthsUsed >= minMonthsForAverage;

  double get averageMonthlySavings => averageMonthlyIncome - averageMonthlyExpense;

  /// Net savings as a percentage of income — 0 when there's no income to
  /// divide by (avoids a divide-by-zero NaN reaching the UI).
  double get savingsRatePercent => averageMonthlyIncome > 0 ? (averageMonthlySavings / averageMonthlyIncome * 100) : 0;
}

/// Same "current month's trailing trend, independent of whatever the
/// Summary tab is showing" reasoning as `emergencyFundDataProvider` — see
/// that provider's doc comment. `totalNetWorth` always comes from the
/// current month's snapshot regardless of how many months have expense/
/// income data (net worth is a point-in-time balance, not something to
/// average).
final retirementDataProvider = FutureProvider.autoDispose<RetirementData>((ref) async {
  final now = DateTime.now();
  final summary = await ref.watch(summaryRepositoryProvider).getSummary(month: now.month, year: now.year);
  final activeMonths = summary.monthlyTrend.where((point) => point.income > 0 || point.expense > 0).toList();
  if (activeMonths.isEmpty) {
    return RetirementData(
      averageMonthlyIncome: 0,
      averageMonthlyExpense: 0,
      monthsUsed: 0,
      currentNetWorth: summary.totalNetWorth,
    );
  }
  final avgIncome = activeMonths.map((point) => point.income).reduce((a, b) => a + b) / activeMonths.length;
  final avgExpense = activeMonths.map((point) => point.expense).reduce((a, b) => a + b) / activeMonths.length;
  return RetirementData(
    averageMonthlyIncome: avgIncome,
    averageMonthlyExpense: avgExpense,
    monthsUsed: activeMonths.length,
    currentNetWorth: summary.totalNetWorth,
  );
});

/// Best-effort match for an existing "dana pensiun"/"fire" savings goal —
/// same reasoning and reuse of the already-fetched goal list as
/// `emergencyFundExistingGoalProvider`.
final fireExistingGoalProvider = Provider.autoDispose<SavingsGoalModel?>((ref) {
  final goals = ref.watch(savingsGoalControllerProvider).valueOrNull?.goals ?? const <SavingsGoalModel>[];
  for (final goal in goals) {
    final haystack = '${goal.name} ${goal.purpose ?? ''}'.toLowerCase();
    if (haystack.contains('pensiun') || haystack.contains('fire') || haystack.contains('retire')) return goal;
  }
  return null;
});

/// Result of [projectFire] — years is capped at [projectionCapYears]; when
/// [reachable] is false the target wasn't hit within that cap (e.g. savings
/// rate is zero/negative), and the calculator should show "belum tercapai"
/// instead of a specific year count.
class FireProjection {
  const FireProjection({required this.targetAmount, required this.years, required this.reachable});

  final double targetAmount;
  final int years;
  final bool reachable;
}

const projectionCapYears = 60;

/// Standard "4% rule" — target = 25x annual expense, i.e. the balance a
/// 4%/year withdrawal can sustain indefinitely. Not user-adjustable (see
/// plan doc BAGIAN 1.3 for why only the return-rate assumption is exposed
/// as a chip, not this one) — it's the one universally-cited FIRE
/// benchmark, unlike the return rate which genuinely varies by portfolio.
const safeWithdrawalRate = 0.04;

/// Year-by-year compound projection (annual contribution added at each
/// year's end) from [currentNetWorth] to the 4%-rule FIRE target implied by
/// [annualExpense], growing at [annualReturnRate] and contributing
/// [annualSavings] each year. A closed-form solution exists for constant
/// contributions, but the simple simulation loop is easier to read/verify
/// and 60 iterations is negligible cost.
FireProjection projectFire({
  required double currentNetWorth,
  required double annualSavings,
  required double annualExpense,
  required double annualReturnRate,
}) {
  final target = annualExpense / safeWithdrawalRate;
  if (currentNetWorth >= target) {
    return FireProjection(targetAmount: target, years: 0, reachable: true);
  }

  var balance = currentNetWorth;
  var years = 0;
  while (balance < target && years < projectionCapYears) {
    balance = balance * (1 + annualReturnRate) + annualSavings;
    years++;
  }
  return FireProjection(targetAmount: target, years: years, reachable: balance >= target);
}
