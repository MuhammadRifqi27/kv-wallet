import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/payroll_settings_controller.dart';
import 'category_list_page.dart' show scrollableCenter, ListErrorState;

class PayrollSettingsPage extends ConsumerWidget {
  const PayrollSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(payrollSettingsControllerProvider);
    final controller = ref.read(payrollSettingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Siklus Gajian')),
      body: settingsAsync.when(
        loading: () => scrollableCenter(const CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => scrollableCenter(
          ListErrorState(
            message: error is ApiException ? error.message : 'Gagal memuat pengaturan.',
            onRetry: controller.refresh,
          ),
        ),
        data: (payrollStartDay) => _PayrollForm(initialValue: payrollStartDay),
      ),
    );
  }
}

class _PayrollForm extends ConsumerStatefulWidget {
  const _PayrollForm({required this.initialValue});

  final Object? initialValue;

  @override
  ConsumerState<_PayrollForm> createState() => _PayrollFormState();
}

class _PayrollFormState extends ConsumerState<_PayrollForm> {
  late bool _useEndOfMonth = widget.initialValue.toString() == 'last';
  late int _day = _parseDay(widget.initialValue);

  /// Backend stores `payroll_start_day` in a generic key-value settings
  /// table, so it can come back as a `String` (e.g. `"10"`) even though we
  /// send it as an `int` — handle both instead of assuming one shape.
  static int _parseDay(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 25;
    return 25;
  }

  bool _isSubmitting = false;
  ApiException? _error;

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref
          .read(payrollSettingsControllerProvider.notifier)
          .updatePayrollStartDay(_useEndOfMonth ? 'last' : _day);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siklus gajian berhasil disimpan.')),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tanggal mulai siklus gajian menentukan periode yang dipakai Dashboard, '
            'Budget, dan Ringkasan — bukan tanggal 1-31 kalender biasa.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            ErrorBanner(message: _error!.message),
            const SizedBox(height: 16),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              value: _useEndOfMonth,
              onChanged: (value) => setState(() => _useEndOfMonth = value),
              activeThumbColor: AppColors.primary,
              title: const Text(
                'Pakai akhir bulan',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Siklus mulai dari tanggal terakhir tiap bulan',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
            ),
          ),
          if (!_useEndOfMonth) ...[
            const SizedBox(height: 8),
            const Text('Tanggal mulai', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            _DayPickerField(
              day: _day,
              onChanged: (value) => setState(() => _day = value),
            ),
          ],
          const SizedBox(height: 28),
          PrimaryButton(label: 'Simpan', isLoading: _isSubmitting, onPressed: _submit),
        ],
      ),
    );
  }
}

/// Tap target that opens [_DayPickerSheet] — a calendar-style grid instead
/// of the stock `DropdownButtonFormField` menu, which always renders with
/// Material's own popup styling regardless of app theme.
class _DayPickerField extends StatelessWidget {
  const _DayPickerField({required this.day, required this.onChanged});

  final int day;
  final ValueChanged<int> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _DayPickerSheet(selectedDay: day),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tanggal $day',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DayPickerSheet extends StatelessWidget {
  const _DayPickerSheet({required this.selectedDay});

  final int selectedDay;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih tanggal mulai',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 31,
              itemBuilder: (context, index) {
                final day = index + 1;
                final selected = day == selectedDay;
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.of(context).pop(day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
