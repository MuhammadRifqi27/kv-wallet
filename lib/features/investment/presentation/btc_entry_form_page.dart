import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/btc_tracking_model.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../master_data/application/investment_list_controller.dart';
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/btc_tracking_controller.dart';

/// Only logs Profit/Loss adjustments — deposit/withdrawal (real money
/// movement) happen via Transfer Antar Akun instead, see
/// InvestmentDashboardPage's doc comment. The account can't be changed on
/// edit (matches `PUT /btc-tracking/{id}`, which doesn't take
/// `finance_investment_id`) — that field is hidden once editing.
class BtcEntryFormPage extends ConsumerStatefulWidget {
  const BtcEntryFormPage({super.key, this.entry});

  /// Null means "create new"; non-null means "edit this entry". Editing a
  /// `source_type: "transfer"` entry isn't possible — the activity page
  /// never routes here for those.
  final BtcActivityItem? entry;

  @override
  ConsumerState<BtcEntryFormPage> createState() => _BtcEntryFormPageState();
}

class _BtcEntryFormPageState extends ConsumerState<BtcEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _assetController = TextEditingController(text: widget.entry?.asset);
  late final _amountController = TextEditingController(
    text: widget.entry != null ? widget.entry!.amount.toStringAsFixed(0) : '',
  );
  late final _descriptionController = TextEditingController(text: widget.entry?.description);

  late DateTime _date = widget.entry?.date ?? DateTime.now();
  late BtcEntryType _type = widget.entry?.type == 'loss' ? BtcEntryType.loss : BtcEntryType.profit;
  late int? _selectedPortfolioId = widget.entry?.portfolioId;

  bool _isSubmitting = false;
  ApiException? _error;

  bool get _isEditing => widget.entry != null;

  @override
  void dispose() {
    _assetController.dispose();
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

  Future<void> _pickPortfolio(List<PortfolioModel> cryptoPortfolios) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _PortfolioPickerSheet(portfolios: cryptoPortfolios, selectedId: _selectedPortfolioId),
    );
    if (selected != null) setState(() => _selectedPortfolioId = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPortfolioId == null) {
      setState(() => _error = ApiException(message: 'Pilih akun crypto terlebih dahulu.'));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final asset = _assetController.text.trim().toUpperCase();
    final amount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    final description = _descriptionController.text.trim();
    final controller = ref.read(btcActivityControllerProvider.notifier);

    try {
      if (_isEditing) {
        await controller.editEntry(
          id: widget.entry!.id,
          asset: asset,
          date: _date,
          type: _type,
          amount: amount,
          description: description.isEmpty ? null : description,
        );
      } else {
        await controller.addEntry(
          portfolioId: _selectedPortfolioId!,
          asset: asset,
          date: _date,
          type: _type,
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
    final investmentsAsync = ref.watch(investmentListControllerProvider);
    final generalError = _error != null && _error!.fieldErrors == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Profit/Loss' : 'Catat Profit/Loss')),
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
                  Text('Akun Crypto', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  (portfoliosAsync.isLoading || investmentsAsync.isLoading)
                      ? LinearProgressIndicator(color: AppColors.primary)
                      : Builder(
                          builder: (context) {
                            final cryptoPortfolios = filterCryptoPortfolios(
                              portfoliosAsync.valueOrNull ?? const [],
                              investmentsAsync.valueOrNull ?? const [],
                            );
                            final selected = cryptoPortfolios.where((p) => p.id == _selectedPortfolioId).firstOrNull;
                            return _TapField(
                              icon: Icons.account_balance_wallet_outlined,
                              label: selected?.accountName ?? (cryptoPortfolios.isEmpty ? 'Belum ada akun crypto' : 'Pilih akun'),
                              onTap: cryptoPortfolios.isEmpty ? null : () => _pickPortfolio(cryptoPortfolios),
                            );
                          },
                        ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  label: 'Simbol aset (mis. BTC)',
                  controller: _assetController,
                  icon: Icons.currency_bitcoin_rounded,
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('asset'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Simbol aset wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text('Tipe', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                SegmentedButton<BtcEntryType>(
                  segments: const [
                    ButtonSegment(value: BtcEntryType.profit, label: Text('Profit'), icon: Icon(Icons.trending_up_rounded)),
                    ButtonSegment(value: BtcEntryType.loss, label: Text('Loss'), icon: Icon(Icons.trending_down_rounded)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) => setState(() => _type = selection.first),
                ),
                const SizedBox(height: 16),
                Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                _TapField(icon: Icons.calendar_today_outlined, label: formatIndonesianDate(_date), onTap: _pickDate),
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
                    if (parsed == null || parsed < 0) return 'Jumlah tidak valid';
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
                  label: _isEditing ? 'Simpan Perubahan' : 'Simpan',
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
            Expanded(child: Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 15))),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ],
        ),
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
            Text('Pilih akun crypto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
