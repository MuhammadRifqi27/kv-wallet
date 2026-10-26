import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/report_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/report_controller.dart';
import 'report_common.dart';

class TaxTab extends ConsumerWidget {
  const TaxTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final async = ref.watch(taxReportControllerProvider);
    final report = async.valueOrNull;

    return ReportTabView(
      value: async,
      onRefresh: () => ref.read(taxReportControllerProvider.notifier).refresh(),
      header: ReportYearStepper(rangeText: report == null ? null : formatCycleRange(report.start, report.end, locale)),
      builder: (data) => [
        // This is a recap, not a tax calculation — must stay visible (docs §3).
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.rptTaxDisclaimer, style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ReportCard(
          child: Column(
            children: [
              ReportRow(label: l10n.rptTaxTotalIncome, value: formatRupiah(data.totalIncome)),
              ReportRow(
                label: l10n.rptTaxTotalDeductible,
                value: '-${formatRupiah(data.totalDeductible)}',
                valueColor: AppColors.error,
              ),
              Divider(color: AppColors.border),
              ReportRow(label: l10n.rptTaxAfter, value: formatRupiah(data.incomeAfterDeductions), bold: true),
            ],
          ),
        ),
        ReportSectionTitle(l10n.rptTaxDeductibleList),
        if (data.deductibleCategories.isEmpty)
          Text(l10n.rptTaxNoDeductible, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
        else
          for (final category in data.deductibleCategories)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReportCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      formatRupiah(category.spent),
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
        ReportSectionTitle(l10n.rptTaxCategoriesTitle),
        Text(l10n.rptTaxCategoriesHint, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 10),
        // Keyed on the year so switching years resets the local selection.
        _TaxChecklist(key: ValueKey('tax-${data.year}-${data.categories.map((c) => '${c.id}${c.deductible}').join()}'), report: data),
      ],
    );
  }
}

/// Local draft of the checklist. Check state is initialised from
/// `categories[].deductible` (NOT `deductible_categories`); saving sends the
/// FULL id list since the endpoint overwrites the previous selection.
class _TaxChecklist extends ConsumerStatefulWidget {
  const _TaxChecklist({super.key, required this.report});

  final TaxReport report;

  @override
  ConsumerState<_TaxChecklist> createState() => _TaxChecklistState();
}

class _TaxChecklistState extends ConsumerState<_TaxChecklist> {
  late final Set<int> _selected = {
    for (final category in widget.report.categories)
      if (category.deductible) category.id,
  };
  bool _isSaving = false;

  Set<int> get _saved => {
        for (final category in widget.report.categories)
          if (category.deductible) category.id,
      };

  bool get _dirty {
    final saved = _saved;
    return saved.length != _selected.length || !saved.containsAll(_selected);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);
    try {
      await ref.read(taxReportControllerProvider.notifier).saveCategories(_selected.toList());
      messenger.showSnackBar(SnackBar(content: Text(l10n.rptTaxSaved)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = widget.report.categories;

    if (categories.isEmpty) {
      return Text(l10n.rptTaxNoCategories, style: TextStyle(color: AppColors.textSecondary, fontSize: 13));
    }

    return Column(
      children: [
        for (final category in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: CheckboxListTile(
                value: _selected.contains(category.id),
                onChanged: _isSaving
                    ? null
                    : (checked) => setState(() {
                          if (checked ?? false) {
                            _selected.add(category.id);
                          } else {
                            _selected.remove(category.id);
                          }
                        }),
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  category.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  formatRupiah(category.spent),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        PrimaryButton(label: l10n.rptTaxSave, isLoading: _isSaving, onPressed: _dirty ? _save : null),
      ],
    );
  }
}
