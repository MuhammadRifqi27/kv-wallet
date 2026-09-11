import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/ocr/receipt_parser.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../master_data/application/category_list_controller.dart';
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/transaction_list_controller.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key, this.transaction});

  /// Null means "create new"; non-null means "edit this transaction".
  final TransactionModel? transaction;

  @override
  ConsumerState<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.transaction != null ? widget.transaction!.amount.toStringAsFixed(0) : '',
  );
  late final _descriptionController = TextEditingController(text: widget.transaction?.description);

  late DateTime _date = widget.transaction?.date ?? DateTime.now();
  late TransactionType _type = widget.transaction?.type ?? TransactionType.expense;
  late int? _selectedCategoryId = widget.transaction?.categoryId;
  late int? _selectedPortfolioId = widget.transaction?.portfolioId;

  bool _isSubmitting = false;
  bool _isScanning = false;
  ApiException? _error;

  bool get _isEditing => widget.transaction != null;

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

  /// See docs/flutter-ocr-scan-struk-plan.txt — reads text off a struk
  /// photo on-device and prefills amount/tanggal/deskripsi. Never touches
  /// Kategori/Akun (OCR can't know either), and every field it does fill
  /// stays fully editable — this is a head start, not an auto-fill user
  /// can't correct.
  Future<void> _scanReceipt() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const _ScanSourceSheet(),
    );
    if (source == null || !mounted) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() => _isScanning = true);
    final text = await ref.read(receiptScannerProvider).recognizeText(picked.path);
    if (!mounted) return;
    setState(() => _isScanning = false);

    if (text == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membaca struk ini, silakan isi manual.')),
      );
      return;
    }

    final amount = parseAmountFromReceipt(text);
    final date = parseDateFromReceipt(text);
    final description = parseDescriptionFromReceipt(text);

    setState(() {
      if (amount != null) _amountController.text = amount.toStringAsFixed(0);
      if (date != null) _date = date;
      if (description != null) _descriptionController.text = description;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terisi otomatis dari struk — mohon periksa kembali sebelum simpan.')),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      setState(() => _error = ApiException(message: 'Pilih kategori terlebih dahulu.'));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final amount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final description = _descriptionController.text.trim();
    final controller = ref.read(transactionListControllerProvider.notifier);

    try {
      if (_isEditing) {
        await controller.editTransaction(
          id: widget.transaction!.id,
          date: _date,
          type: _type,
          categoryId: _selectedCategoryId!,
          amount: amount,
          portfolioId: _selectedPortfolioId,
          description: description.isEmpty ? null : description,
        );
      } else {
        await controller.addTransaction(
          date: _date,
          type: _type,
          categoryId: _selectedCategoryId!,
          amount: amount,
          portfolioId: _selectedPortfolioId,
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
      appBar: AppBar(title: Text(_isEditing ? 'Edit Transaksi' : 'Tambah Transaksi')),
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
                if (!_isEditing) ...[
                  _ScanReceiptButton(isScanning: _isScanning, onTap: _scanReceipt),
                  const SizedBox(height: 20),
                ],
                Text('Tipe', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                _TapField(
                  icon: Icons.calendar_today_outlined,
                  label: formatIndonesianDate(_date),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                categoriesAsync.when(
                  loading: () => LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat kategori.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (categories) {
                    final filtered = categories.where((c) => c.type.name == _type.name).toList();
                    return _CategoryPickerField(
                      categories: filtered,
                      selectedId: _selectedCategoryId,
                      onChanged: (id) => setState(() => _selectedCategoryId = id),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Akun (opsional)',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                portfoliosAsync.when(
                  loading: () => LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat akun.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (portfolios) => _PortfolioPickerField(
                    portfolios: portfolios,
                    selectedId: _selectedPortfolioId,
                    onChanged: (id) => setState(() => _selectedPortfolioId = id),
                  ),
                ),
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
                  label: _isEditing ? 'Simpan Perubahan' : 'Tambah Transaksi',
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

/// Full-width entry point for Scan Struk (see
/// docs/flutter-ocr-scan-struk-plan.txt) — styled like the app's other
/// promoted-action tiles (e.g. _RecurringMenuTile) rather than a bare
/// Material button, to match the rest of the form's look.
class _ScanReceiptButton extends StatelessWidget {
  const _ScanReceiptButton({required this.isScanning, required this.onTap});

  final bool isScanning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isScanning ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isScanning)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              else
                Icon(Icons.document_scanner_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                isScanning ? 'Membaca struk...' : 'Scan Struk',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanSourceSheet extends StatelessWidget {
  const _ScanSourceSheet();

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
            Text('Scan Struk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _ScanSourceTile(
              icon: Icons.camera_alt_outlined,
              label: 'Ambil Foto',
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
            _ScanSourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Pilih dari Galeri',
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanSourceTile extends StatelessWidget {
  const _ScanSourceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
            Expanded(child: Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 15))),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _CategoryPickerField extends StatelessWidget {
  const _CategoryPickerField({required this.categories, required this.selectedId, required this.onChanged});

  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int> onChanged;

  CategoryModel? get _selected {
    for (final category in categories) {
      if (category.id == selectedId) return category;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _PickerSheet<CategoryModel>(
        title: 'Pilih kategori',
        items: categories,
        selectedId: selectedId,
        idOf: (c) => c.id,
        titleOf: (c) => c.name,
        subtitleOf: (c) => c.type.label,
      ),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return _TapField(
      icon: Icons.category_outlined,
      label: selected?.name ?? (categories.isEmpty ? 'Belum ada kategori untuk tipe ini' : 'Pilih kategori'),
      onTap: categories.isEmpty ? () {} : () => _openPicker(context),
    );
  }
}

class _PortfolioPickerField extends StatelessWidget {
  const _PortfolioPickerField({required this.portfolios, required this.selectedId, required this.onChanged});

  final List<PortfolioModel> portfolios;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  PortfolioModel? get _selected {
    for (final portfolio in portfolios) {
      if (portfolio.id == selectedId) return portfolio;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _PickerSheet<PortfolioModel>(
        title: 'Pilih akun',
        items: portfolios,
        selectedId: selectedId,
        idOf: (p) => p.id,
        titleOf: (p) => p.accountName,
        subtitleOf: (p) => p.accountNumber ?? '',
        allowClear: true,
      ),
    );
    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return _TapField(
      icon: Icons.account_balance_wallet_outlined,
      label: selected?.accountName ?? 'Tidak ada',
      onTap: () => _openPicker(context),
    );
  }
}

/// Generic bottom-sheet list picker shared by category & portfolio pickers
/// — same custom-sheet pattern as the payroll day picker and Portfolio
/// form's investment picker, kept consistent instead of a stock dropdown.
class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.idOf,
    required this.titleOf,
    required this.subtitleOf,
    this.allowClear = false,
  });

  final String title;
  final List<T> items;
  final int? selectedId;
  final int Function(T) idOf;
  final String Function(T) titleOf;
  final String Function(T) subtitleOf;
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
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (allowClear)
                    _PickerRow(
                      title: 'Tidak ada',
                      subtitle: '',
                      selected: selectedId == null,
                      onTap: () => Navigator.of(context).pop(null),
                    ),
                  for (final item in items)
                    _PickerRow(
                      title: titleOf(item),
                      subtitle: subtitleOf(item),
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
  const _PickerRow({required this.title, required this.subtitle, required this.selected, required this.onTap});

  final String title;
  final String subtitle;
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
