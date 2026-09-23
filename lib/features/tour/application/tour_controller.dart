import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/providers/core_providers.dart';
import '../../../routing/app_router.dart';
import '../../auth/application/auth_controller.dart';
import '../../savings_goals/application/savings_goal_controller.dart';

// Dashboard targets (lib/features/dashboard/presentation/dashboard_page.dart).
final tourNetWorthCardKey = GlobalKey(debugLabel: 'tourNetWorthCard');
final tourStatsGridKey = GlobalKey(debugLabel: 'tourStatsGrid');
final tourSavingsGoalsCardKey = GlobalKey(debugLabel: 'tourSavingsGoalsCard');

// Bottom-nav targets (lib/routing/main_shell.dart).
final tourNavDashboardKey = GlobalKey(debugLabel: 'tourNavDashboard');
final tourNavTransactionsKey = GlobalKey(debugLabel: 'tourNavTransactions');
final tourNavSummaryKey = GlobalKey(debugLabel: 'tourNavSummary');
final tourNavBudgetsKey = GlobalKey(debugLabel: 'tourNavBudgets');
final tourNavProfileKey = GlobalKey(debugLabel: 'tourNavProfile');

// Profile-page targets (lib/features/profile/presentation/profile_page.dart)
// — "gelombang 2", see maybeAutoStart's class doc.
final tourPayrollTileKey = GlobalKey(debugLabel: 'tourPayrollTile');
final tourPortfolioTileKey = GlobalKey(debugLabel: 'tourPortfolioTile');

/// Nav tour key per permission — mirrors main_shell.dart's `_navItems`
/// permission set/order exactly, so a locked tab can be filtered out of the
/// tour the same way `MainShell._isAllowed` decides whether to show the
/// lock badge.
final Map<String, GlobalKey> _navTourKeysByPermission = {
  'dashboard': tourNavDashboardKey,
  'transactions': tourNavTransactionsKey,
  'summary': tourNavSummaryKey,
  'budgets': tourNavBudgetsKey,
  'settings': tourNavProfileKey,
};

/// Which "gelombang" (wave) is currently in flight — drives [TourController]'s
/// `onFinish` handler. Using a state flag instead of matching a specific key
/// in `onComplete` is deliberate: `skipIfTargetNotPresent: true` means a step
/// can be silently SKIPPED rather than "completed" (e.g. if the Profile nav
/// icon somehow isn't found in time), and a skip never fires `onComplete` for
/// that key — matching on `onFinish` (which fires once the whole queue passed
/// to `startShowCase` is exhausted, skipped-or-not) is immune to that.
enum _TourWave { none, wave1, wave2 }

/// Orchestrates the interactive feature tour — see
/// docs/plan-dev/onboarding-tour-plan.txt for the full design.
///
/// The tour runs in 2 "gelombang" (waves): gelombang 1 covers the Dashboard
/// (Net Worth card, stats, Savings Goals card) plus every unlocked
/// bottom-nav icon, none of which need any navigation between them since
/// `MainShell`'s `NavigationBar` is always painted regardless of the active
/// tab (see main_shell.dart). Gelombang 2 covers the Payroll and Portfolio
/// tiles on the Profile page — those only exist in the widget tree while
/// the Profile branch is the active tab, so finishing gelombang 1's last
/// step (the Profile nav icon) triggers a `context.go('/profile')`-style
/// navigation before gelombang 2 starts.
class TourController {
  TourController(this._ref) {
    ShowcaseView.register(
      enableAutoScroll: true,
      // Defensive safety net — if any target key is ever not actually
      // rendered when its turn comes up (the exact bug that made the
      // Dashboard nav icon step freeze the tour, see main_shell.dart's
      // _buildDestination), skip it instead of getting stuck.
      skipIfTargetNotPresent: true,
      onStart: (index, key) => _log('onStart', index, key),
      onComplete: (index, key) => _log('onComplete', index, key),
      // Dismissed (barrier tap / swipe away) mid-tour never fires onFinish,
      // so without this the wave flag would stay stuck at whatever it was —
      // harmless in practice (the next startManually()/maybeAutoStart()
      // call resets it anyway) but reset explicitly for cleanliness.
      onDismiss: (key) {
        _log('onDismiss', null, key);
        _currentWave = _TourWave.none;
      },
      onFinish: () {
        _log('onFinish (wave was $_currentWave)', null, null);
        if (_currentWave != _TourWave.wave1) {
          _currentWave = _TourWave.none;
          return;
        }
        _startWave2();
      },
    );
  }

