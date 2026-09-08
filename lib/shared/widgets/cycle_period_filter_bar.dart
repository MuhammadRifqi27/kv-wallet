import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import 'filter_pill_bar.dart';
import 'month_period_selector.dart';

/// "Bulan Ini" / "Bulan Lalu" / [pick month] pill row — shared by every
/// screen keyed to a single calendar month sent to the backend as
/// `month`/`year` (Dashboard, Budget, Ringkasan). The backend applies the
/// payroll cycle itself from that month/year (see
/// docs/flutter-mobile-app-development-guide.txt — "cycle_start_date"/
/// "cycle_end_date" in those responses), so this widget only ever deals in
/// plain calendar months — no cycle math needed here. Contrast with
/// Transaksi's date-range filter, which resolves the actual cycle dates
/// itself because its API takes raw `start_date`/`end_date`, not
/// `month`/`year` (see [resolveTransactionDateRange] and
/// `payrollCycleProvider`).
class CyclePeriodFilterBar extends StatelessWidget {
  const CyclePeriodFilterBar({super.key, required this.period, required this.onChanged});

  final DateTime period;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pickCustom(BuildContext context) async {
    final picked = await pickMonthYear(context, period);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);
    final isThisMonth = period.year == thisMonth.year && period.month == thisMonth.month;
    final isLastMonth = period.year == lastMonth.year && period.month == lastMonth.month;
    final isCustom = !isThisMonth && !isLastMonth;

    return FilterPillBar(
      pills: [
        FilterPillSpec(label: 'Bulan Ini', selected: isThisMonth, onTap: () => onChanged(thisMonth)),
        FilterPillSpec(label: 'Bulan Lalu', selected: isLastMonth, onTap: () => onChanged(lastMonth)),
        FilterPillSpec(
          icon: Icons.calendar_today_outlined,
          label: isCustom ? '${monthName(period.month)} ${period.year}' : 'Pilih Bulan',
          selected: isCustom,
          onTap: () => _pickCustom(context),
        ),
      ],
    );
  }
}
