import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/biometric_enroll.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../l10n/app_localizations.dart';
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
  final l10n = AppLocalizations.of(context);
  if (!enabled) {
    await ref.read(secureStorageServiceProvider).deleteCachedPin();
    await ref.read(biometricPreferenceServiceProvider).setEnabled(false);
    ref.read(biometricEnabledProvider.notifier).state = false;
    return;
  }

  if (!await ref.read(biometricServiceProvider).isSupported()) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileBiometricUnsupported)),
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
    reason: l10n.profileBiometricEnrollReason,
  );
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        enrolled ? l10n.profileBiometricEnrolledSuccess : l10n.profileBiometricEnrollFailed,
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

Future<void> _setThemeMode(WidgetRef ref, ThemeMode mode) async {
  ref.read(themeModeProvider.notifier).state = mode;
  await ref.read(themePreferenceServiceProvider).setThemeMode(mode);
}

Future<void> _setLocale(WidgetRef ref, Locale? locale) async {
  ref.read(localeProvider.notifier).state = locale;
  await ref.read(localePreferenceServiceProvider).setLocale(locale);
}

/// Landing page for the "settings" permission — framed as the user's
/// account/profile hub: profile info + membership status up top, then
/// Portfolio, Master Data (kategori, provider investasi — view-only, admin
/// manages it via the web app) and other settings below, per
/// docs/flutter-mobile-app-development-guide.txt BAGIAN 3.6.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.profileLogoutDialogTitle),
        content: Text(l10n.profileLogoutDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.profileCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.profileLogoutConfirm, style: TextStyle(color: AppColors.error)),
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
        SnackBar(content: Text(AppLocalizations.of(context).profileCustomerServiceLaunchFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.profileAppBarTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) _ProfileHeader(user: user),
          const SizedBox(height: 24),
          _SectionLabel(l10n.profileSectionPortfolio),
          SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.profilePortfolioTileTitle,
            subtitle: l10n.profilePortfolioTileSubtitle,
            onTap: () => context.push('/portfolio'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.savings_outlined,
            title: l10n.profileSavingsGoalTileTitle,
            subtitle: l10n.profileSavingsGoalTileSubtitle,
            onTap: () => context.push('/savings-goals'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.currency_bitcoin_outlined,
            title: l10n.profileInvestmentTileTitle,
            subtitle: l10n.profileInvestmentTileSubtitle,
            onTap: () => context.push('/investment'),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l10n.profileSectionDisplay),
          _ThemeModeTile(
            mode: ref.watch(themeModeProvider),
            onChanged: (mode) => _setThemeMode(ref, mode),
          ),
          const SizedBox(height: 8),
          _LanguageTile(
            locale: ref.watch(localeProvider),
            onChanged: (locale) => _setLocale(ref, locale),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l10n.profileSectionMasterData),
          SettingsTile(
            icon: Icons.category_outlined,
            title: l10n.profileCategoryTileTitle,
            subtitle: l10n.profileCategoryTileSubtitle,
            onTap: () => context.push('/profile/categories'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.account_balance_outlined,
            title: l10n.profileInvestmentProviderTileTitle,
            subtitle: l10n.profileInvestmentProviderTileSubtitle,
            onTap: () => context.push('/profile/investments'),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l10n.profileSectionOther),
          SettingsTile(
            icon: Icons.tune_rounded,
            title: l10n.profilePayrollTileTitle,
            subtitle: l10n.profilePayrollTileSubtitle,
            onTap: () => context.push('/profile/payroll'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.support_agent_rounded,
            title: l10n.profileCustomerServiceTileTitle,
            subtitle: l10n.profileCustomerServiceTileSubtitle,
            onTap: () => _contactCustomerService(context),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l10n.profileSectionSecurity),
          SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: l10n.profileChangePasswordTileTitle,
            subtitle: l10n.profileChangePasswordTileSubtitle,
            onTap: () => context.push('/profile/change-password'),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.pin_outlined,
            title: l10n.profileChangePinTileTitle,
            subtitle: l10n.profileChangePinTileSubtitle,
            onTap: () => context.push('/profile/change-pin'),
          ),
          const SizedBox(height: 8),
          _BiometricToggleTile(
            enabled: ref.watch(biometricEnabledProvider),
            onChanged: (value) => _setBiometricEnabled(context, ref, value),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l10n.profileSectionAccount),
          SettingsTile(
            icon: Icons.logout_rounded,
            title: l10n.profileLogoutTileTitle,
            subtitle: l10n.profileLogoutTileSubtitle,
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
    final l10n = AppLocalizations.of(context);
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
                tooltip: l10n.profileEditTooltip,
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
                        ? (user.membershipPlan?.name ?? l10n.profileMembershipFallback)
                        : l10n.profileMembershipFree,
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
    final l10n = AppLocalizations.of(context);
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
                l10n.profileAppVersion(version),
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
    final l10n = AppLocalizations.of(context);
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
        title: Text(l10n.profileBiometricTitle, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(
          enabled ? l10n.profileBiometricSubtitleEnabled : l10n.profileBiometricSubtitleDisabled,
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
    final l10n = AppLocalizations.of(context);
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
          Text(l10n.profileThemeTitle, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _SettingsDropdown<ThemeMode>(
            value: mode,
            onChanged: onChanged,
            items: [
              _SettingsDropdownItem(
                value: ThemeMode.system,
                label: l10n.profileThemeSystem,
                icon: Icons.brightness_auto_rounded,
              ),
              _SettingsDropdownItem(
                value: ThemeMode.light,
                label: l10n.profileThemeLight,
                icon: Icons.light_mode_outlined,
              ),
              _SettingsDropdownItem(
                value: ThemeMode.dark,
                label: l10n.profileThemeDark,
                icon: Icons.dark_mode_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sistem/Indonesia/English picker driving [localeProvider] — same dropdown
/// pattern as [_ThemeModeTile] right above it. `null` in [locale] means
/// "ikuti sistem" (see [LocalePreferenceService] doc).
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.locale, required this.onChanged});

  final Locale? locale;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(l10n.profileLanguageTitle, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _SettingsDropdown<Locale?>(
            value: locale,
            onChanged: onChanged,
            items: [
              _SettingsDropdownItem(
                value: null,
                label: l10n.profileLanguageSystem,
                icon: Icons.smartphone_outlined,
              ),
              _SettingsDropdownItem(
                value: const Locale('id'),
                label: l10n.profileLanguageIndonesian,
                icon: Icons.language_rounded,
              ),
              _SettingsDropdownItem(
                value: const Locale('en'),
                label: l10n.profileLanguageEnglish,
                icon: Icons.language_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One option in a [_SettingsDropdown] — a value paired with the label/icon
/// to render for it.
class _SettingsDropdownItem<T> {
  const _SettingsDropdownItem({required this.value, required this.label, required this.icon});

  final T value;
  final String label;
  final IconData icon;
}

/// Full-width bordered dropdown shared by [_ThemeModeTile] and
/// [_LanguageTile] — same visual container as other pickers on this page
/// (`SettingsTile`, the InkWell pickers on SavingsGoalFormPage), just with
/// a native [DropdownButton] instead of a bottom sheet since the option
/// list here is always short and fully known upfront.
class _SettingsDropdown<T> extends StatelessWidget {
  const _SettingsDropdown({required this.value, required this.items, required this.onChanged});

  final T value;
  final List<_SettingsDropdownItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          // `DropdownButton.onChanged` only ever fires with one of `items`'
          // own values (including a literal `null` entry, for the "follow
          // system" option) — never an unrelated null, so this cast is safe.
          onChanged: (selected) => onChanged(selected as T),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(item.label, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  ],
                ),
              ),
          ],
        ),
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

