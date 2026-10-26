import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/budget_recommendation_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/cycle_period_filter_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/budget_controller.dart';

/// "Rekomendasi Budget" (docs/mobile-api-budget-recomendation.md): the server
/// suggests a budget per expense category from the last 3 cycles; the user
/// ticks which ones to apply. Only category ids are sent back — the server
/// recomputes the amounts itself.
class BudgetRecommendationPage extends ConsumerStatefulWidget {
  const BudgetRecommendationPage({super.key});

  @override
  ConsumerState<BudgetRecommendationPage> createState() => _BudgetRecommendationPageState();
}

class _BudgetRecommendationPageState extends ConsumerState<BudgetRecommendationPage> {
  /// Ticked category ids. Re-seeded whenever a new [BudgetRecommendations]
  /// arrives (period change / refresh), see [_syncSelection].
  Set<int> _selected = {};
  BudgetRecommendations? _seededFrom;
  bool _isApplying = false;

  /// Items whose suggestion equals the current budget (incl. `limited`)
  /// start unticked — applying them would change nothing.
  void _syncSelection(BudgetRecommendations data) {
    if (identical(_seededFrom, data)) return;
    _seededFrom = data;
    _selected = {
      for (final item in data.items)
        if (item.changesBudget) item.categoryId,
    };
  }

  Future<void> _apply(BudgetRecommendations data) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Keep the order of the list so what's sent mirrors what's on screen.
    final ids = [
      for (final item in data.items)
        if (_selected.contains(item.categoryId)) item.categoryId,
    ];
    if (ids.isEmpty) return;

    setState(() => _isApplying = true);
    try {
      final saved = await ref.read(budgetControllerProvider.notifier).applyRecommendations(ids);
      if (!mounted) return;
      // `saved` can be lower than what was sent (ids without a suggestion
      // are skipped silently by the server) — say so rather than imply all.
      if (saved == 0) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.brcAppliedNone)));
        ref.invalidate(budgetRecommendationsProvider);
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(saved < ids.length ? l10n.brcAppliedPartial(saved, ids.length) : l10n.brcApplied(saved))),
      );
      context.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final period = ref.watch(selectedBudgetPeriodProvider);
    final async = ref.watch(budgetRecommendationsProvider);
    final data = async.valueOrNull;
    if (data != null) _syncSelection(data);

    Future<void> refresh() async {
      try {
        ref.invalidate(budgetRecommendationsProvider);
        await ref.read(budgetRecommendationsProvider.future);
      } catch (_) {
        // Error state is rendered from `async`.
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.brcTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CyclePeriodFilterBar(
                period: period,
                onChanged: (value) => ref.read(selectedBudgetPeriodProvider.notifier).state = value,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: refresh,
              child: async.when(
                loading: () => scrollableCenter(const AppLoadingIndicator()),
                error: (error, _) => scrollableCenter(
                  ListErrorState(message: error is ApiException ? error.message : l10n.brcLoadError, onRetry: refresh),
                ),
                data: (recommendations) {
                  if (recommendations.items.isEmpty) {
                    return scrollableCenter(
                      ListEmptyState(
                        icon: Icons.lightbulb_outline_rounded,
                        title: l10n.brcEmptyTitle,
                        subtitle: l10n.brcEmptySubtitle(recommendations.cycles),
                      ),
                    );
                  }
                  return _buildList(recommendations);
                },
              ),
            ),
          ),
          if (data != null && data.items.isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: PrimaryButton(
                  label: l10n.brcApplyButton(_selected.length),
                  isLoading: _isApplying,
                  onPressed: _selected.isEmpty ? null : () => _apply(data),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(BudgetRecommendations data) {
    final l10n = AppLocalizations.of(context);
    final allSelected = _selected.length == data.items.length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        _BasisCard(data: data),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.brcSelectedCount(_selected.length, data.items.length),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
            ),
            TextButton(
              onPressed: _isApplying
                  ? null
                  : () => setState(() {
                        _selected = allSelected ? {} : {for (final item in data.items) item.categoryId};
                      }),
              child: Text(allSelected ? l10n.brcDeselectAll : l10n.brcSelectAll),
            ),
          ],
        ),
        for (final item in data.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RecommendationCard(
              item: item,
              selected: _selected.contains(item.categoryId),
              enabled: !_isApplying,
              onChanged: (checked) => setState(() {
                if (checked) {
                  _selected.add(item.categoryId);
                } else {
                  _selected.remove(item.categoryId);
                }
              }),
            ),
          ),
      ],
    );
  }
}

/// Explains how the suggestions were computed (`basis`), per the doc's
/// "teks penjelasan di UI" guidance.
class _BasisCard extends StatelessWidget {
  const _BasisCard({required this.data});

  final BudgetRecommendations data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNominal = data.basis == RecommendationBasis.nominal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNominal ? AppColors.accent.withValues(alpha: 0.12) : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isNominal ? Icons.info_outline_rounded : Icons.auto_awesome_rounded,
            size: 18,
            color: isNominal ? AppColors.accent : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isNominal
                  ? l10n.brcBasisNominal(data.cycles)
                  : l10n.brcBasisPercentage(formatRupiah(data.incomePool), data.cycles),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final BudgetRecommendationItem item;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    // Suggestion identical to the current budget: shown dimmed.
    final dimmed = !item.changesBudget;

    return Opacity(
      opacity: dimmed && !selected ? 0.6 : 1,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? () => onChanged(!selected) : null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  activeColor: AppColors.primary,
                  onChanged: enabled ? (value) => onChanged(value ?? false) : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.categoryName,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            item.hasCurrentBudget ? formatRupiah(item.currentBudget) : l10n.brcNoBudgetYet,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textSecondary),
                          ),
                          Text(
                            formatRupiah(item.suggestedBudget),
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary),
                          ),
                          if (item.suggestedPercent != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(${_percent(item.suggestedPercent!, locale)})',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.brcAverageSpent(formatRupiah(item.averageSpent), _percent(item.sharePercent, locale)),
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                      ),
                      if (item.limited) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.accent),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  l10n.brcLimitedNote(item.overspentCycles),
                                  style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Server percentages are plain numbers (`13.5` = 13,5%); shown as-is,
  /// trimmed to at most 1 decimal.
  static String _percent(double value, Locale locale) {
    var text = value.toStringAsFixed(1);
    if (text.endsWith('.0')) text = text.substring(0, text.length - 2);
    if (locale.languageCode != 'en') text = text.replaceAll('.', ',');
    return '$text%';
  }
}
