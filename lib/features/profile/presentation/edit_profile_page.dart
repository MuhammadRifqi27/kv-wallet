import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../../auth/application/auth_controller.dart';

/// Edits name/username/email via `POST /auth/profile` (see
/// docs/mobile-api-reference.md). Avatar isn't editable here — no upload UI
/// yet. Password and PIN are handled by their own dedicated pages, linked
/// from the "Keamanan" section below (same as on the main Profile page).
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _nameController.text = user?.name ?? '';
    _usernameController.text = user?.username ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).appEditProfileSuccessMessage)),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final generalError = _error != null && _error!.fieldErrors == null;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.appEditProfileAppBarTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (generalError) ...[
                      ErrorBanner(message: _error!.message),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      label: l10n.appEditProfileNameLabel,
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      errorText: _error?.errorFor('name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.appEditProfileNameRequired;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.appEditProfileUsernameLabel,
                      controller: _usernameController,
                      icon: Icons.alternate_email_rounded,
                      textInputAction: TextInputAction.next,
                      errorText: _error?.errorFor('username'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.appEditProfileUsernameRequired;
                        if (value.contains(' ')) return l10n.appEditProfileUsernameNoSpaces;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.appEditProfileEmailLabel,
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      errorText: _error?.errorFor('email'),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.appEditProfileEmailRequired;
                        if (!value.contains('@')) return l10n.appEditProfileEmailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(label: l10n.appEditProfileSaveButton, isLoading: _isSubmitting, onPressed: _submit),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Text(
                  l10n.appEditProfileSecuritySectionLabel,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
              SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: l10n.appEditProfileChangePasswordTitle,
                subtitle: l10n.appEditProfileChangePasswordSubtitle,
                onTap: () => context.push('/profile/change-password'),
              ),
              const SizedBox(height: 8),
              SettingsTile(
                icon: Icons.pin_outlined,
                title: l10n.appEditProfileChangePinTitle,
                subtitle: l10n.appEditProfileChangePinSubtitle,
                onTap: () => context.push('/profile/change-pin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
