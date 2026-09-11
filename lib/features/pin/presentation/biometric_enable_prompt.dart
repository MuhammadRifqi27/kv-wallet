import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/biometric_enroll.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/storage/biometric_prompt_service.dart';
import '../../../core/theme/app_colors.dart';

/// Nudge shown right after a successful PIN entry (SetPinPage's first-time
/// setup, or VerifyPinPage's manual unlock — not the biometric-unlock path
/// itself, since biometric would already be on by then) offering to turn
/// biometric login on, using the [pin] just typed/verified instead of
/// asking for it again.
///
/// No-op (skips silently) if biometric is already on, unsupported on this
/// device, or has already been offered [BiometricPromptService.maxPromptCount]
/// times — some people will always prefer typing their PIN, so this stops
/// asking instead of nagging forever. Call this *before* navigating away
/// (e.g. before `context.go('/home')`) while the page's context is still
/// valid for showing a dialog.
Future<void> maybeShowBiometricEnablePrompt(BuildContext context, WidgetRef ref, String pin) async {
  if (ref.read(biometricEnabledProvider)) return;
  if (!await ref.read(biometricServiceProvider).isSupported()) return;

  final promptService = ref.read(biometricPromptServiceProvider);
  if (await promptService.getShownCount() >= BiometricPromptService.maxPromptCount) return;
  await promptService.incrementShownCount();
  if (!context.mounted) return;

  final wantsToEnable = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 32),
      title: const Text('Masuk lebih cepat dengan biometrik?'),
      content: const Text(
        'Buka Flowr pakai sidik jari atau Face ID, tanpa perlu mengetik PIN tiap kali. '
        'Bisa diaktifkan/dimatikan kapan saja lewat Profile.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Nanti saja')),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Aktifkan')),
      ],
    ),
  );
  if (wantsToEnable != true || !context.mounted) return;

  final enabled = await enrollBiometricLogin(ref, pin: pin, reason: 'Aktifkan login biometrik untuk Flowr');
  if (!context.mounted) return;

  // A dialog (awaited, must be dismissed) instead of a SnackBar — the
  // caller navigates to '/home' right after this returns, which would
  // otherwise tear down the Scaffold hosting a SnackBar before anyone
  // had a chance to see it.
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(
        enabled ? Icons.check_circle_rounded : Icons.error_outline_rounded,
        color: enabled ? AppColors.success : AppColors.error,
        size: 32,
      ),
      title: Text(enabled ? 'Biometrik aktif!' : 'Gagal mengaktifkan'),
      content: Text(
        enabled
            ? 'Lain kali Anda bisa masuk ke Flowr tanpa mengetik PIN.'
            : 'Verifikasi biometrik gagal atau dibatalkan. Anda bisa coba lagi kapan saja lewat Profile.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Oke')),
      ],
    ),
  );
}