  final Ref _ref;

  /// Guards [maybeAutoStart] against re-triggering on every DashboardPage
  /// rebuild — a plain field is enough since this controller (via its
  /// Provider) lives for the whole app session, no separate StateProvider
  /// needed just to remember "already handled this session".
  bool _autoHandledThisSession = false;

  _TourWave _currentWave = _TourWave.none;

  /// `key` prints via its `debugLabel` (e.g. "tourNavProfile") since every
  /// tour target key is created with one (see the GlobalKey constants
  /// above) — makes `flutter run` logs immediately readable for diagnosing
  /// exactly which step ran/skipped, instead of an opaque hash.
  static void _log(String event, int? index, GlobalKey? key) {
    if (!kDebugMode) return;
    debugPrint('[TourController] $event index=$index key=$key');
  }

  List<GlobalKey> _wave1Keys() {
    final user = _ref.read(authControllerProvider).user;
    final savingsGoals = _ref.read(savingsGoalControllerProvider).valueOrNull;
    final hasSavingsGoals = savingsGoals != null && savingsGoals.goals.isNotEmpty;

    return [
      tourNetWorthCardKey,
      tourStatsGridKey,
      if (hasSavingsGoals) tourSavingsGoalsCardKey,
      for (final entry in _navTourKeysByPermission.entries)
        if (user?.hasPermission(entry.key) ?? false) entry.value,
    ];
  }

  /// [savingsGoalControllerProvider] loads independently of
  /// [dashboardControllerProvider] (fetched separately by
  /// `_SavingsGoalsCard` itself), so it can still be mid-flight right when
  /// the dashboard finishes loading and the tour is about to start — without
  /// this wait, `_wave1Keys()` would just read a `null` `valueOrNull` and
  /// silently drop the Savings Goals step for a user who actually has goals,
  /// purely because of which of the two requests happened to answer first.
  /// Bounded so a slow/failed request can never hang the tour.
  Future<void> _startWave1() async {
    _currentWave = _TourWave.wave1;
    if (_ref.read(savingsGoalControllerProvider).isLoading) {
      try {
        await _ref.read(savingsGoalControllerProvider.future).timeout(const Duration(seconds: 3));
      } catch (_) {
        // Ignored — _wave1Keys() below treats "still no data" as "no goals
        // to showcase", same as a genuinely empty list.
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowcaseView.get().startShowCase(_wave1Keys());
    });
  }

  /// Navigates to Profile first, then — after a full extra frame plus a
  /// short fixed delay (belt-and-suspenders: `StatefulShellRoute` branch
  /// switches are instant with no transition animation to wait out, but the
  /// delay costs nothing and guards against any layout not having settled
  /// yet) — starts gelombang 2. Both steps are deferred with
  /// `addPostFrameCallback` rather than run synchronously inside the
  /// `onFinish` callback, since that callback itself fires while
  /// ShowcaseView is still tearing down gelombang 1's overlay.
  void _startWave2() {
    _currentWave = _TourWave.wave2;
    _ref.read(appRouterProvider).go('/profile');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowcaseView.get().startShowCase(
        [tourPayrollTileKey, tourPortfolioTileKey],
        delay: const Duration(milliseconds: 250),
      );
    });
  }

  /// Called from DashboardPage once dashboard data has loaded. Safe to call
  /// on every build — only the first call (per app session) that also finds
  /// [TourService.hasSeenTour] false actually starts the tour.
  Future<void> maybeAutoStart() async {
    if (_autoHandledThisSession) return;
    _autoHandledThisSession = true;

    final service = _ref.read(tourServiceProvider);
    if (await service.hasSeenTour()) return;
    await service.markSeen();

    await _startWave1();
  }

  /// "Lihat Tour Fitur" tile in Profile — ignores [TourService.hasSeenTour],
  /// always replays from the start. Also marks the tour as seen + flips the
  /// session guard so a brand-new user who finds this tile before the
  /// auto-trigger fires doesn't see the tour start twice.
  Future<void> startManually() async {
    _autoHandledThisSession = true;
    await _ref.read(tourServiceProvider).markSeen();
    _ref.read(appRouterProvider).go('/home');
    await _startWave1();
  }
}

final tourControllerProvider = Provider<TourController>((ref) => TourController(ref));
