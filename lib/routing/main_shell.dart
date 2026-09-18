import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/core_providers.dart';
import '../core/theme/app_colors.dart';
import '../data/models/user_model.dart';
import '../features/auth/application/auth_controller.dart';
import '../l10n/app_localizations.dart';

class _NavItem {
  const _NavItem({required this.permission, required this.icon, required this.selectedIcon});

  final String permission;
  final IconData icon;
  final IconData selectedIcon;
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
      return permission;
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
const _navItems = [
  _NavItem(
    permission: 'dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
  ),
  _NavItem(
    permission: 'transactions',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long_rounded,
  ),
  _NavItem(
    permission: 'summary',
    icon: Icons.pie_chart_outline_rounded,
    selectedIcon: Icons.pie_chart_rounded,
  ),
  _NavItem(
    permission: 'budgets',
    icon: Icons.calculate_outlined,
    selectedIcon: Icons.calculate_rounded,
  ),
  _NavItem(
    permission: 'settings',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
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
          for (final item in _navItems)
            NavigationDestination(
              icon: _NavIcon(icon: item.icon, locked: !_isAllowed(user, item)),
              selectedIcon: _NavIcon(icon: item.selectedIcon, locked: !_isAllowed(user, item)),
              label: _navLabelFor(l10n, item.permission),
            ),
        ],
      ),
    );
  }

  bool _isAllowed(UserModel? user, _NavItem item) => user?.hasPermission(item.permission) ?? false;
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
