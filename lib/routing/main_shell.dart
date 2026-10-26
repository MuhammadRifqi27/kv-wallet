import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../core/providers/core_providers.dart';
import '../core/theme/app_colors.dart';
import '../data/models/user_model.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/tour/application/tour_controller.dart';
import '../l10n/app_localizations.dart';

class _NavItem {
  const _NavItem({
    required this.permission,
    required this.icon,
    required this.selectedIcon,
    required this.tourKey,
  });

  final String permission;
  final IconData icon;
  final IconData selectedIcon;
  final GlobalKey tourKey;
}

/// Nav item labels are locale-dependent, so they can't live on the const
/// [_NavItem] list itself — this maps a nav item's stable `permission` key
/// to its localized label at build time.
String _navLabelFor(AppLocalizations l10n, String permission) {
  switch (permission) {
    case 'dashboard':
      return l10n.appNavDashboard;
    case 'transactions':
      return l10n.appNavTransactions;
    case 'summary':
      return l10n.appNavSummary;
    case 'budgets':
      return l10n.appNavBudgets;
    case 'settings':
      return l10n.appNavProfile;
    default:
      // A future tab added without a matching case here would otherwise
      // silently leak the raw permission string to users (e.g. literal
      // "portfolio") — fail loudly in debug instead. See
      // docs/ide-improvement-fitur-existing.txt BAGIAN B #11.
      assert(false, 'No label mapped for nav permission "$permission" — add a case to _navLabelFor.');
      return permission;
  }
}

/// Tour tooltip title/description per nav item — same permission-keyed
/// lookup pattern as [_navLabelFor], for the gelombang-1 nav-icon steps
/// (see docs/plan-dev/onboarding-tour-plan.txt).
(String, String) _navTourCopyFor(AppLocalizations l10n, String permission) {
  switch (permission) {
    case 'dashboard':
      return (l10n.tourNavDashboardTitle, l10n.tourNavDashboardDescription);
    case 'transactions':
      return (l10n.tourNavTransactionsTitle, l10n.tourNavTransactionsDescription);
    case 'summary':
      return (l10n.tourNavSummaryTitle, l10n.tourNavSummaryDescription);
    case 'budgets':
      return (l10n.tourNavBudgetsTitle, l10n.tourNavBudgetsDescription);
    case 'settings':
      return (l10n.tourNavProfileTitle, l10n.tourNavProfileDescription);
    default:
      assert(false, 'No tour copy mapped for nav permission "$permission" — add a case to _navTourCopyFor.');
      return (permission, '');
  }
}

/// Index order must match the branch order in app_router.dart's
/// StatefulShellRoute (NavigationBar matches by index) — reorder both
/// together. Permission keys per
/// docs/flutter-navbar-permission-gating-plan.txt BAGIAN 0. Portfolio isn't
/// a tab here — it's reached via a menu tile on the Profile page — but its
/// route still carries the `portfolio` permission (see app_router.dart's
/// `_routePermissions`) so a direct/deep link into it still gets gated.
/// Investment/BTC Tracking was a tab here too until it was moved to a
/// Profile menu tile (same treatment as Portfolio) to bring the bar down
/// from 6 tabs to the UX-recommended 4-5 — it's the most niche/premium-only
/// destination of the six.
/// [_NavItem.tourKey]s below feed TourController's gelombang 1 — see
/// docs/plan-dev/onboarding-tour-plan.txt.
final _navItems = [
  _NavItem(
    permission: 'dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
    tourKey: tourNavDashboardKey,
  ),
  _NavItem(
    permission: 'transactions',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long_rounded,
    tourKey: tourNavTransactionsKey,
  ),
  _NavItem(
    permission: 'summary',
    icon: Icons.pie_chart_outline_rounded,
    selectedIcon: Icons.pie_chart_rounded,
    tourKey: tourNavSummaryKey,
  ),
  _NavItem(
    permission: 'budgets',
    icon: Icons.calculate_outlined,
    selectedIcon: Icons.calculate_rounded,
    tourKey: tourNavBudgetsKey,
  ),
  _NavItem(
    permission: 'settings',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    tourKey: tourNavProfileKey,
  ),
];

/// Bottom nav shell for the 5 top-level destinations. Tabs the user's
/// `money_management_permissions` doesn't cover stay visible but locked
/// (dimmed + lock badge) — tapping one redirects to Upgrade Membership
/// instead of navigating, per
/// docs/flutter-navbar-permission-gating-plan.txt.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(BuildContext context, WidgetRef ref, int index) {
    final item = _navItems[index];
    final user = ref.read(authControllerProvider).user;

    if (user?.hasPermission(item.permission) ?? false) {
      navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).appNavUpgradeRequired)),
    );
    context.push('/profile/membership');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    // MainShell stays mounted the whole time any of its 6 IndexedStack
    // branches is visible, so it's never naturally rebuilt by Flutter's
    // normal parent-cascade when the user flips light/dark from deep
    // inside the Profile branch — watching the mode here forces Riverpod
    // to rebuild it directly instead, see AppColors' class doc.
    ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, ref, index),
        destinations: [
          for (var i = 0; i < _navItems.length; i++)
            _buildDestination(
              context: context,
              l10n: l10n,
              user: user,
              item: _navItems[i],
              // NavigationBar only ever mounts ONE of `icon`/`selectedIcon`
              // for a given destination — whichever matches its current
              // selection state — so the Showcase has to move to whichever
              // slot is actually being built, otherwise the tour gets stuck
              // the moment it reaches the currently-active tab's own icon
              // (its `icon:` slot never renders while selected, so the
              // library can never find that target). See
              // docs/plan-dev/onboarding-tour-plan.txt.
              isSelected: i == navigationShell.currentIndex,
            ),
        ],
      ),
    );
  }

  bool _isAllowed(UserModel? user, _NavItem item) => user?.hasPermission(item.permission) ?? false;

  NavigationDestination _buildDestination({
    required BuildContext context,
    required AppLocalizations l10n,
    required UserModel? user,
    required _NavItem item,
    required bool isSelected,
  }) {
    final locked = !_isAllowed(user, item);
    final tourCopy = _navTourCopyFor(l10n, item.permission);
    final unselected = _NavIcon(icon: item.icon, locked: locked);
    final selected = _NavIcon(icon: item.selectedIcon, locked: locked);

    Widget showcased(Widget child) => Showcase(
          key: item.tourKey,
          title: tourCopy.$1,
          description: tourCopy.$2,
          tooltipBackgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
          targetShapeBorder: const CircleBorder(),
          child: child,
        );

    return NavigationDestination(
      icon: isSelected ? unselected : showcased(unselected),
      selectedIcon: isSelected ? showcased(selected) : selected,
      label: _navLabelFor(l10n, item.permission),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.locked});

  final IconData icon;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    if (!locked) return Icon(icon);

    return Opacity(
      opacity: 0.4,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Icon(icon),
          Icon(Icons.lock_rounded, size: 10, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
