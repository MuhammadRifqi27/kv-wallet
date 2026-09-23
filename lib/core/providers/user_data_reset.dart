import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/budget/application/budget_controller.dart';
import '../../features/dashboard/application/dashboard_controller.dart';
import '../../features/investment/application/btc_tracking_controller.dart';
import '../../features/master_data/application/category_list_controller.dart';
import '../../features/master_data/application/investment_list_controller.dart';
import '../../features/master_data/application/payroll_settings_controller.dart';
import '../../features/portfolio/application/portfolio_list_controller.dart';
import '../../features/recurring/application/recurring_list_controller.dart';
import '../../features/savings_goals/application/savings_goal_controller.dart';
import '../../features/summary/application/summary_controller.dart';
import '../../features/transactions/application/transaction_list_controller.dart';
import '../../features/transfers/application/transfer_list_controller.dart';

/// Every non-`autoDispose` `AsyncNotifierProvider` that caches data fetched
/// for the CURRENTLY logged-in user. Call [invalidateUserDataProviders]
/// whenever the authenticated user changes (logout, forced logout on a 401)
/// — without it, these providers keep their last successful [AsyncData]
/// forever (that's the whole point of not being `autoDispose`: survive
/// navigating away and back without refetching), so logging in as a
/// DIFFERENT user on the same device/session shows the previous user's
/// data until something happens to trigger a manual refresh on each page.
/// See docs/ide-improvement-fitur-existing.txt (account-switch stale-data
/// bug reported directly by the user, not from the earlier codebase audit).
///
/// `autoDispose` providers (emergencyFundDataProvider, membershipPlansProvider,
/// assetPricesProvider, etc.) are deliberately NOT listed here — they
/// already self-clear once their last watcher unmounts, which happens
/// naturally when the router redirects away from every authenticated route
/// on logout (see app_router.dart's redirect).
///
/// IMPORTANT: adding a new user-scoped `AsyncNotifierProvider` (a
/// controller that fetches this user's own data) elsewhere in the app?
/// Add it to this list too, or it'll silently keep showing stale data
/// after an account switch exactly like the bug this file fixes.
void invalidateUserDataProviders(Ref ref) {
  ref.invalidate(dashboardControllerProvider);
  ref.invalidate(transactionListControllerProvider);
  ref.invalidate(budgetControllerProvider);
  ref.invalidate(summaryControllerProvider);
  ref.invalidate(savingsGoalControllerProvider);
  ref.invalidate(recurringListControllerProvider);
  ref.invalidate(portfolioListControllerProvider);
  ref.invalidate(transferListControllerProvider);
  ref.invalidate(btcOverviewControllerProvider);
  ref.invalidate(btcActivityControllerProvider);
  ref.invalidate(categoryListControllerProvider);
  ref.invalidate(investmentListControllerProvider);
  ref.invalidate(payrollSettingsControllerProvider);
}
