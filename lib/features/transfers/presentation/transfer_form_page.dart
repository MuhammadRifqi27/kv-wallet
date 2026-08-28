import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../data/models/transfer_model.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/transfer_list_controller.dart';

class TransferFormPage extends ConsumerStatefulWidget {
  const TransferFormPage({super.key, this.transfer});

  /// Null means "create new"; non-null means "edit this transfer".
  final TransferModel? transfer;

  @override
  ConsumerState<TransferFormPage> createState() => _TransferFormPageState();
}

class _TransferFormPageState extends ConsumerState<TransferFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.transfer != null ? widget.transfer!.amount.toStringAsFixed(0) : '',
  );
  late final _descriptionController = TextEditingController(text: widget.transfer?.description);

  late DateTime _date = widget.transfer?.date ?? DateTime.now();
  // Local form state is named to match the create/update request
  // (`fromAccountId`/`toAccountId`), even though it's seeded from
  // TransferModel's differently-named `financeInvestmentId`/
  // `toFinanceInvestmentId` — see TransferModel's IMPORTANT note.
  late int? _fromAccountId = widget.transfer?.financeInvestmentId;
  late int? _toAccountId = widget.transfer?.toFinanceInvestmentId;

  bool _isSubmitting = false;
  ApiException? _error;
  String? _accountError;

  bool get _isEditing => widget.transfer != null;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccountId == null || _toAccountId == null) {
      setState(() => _accountError = 'Pilih akun asal dan akun tujuan.');
      return;
    }
    if (_fromAccountId == _toAccountId) {
      setState(() => _accountError = 'Akun asal dan tujuan tidak boleh sama.');
      return;
    }
    setState(() => _accountError = null);

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final amount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final description = _descriptionController.text.trim();
    final controller = ref.read(transferListControllerProvider.notifier);

    try {
      if (_isEditing) {
        await controller.editTransfer(
          id: widget.transfer!.id,
          date: _date,
          fromAccountId: _fromAccountId!,
          toAccountId: _toAccountId!,
          amount: amount,
          description: description.isEmpty ? null : description,
        );
      } else {
        await controller.addTransfer(
          date: _date,
          fromAccountId: _fromAccountId!,
          toAccountId: _toAccountId!,
          amount: amount,
          description: description.isEmpty ? null : description,
        );
      }
      if (mounted) context.pop();
    } on ApiException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfoliosAsync = ref.watch(portfolioListControllerProvider);
    final generalError = _error != null && _error!.fieldErrors == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Transfer' : 'Transfer Antar Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (generalError) ...[
                  ErrorBanner(message: _error!.message),
                  const SizedBox(height: 16),
                ],
                const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                _TapField(
                  icon: Icons.calendar_today_outlined,
                  label: formatIndonesianDate(_date),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                const Text('Dari Akun', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                portfoliosAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat akun.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (portfolios) => _AccountPickerField(
                    portfolios: portfolios,
                    selectedId: _fromAccountId,
                    placeholder: 'Pilih akun asal',
                    onChanged: (id) => setState(() {
                      _fromAccountId = id;
                      _accountError = null;
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Ke Akun', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                portfoliosAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat akun.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (portfolios) => _AccountPickerField(
                    portfolios: portfolios,
                    selectedId: _toAccountId,
                    placeholder: 'Pilih akun tujuan',
                    onChanged: (id) => setState(() {
                      _toAccountId = id;
                      _accountError = null;
                    }),
                  ),
                ),
                if (_accountError != null) ...[
                  const SizedBox(height: 8),
                  Text(_accountError!, style: const TextStyle(color: AppColors.error, fontSize: 12.5)),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Jumlah (Rp)',
                  controller: _amountController,
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('amount'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Jumlah wajib diisi';
                    final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
                    if (parsed == null || parsed <= 0) return 'Jumlah tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Deskripsi (opsional)',
                  controller: _descriptionController,
                  icon: Icons.notes_rounded,
                  textInputAction: TextInputAction.done,
                  errorText: _error?.errorFor('description'),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _isEditing ? 'Simpan Perubahan' : 'Transfer',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15))),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _AccountPickerField extends StatelessWidget {
  const _AccountPickerField({
    required this.portfolios,
    required this.selectedId,
    required this.placeholder,
    required this.onChanged,
  });

  final List<PortfolioModel> portfolios;
  final int? selectedId;
  final String placeholder;
  final ValueChanged<int> onChanged;

  PortfolioModel? get _selected {
    for (final portfolio in portfolios) {
      if (portfolio.id == selectedId) return portfolio;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _AccountPickerSheet(portfolios: portfolios, selectedId: selectedId),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return _TapField(
      icon: Icons.account_balance_wallet_outlined,
      label: selected?.accountName ?? (portfolios.isEmpty ? 'Belum ada akun' : placeholder),
      onTap: portfolios.isEmpty ? () {} : () => _openPicker(context),
    );
  }
}

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({required this.portfolios, required this.selectedId});

  final List<PortfolioModel> portfolios;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
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
            const Text('Pilih akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                            border: Border.all(
                              color: portfolio.id == selectedId ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  portfolio.accountName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ),
                              if (portfolio.id == selectedId)
                                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
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
