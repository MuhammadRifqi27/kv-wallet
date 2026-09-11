import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/pin_code_field.dart';
import '../application/pin_controller.dart';
import 'biometric_enable_prompt.dart';

/// Forced right after register/login when the account has no PIN yet — no
/// way to skip (this app-lock PIN is mandatory, see
/// docs/flutter-pin-security-feature-plan.txt).
class SetPinPage extends ConsumerStatefulWidget {
  const SetPinPage({super.key});

  @override
  ConsumerState<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends ConsumerState<SetPinPage> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _confirming = false;
  String? _confirmError;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onFirstCompleted(String pin) {
    setState(() => _confirming = true);
  }

  Future<void> _onConfirmCompleted(String confirmPin) async {
    if (confirmPin != _pinController.text) {
      setState(() => _confirmError = 'PIN tidak cocok, coba lagi');
      _confirmController.clear();
      return;
    }
    setState(() => _confirmError = null);

    final success = await ref.read(pinControllerProvider.notifier).setPin(
          pin: _pinController.text,
          pinConfirmation: confirmPin,
        );
    if (success && mounted) {
      await maybeShowBiometricEnablePrompt(context, ref, confirmPin);
      if (mounted) context.go('/home');
    } else if (mounted) {
      // Server rejected it (e.g. validation) — restart from the first step.
      setState(() {
        _confirming = false;
        _pinController.clear();
        _confirmController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinControllerProvider);

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
                    _confirming ? 'Konfirmasi PIN' : 'Buat PIN 6 Digit',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _confirming
                        ? 'Masukkan ulang PIN yang sama untuk konfirmasi'
                        : 'PIN ini dipakai untuk membuka aplikasi setiap kali dibuka, mirip aplikasi m-banking',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  if (pinState.error != null) ...[
                    ErrorBanner(message: pinState.error!.message),
                    const SizedBox(height: 20),
                  ],
                  if (pinState.isLoading)
                    CircularProgressIndicator(color: AppColors.primary)
                  else if (_confirming)
                    PinCodeField(
                      key: const ValueKey('confirm'),
                      controller: _confirmController,
                      autofocus: true,
                      errorText: _confirmError,
                      onCompleted: _onConfirmCompleted,
                    )
                  else
                    PinCodeField(
                      key: const ValueKey('first'),
                      controller: _pinController,
                      autofocus: true,
                      onCompleted: _onFirstCompleted,
                    ),
                  if (_confirming && !pinState.isLoading) ...[
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _confirming = false;
                          _confirmError = null;
                          _pinController.clear();
                          _confirmController.clear();
                        });
                      },
                      child: const Text('Ulangi dari awal'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
