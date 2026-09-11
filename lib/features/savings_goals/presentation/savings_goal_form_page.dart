import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/savings_goal_controller.dart';
import 'savings_goal_style.dart';

class SavingsGoalFormPage extends ConsumerStatefulWidget {
  const SavingsGoalFormPage({super.key, this.goal});

  /// Null means "create new"; non-null means "edit this goal".
  final SavingsGoalModel? goal;

  @override
  ConsumerState<SavingsGoalFormPage> createState() => _SavingsGoalFormPageState();
}

class _SavingsGoalFormPageState extends ConsumerState<SavingsGoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.goal?.name);
  late final _purposeController = TextEditingController(text: widget.goal?.purpose);
  late final _targetAmountController = TextEditingController(
    text: widget.goal != null ? widget.goal!.targetAmount.toStringAsFixed(0) : '',
  );

  late int? _selectedPortfolioId = widget.goal?.portfolioId;
  late DateTime? _targetDate = widget.goal?.targetDate;
  late String _icon = widget.goal?.icon ?? savingsGoalIconOptions.first;
  late String _color = widget.goal?.color ?? savingsGoalColorOptions.first;

  bool _isSubmitting = false;
  ApiException? _error;

  bool get _isEditing => widget.goal != null;

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _pickPortfolio(List<PortfolioModel> portfolios) async {
    // Sheet pops `0` (never a real portfolio id) for the explicit "Tidak
    // diikat ke akun manapun" option, and bare `null` only when dismissed
    // without choosing anything — otherwise dismiss-by-tapping-outside
    // would be indistinguishable from deliberately clearing the selection.
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _PortfolioPickerSheet(portfolios: portfolios, selectedId: _selectedPortfolioId),
    );
    if (selected == null) return;
    setState(() => _selectedPortfolioId = selected == 0 ? null : selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final name = _nameController.text.trim();
    final purpose = _purposeController.text.trim();
    final targetAmount = double.parse(_targetAmountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final controller = ref.read(savingsGoalControllerProvider.notifier);

    try {
      if (_isEditing) {
        await controller.editGoal(
          id: widget.goal!.id,
          name: name,
          purpose: purpose.isEmpty ? null : purpose,
          financePortfolioId: _selectedPortfolioId,
          targetAmount: targetAmount,
          targetDate: _targetDate,
          icon: _icon,
          color: _color,
        );
      } else {
        await controller.addGoal(
          name: name,
          purpose: purpose.isEmpty ? null : purpose,
          financePortfolioId: _selectedPortfolioId,
          targetAmount: targetAmount,
          targetDate: _targetDate,
          icon: _icon,
          color: _color,
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
    final selectedPortfolioName =
        portfoliosAsync.valueOrNull?.where((p) => p.id == _selectedPortfolioId).firstOrNull?.accountName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Target Tabungan' : 'Target Tabungan Baru')),
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
                AppTextField(
                  label: 'Nama target',
                  controller: _nameController,
                  icon: Icons.flag_outlined,
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nama target wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Tujuan (opsional)',
                  controller: _purposeController,
                  icon: Icons.notes_rounded,
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('purpose'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Jumlah Target (Rp)',
                  controller: _targetAmountController,
                  icon: Icons.savings_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('target_amount'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Jumlah target wajib diisi';
                    final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
                    if (parsed == null || parsed <= 0) return 'Jumlah tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Tenggat (opsional)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickTargetDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _targetDate != null ? formatIndonesianDate(_targetDate!) : 'Tanpa tenggat',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                          ),
                        ),
                        if (_targetDate != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                            onPressed: () => setState(() => _targetDate = null),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Akun sumber dana (opsional)',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                portfoliosAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat daftar akun.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (portfolios) => InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: portfolios.isEmpty ? null : () => _pickPortfolio(portfolios),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedPortfolioName ??
                                  (portfolios.isEmpty ? 'Belum ada akun' : 'Tidak diikat ke akun manapun'),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Warna', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final option in savingsGoalColorOptions)
                      _ColorChoice(
                        color: savingsGoalColorFor(option),
                        selected: _color == option,
                        onTap: () => setState(() => _color = option),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Ikon', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final option in savingsGoalIconOptions)
                      _IconChoice(
                        icon: savingsGoalIconFor(option),
                        color: savingsGoalColorFor(_color),
                        selected: _icon == option,
                        onTap: () => setState(() => _icon = option),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _isEditing ? 'Simpan Perubahan' : 'Buat Target',
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

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? AppColors.textPrimary : Colors.transparent, width: 2),
        ),
        child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({required this.icon, required this.color, required this.selected, required this.onTap});

  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Icon(icon, color: selected ? color : AppColors.textSecondary, size: 20),
      ),
    );
  }
}

class _PortfolioPickerSheet extends StatelessWidget {
  const _PortfolioPickerSheet({required this.portfolios, required this.selectedId});

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
            const Text('Pilih akun sumber dana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedId == null ? AppColors.primaryLight : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selectedId == null ? AppColors.primary : AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tidak diikat ke akun manapun',
                                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
