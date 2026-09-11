import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/membership_status_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/application/auth_controller.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListErrorState;
import '../application/membership_controller.dart';

/// Static payment destination — not provided by the API (see
/// docs/pin-and-membership-plan-api-reference.md: "kelola sebagai konten
/// statis di app").
const _bankName = 'SEABANK';
const _bankAccountNumber = '901026474553';
const _bankAccountHolder = 'Muhammad Rifqi Zaki Rizqullah';

/// Refreshes membership status/plans and, if that reveals the payment is
/// now verified, also refetches `/auth/me` so permissions (and locked
/// navbar tabs) update immediately instead of needing a re-login. Shared
/// by pull-to-refresh and the "Saya sudah transfer, cek status" button.
Future<void> _refreshMembership(WidgetRef ref) async {
  ref.invalidate(membershipPlansProvider);
  ref.invalidate(membershipStatusProvider);
  final status = await ref.read(membershipStatusProvider.future);
  if (status.isPaidMember) {
    await ref.read(authControllerProvider.notifier).refreshUser();
  }
}

class MembershipPlansPage extends ConsumerWidget {
  const MembershipPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(membershipStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Upgrade Membership')),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _refreshMembership(ref),
        child: statusAsync.when(
          loading: () => scrollableCenter(const AppLoadingIndicator()),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : 'Gagal memuat status membership.',
              onRetry: () async => ref.invalidate(membershipStatusProvider),
            ),
          ),
          data: (status) => _MembershipBody(status: status),
        ),
      ),
    );
  }
}

class _MembershipBody extends ConsumerWidget {
  const _MembershipBody({required this.status});

  final MembershipStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(membershipPlansProvider);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _StatusCard(status: status),
        if (status.isPendingVerification) ...[
          const SizedBox(height: 16),
          _PaymentInstructions(status: status),
        ],
        const SizedBox(height: 24),
        Text(
          'Pilih Plan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        plansAsync.when(
          loading: () => Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
          error: (error, _) => ListErrorState(
            message: error is ApiException ? error.message : 'Gagal memuat daftar plan.',
            onRetry: () async => ref.invalidate(membershipPlansProvider),
          ),
          data: (plans) => Column(
            children: [
              for (final plan in plans) ...[
                _PlanCard(plan: plan, status: status),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final MembershipStatus status;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String subtitle;
    final Color color;
    final IconData icon;

    if (status.isPaidMember) {
      title = status.membershipPlan?.name ?? 'Member';
      final expiresAt = status.membershipExpiresAt;
      subtitle = expiresAt != null ? 'Berlaku sampai ${formatIndonesianDate(expiresAt)}' : 'Aktif';
      color = AppColors.success;
      icon = Icons.workspace_premium_rounded;
    } else if (status.isPendingVerification) {
      title = status.membershipPlan?.name ?? 'Member';
      subtitle = 'Menunggu verifikasi pembayaran dari admin';
      color = AppColors.accent;
      icon = Icons.hourglass_top_rounded;
    } else {
      title = 'Free';
      subtitle = 'Belum upgrade membership';
      color = AppColors.textSecondary;
      icon = Icons.account_circle_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInstructions extends ConsumerStatefulWidget {
  const _PaymentInstructions({required this.status});

  final MembershipStatus status;

  @override
  ConsumerState<_PaymentInstructions> createState() => _PaymentInstructionsState();
}

class _PaymentInstructionsState extends ConsumerState<_PaymentInstructions> {
  bool _checking = false;

  Future<void> _checkStatus() async {
    setState(() => _checking = true);
    try {
      await _refreshMembership(ref);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final plansAsync = ref.watch(membershipPlansProvider);
    final planId = status.membershipPlan?.id;
    final price = plansAsync.asData?.value.where((p) => p.id == planId).firstOrNull?.price;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transfer Manual',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'Bank', value: _bankName),
          _InfoRow(label: 'No. Rekening', value: _bankAccountNumber),
          _InfoRow(label: 'Atas Nama', value: _bankAccountHolder),
          if (price != null) _InfoRow(label: 'Nominal', value: formatRupiah(price)),
          const SizedBox(height: 12),
          const Text(
            'Setelah transfer, admin akan memverifikasi pembayaran dan mengaktifkan membership Anda secara manual.',
            style: TextStyle(color: AppColors.primaryDark, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _checking ? null : _checkStatus,
              child: _checking
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
                    )
                  : const Text('Saya sudah transfer, cek status'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.primaryDark, fontSize: 12.5)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.primaryDark, fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan, required this.status});

  final MembershipPlan plan;
  final MembershipStatus status;

  bool get _isCurrentPlan => status.membershipPlan?.id == plan.id;

  Future<void> _showPlanDetail(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => _PlanDetailSheet(
        plan: plan,
        onSelectPlan: () {
          Navigator.of(sheetContext).pop();
          _confirmAndSelect(context, ref);
        },
      ),
    );
  }

  Future<void> _confirmAndSelect(BuildContext context, WidgetRef ref) async {
    final isSwitchingActivePlan = status.isPaidMember && !_isCurrentPlan;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Konfirmasi ${plan.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan upgrade ke plan ${plan.name} seharga ${formatRupiah(plan.price)} '
              'untuk ${plan.durationDays} hari.',
            ),
            if (isSwitchingActivePlan) ...[
              const SizedBox(height: 12),
              const Text(
                'Plan Anda saat ini masih aktif. Mengganti ke plan lain akan mereset akses '
                'Anda ke Free sampai pembayaran baru diverifikasi admin.',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Konfirmasi')),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await ref.read(selectPlanControllerProvider.notifier).selectPlan(plan.id);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan dipilih. Silakan transfer sesuai instruksi di atas.')),
      );
    } else {
      final error = ref.read(selectPlanControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.message ?? 'Gagal memilih plan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectState = ref.watch(selectPlanControllerProvider);

    final isLockedActive = _isCurrentPlan && status.isPaidMember;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isLockedActive || selectState.isLoading ? null : () => _showPlanDetail(context, ref),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _isCurrentPlan ? AppColors.primary : AppColors.border, width: _isCurrentPlan ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '${formatRupiah(plan.price)} / ${plan.durationDays} hari',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (isLockedActive)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Plan Aktif', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12.5)),
                )
              else
                OutlinedButton(
                  onPressed: selectState.isLoading ? null : () => _showPlanDetail(context, ref),
                  child: const Text('Pilih Plan'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full plan info shown as a bottom sheet before the user commits — name,
/// price, and the benefit list (from [MembershipPlan.description]) — with
/// "Pilih Plan" at the bottom leading into the confirmation dialog.
class _PlanDetailSheet extends StatelessWidget {
  const _PlanDetailSheet({required this.plan, required this.onSelectPlan});

  final MembershipPlan plan;
  final VoidCallback onSelectPlan;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
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
              plan.name,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '${formatRupiah(plan.price)} / ${plan.durationDays} hari',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            if (plan.benefits.isNotEmpty) ...[
              Text(
                'Fitur yang didapat',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [for (final benefit in plan.benefits) _BenefitRow(text: benefit)],
                  ),
                ),
              ),
            ] else
              Text(
                'Detail fitur untuk plan ini belum tersedia.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: 'Pilih Plan', onPressed: onSelectPlan),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
