import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flowr/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authControllerProvider.notifier).register(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // No explicit navigation on success — registration now auto-logs in,
    // so the router redirect sends the new session straight to /pin/set.
    if (!mounted || success) return;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final error = authState.error;
    final generalError = error != null && error.fieldErrors == null;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/login')),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 64, showWordmark: false)),
                    const SizedBox(height: 24),
                    Text(
                      l10n.authRegisterTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.authRegisterSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.authRegisterInfoBanner,
                              style: TextStyle(color: AppColors.primaryDark, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (generalError) ...[
                      ErrorBanner(message: error.message),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      label: l10n.authRegisterNameLabel,
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      errorText: error?.errorFor('name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.authRegisterNameRequired;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.authRegisterUsernameLabel,
                      controller: _usernameController,
                      icon: Icons.alternate_email_rounded,
                      textInputAction: TextInputAction.next,
                      errorText: error?.errorFor('username'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.authRegisterUsernameRequired;
                        if (value.contains(' ')) return l10n.authRegisterUsernameNoSpaces;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.authRegisterEmailLabel,
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: error?.errorFor('email'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.authRegisterEmailRequired;
                        if (!value.contains('@')) return l10n.authRegisterEmailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.authRegisterPasswordLabel,
                      controller: _passwordController,
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      errorText: error?.errorFor('password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return l10n.authRegisterPasswordRequired;
                        if (value.length < 8) return l10n.authRegisterPasswordMinLength;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.authRegisterConfirmPasswordLabel,
                      controller: _confirmController,
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value != _passwordController.text) return l10n.authRegisterPasswordMismatch;
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: l10n.authRegisterSubmitButton,
                      isLoading: authState.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.authRegisterHaveAccountPrompt, style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(l10n.authRegisterLoginLink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
