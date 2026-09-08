import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../master_data/application/category_list_controller.dart';
import '../application/budget_controller.dart';

class BudgetFormPage extends ConsumerStatefulWidget {
  const BudgetFormPage({super.key, this.budget});

  /// Null means "create new"; non-null means "edit this category's budget".
  /// There's no separate update endpoint on the backend — both cases call
  /// [BudgetController.addBudget], which upserts by category + period (see
  /// docs/flutter-mobile-app-development-guide.txt BAGIAN "BUDGET": the
  /// same `POST /money-management/budgets` is used for both).
  final BudgetCategoryItem? budget;

  @override
  ConsumerState<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends ConsumerState<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.budget != null ? widget.budget!.amount.toStringAsFixed(0) : '',
  );

  late int? _selectedCategoryId = widget.budget?.categoryId;
  bool _isSubmitting = false;
  ApiException? _error;

  bool get _isEditing => widget.budget != null;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _openCategoryPicker(List<CategoryModel> categories) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _CategoryPickerSheet(categories: categories, selectedId: _selectedCategoryId),
    );
    if (selected != null) setState(() => _selectedCategoryId = selected);
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

    try {
      await ref.read(budgetControllerProvider.notifier).addBudget(
            categoryId: _selectedCategoryId!,
            amount: amount,
          );
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
    final period = ref.watch(selectedBudgetPeriodProvider);
    final generalError = _error != null && _error!.fieldErrors == null;

    // Categories that already have a budget this period shouldn't be
    // pickable from "Tambah Budget" — re-adding one there would silently
    // overwrite it (same upsert endpoint) instead of visibly editing it.
    // Editing an existing one happens by tapping its card in the list
    // instead, which opens this form with `budget` set and the category
    // locked in.
    final alreadyBudgetedIds = _isEditing
        ? const <int>{}
        : (ref.watch(budgetControllerProvider).valueOrNull?.categories.map((c) => c.categoryId).toSet() ??
            const <int>{});

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Budget' : 'Tambah Budget')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Untuk periode ${monthName(period.month)} ${period.year}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                if (generalError) ...[
                  ErrorBanner(message: _error!.message),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Kategori Pengeluaran',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                categoriesAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => const Text(
                    'Gagal memuat kategori.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (categories) {
                    final expenseCategories = categories
                        .where((c) => c.type == CategoryType.expense)
                        .where((c) => _isEditing || !alreadyBudgetedIds.contains(c.id))
                        .toList();
                    final selected = categories.where((c) => c.id == _selectedCategoryId).firstOrNull;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _isEditing || expenseCategories.isEmpty
                          ? null
                          : () => _openCategoryPicker(expenseCategories),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: _isEditing ? AppColors.background : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.category_outlined, color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selected?.name ??
                                    (expenseCategories.isEmpty ? 'Semua kategori sudah punya budget' : 'Pilih kategori'),
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                              ),
                            ),
                            if (!_isEditing)
                              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Jumlah Budget (Rp)',
                  controller: _amountController,
                  icon: Icons.calculate_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  textInputAction: TextInputAction.done,
                  errorText: _error?.errorFor('amount'),
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Jumlah wajib diisi';
                    final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
                    if (parsed == null || parsed <= 0) return 'Jumlah tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _isEditing ? 'Simpan Perubahan' : 'Tambah Budget',
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

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({required this.categories, required this.selectedId});

  final List<CategoryModel> categories;
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
              'Pilih kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final category in categories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).pop(category.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: category.id == selectedId ? AppColors.primaryLight : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: category.id == selectedId ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ),
                              if (category.id == selectedId)
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
