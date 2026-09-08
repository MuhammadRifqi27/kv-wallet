import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../data/models/recurring_transaction_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../master_data/application/category_list_controller.dart';
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/recurring_list_controller.dart';

/// `POST /money-management/recurring` for create, `PUT .../{id}` for edit —
/// same body shape for both (see docs/mobile-api-reference.md's "Recurring
/// Transactions" section), so this form handles both in one place, mirroring
/// TransactionFormPage's create/edit pattern.
class RecurringFormPage extends ConsumerStatefulWidget {
  const RecurringFormPage({super.key, this.recurring});

  /// Null means "create new"; non-null means "edit this template".
  final RecurringTransactionModel? recurring;

  @override
  ConsumerState<RecurringFormPage> createState() => _RecurringFormPageState();
}

class _RecurringFormPageState extends ConsumerState<RecurringFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.recurring?.name);
  late final _amountController = TextEditingController(
    text: widget.recurring != null ? widget.recurring!.amount.toStringAsFixed(0) : '',
  );
  late final _descriptionController = TextEditingController(text: widget.recurring?.description);

  late TransactionType _type = widget.recurring?.type ?? TransactionType.expense;
  late RecurringFrequency _frequency = widget.recurring?.frequency ?? RecurringFrequency.monthly;
  late DateTime _startDate = widget.recurring?.startDate ?? DateTime.now();
  late int? _selectedCategoryId = widget.recurring?.categoryId;
  late int? _selectedPortfolioId = widget.recurring?.portfolioId;

  bool _isSubmitting = false;
  ApiException? _error;

  bool get _isEditing => widget.recurring != null;

  /// Per docs/mobile-api-reference.md: editing `start_date` only shifts
  /// `next_date` if the template hasn't been processed yet (i.e. it never
  /// advanced past its original start date). Once it has run at least once,
  /// `start_date` becomes purely historical.
  bool get _startDateIsHistorical {
    final recurring = widget.recurring;
    if (recurring == null || recurring.nextDate == null) return false;
    return recurring.nextDate!.isAfter(recurring.startDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickFrequency() async {
    final selected = await showModalBottomSheet<RecurringFrequency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _FrequencyPickerSheet(selected: _frequency),
    );
    if (selected != null) setState(() => _frequency = selected);
  }

  Future<void> _pickCategory(List<CategoryModel> categories) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _PickerSheet<CategoryModel>(
        title: 'Pilih kategori',
        items: categories,
        selectedId: _selectedCategoryId,
        idOf: (c) => c.id,
        titleOf: (c) => c.name,
      ),
    );
    if (selected != null) setState(() => _selectedCategoryId = selected);
  }

  Future<void> _pickPortfolio(List<PortfolioModel> portfolios) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _PickerSheet<PortfolioModel>(
        title: 'Pilih akun',
        items: portfolios,
        selectedId: _selectedPortfolioId,
        idOf: (p) => p.id,
        titleOf: (p) => p.accountName,
      ),
    );
    if (selected != null) setState(() => _selectedPortfolioId = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      setState(() => _error = ApiException(message: 'Pilih kategori terlebih dahulu.'));
      return;
    }
    if (_selectedPortfolioId == null) {
      setState(() => _error = ApiException(message: 'Pilih akun terlebih dahulu.'));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final amount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final description = _descriptionController.text.trim();
    final controller = ref.read(recurringListControllerProvider.notifier);

    try {
      if (_isEditing) {
        await controller.editRecurring(
          id: widget.recurring!.id,
          name: _nameController.text.trim(),
          type: _type,
          categoryId: _selectedCategoryId!,
          portfolioId: _selectedPortfolioId!,
          frequency: _frequency,
          startDate: _startDate,
          amount: amount,
          description: description.isEmpty ? null : description,
        );
      } else {
        await controller.addRecurring(
          name: _nameController.text.trim(),
          type: _type,
          categoryId: _selectedCategoryId!,
          portfolioId: _selectedPortfolioId!,
          frequency: _frequency,
          startDate: _startDate,
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
    final categoriesAsync = ref.watch(categoryListControllerProvider);
    final portfoliosAsync = ref.watch(portfolioListControllerProvider);
    final generalError = _error != null && _error!.fieldErrors == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Transaksi Berulang' : 'Tambah Transaksi Berulang')),
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
                  label: 'Nama',
                  controller: _nameController,
                  icon: Icons.label_outline_rounded,
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Tipe', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Pengeluaran'),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Pemasukan'),
                      icon: Icon(Icons.arrow_downward_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) => setState(() {
                    _type = selection.first;
                    // Selected category may not belong to the new type anymore.
                    _selectedCategoryId = null;
                  }),
                ),
                const SizedBox(height: 16),
                const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                categoriesAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat kategori.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (categories) {
                    final filtered = categories.where((c) => c.type.name == _type.name).toList();
                    final selected = filtered.where((c) => c.id == _selectedCategoryId).firstOrNull;
                    return _TapField(
                      icon: Icons.category_outlined,
                      label: selected?.name ?? (filtered.isEmpty ? 'Belum ada kategori untuk tipe ini' : 'Pilih kategori'),
                      onTap: filtered.isEmpty ? null : () => _pickCategory(filtered),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Akun', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                portfoliosAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat akun.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (portfolios) {
                    final selected = portfolios.where((p) => p.id == _selectedPortfolioId).firstOrNull;
                    return _TapField(
                      icon: Icons.account_balance_wallet_outlined,
                      label: selected?.accountName ?? (portfolios.isEmpty ? 'Belum ada akun' : 'Pilih akun'),
                      onTap: portfolios.isEmpty ? null : () => _pickPortfolio(portfolios),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Frekuensi', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                _TapField(icon: Icons.repeat_rounded, label: _frequency.label, onTap: _pickFrequency),
                const SizedBox(height: 16),
                const Text('Mulai Tanggal', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                _TapField(
                  icon: Icons.calendar_today_outlined,
                  label: formatIndonesianDate(_startDate),
                  onTap: _pickStartDate,
                ),
                if (_startDateIsHistorical) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Template ini sudah pernah diproses, jadi mengubah tanggal ini tidak '
                    'menggeser jadwal berikutnya — cuma jadi catatan kapan pertama dibuat.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
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
                  label: _isEditing ? 'Simpan Perubahan' : 'Tambah',
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

class _FrequencyPickerSheet extends StatelessWidget {
  const _FrequencyPickerSheet({required this.selected});

  final RecurringFrequency selected;

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
            const Text('Pilih frekuensi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            for (final frequency in RecurringFrequency.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(frequency),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: frequency == selected ? AppColors.primaryLight : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: frequency == selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(frequency.label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ),
                        if (frequency == selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

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

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.idOf,
    required this.titleOf,
    this.allowClear = false,
  });

  final String title;
  final List<T> items;
  final int? selectedId;
  final int Function(T) idOf;
  final String Function(T) titleOf;
  final bool allowClear;

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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (allowClear)
                    _PickerRow(title: 'Tidak ada', selected: selectedId == null, onTap: () => Navigator.of(context).pop(null)),
                  for (final item in items)
                    _PickerRow(
                      title: titleOf(item),
                      selected: idOf(item) == selectedId,
                      onTap: () => Navigator.of(context).pop(idOf(item)),
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

class _PickerRow extends StatelessWidget {
  const _PickerRow({required this.title, required this.selected, required this.onTap});

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
