import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/investment_repository.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/summary_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../features/auth/application/auth_controller.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

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

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(apiClient: ref.read(apiClientProvider));
});

final summaryRepositoryProvider = Provider<SummaryRepository>((ref) {
  return SummaryRepository(apiClient: ref.read(apiClientProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(apiClient: ref.read(apiClientProvider));
});
