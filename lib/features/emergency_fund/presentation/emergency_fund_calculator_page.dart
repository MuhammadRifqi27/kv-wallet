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
import '../application/emergency_fund_controller.dart';

/// Emergency Fund Calculator — recommends an ideal nominal based on the
/// user's average monthly recorded expense. Pure calculator: reads existing
/// Summary/Savings Goal data, computes locally, never writes anything to
/// the backend by itself. See docs/plan-dev/kalkulator-dana-darurat-plan.txt.
class EmergencyFundCalculatorPage extends ConsumerStatefulWidget {
  const EmergencyFundCalculatorPage({super.key});

  @override
  ConsumerState<EmergencyFundCalculatorPage> createState() => _EmergencyFundCalculatorPageState();
}

class _EmergencyFundCalculatorPageState extends ConsumerState<EmergencyFundCalculatorPage> {
  static const _multiplierOptions = [3, 6, 9, 12];

  final _manualAverageController = TextEditingController();
  int _multiplier = 6;
  double? _manualAverage;

  @override
  void initState() {
    super.initState();
    _manualAverageController.addListener(_onManualAverageChanged);
  }

  @override
  void dispose() {
    _manualAverageController.removeListener(_onManualAverageChanged);
    _manualAverageController.dispose();
    super.dispose();
  }

  void _onManualAverageChanged() {
    final parsed = double.tryParse(_manualAverageController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final value = (parsed != null && parsed > 0) ? parsed : null;
    if (value != _manualAverage) setState(() => _manualAverage = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(emergencyFundDataProvider);
    final existingGoal = ref.watch(emergencyFundExistingGoalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.emergencyFundTitle)),
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
                    error is ApiException ? error.message : l10n.emergencyFundLoadError,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(emergencyFundDataProvider),
                    child: Text(l10n.emergencyFundRetry),
                  ),
                ],
              ),
            ),
          ),
          data: (data) {
            final average = data.isDataSufficient ? data.averageExpense : (_manualAverage ?? 0);
            final hasUsableAverage = average > 0;
            final recommendation = average * _multiplier;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (data.isDataSufficient)
                  _AverageCard(average: data.averageExpense, monthsUsed: data.monthsUsed)
                else
                  _ManualAverageInput(controller: _manualAverageController),
                const SizedBox(height: 20),
                Text(
                  l10n.emergencyFundTargetLabel,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final option in _multiplierOptions)
                      _MultiplierChip(
                        months: option,
                        selected: _multiplier == option,
                        onTap: () => setState(() => _multiplier = option),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _RecommendationCard(amount: recommendation, multiplier: _multiplier, hasUsableAverage: hasUsableAverage),
                if (existingGoal != null) ...[
                  const SizedBox(height: 16),
                  _ExistingGoalProgressCard(goal: existingGoal, recommendation: recommendation),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.emergencyFundCreateGoalButton,
                  onPressed: hasUsableAverage
                      ? () => context.push(
                            '/savings-goals/form',
                            extra: SavingsGoalDraft(
                              name: l10n.emergencyFundGoalName,
                              targetAmount: recommendation,
                              icon: 'shield-tick',
                              color: 'success',
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

class _AverageCard extends StatelessWidget {
  const _AverageCard({required this.average, required this.monthsUsed});

  final double average;
  final int monthsUsed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(l10n.emergencyFundAverageLabel, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 6),
          Text(
            formatRupiah(average),
            style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.emergencyFundAverageBasis(monthsUsed),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

/// Fallback when there's under `EmergencyFundData.minMonthsForAverage`
/// months of recorded expense — lets the calculator still be usable for a
/// brand-new account. Purely local state (see [_EmergencyFundCalculatorPageState]),
/// never sent to the backend.
class _ManualAverageInput extends StatelessWidget {
  const _ManualAverageInput({required this.controller});

  final TextEditingController controller;

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
                  l10n.emergencyFundManualHint,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: l10n.emergencyFundManualLabel,
            controller: controller,
            icon: Icons.calculate_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
          ),
        ],
      ),
    );
  }
}

class _MultiplierChip extends StatelessWidget {
  const _MultiplierChip({required this.months, required this.selected, required this.onTap});

  final int months;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          '${months}x',
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.amount, required this.multiplier, required this.hasUsableAverage});

  final double amount;
  final int multiplier;
  final bool hasUsableAverage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            l10n.emergencyFundRecommendationLabel(multiplier),
            style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          Text(
            hasUsableAverage ? formatRupiah(amount) : '—',
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 26, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ExistingGoalProgressCard extends StatelessWidget {
  const _ExistingGoalProgressCard({required this.goal, required this.recommendation});

  final SavingsGoalModel goal;
  final double recommendation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = recommendation > 0 ? (goal.savedAmount / recommendation).clamp(0, 1).toDouble() : 0.0;

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
              Icon(Icons.shield_outlined, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.emergencyFundExistingGoalProgress(goal.name),
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
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emergencyFundExistingGoalAmounts(formatRupiah(goal.savedAmount), formatRupiah(recommendation)),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
