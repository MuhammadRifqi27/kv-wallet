import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/named_amount.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/cycle_period_filter_bar.dart';
import '../../auth/application/auth_controller.dart';
import '../../../shared/widgets/list_states.dart';
import '../../savings_goals/application/savings_goal_controller.dart';
import '../../savings_goals/presentation/savings_goal_style.dart';
import '../../tour/application/tour_controller.dart';
import '../application/dashboard_controller.dart';

/// Whether nominal amounts on the dashboard are hidden behind a mask.
/// Page-local UI state, not part of [dashboardControllerProvider]'s data.
final hideNominalProvider = StateProvider<bool>((ref) => false);

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final hideNominal = ref.watch(hideNominalProvider);
    final selectedPeriod = ref.watch(selectedDashboardPeriodProvider);
    final l10n = AppLocalizations.of(context);
    // Kept alive inside MainShell's IndexedStack, so it's never naturally
    // rebuilt by Flutter's parent-cascade when the theme is toggled from
    // the Profile branch — see AppColors' class doc + MainShell's note.
    ref.watch(themeModeProvider);

    // Safe to call on every build — TourController's own session guard
    // makes sure this only actually starts the tour once, the first time
    // dashboard data is available. See docs/plan-dev/onboarding-tour-plan.txt.
    if (dashboardAsync.hasValue) {
      ref.read(tourControllerProvider).maybeAutoStart();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/branding/logo_mark.png',
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Flowr'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: CyclePeriodFilterBar(
              period: selectedPeriod ?? DateTime.now(),
              onChanged: (value) {
                final now = DateTime.now();
                // Picking the actual current month resets to null ("current
                // payroll cycle") instead of pinning an explicit month/year —
                // keeps the original default behavior for anyone who taps
                // back to "Bulan Ini" instead of leaving a redundant explicit
                // selection sitting in state.
                final isCurrentCycle =
                    value.year == now.year && value.month == now.month;
                ref.read(selectedDashboardPeriodProvider.notifier).state =
                    isCurrentCycle ? null : value;
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refresh,
              child: dashboardAsync.when(
                loading: () => scrollableCenter(const AppLoadingIndicator()),
                error: (error, _) => scrollableCenter(
                  ListErrorState(
                    message: error is ApiException
                        ? error.message
                        : l10n.walletDashboardLoadError,
                    onRetry: controller.refresh,
                  ),
                ),
                data: (dashboard) => _DashboardBody(
                  dashboard: dashboard,
                  hideNominal: hideNominal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.dashboard, required this.hideNominal});

  final DashboardModel dashboard;
  final bool hideNominal;

  List<DashboardPortfolioItem> get _dailyAccounts =>
      dashboard.portfolios.where((p) => !p.isInvestment).toList();

  List<DashboardPortfolioItem> get _investmentAccounts =>
      dashboard.portfolios.where((p) => p.isInvestment).toList();

  @override
  Widget build(BuildContext context) {
    final cycleStart = dashboard.cycleStartDate;
    final cycleEnd = dashboard.cycleEndDate;
    final l10n = AppLocalizations.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Showcase(
          key: tourNetWorthCardKey,
          title: l10n.tourNetWorthTitle,
          description: l10n.tourNetWorthDescription,
          tooltipBackgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
          targetBorderRadius: BorderRadius.circular(20),
          child: _NetWorthCard(
            amount: dashboard.totalNetWorth,
            cycleStart: cycleStart,
            cycleEnd: cycleEnd,
          ),
        ),
        const SizedBox(height: 12),
        Showcase(
          key: tourStatsGridKey,
          title: l10n.tourStatsTitle,
          description: l10n.tourStatsDescription,
          tooltipBackgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
          targetBorderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.payments_outlined,
                      label: l10n.walletDashboardCashBalanceLabel,
                      value: maskRupiah(
                        dashboard.totalLiquidCash,
                        hide: hideNominal,
                      ),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.trending_up_rounded,
                      label: l10n.walletDashboardInvestmentBalanceLabel,
                      value: maskRupiah(
                        dashboard.totalInvestmentValue,
                        hide: hideNominal,
                      ),
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.arrow_downward_rounded,
                      label: l10n.walletDashboardIncomeLabel,
                      value: maskRupiah(
                        dashboard.incomePool,
                        hide: hideNominal,
                      ),
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.arrow_upward_rounded,
                      label: l10n.walletDashboardExpenseLabel,
                      value: maskRupiah(
                        dashboard.monthlyExpense,
                        hide: hideNominal,
                      ),
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Showcase(
          key: tourSavingsGoalsCardKey,
          title: l10n.tourSavingsGoalsTitle,
          description: l10n.tourSavingsGoalsDescription,
          tooltipBackgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
          targetBorderRadius: BorderRadius.circular(14),
          child: _SavingsGoalsCard(hideNominal: hideNominal),
        ),
        // One consolidated prompt when there's truly nothing anywhere below
        // (a brand-new account), rather than each of the 5 sections below
        // just silently vanishing with zero guidance. Deliberately NOT a
        // separate empty-state block per section (accounts/income/top
        // categories/recent transactions) — for an ESTABLISHED user who
        // simply hasn't touched one particular section yet (e.g. no
        // investment accounts, but plenty of transactions), stacking
        // multiple "nothing here" cards among real data would be more
        // clutter than help; that case is left as a silent omission like
        // before. See docs/ide-improvement-fitur-existing.txt BAGIAN E #30.
        if (dashboard.portfolios.isEmpty &&
            dashboard.incomeBreakdown.isEmpty &&
            dashboard.topExpenses.isEmpty &&
            dashboard.recentTransactions.isEmpty) ...[
          const SizedBox(height: 24),
          const _DashboardEmptyState(),
        ],
        if (_dailyAccounts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.walletDashboardDailyAccountsTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final portfolio in _dailyAccounts) ...[
            _AccountTile(portfolio: portfolio, hideNominal: hideNominal),
            const SizedBox(height: 8),
          ],
        ],
        if (_investmentAccounts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.walletDashboardInvestmentAccountsTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final portfolio in _investmentAccounts) ...[
            _AccountTile(portfolio: portfolio, hideNominal: hideNominal),
            const SizedBox(height: 8),
          ],
        ],
        if (dashboard.incomeBreakdown.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.walletDashboardIncomeSourcesTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _NamedAmountCard(
            items: dashboard.incomeBreakdown,
            hideNominal: hideNominal,
          ),
        ],
        if (dashboard.topExpenses.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.walletDashboardTopCategoriesTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _NamedAmountCard(
            items: dashboard.topExpenses,
            hideNominal: hideNominal,
          ),
        ],
        if (dashboard.recentTransactions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.walletDashboardRecentTransactionsTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final transaction in dashboard.recentTransactions) ...[
            _RecentTransactionTile(
              transaction: transaction,
              hideNominal: hideNominal,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

/// See the "consolidated empty state" comment at its call site in
/// `_DashboardBody.build` above — docs/ide-improvement-fitur-existing.txt
/// BAGIAN E #30.
class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.walletDashboardEmptyTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.walletDashboardEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('/transactions/form'),
            child: Text(l10n.walletDashboardEmptyCta),
          ),
        ],
      ),
    );
  }
}

