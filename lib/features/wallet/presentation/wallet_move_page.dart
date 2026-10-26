import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/wallet_controller.dart';
import 'wallet_pin_sheet.dart';

enum WalletMoveMode { topup, withdraw }

/// Top up (portfolio -> wallet) and withdraw (wallet -> portfolio) share one
/// form — the request bodies are identical, only the endpoint and which
/// side's balance is checked differ.
class WalletMovePage extends ConsumerStatefulWidget {
  const WalletMovePage({super.key, required this.mode});

  final WalletMoveMode mode;

  @override
  ConsumerState<WalletMovePage> createState() => _WalletMovePageState();
}

class _WalletMovePageState extends ConsumerState<WalletMovePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _portfolioId;
  String? _portfolioError;

  bool get _isTopup => widget.mode == WalletMoveMode.topup;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(walletControllerProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  PortfolioModel? _selected(List<PortfolioModel> portfolios) {
    for (final portfolio in portfolios) {
      if (portfolio.id == _portfolioId) return portfolio;
    }
    return null;
  }

  Future<void> _pickPortfolio(List<PortfolioModel> portfolios) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _PortfolioSheet(portfolios: portfolios, selectedId: _portfolioId),
    );
    if (picked != null) {
      setState(() {
        _portfolioId = picked;
        _portfolioError = null;
      });
    }
  }

  Future<void> _submit(List<PortfolioModel> portfolios) async {
    final l10n = AppLocalizations.of(context);
    final valid = _formKey.currentState!.validate();
    if (_portfolioId == null) {
      setState(() => _portfolioError = l10n.wltMoveSelectPortfolioError);
      return;
    }
    if (!valid) return;

    final amount = parseRupiahInput(_amountController.text)!;
    final description = _descriptionController.text.trim();
    final portfolioId = _portfolioId!;
    final controller = ref.read(walletControllerProvider.notifier);

    final ok = await WalletPinSheet.show(
      context,
      onConfirm: (pin) => _isTopup
          ? controller.topup(
              portfolioId: portfolioId,
              amount: amount,
              description: description.isEmpty ? null : description,
              pin: pin,
            )
          : controller.withdraw(
              portfolioId: portfolioId,
              amount: amount,
              description: description.isEmpty ? null : description,
              pin: pin,
            ),
    );
    if (ok != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isTopup ? l10n.wltMoveSuccessTopup : l10n.wltMoveSuccessWithdraw)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final portfoliosAsync = ref.watch(portfolioListControllerProvider);
    final wallet = ref.watch(walletControllerProvider).valueOrNull;
    final portfolios = portfoliosAsync.valueOrNull ?? const <PortfolioModel>[];
    final selected = _selected(portfolios);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isTopup ? l10n.wltTopupTitle : l10n.wltWithdrawTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isTopup ? l10n.wltMoveTopupInfo : l10n.wltMoveWithdrawInfo,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.wltMovePortfolioLabel,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                portfoliosAsync.when(
                  loading: () => LinearProgressIndicator(color: AppColors.primary),
                  error: (_, _) => Text(
                    l10n.txnCommonAccountLoadError,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (_) => InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: portfolios.isEmpty ? null : () => _pickPortfolio(portfolios),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _portfolioError != null ? AppColors.error : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selected?.accountName ??
                                  (portfolios.isEmpty ? l10n.txnCommonNoAccountAvailable : l10n.wltMovePortfolioPlaceholder),
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_portfolioError != null) ...[
                  const SizedBox(height: 8),
                  Text(_portfolioError!, style: const TextStyle(color: AppColors.error, fontSize: 12.5)),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.wltTransferAmountLabel,
                  controller: _amountController,
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  textInputAction: TextInputAction.next,
                  helperText: _isTopup
                      ? (selected?.balance == null ? null : l10n.wltMovePortfolioBalance(formatRupiah(selected!.balance!)))
                      : (wallet == null ? null : l10n.wltTransferAvailableBalance(formatRupiah(wallet.balance))),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.wltTransferAmountRequired;
                    final parsed = parseRupiahInput(value);
                    if (parsed == null || parsed <= 0) return l10n.txnCommonAmountInvalid;
                    // Client-side pre-check only; the server stays the
                    // source of truth (INSUFFICIENT_* codes).
                    if (_isTopup) {
                      final balance = selected?.balance;
                      if (balance != null && parsed > balance) return l10n.wltErrInsufficientPortfolio;
                    } else if (wallet != null && parsed > wallet.balance) {
                      return l10n.wltTransferInsufficient;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.wltMoveDescriptionLabel,
                  controller: _descriptionController,
                  icon: Icons.notes_rounded,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(portfolios),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _isTopup ? l10n.wltMoveSubmitTopup : l10n.wltMoveSubmitWithdraw,
                  onPressed: (wallet?.isFrozen ?? false) ? null : () => _submit(portfolios),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortfolioSheet extends StatelessWidget {
  const _PortfolioSheet({required this.portfolios, required this.selectedId});

  final List<PortfolioModel> portfolios;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.txnCommonSelectAccountTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final portfolio in portfolios)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).pop(portfolio.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: portfolio.id == selectedId ? AppColors.primaryLight : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: portfolio.id == selectedId ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  portfolio.accountName,
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ),
                              if (portfolio.balance != null) ...[
                                Text(
                                  formatRupiah(portfolio.balance!),
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (portfolio.id == selectedId)
                                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
