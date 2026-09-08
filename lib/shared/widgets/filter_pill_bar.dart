import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// One chip's data — the bar itself is purely presentational, so each
/// caller decides what "selected" means and what happens on tap (set a
/// value directly, or open a picker and set state from its result).
class FilterPillSpec {
  const FilterPillSpec({required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
}

/// Horizontal row of tappable pill chips — shared visual language for every
/// "filter by period/type/whatever" bar in the app (date-range shortcuts on
/// Transaksi, month-cycle shortcuts on Dashboard/Budget/Ringkasan, the
/// income/expense/all toggle on Transaksi). Scrolls horizontally so it
/// doesn't need to fit every option on screen at once.
class FilterPillBar extends StatelessWidget {
  const FilterPillBar({super.key, required this.pills});

  final List<FilterPillSpec> pills;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pills.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => _Pill(spec: pills[index]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.spec});

  final FilterPillSpec spec;

  @override
  Widget build(BuildContext context) {
    final selected = spec.selected;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: spec.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spec.icon != null) ...[
              Icon(spec.icon, size: 13, color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              spec.label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
