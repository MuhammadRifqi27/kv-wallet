import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/biometric_enroll.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../../auth/application/auth_controller.dart';
import '../../pin/presentation/confirm_pin_sheet.dart';

const _customerServiceFormUrl = 'https://forms.gle/DsB5KK67qddKvUuM9';
const _instagramUrl = 'https://www.instagram.com/kodevisual';

/// Turning biometric login on/off — see BiometricService's doc comment for
/// why this is `biometricOnly` (no device-credential fallback) and
/// SecureStorageService.saveCachedPin for why a PIN needs caching at all.
/// Disabling never needs re-confirmation: wiping the cached PIN is always
/// safe, there's nothing destructive about it.
Future<void> _setBiometricEnabled(BuildContext context, WidgetRef ref, bool enabled) async {
  if (!enabled) {
    await ref.read(secureStorageServiceProvider).deleteCachedPin();
    await ref.read(biometricPreferenceServiceProvider).setEnabled(false);
    ref.read(biometricEnabledProvider.notifier).state = false;
    return;
  }

  if (!await ref.read(biometricServiceProvider).isSupported()) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perangkat ini tidak mendukung atau belum mendaftarkan biometrik.')),
      );
    }
    return;
  }
  if (!context.mounted) return;

  // Need the plaintext PIN once, to cache it — nothing else in the app
  // holds it in memory at the point this toggle is flipped.
  final confirmedPin = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => const ConfirmPinSheet(),
  );
  if (confirmedPin == null || !context.mounted) return;

  final enrolled = await enrollBiometricLogin(
    ref,
    pin: confirmedPin,
    reason: 'Aktifkan login biometrik untuk Flowr',
  );
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        enrolled
            ? 'Biometrik aktif. Mulai sekarang cukup tap "Gunakan Biometrik" di layar kunci untuk masuk tanpa PIN.'
            : 'Verifikasi biometrik gagal atau dibatalkan.',
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

Future<void> _setThemeMode(WidgetRef ref, ThemeMode mode) async {
  ref.read(themeModeProvider.notifier).state = mode;
  await ref.read(themePreferenceServiceProvider).setThemeMode(mode);
}