/// Which contextual greeting `_NetWorthCard` should show — time-of-day by
/// default, overridden by a payroll-cycle "moment" when one applies (see
/// [_resolveGreetingMoment]). Item #228,
/// docs/ide-pengembangan-100.txt BAGIAN P.
enum _GreetingMoment { payday, endingSoon, morning, midday, afternoon, night }

/// [cycleStart]/[cycleEnd] take priority over time-of-day: today being the
/// very first day of the payroll cycle reads as "gajian" (payday), and the
/// last 3 days of the cycle (today + 2 days out) read as "gajian sebentar
/// lagi" (next payday coming up) — both more useful context on this card
/// than just the hour. Falls back to plain time-of-day (pagi/siang/sore/
/// malam) the rest of the cycle, or always if cycle dates aren't loaded yet.
_GreetingMoment _resolveGreetingMoment(
  DateTime now,
  DateTime? cycleStart,
  DateTime? cycleEnd,
) {
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  if (cycleStart != null && isSameDay(now, cycleStart)) {
    return _GreetingMoment.payday;
  }
  if (cycleEnd != null) {
    final today = DateTime(now.year, now.month, now.day);
    final endDay = DateTime(cycleEnd.year, cycleEnd.month, cycleEnd.day);
    final daysUntilEnd = endDay.difference(today).inDays;
    if (daysUntilEnd >= 0 && daysUntilEnd <= 2) {
      return _GreetingMoment.endingSoon;
    }
  }

  final hour = now.hour;
  if (hour >= 4 && hour < 11) return _GreetingMoment.morning;
  if (hour >= 11 && hour < 15) return _GreetingMoment.midday;
  if (hour >= 15 && hour < 18) return _GreetingMoment.afternoon;
  return _GreetingMoment.night;
}

String _greetingFor(
  AppLocalizations l10n,
  _GreetingMoment moment,
  String name,
) {
  switch (moment) {
    case _GreetingMoment.payday:
      return l10n.walletDashboardGreetingPayday(name);
    case _GreetingMoment.endingSoon:
      return l10n.walletDashboardGreetingEndingSoon(name);
    case _GreetingMoment.morning:
      return l10n.walletDashboardGreetingMorning(name);
    case _GreetingMoment.midday:
      return l10n.walletDashboardGreetingMidday(name);
    case _GreetingMoment.afternoon:
      return l10n.walletDashboardGreetingAfternoon(name);
    case _GreetingMoment.night:
      return l10n.walletDashboardGreetingNight(name);
  }
}

class _NetWorthCard extends ConsumerWidget {
  const _NetWorthCard({required this.amount, this.cycleStart, this.cycleEnd});

