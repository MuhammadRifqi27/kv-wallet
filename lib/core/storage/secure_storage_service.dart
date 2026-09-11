import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _cachedPinKey = 'biometric_cached_pin';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  /// Only ever written when the user explicitly turns on biometric login
  /// (see ProfilePage's biometric toggle) — encrypted at rest the same way
  /// [_tokenKey] already is, so this doesn't introduce a materially weaker
  /// secret than what's already stored here. Read back after a successful
  /// OS biometric prompt to silently replay `POST /auth/verify-pin` on the
  /// user's behalf, see VerifyPinPage.
  Future<void> saveCachedPin(String pin) => _storage.write(key: _cachedPinKey, value: pin);

  Future<String?> readCachedPin() => _storage.read(key: _cachedPinKey);

  Future<void> deleteCachedPin() => _storage.delete(key: _cachedPinKey);
}
