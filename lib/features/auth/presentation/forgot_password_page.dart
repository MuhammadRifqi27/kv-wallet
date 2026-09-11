import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/password_reset_controller.dart';

/// First step of the admin-mediated reset flow — see
/// docs/password-reset-request-flow.md. Submits a ticket; an admin then
/// processes it from the web panel and sends the reset link manually via
/// WhatsApp/telepon, there is no automatic email/SMS.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final identifier = _identifierController.text.trim();
    final success = await ref.read(passwordResetControllerProvider.notifier).submitRequest(
          identifier: identifier,
          phone: _phoneController.text.trim(),
          note: _noteController.text.trim(),
        );
    if (success && mounted) {
      context.push('/forgot-password/status', extra: identifier);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetControllerProvider);
    final error = resetState.error;
    final generalError = error != null && error.fieldErrors == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const BackButton()),
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
                    Text(
                      'Lupa Kata Sandi',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Isi form di bawah, admin akan memproses pengajuanmu',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
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
                              'Belum ada reset otomatis lewat email. Admin akan menghubungimu lewat '
                              'WhatsApp/telepon untuk mengirim link reset kata sandi.',
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
                      label: 'Email atau Username',
                      controller: _identifierController,
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      errorText: error?.errorFor('identifier'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email atau username wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nomor WhatsApp/telepon',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      errorText: error?.errorFor('phone'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Nomor WhatsApp/telepon wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Catatan (opsional)',
                      controller: _noteController,
                      icon: Icons.edit_note_rounded,
                      textInputAction: TextInputAction.done,
                      errorText: error?.errorFor('note'),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Kirim Pengajuan',
                      isLoading: resetState.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push(
                          '/forgot-password/status',
                          extra: _identifierController.text.trim().isEmpty ? null : _identifierController.text.trim(),
                        ),
                        child: const Text('Sudah pernah mengajukan? Cek status'),
                      ),
                    ),
                    const SizedBox(height: 12),
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
