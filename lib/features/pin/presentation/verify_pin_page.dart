import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/pin_code_field.dart';
import '../../auth/application/auth_controller.dart';
import '../application/pin_controller.dart';
import 'biometric_enable_prompt.dart';

/// App-lock screen — shown every cold start whenever the account has a PIN,
/// before the rest of the app becomes reachable. When biometric login is on
/// (see ProfilePage), a fingerprint/Face ID prompt is offered as a shortcut
/// that replays the cached PIN through the exact same [PinController.verifyPin]
/// call a manual entry would make — there's no separate "biometric-verified"
/// server state, so a stale cached PIN (changed elsewhere) just fails like a
/// wrong manual entry would.
class VerifyPinPage extends ConsumerStatefulWidget {
  const VerifyPinPage({super.key});

  @override
  ConsumerState<VerifyPinPage> createState() => _VerifyPinPageState();
}

class _VerifyPinPageState extends ConsumerState<VerifyPinPage> {
  final _pinController = TextEditingController();
  bool _isBiometricAttemptInFlight = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(biometricEnabledProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricUnlock());
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricUnlock() async {
    if (!mounted || _isBiometricAttemptInFlight) return;
    final cachedPin = await ref.read(secureStorageServiceProvider).readCachedPin();
    if (cachedPin == null || !mounted) return;

    setState(() => _isBiometricAttemptInFlight = true);
    final authenticated = await ref.read(biometricServiceProvider).authenticate('Buka Flowr dengan biometrik');
    if (!mounted) return;
    if (!authenticated) {
      // User cancelled/failed the OS prompt (or hardware error) — no error
      // banner for this, just quietly fall back to the PIN pad below.
      setState(() => _isBiometricAttemptInFlight = false);
      return;
    }

    final success = await ref.read(pinControllerProvider.notifier).verifyPin(pin: cachedPin);
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      setState(() => _isBiometricAttemptInFlight = false);
    }
  }

  Future<void> _onCompleted(String pin) async {
    final success = await ref.read(pinControllerProvider.notifier).verifyPin(pin: pin);
    if (success && mounted) {
      // Only for manual entry — biometric unlock (_tryBiometricUnlock)
      // means it's already on, so the nudge would be a no-op there anyway.
      await maybeShowBiometricEnablePrompt(context, ref, pin);
      if (mounted) context.go('/home');
    } else if (mounted) {
      _pinController.clear();
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Bukan Anda?'),
        content: const Text('Anda akan logout dan perlu login kembali dengan email/username & password.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinControllerProvider);
    final userName = ref.watch(authControllerProvider).user?.name;
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final showLoading = pinState.isLoading || _isBiometricAttemptInFlight;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(child: AppLogo(size: 64, showWordmark: false)),
                  const SizedBox(height: 24),
                  Text(
                    userName != null ? 'Halo, $userName' : 'Masukkan PIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    biometricEnabled
                        ? 'Masukkan PIN atau gunakan sidik jari/Face ID untuk membuka aplikasi'
                        : 'Masukkan PIN 6 digit untuk membuka aplikasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  if (showLoading)
                    CircularProgressIndicator(color: AppColors.primary)
                  else
                    PinCodeField(
                      controller: _pinController,
                      autofocus: true,
                      errorText: pinState.error?.message,
                      onCompleted: _onCompleted,
                    ),
                  if (biometricEnabled && !showLoading) ...[
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: _tryBiometricUnlock,
                      icon: const Icon(Icons.fingerprint_rounded, size: 20),
                      label: const Text('Gunakan Biometrik'),
                    ),
                  ],
                  const SizedBox(height: 28),
                  TextButton(
                    onPressed: _logout,
                    child: const Text('Bukan Anda? Keluar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
