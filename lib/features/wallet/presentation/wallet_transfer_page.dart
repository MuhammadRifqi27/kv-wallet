import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/uuid.dart';
import '../../../data/models/wallet_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/wallet_controller.dart';
import 'wallet_errors.dart';
import 'wallet_pin_sheet.dart';

/// P2P transfer: (1) look up the recipient by account number, (2) enter
/// amount/note, (3) confirm, (4) PIN — see docs/mobile-api-reference.md
/// "Wallet". The PIN goes inside the transfer request itself.
class WalletTransferPage extends ConsumerStatefulWidget {
  const WalletTransferPage({super.key});

  @override
  ConsumerState<WalletTransferPage> createState() => _WalletTransferPageState();
}

class _WalletTransferPageState extends ConsumerState<WalletTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  WalletLookupModel? _recipient;
  bool _isLookingUp = false;
  String? _accountError;

  @override
  void initState() {
    super.initState();
    // Limits/balance drive client-side validation — make sure they're fresh.
    Future.microtask(() => ref.read(walletControllerProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _accountDigits => _accountController.text.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _lookup() async {
    final l10n = AppLocalizations.of(context);
    if (_accountDigits.length != 12) {
      setState(() => _accountError = l10n.wltTransferAccountInvalid);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLookingUp = true;
      _accountError = null;
    });
    try {
      final result = await ref.read(walletControllerProvider.notifier).lookup(_accountDigits);
      if (mounted) setState(() => _recipient = result);
    } on ApiException catch (e) {
      if (mounted) setState(() => _accountError = walletErrorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _isLookingUp = false);
    }
  }

  void _resetRecipient() {
    setState(() => _recipient = null);
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final recipient = _recipient!;
    final amount = parseRupiahInput(_amountController.text)!;
    final note = _noteController.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(recipient: recipient, amount: amount, note: note),
    );
    if (confirmed != true || !mounted) return;

    // One key per user-confirmed attempt, reused by every retry inside the
    // PIN sheet (wrong PIN, timeout) so a transfer that actually went
    // through on a flaky connection is never executed twice.
    final idempotencyKey = generateUuidV4();
    WalletTransferModel? result;

    final ok = await WalletPinSheet.show(
      context,
      onConfirm: (pin) async {
        result = await ref.read(walletControllerProvider.notifier).transfer(
              toAccountNumber: recipient.accountNumber,
              amount: amount,
              note: note.isEmpty ? null : note,
              pin: pin,
              idempotencyKey: idempotencyKey,
            );
      },
    );
    if (ok == true && result != null && mounted) {
      context.pushReplacement('/wallet/transfers/${result!.id}', extra: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wallet = ref.watch(walletControllerProvider).valueOrNull;
    final recipient = _recipient;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.wltTransferTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wallet?.isFrozen ?? false) ...[
                  ErrorBanner(message: l10n.wltFrozenBanner),
                  const SizedBox(height: 16),
                ],
                if (recipient == null) ..._buildLookupStep(l10n) else ..._buildAmountStep(l10n, recipient, wallet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLookupStep(AppLocalizations l10n) {
    return [
      TextField(
        controller: _accountController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _lookup(),
        onChanged: (_) {
          if (_accountError != null) setState(() => _accountError = null);
        },
        style: TextStyle(color: AppColors.textPrimary, fontSize: 15, letterSpacing: 1),
        decoration: InputDecoration(
          labelText: l10n.wltTransferAccountField,
          helperText: l10n.wltTransferAccountHelper,
          errorText: _accountError,
          prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.textSecondary, size: 20),
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButton(label: l10n.wltTransferCheck, isLoading: _isLookingUp, onPressed: _lookup),
    ];
  }

  List<Widget> _buildAmountStep(AppLocalizations l10n, WalletLookupModel recipient, WalletModel? wallet) {
    final limits = wallet?.limits;
    return [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                recipient.name.isNotEmpty ? recipient.name[0].toUpperCase() : '?',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipient.name,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recipient.maskedAccountNumber,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: _resetRecipient, child: Text(l10n.wltTransferChange)),
          ],
        ),
      ),
      const SizedBox(height: 20),
      AppTextField(
        label: l10n.wltTransferAmountLabel,
        controller: _amountController,
        icon: Icons.payments_outlined,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        textInputAction: TextInputAction.next,
        helperText: wallet == null ? null : l10n.wltTransferAvailableBalance(formatRupiah(wallet.balance)),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return l10n.wltTransferAmountRequired;
          final parsed = parseRupiahInput(value);
          if (parsed == null || parsed <= 0) return l10n.txnCommonAmountInvalid;
          if (limits != null) {
            if (parsed < limits.minTransfer) return l10n.wltTransferAmountTooSmall(formatRupiah(limits.minTransfer));
            if (parsed > limits.maxTransfer) return l10n.wltTransferAmountTooLarge(formatRupiah(limits.maxTransfer));
            if (parsed > limits.remainingToday) {
              return l10n.wltTransferExceedsDaily(formatRupiah(limits.remainingToday));
            }
          }
          if (wallet != null && parsed > wallet.balance) return l10n.wltTransferInsufficient;
          return null;
        },
      ),
      const SizedBox(height: 16),
      AppTextField(
        label: l10n.wltTransferNoteLabel,
        controller: _noteController,
        icon: Icons.notes_rounded,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _continue(),
      ),
      const SizedBox(height: 28),
      PrimaryButton(
        label: l10n.wltTransferContinue,
        onPressed: (wallet?.isFrozen ?? false) ? null : _continue,
      ),
    ];
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.recipient, required this.amount, required this.note});

  final WalletLookupModel recipient;
  final double amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 84, child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5))),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.wltTransferConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row(l10n.wltReceiptRecipient, recipient.name),
          row(l10n.wltReceiptAccount, recipient.maskedAccountNumber),
          row(l10n.wltReceiptAmount, formatRupiah(amount)),
          if (note.isNotEmpty) row(l10n.wltReceiptNote, note),
          const SizedBox(height: 10),
          Text(l10n.wltTransferConfirmCheckName, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.wltCancel)),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.wltTransferConfirmSend)),
      ],
    );
  }
}
