import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../master_data/presentation/category_list_page.dart' show ListEmptyState, ListErrorState;
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/savings_goal_controller.dart';
import 'savings_goal_style.dart';

/// Opened by tapping a goal card on [SavingsGoalListPage]. `goal` is the
/// snapshot at tap time; the header re-reads the live value from
/// [savingsGoalControllerProvider] (falling back to that snapshot) so
/// `saved_amount`/`progress_percent`/`status` reflect any contribution
/// logged from this same page without needing to pop back first — same
/// "valueOrNull...firstOrNull ?? fallback" pattern as AssetDetailPage.
class SavingsGoalDetailPage extends ConsumerWidget {
  const SavingsGoalDetailPage({super.key, required this.goal});

  final SavingsGoalModel goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(savingsGoalControllerProvider).valueOrNull?.goals.where((g) => g.id == goal.id).firstOrNull ??
        goal;
    final contributionsAsync = ref.watch(savingsGoalContributionsProvider(goal.id));
    final color = savingsGoalColorFor(latest.color);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(latest.name)),
      floatingActionButton: latest.status == SavingsGoalStatus.archived
          ? null
          : FloatingActionButton(
              onPressed: () => _openContributionForm(context, ref),
              backgroundColor: AppColors.primary,
              tooltip: 'Catat Nabung/Tarik',
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(savingsGoalContributionsProvider(goal.id));
          await ref.read(savingsGoalControllerProvider.notifier).refresh();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _GoalSummaryCard(goal: latest, color: color),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Nabung/Tarik',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            contributionsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: AppLoadingIndicator()),
              ),
              error: (error, _) => ListErrorState(
                message: error is ApiException ? error.message : 'Gagal memuat riwayat.',
                onRetry: () async => ref.invalidate(savingsGoalContributionsProvider(goal.id)),
              ),
              data: (contributions) {
                if (contributions.isEmpty) {
                  return const ListEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum ada riwayat',
                    subtitle: 'Tekan tombol + untuk mencatat nabung/tarik pertama.',
                  );
                }
                return Column(
                  children: [
                    for (final contribution in contributions) ...[
                      _ContributionTile(goalId: goal.id, contribution: contribution),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openContributionForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _ContributionFormSheet(goal: goal),
    );
  }
}

class _GoalSummaryCard extends StatelessWidget {
  const _GoalSummaryCard({required this.goal, required this.color});

  final SavingsGoalModel goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(savingsGoalIconFor(goal.icon), color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    if (goal.purpose != null && goal.purpose!.isNotEmpty)
                      Text(
                        goal.purpose!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  savingsGoalStatusLabel(goal.status),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Terkumpul', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            formatRupiah(goal.savedAmount),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target ${formatRupiah(goal.targetAmount)}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
              Text(
                '${goal.progressPercent.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
          if (goal.remainingAmount > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Kurang ${formatRupiah(goal.remainingAmount)} lagi',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
          if (goal.targetDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tenggat ${formatIndonesianDate(goal.targetDate!)}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
          if (goal.portfolioName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Akun default: ${goal.portfolioName}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
          if (goal.isOverAllocated) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Total alokasi ke akun ini dari semua goal sudah melebihi saldo aslinya.',
                      style: TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContributionTile extends ConsumerWidget {
  const _ContributionTile({required this.goalId, required this.contribution});

  final int goalId;
  final SavingsGoalContributionModel contribution;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus baris ini?'),
        content: const Text('Baris riwayat ini akan dihapus permanen dan progress target dihitung ulang.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(savingsGoalControllerProvider.notifier)
          .removeContribution(goalId: goalId, contributionId: contribution.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWithdrawal = contribution.type == SavingsGoalEntryType.withdrawal;
    final color = isWithdrawal ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              isWithdrawal ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWithdrawal ? 'Tarik' : 'Nabung',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    formatIndonesianDateShort(contribution.date),
                    if (contribution.portfolioName != null) contribution.portfolioName!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                if (contribution.note != null && contribution.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    contribution.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isWithdrawal ? '-' : '+'} ${formatRupiah(contribution.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 18),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}

class _ContributionFormSheet extends ConsumerStatefulWidget {
  const _ContributionFormSheet({required this.goal});

  final SavingsGoalModel goal;

  @override
  ConsumerState<_ContributionFormSheet> createState() => _ContributionFormSheetState();
}

class _ContributionFormSheetState extends ConsumerState<_ContributionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  SavingsGoalEntryType _type = SavingsGoalEntryType.contribution;
  DateTime _date = DateTime.now();
  late int? _selectedPortfolioId = widget.goal.portfolioId;

  bool _isSubmitting = false;
  ApiException? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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

  Future<void> _pickPortfolio(List<PortfolioModel> portfolios) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _ContributionPortfolioPickerSheet(portfolios: portfolios, selectedId: _selectedPortfolioId),
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

    final amount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final note = _noteController.text.trim();

    try {
      await ref.read(savingsGoalControllerProvider.notifier).addContribution(
            goalId: widget.goal.id,
            type: _type,
            date: _date,
            amount: amount,
            financePortfolioId: _selectedPortfolioId,
            note: note.isEmpty ? null : note,
          );
      if (mounted) Navigator.of(context).pop();
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

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  'Catat Nabung/Tarik',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                if (generalError) ...[
                  ErrorBanner(message: _error!.message),
                  const SizedBox(height: 16),
                ],
                SegmentedButton<SavingsGoalEntryType>(
                  segments: const [
                    ButtonSegment(
                      value: SavingsGoalEntryType.contribution,
                      label: Text('Nabung'),
                      icon: Icon(Icons.arrow_downward_rounded),
                    ),
                    ButtonSegment(
                      value: SavingsGoalEntryType.withdrawal,
                      label: Text('Tarik'),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) => setState(() => _type = selection.first),
                ),
                const SizedBox(height: 16),
                const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text(formatIndonesianDate(_date), style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                      ],
                    ),
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
                const Text('Akun (opsional)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                        color: AppColors.background,
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
                                  (portfolios.isEmpty ? 'Belum ada akun' : 'Tidak dicatat ke akun manapun'),
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
                AppTextField(
                  label: 'Catatan (opsional)',
                  controller: _noteController,
                  icon: Icons.notes_rounded,
                  textInputAction: TextInputAction.done,
                  errorText: _error?.errorFor('note'),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Simpan', isLoading: _isSubmitting, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContributionPortfolioPickerSheet extends StatelessWidget {
  const _ContributionPortfolioPickerSheet({required this.portfolios, required this.selectedId});

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
                        child: const Text(
                          'Tidak dicatat ke akun manapun',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
