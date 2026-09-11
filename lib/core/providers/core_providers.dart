import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/investment_repository.dart';
import '../../data/repositories/membership_repository.dart';
import '../../data/repositories/pin_repository.dart';
import '../../data/repositories/btc_tracking_repository.dart';
import '../../data/repositories/crypto_price_repository.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/repositories/recurring_repository.dart';
import '../../data/repositories/savings_goal_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/summary_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/transfer_repository.dart';
import '../../features/auth/application/auth_controller.dart';
import '../network/api_client.dart';
import '../notifications/notification_service.dart';
import '../storage/onboarding_service.dart';
import '../storage/secure_storage_service.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

/// Overridden in main.dart with the real value read at startup (see
/// OnboardingService) so the router redirect can read it synchronously;
/// flipped to true once the user finishes/skips the slides.
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    storage: ref.read(secureStorageServiceProvider),
    onUnauthorized: () => ref.read(authControllerProvider.notifier).forceLogout(),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.read(apiClientProvider),
    storage: ref.read(secureStorageServiceProvider),
  );
});

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  return PinRepository(apiClient: ref.read(apiClientProvider));
});

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  return MembershipRepository(apiClient: ref.read(apiClientProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(apiClient: ref.read(apiClientProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(apiClient: ref.read(apiClientProvider));
});

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository(apiClient: ref.read(apiClientProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(apiClient: ref.read(apiClientProvider));
});

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(apiClient: ref.read(apiClientProvider));
});

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository(apiClient: ref.read(apiClientProvider));
});

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return SavingsGoalRepository(apiClient: ref.read(apiClientProvider));
});

final btcTrackingRepositoryProvider = Provider<BtcTrackingRepository>((ref) {
  return BtcTrackingRepository(apiClient: ref.read(apiClientProvider));
});

final cryptoPriceRepositoryProvider = Provider<CryptoPriceRepository>((ref) {
  return CryptoPriceRepository();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(apiClient: ref.read(apiClientProvider));
});

final summaryRepositoryProvider = Provider<SummaryRepository>((ref) {
  return SummaryRepository(apiClient: ref.read(apiClientProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(apiClient: ref.read(apiClientProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository(apiClient: ref.read(apiClientProvider));
});
