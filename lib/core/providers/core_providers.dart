import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
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
