import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pin_code_field.dart';
import '../application/pin_controller.dart';

/// Bottom sheet asking the user to re-enter their current PIN, verified
/// against the server the same way [VerifyPinPage] does. Used before
/// turning biometric login on (see ProfilePage) — enabling it needs a
/// plaintext PIN to cache for [SecureStorageService.saveCachedPin], and
/// there's nowhere else in the app already holding that in memory at the
/// point the user flips the toggle.
///
/// Pops the confirmed PIN string on success, `null` if dismissed.
class ConfirmPinSheet extends ConsumerStatefulWidget {
  const ConfirmPinSheet({super.key});

  @override
  ConsumerState<ConfirmPinSheet> createState() => _ConfirmPinSheetState();
}

class _ConfirmPinSheetState extends ConsumerState<ConfirmPinSheet> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _onCompleted(String pin) async {
    final success = await ref
        .read(pinControllerProvider.notifier)
        .verifyPin(pin: pin);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(pin);
    } else {
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Konfirmasi PIN Anda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Masukkan PIN 6 digit saat ini untuk mengaktifkan login biometrik',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 24),
              if (pinState.isLoading)
                CircularProgressIndicator(color: AppColors.primary)
              else
                PinCodeField(
                  controller: _pinController,
                  autofocus: true,
                  errorText: pinState.error?.message,
                  onCompleted: _onCompleted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