/// Landing page for the "settings" permission — framed as the user's
/// account/profile hub: profile info + membership status up top, then
/// Portfolio, Master Data (kategori, provider investasi — view-only, admin
/// manages it via the web app) and other settings below, per
/// docs/flutter-mobile-app-development-guide.txt BAGIAN 3.6.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
    final uri = Uri.parse(_customerServiceFormUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka form.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) _ProfileHeader(user: user),
          const SizedBox(height: 24),
          const _SectionLabel('Portfolio'),
          SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Portfolio Saya',
            subtitle: 'Akun, dompet, dan investasi Anda',
            onTap: () => context.push('/portfolio'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.savings_outlined,
            title: 'Target Tabungan',
            subtitle: 'Buat target dan catat nabung/tarik dana',
            onTap: () => context.push('/savings-goals'),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Tampilan'),
          _ThemeModeTile(
            mode: ref.watch(themeModeProvider),
            onChanged: (mode) => _setThemeMode(ref, mode),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Master Data'),
          SettingsTile(
            icon: Icons.category_outlined,
            title: 'Kategori',
            subtitle: 'Kategori pemasukan & pengeluaran',
            onTap: () => context.push('/profile/categories'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.account_balance_outlined,
            title: 'Provider Investasi',
            subtitle: 'Bank, exchange, dan broker',
            onTap: () => context.push('/profile/investments'),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Lainnya'),
          SettingsTile(
            icon: Icons.tune_rounded,
            title: 'Siklus Gajian',
            subtitle: 'Atur tanggal mulai periode gajian',
            onTap: () => context.push('/profile/payroll'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.support_agent_rounded,
            title: 'Hubungi Customer Service',
            subtitle: 'Isi form bantuan',
            onTap: () => _contactCustomerService(context),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Keamanan'),
          SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun Anda',
            onTap: () => context.push('/profile/change-password'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.pin_outlined,
            title: 'Ubah PIN',
            subtitle: 'Ganti PIN 6 digit untuk membuka aplikasi',
            onTap: () => context.push('/profile/change-pin'),
          ),
          const SizedBox(height: 8),
          _BiometricToggleTile(
            enabled: ref.watch(biometricEnabledProvider),
            onChanged: (value) => _setBiometricEnabled(context, ref, value),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Akun'),
          SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            subtitle: 'Logout dari akun ini',
            onTap: () => _confirmLogout(context, ref),
          ),
          const _AppFooter(),
        ],
      ),
    );
  }
}

/// Avatar, name/username/email, and a tappable membership badge (→ Upgrade
/// Membership) up top of the Profile page. Avatar is read-only — there's no
/// upload endpoint on the backend — falls back to the user's initial.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final avatarUrl = user.avatarUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        initial,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    if (user.username != null && user.username!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('@${user.username}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                    ],
                    const SizedBox(height: 2),
                    Text(user.email, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                tooltip: 'Edit Profil',
                onPressed: () => context.push('/profile/edit'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context.push('/profile/membership'),
            child: Row(
              children: [
                Icon(
                  user.isPaidMember ? Icons.workspace_premium_rounded : Icons.workspace_premium_outlined,
                  color: user.isPaidMember ? AppColors.success : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.isPaidMember
                        ? (user.membershipPlan?.name ?? 'Member')
                        : 'Free — belum upgrade membership',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Version, social link, and copyright — standard "about" footer content.
/// A Privacy Policy link belongs here too once one exists (Play Store
/// requires it, see docs/flutter-playstore-deployment-guide.txt), left out
/// for now rather than pointing at a URL that doesn't exist yet.
class _AppFooter extends StatelessWidget {
  const _AppFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 24),
          ColorFiltered(
            colorFilter: ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
            child: Image.asset('assets/branding/logo_mark.png', height: 26),
          ),
          const SizedBox(height: 10),
          Text(
            'Flowr',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13),
          ),
          const SizedBox(height: 3),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.0.0';
              return Text(
                'Versi $version',
                style: TextStyle(color: AppColors.textDisabled, fontSize: 10.5),
              );
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => launchUrl(Uri.parse(_instagramUrl), mode: LaunchMode.externalApplication),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alternate_email_rounded, size: 13, color: AppColors.primary),
                  SizedBox(width: 3),
                  Text(
                    'kodevisual',
                    style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '© 2026 Kodevisual. All rights reserved.',
            style: TextStyle(color: AppColors.textDisabled, fontSize: 9.5),
          ),
        ],
      ),
    );
  }
}

/// Same tappable-card look as [SettingsTile], but with a [Switch] instead
/// of a chevron since this toggles a setting in place rather than
/// navigating anywhere.
class _BiometricToggleTile extends StatelessWidget {
  const _BiometricToggleTile({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: enabled,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 20),
        ),
        title: Text('Login Biometrik', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(
          enabled
              ? 'Aktif — tap "Gunakan Biometrik" di layar kunci untuk masuk tanpa mengetik PIN'
              : 'Buka aplikasi dengan sidik jari/Face ID, sebagai pengganti mengetik PIN',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
        ),
      ),
    );
  }
}

/// Sistem/Terang/Gelap picker driving [themeModeProvider] — a compact
/// 3-way segmented control rather than a navigation tile, since there's
/// nothing further to drill into.
class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tema Aplikasi', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Sistem'), icon: Icon(Icons.brightness_auto_rounded)),
              ButtonSegment(value: ThemeMode.light, label: Text('Terang'), icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Gelap'), icon: Icon(Icons.dark_mode_outlined)),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => onChanged(selection.first),
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
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
      ),
    );
  }
}

