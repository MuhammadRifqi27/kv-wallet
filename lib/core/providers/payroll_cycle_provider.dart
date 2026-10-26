import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

class PayrollCycle {
  const PayrollCycle({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

/// Resolves the real payroll-cycle boundary dates for a reference month
/// (day is ignored) — e.g. the cycle labeled "Maret 2026" might actually run
/// 25 Feb–24 Mar if `payroll_start_day` is 25, not the 1st–31st. Dashboard,
/// Budget, and Ringkasan don't need this — they send `month`/`year` and let
/// the backend apply the cycle itself. This exists only for screens that
/// take raw `start_date`/`end_date` (Transaksi's date filter) and need to
/// match that same cycle exactly.
///
/// Deliberately reuses the Budget endpoint's `cycle_start_date`/
/// `cycle_end_date` fields instead of replicating the payroll-cycle math
/// client-side — the exact rule for edge cases (end-of-month, year
/// rollover) lives in the backend, and re-guessing it here risks silently
/// drifting from what Dashboard/Budget/Ringkasan actually show.
final payrollCycleProvider = FutureProvider.family<PayrollCycle, DateTime>((ref, referenceMonth) async {
  final summary = await ref.read(budgetRepositoryProvider).getBudgets(
        month: referenceMonth.month,
        year: referenceMonth.year,
      );
  final start = summary.cycleStartDate;
  final end = summary.cycleEndDate;
  // Was previously a silent calendar-month fallback (1st-to-end-of-month)
  // when the backend omitted these — exactly the "silently drifting from
  // what Dashboard/Budget/Ringkasan actually show" risk this class doc
  // already warned about above. Throwing instead surfaces it as a real
  // `AsyncError` on whichever provider called this (both existing call
  // sites already handle that: `TransactionListController.build()`'s
  // exception becomes its own AsyncError automatically, and `refresh()`
  // wraps its call in `AsyncValue.guard`) — a visible retry-able error beats
  // a wrong-but-successful date range with no indication anything's off.
  // See docs/ide-improvement-fitur-existing.txt BAGIAN D #29.
  if (start == null || end == null) {
    throw StateError(
      'Budget summary for $referenceMonth is missing cycle_start_date/cycle_end_date — '
      'cannot resolve the real payroll cycle.',
    );
  }
  return PayrollCycle(start: start, end: end);
});
