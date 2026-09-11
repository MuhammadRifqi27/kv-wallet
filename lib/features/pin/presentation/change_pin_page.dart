import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/pin_code_field.dart';
import '../application/pin_controller.dart';

enum _Step { current, newPin, confirm }

/// Changing an existing PIN — 3 steps (current → new → confirm), all
/// collected locally before a single `POST /auth/pin` call with
/// `current_pin` + `pin` + `pin_confirmation` (see [PinController.changePin]).
/// Distinct from SetPinPage, which is only for the first-time, no-PIN-yet
/// case reached from the auth-gate redirect.
class ChangePinPage extends ConsumerStatefulWidget {
  const ChangePinPage({super.key});

  @override
  ConsumerState<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends ConsumerState<ChangePinPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  _Step _step = _Step.current;
  String? _confirmError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onCurrentCompleted(String pin) {
    setState(() => _step = _Step.newPin);
  }

  void _onNewCompleted(String pin) {
    setState(() => _step = _Step.confirm);
  }

  Future<void> _onConfirmCompleted(String confirmPin) async {
    if (confirmPin != _newController.text) {
      setState(() => _confirmError = 'PIN tidak cocok, coba lagi');
      _confirmController.clear();
      return;
    }
    setState(() => _confirmError = null);

    final success = await ref.read(pinControllerProvider.notifier).changePin(
          currentPin: _currentController.text,
          pin: _newController.text,
          pinConfirmation: confirmPin,
        );

    if (!mounted) return;
    if (success) {
      // Keep biometric unlock working with the new PIN — otherwise it'd
      // keep silently replaying the now-stale one until it fails and falls
      // back to manual entry (see VerifyPinPage._tryBiometricUnlock).
      if (ref.read(biometricEnabledProvider)) {
        await ref.read(secureStorageServiceProvider).saveCachedPin(_newController.text);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN berhasil diperbarui.')),
      );
      Navigator.of(context).pop();
    } else {
      // Server rejected it (most likely current_pin salah) — restart from
      // the first step, same pattern as SetPinPage.
      setState(() {
        _step = _Step.current;
        _currentController.clear();
        _newController.clear();
        _confirmController.clear();
      });
    }
  }

  String get _title => switch (_step) {
        _Step.current => 'Masukkan PIN Saat Ini',
        _Step.newPin => 'Buat PIN Baru',
        _Step.confirm => 'Konfirmasi PIN Baru',
      };

  String get _subtitle => switch (_step) {
        _Step.current => 'Masukkan PIN 6 digit yang sedang Anda pakai',
        _Step.newPin => 'Masukkan PIN 6 digit yang baru',
        _Step.confirm => 'Masukkan ulang PIN baru untuk konfirmasi',
      };

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ubah PIN')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  if (pinState.error != null) ...[
                    ErrorBanner(message: pinState.error!.message),
                    const SizedBox(height: 20),
                  ],
                  if (pinState.isLoading)
                    CircularProgressIndicator(color: AppColors.primary)
                  else
                    switch (_step) {
                      _Step.current => PinCodeField(
                          key: const ValueKey('current'),
                          controller: _currentController,
                          autofocus: true,
                          onCompleted: _onCurrentCompleted,
                        ),
                      _Step.newPin => PinCodeField(
                          key: const ValueKey('new'),
                          controller: _newController,
                          autofocus: true,
                          onCompleted: _onNewCompleted,
                        ),
                      _Step.confirm => PinCodeField(
                          key: const ValueKey('confirm'),
                          controller: _confirmController,
                          autofocus: true,
                          errorText: _confirmError,
                          onCompleted: _onConfirmCompleted,
                        ),
                    },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
