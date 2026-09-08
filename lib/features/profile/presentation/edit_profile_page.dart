import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
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
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profil')),
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
                      label: 'Nama lengkap',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      errorText: _error?.errorFor('name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Username',
                      controller: _usernameController,
                      icon: Icons.alternate_email_rounded,
                      textInputAction: TextInputAction.next,
                      errorText: _error?.errorFor('username'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Username wajib diisi';
                        if (value.contains(' ')) return 'Username tidak boleh mengandung spasi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      errorText: _error?.errorFor('email'),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                        if (!value.contains('@')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(label: 'Simpan', isLoading: _isSubmitting, onPressed: _submit),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Text(
                  'Keamanan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