  final double amount;
  final DateTime? cycleStart;
  final DateTime? cycleEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideNominal = ref.watch(hideNominalProvider);
    final userName = ref.watch(authControllerProvider).user?.name;
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
            _greetingFor(
              l10n,
              _resolveGreetingMoment(DateTime.now(), cycleStart, cycleEnd),
              userName ?? '',
            ),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (cycleStart != null && cycleEnd != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.walletDashboardCycleRange(
                formatLocalizedDate(
                  cycleStart!,
                  Localizations.localeOf(context),
                ),
                formatLocalizedDate(cycleEnd!, Localizations.localeOf(context)),
              ),
              style: TextStyle(
                color: AppColors.primaryDark.withValues(alpha: 0.65),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.walletDashboardNetWorthLabel,
            style: TextStyle(
              color: AppColors.primaryDark.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                maskRupiah(amount, hide: hideNominal),
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: hideNominal
                    ? l10n.walletDashboardToggleNominalShow
                    : l10n.walletDashboardToggleNominalHide,
                child: Semantics(
                  button: true,
                  label: hideNominal
                      ? l10n.walletDashboardToggleNominalShow
                      : l10n.walletDashboardToggleNominalHide,
                  child: InkWell(
                    onTap: () => ref.read(hideNominalProvider.notifier).state =
                        !hideNominal,
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: Icon(
                          hideNominal
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.primaryDark.withValues(alpha: 0.65),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shortcut into Savings Goals (off the bottom-nav shell, see
/// routing/app_router.dart) — highlights whichever active goal is closest
/// to its target so the card isn't just a bare counter. Fetches its own
/// summary independently of [DashboardModel]/[dashboardControllerProvider]
/// rather than folding savings goals into the dashboard endpoint's shape.
class _SavingsGoalsCard extends ConsumerWidget {
  const _SavingsGoalsCard({required this.hideNominal});

  final bool hideNominal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(savingsGoalControllerProvider);
    // Still renders nothing either way — a secondary card failing
    // shouldn't break the primary Dashboard — but a genuine fetch failure
    // is now at least distinguishable from "no goals yet" in debug logs,
    // instead of both silently collapsing to the exact same
    // SizedBox.shrink(). See
    // docs/ide-improvement-fitur-existing.txt BAGIAN E #35.
    if (summaryAsync.hasError && kDebugMode) {
      debugPrint(
        '[_SavingsGoalsCard] failed to load savings goals: ${summaryAsync.error}',
      );
    }
    final summary = summaryAsync.valueOrNull;
    if (summary == null || summary.goals.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeGoals =
        summary.goals
            .where((g) => g.status == SavingsGoalStatus.active)
            .toList()
          ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
    final highlight = activeGoals.isNotEmpty
        ? activeGoals.first
        : summary.goals.first;
    final color = savingsGoalColorFor(highlight.color);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      // MergeSemantics — without it a screen reader steps through each
      // descendant Text as a separate stop instead of announcing this
      // whole tappable card as one "go to Savings Goals" button. See
      // docs/ide-improvement-fitur-existing.txt BAGIAN I #49.
      child: MergeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/savings-goals'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.walletDashboardSavingsGoalsCardTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      l10n.walletDashboardSavingsGoalsSummary(
                        summary.activeCount,
                        summary.achievedCount,
                      ),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  highlight.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: highlight.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.background,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.walletDashboardSavingsGoalProgress(
                    maskRupiah(highlight.savedAmount, hide: hideNominal),
                    maskRupiah(highlight.targetAmount, hide: hideNominal),
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.portfolio, required this.hideNominal});

  final DashboardPortfolioItem portfolio;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              portfolio.isInvestment
                  ? Icons.trending_up_rounded
                  : Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolio.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                if (portfolio.investmentCode != null)
                  Text(
                    portfolio.investmentCode!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            maskRupiah(portfolio.balance, hide: hideNominal),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared bar-list layout for "Sumber Pemasukan" (incomeBreakdown) and
/// "Kategori Terbesar" (topExpenses) — both are just a list of {name, amount}.
class _NamedAmountCard extends StatelessWidget {
  const _NamedAmountCard({required this.items, required this.hideNominal});

  final List<NamedAmount> items;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    final maxAmount = items
        .map((c) => c.amount)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _AmountBar(
              item: items[i],
              maxAmount: maxAmount,
              hideNominal: hideNominal,
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountBar extends StatelessWidget {
  const _AmountBar({
    required this.item,
    required this.maxAmount,
    required this.hideNominal,
  });

  final NamedAmount item;
  final double maxAmount;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    final fraction = maxAmount > 0
        ? (item.amount / maxAmount).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              maskRupiah(item.amount, hide: hideNominal),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(color: AppColors.background),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({
    required this.transaction,
    required this.hideNominal,
  });

  final RecentTransactionItem transaction;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.categoryName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  [
                    formatLocalizedDateShort(
                      transaction.date,
                      Localizations.localeOf(context),
                    ),
                    if (transaction.portfolioName != null)
                      transaction.portfolioName!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            hideNominal
                ? maskRupiah(transaction.amount, hide: true)
                : '${transaction.isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
