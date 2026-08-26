import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_controller.dart';

/// wa.me link expects international format, no leading zero.
const _customerServiceWhatsApp = '6289628169104';

/// Landing page for the "settings" permission — Master Data (kategori,
/// provider investasi) & Pengaturan, per
/// docs/flutter-mobile-app-development-guide.txt BAGIAN 3.6. Master data is
/// view-only here (admin manages it via the web app); only Siklus Gajian
/// is editable from mobile.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar akun?'),
        content: const Text('Anda perlu login kembali untuk mengakses aplikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authControllerProvider.notifier).logout();
    // Explicit navigation instead of relying only on the router's redirect
    // + refreshListenable to notice the auth state change on its own.
    if (context.mounted) context.go('/login');
  }

  Future<void> _contactCustomerService(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/$_customerServiceWhatsApp');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel('Master Data'),
          _SettingsTile(
            icon: Icons.category_outlined,
            title: 'Kategori',
            subtitle: 'Kategori pemasukan & pengeluaran',
            onTap: () => context.push('/settings/categories'),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.account_balance_outlined,
            title: 'Provider Investasi',
            subtitle: 'Bank, exchange, dan broker',
            onTap: () => context.push('/settings/investments'),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Lainnya'),
          _SettingsTile(
            icon: Icons.tune_rounded,
            title: 'Siklus Gajian',
            subtitle: 'Atur tanggal mulai periode gajian',
            onTap: () => context.push('/settings/payroll'),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Upgrade Membership',
            subtitle: 'Naik ke Member atau Member Premium',
            onTap: () => context.push('/settings/membership'),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.support_agent_rounded,
            title: 'Hubungi Customer Service',
            subtitle: 'Chat langsung lewat WhatsApp',
            onTap: () => _contactCustomerService(context),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Akun'),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            subtitle: 'Logout dari akun ini',
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ),
    );
  }
}
