import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/pin_code_field.dart';
import 'wallet_errors.dart';

/// Collects the PIN for a wallet action and runs [onConfirm] with it.
///
/// Unlike [ConfirmPinSheet] this does NOT call `/auth/verify-pin` — wallet
/// endpoints verify the PIN themselves inside the request (docs "Wallet"
/// rule 2), and `verify-pin` must not stand in for that. The sheet stays
/// open on failure so the user can retype the PIN (a `PIN_INVALID` /
/// `PIN_LOCKED` / network error shows inline), and pops `true` only once
/// [onConfirm] completes without throwing.
class WalletPinSheet extends StatefulWidget {
  const WalletPinSheet({super.key, required this.onConfirm});

  final Future<void> Function(String pin) onConfirm;

  /// Returns `true` if the action succeeded, `null` if dismissed.
  static Future<bool?> show(BuildContext context, {required Future<void> Function(String pin) onConfirm}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => WalletPinSheet(onConfirm: onConfirm),
    );
  }

  @override
  State<WalletPinSheet> createState() => _WalletPinSheetState();
}

class _WalletPinSheetState extends State<WalletPinSheet> {
  final _pinController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit(String pin) async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.onConfirm(pin);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      _pinController.clear();
      setState(() {
        _isSubmitting = false;
        // A timeout leaves the outcome unknown — the caller keeps the same
        // idempotency key, so retrying here is safe.
        _error = e.isNetworkError ? l10n.wltPinRetryNetwork : walletErrorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_isSubmitting,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.wltPinTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.wltPinSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 24),
                if (_isSubmitting)
                  SizedBox(height: 52, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                else
                  PinCodeField(
                    controller: _pinController,
                    autofocus: true,
                    errorText: _error,
                    onCompleted: _submit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
