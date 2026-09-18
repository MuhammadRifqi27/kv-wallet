import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/fire_calculator_controller.dart';

/// Pensiun/FIRE Calculator — projects years-to-financial-independence from
/// the user's recorded income/expense (savings rate) and current net
/// worth, using the standard 4% rule for the target amount. Pure
/// calculator like EmergencyFundCalculatorPage: reads existing Summary/
/// Savings Goal data, computes locally, never writes to the backend by
/// itself. See docs/plan-dev/kalkulator-pensiun-fire-plan.txt.
class FireCalculatorPage extends ConsumerStatefulWidget {
  const FireCalculatorPage({super.key});

  @override
  ConsumerState<FireCalculatorPage> createState() => _FireCalculatorPageState();
}

class _FireCalculatorPageState extends ConsumerState<FireCalculatorPage> {
  static const _returnRateOptions = [0.04, 0.06, 0.08];

  final _manualIncomeController = TextEditingController();
  final _manualExpenseController = TextEditingController();
  double _returnRate = 0.06;
  double? _manualIncome;
  double? _manualExpense;

  @override
  void initState() {
    super.initState();
    _manualIncomeController.addListener(_onManualIncomeChanged);
    _manualExpenseController.addListener(_onManualExpenseChanged);
  }

  @override
  void dispose() {
    _manualIncomeController.removeListener(_onManualIncomeChanged);
    _manualExpenseController.removeListener(_onManualExpenseChanged);
    _manualIncomeController.dispose();
    _manualExpenseController.dispose();
    super.dispose();
  }

  void _onManualIncomeChanged() {
    final parsed = double.tryParse(_manualIncomeController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final value = (parsed != null && parsed > 0) ? parsed : null;
    if (value != _manualIncome) setState(() => _manualIncome = value);
  }

  void _onManualExpenseChanged() {
    final parsed = double.tryParse(_manualExpenseController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final value = (parsed != null && parsed > 0) ? parsed : null;
    if (value != _manualExpense) setState(() => _manualExpense = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(retirementDataProvider);
    final existingGoal = ref.watch(fireExistingGoalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.fireTitle)),
      body: SafeArea(
        child: dataAsync.when(
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error is ApiException ? error.message : l10n.fireLoadError,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(retirementDataProvider),
                    child: Text(l10n.fireRetry),
                  ),
                ],
              ),
            ),
          ),
          data: (data) {
            final monthlyIncome = data.isDataSufficient ? data.averageMonthlyIncome : (_manualIncome ?? 0);
            final monthlyExpense = data.isDataSufficient ? data.averageMonthlyExpense : (_manualExpense ?? 0);
            final hasUsableData = monthlyExpense > 0 && monthlyIncome > 0;
            final projection = hasUsableData
                ? projectFire(
                    currentNetWorth: data.currentNetWorth,
                    annualSavings: (monthlyIncome - monthlyExpense) * 12,
                    annualExpense: monthlyExpense * 12,
                    annualReturnRate: _returnRate,
                  )
                : null;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (data.isDataSufficient)
                  _DataCard(data: data)
                else
                  _ManualDataInput(incomeController: _manualIncomeController, expenseController: _manualExpenseController),
                const SizedBox(height: 20),
                Text(
                  l10n.fireReturnRateLabel,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final option in _returnRateOptions)
                      _ReturnRateChip(
                        rate: option,
                        selected: _returnRate == option,
                        onTap: () => setState(() => _returnRate = option),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _ProjectionCard(projection: projection),
                if (existingGoal != null && projection != null) ...[
                  const SizedBox(height: 16),
                  _ExistingGoalProgressCard(goal: existingGoal, target: projection.targetAmount),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.fireCreateGoalButton,
                  onPressed: projection != null
                      ? () => context.push(
                            '/savings-goals/form',
                            extra: SavingsGoalDraft(
                              name: l10n.fireGoalName,
                              targetAmount: projection.targetAmount,
                              icon: 'savings',
                              color: 'info',
                            ),
                          )
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.data});

  final RetirementData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final savingsRateColor = data.savingsRatePercent >= 0 ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: l10n.fireAverageIncomeLabel,
                  value: formatRupiah(data.averageMonthlyIncome),
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: l10n.fireAverageExpenseLabel,
                  value: formatRupiah(data.averageMonthlyExpense),
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.fireSavingsRateLabel,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ),
              Text(
                '${data.savingsRatePercent.toStringAsFixed(0)}%',
                style: TextStyle(color: savingsRateColor, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.fireAverageBasis(data.monthsUsed),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}

/// Fallback when there's under `RetirementData.minMonthsForAverage` months
/// of recorded income/expense — same reasoning as EmergencyFundCalculatorPage's
/// `_ManualAverageInput`, but needs both income and expense here since the
/// projection depends on the gap between them. Purely local state, never
/// sent to the backend.
class _ManualDataInput extends StatelessWidget {
  const _ManualDataInput({required this.incomeController, required this.expenseController});

  final TextEditingController incomeController;
  final TextEditingController expenseController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.fireManualHint,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: l10n.fireManualIncomeLabel,
            controller: incomeController,
            icon: Icons.trending_up_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: l10n.fireManualExpenseLabel,
            controller: expenseController,
            icon: Icons.trending_down_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
          ),
        ],
      ),
    );
  }
}

class _ReturnRateChip extends StatelessWidget {
  const _ReturnRateChip({required this.rate, required this.selected, required this.onTap});

  final double rate;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (rate) {
      0.04 => l10n.fireReturnRateConservative,
      0.08 => l10n.fireReturnRateAggressive,
      _ => l10n.fireReturnRateModerate,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          '$label (${(rate * 100).toStringAsFixed(0)}%)',
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  const _ProjectionCard({required this.projection});

  final FireProjection? projection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.fireProjectionLabel,
            style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          Text(
            projection == null
                ? '—'
                : (projection!.reachable
                    ? l10n.fireYearsToGo(projection!.years)
                    : l10n.fireNotReachableWithinCap(projectionCapYears)),
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          if (projection != null) ...[
            const SizedBox(height: 6),
            Text(
              projection!.reachable
                  ? l10n.fireTargetYear(now.year + projection!.years, formatRupiah(projection!.targetAmount))
                  : l10n.fireTargetAmountOnly(formatRupiah(projection!.targetAmount)),
              style: TextStyle(
                color: AppColors.primaryDark.withValues(alpha: 0.65),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExistingGoalProgressCard extends StatelessWidget {
  const _ExistingGoalProgressCard({required this.goal, required this.target});

  final SavingsGoalModel goal;
  final double target;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = target > 0 ? (goal.savedAmount / target).clamp(0, 1).toDouble() : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings_outlined, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.fireExistingGoalProgress(goal.name),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fireExistingGoalAmounts(formatRupiah(goal.savedAmount), formatRupiah(target)),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
