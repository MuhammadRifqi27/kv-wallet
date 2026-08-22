import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/investment_model.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../master_data/application/investment_list_controller.dart';
import '../application/portfolio_list_controller.dart';

class PortfolioFormPage extends ConsumerStatefulWidget {
  const PortfolioFormPage({super.key, this.portfolio});

  /// Null means "create new"; non-null means "edit this account".
  final PortfolioModel? portfolio;

  @override
  ConsumerState<PortfolioFormPage> createState() => _PortfolioFormPageState();
}

class _PortfolioFormPageState extends ConsumerState<PortfolioFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _accountNameController = TextEditingController(text: widget.portfolio?.accountName);
  late final _accountNumberController = TextEditingController(text: widget.portfolio?.accountNumber);
  late final _descriptionController = TextEditingController(text: widget.portfolio?.description);
  late int? _selectedInvestmentId = widget.portfolio?.financeInvestmentId;
  late bool _isInvestmentAccount = widget.portfolio?.isInvestmentAccount ?? false;

  bool _isSubmitting = false;
  ApiException? _error;

  bool get _isEditing => widget.portfolio != null;

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvestmentId == null) {
      setState(() => _error = ApiException(message: 'Pilih provider investasi terlebih dahulu.'));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final accountNumber = _accountNumberController.text.trim();
    final description = _descriptionController.text.trim();
    final controller = ref.read(portfolioListControllerProvider.notifier);

    try {
      if (_isEditing) {
        await controller.editPortfolio(
          id: widget.portfolio!.id,
          financeInvestmentId: _selectedInvestmentId!,
          accountName: _accountNameController.text.trim(),
          isInvestmentAccount: _isInvestmentAccount,
          accountNumber: accountNumber.isEmpty ? null : accountNumber,
          description: description.isEmpty ? null : description,
        );
      } else {
        await controller.addPortfolio(
          financeInvestmentId: _selectedInvestmentId!,
          accountName: _accountNameController.text.trim(),
          isInvestmentAccount: _isInvestmentAccount,
          accountNumber: accountNumber.isEmpty ? null : accountNumber,
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
    final investmentsAsync = ref.watch(investmentListControllerProvider);
    final generalError = _error != null && _error!.fieldErrors == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Akun' : 'Tambah Akun')),
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
                const Text('Provider', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                investmentsAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat daftar provider.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (investments) => _InvestmentPickerField(
                    investments: investments,
                    selectedId: _selectedInvestmentId,
                    onChanged: (id) => setState(() => _selectedInvestmentId = id),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nama akun',
                  controller: _accountNameController,
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('account_name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nama akun wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nomor akun (opsional)',
                  controller: _accountNumberController,
                  icon: Icons.numbers_rounded,
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('account_number'),
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
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    value: _isInvestmentAccount,
                    onChanged: (value) => setState(() => _isInvestmentAccount = value),
                    activeThumbColor: AppColors.primary,
                    title: const Text(
                      'Akun investasi',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Dana masuk/keluar dicatat sebagai deposit/profit/withdrawal/loss, terpisah dari transaksi biasa',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _isEditing ? 'Simpan Perubahan' : 'Tambah Akun',
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

/// Tap target that opens [_InvestmentPickerSheet] — same custom-bottom-sheet
/// pattern as the payroll day picker, kept consistent instead of falling
/// back to a stock `DropdownButtonFormField`.
class _InvestmentPickerField extends StatelessWidget {
  const _InvestmentPickerField({required this.investments, required this.selectedId, required this.onChanged});

  final List<InvestmentModel> investments;
  final int? selectedId;
  final ValueChanged<int> onChanged;

  InvestmentModel? get _selected {
    for (final investment in investments) {
      if (investment.id == selectedId) return investment;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _InvestmentPickerSheet(investments: investments, selectedId: selectedId),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: investments.isEmpty ? null : () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_outlined, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selected?.name ?? (investments.isEmpty ? 'Belum ada provider investasi' : 'Pilih provider'),
                style: TextStyle(
                  color: selected != null ? AppColors.textPrimary : AppColors.textDisabled,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _InvestmentPickerSheet extends StatelessWidget {
  const _InvestmentPickerSheet({required this.investments, required this.selectedId});

  final List<InvestmentModel> investments;
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
            const Text(
              'Pilih provider investasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: investments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final investment = investments[index];
                  final selected = investment.id == selectedId;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(investment.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryLight : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  investment.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                                Text(
                                  investment.type.label,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
