import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flowr/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/password_reset_ticket_model.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/password_reset_controller.dart';

/// Standalone tracking screen for an admin-mediated reset ticket — see
/// docs/password-reset-request-flow.md. Reachable any time from
/// [ForgotPasswordPage] ("Sudah pernah mengajukan?"), not just right after
/// submitting one, so it takes its own identifier input rather than
/// requiring a ticket already in memory.
///
/// `processed` only means the admin generated the link and (should have)
/// sent it manually via WhatsApp/telepon — actually setting the new
/// password happens on that web link, outside the app, so this screen is
/// purely informational.
class PasswordResetStatusPage extends ConsumerStatefulWidget {
  const PasswordResetStatusPage({super.key, this.initialIdentifier});

  final String? initialIdentifier;

  @override
  ConsumerState<PasswordResetStatusPage> createState() => _PasswordResetStatusPageState();
}

class _PasswordResetStatusPageState extends ConsumerState<PasswordResetStatusPage> {
  final _formKey = GlobalKey<FormState>();
  late final _identifierController = TextEditingController(text: widget.initialIdentifier);

  @override
  void initState() {
    super.initState();
    final identifier = widget.initialIdentifier;
    if (identifier != null && identifier.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _checkStatus() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(passwordResetControllerProvider.notifier).refreshStatus(_identifierController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetControllerProvider);
    final ticket = resetState.ticket;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.authResetStatusAppBarTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.authResetStatusDescription,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.authResetStatusIdentifierLabel,
                      controller: _identifierController,
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _checkStatus(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.authResetStatusIdentifierRequired;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: l10n.authResetStatusCheckButton,
                      isLoading: resetState.isLoading,
                      onPressed: _checkStatus,
                    ),
                    const SizedBox(height: 24),
                    if (resetState.error != null) ErrorBanner(message: resetState.error!.message),
                    if (ticket != null) _TicketStatusCard(ticket: ticket),
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

class _TicketStatusCard extends StatelessWidget {
  const _TicketStatusCard({required this.ticket});

  final PasswordResetTicket ticket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final IconData icon;
    final Color color;
    final String title;
    final String description;

    if (ticket.isPending) {
      icon = Icons.hourglass_top_rounded;
      color = AppColors.accent;
      title = l10n.authResetStatusPendingTitle;
      description = l10n.authResetStatusPendingDescription;
    } else if (ticket.isProcessed) {
      icon = Icons.mark_email_read_outlined;
      color = AppColors.success;
      title = l10n.authResetStatusProcessedTitle;
      description = l10n.authResetStatusProcessedDescription;
    } else {
      icon = Icons.cancel_outlined;
      color = AppColors.error;
      title = l10n.authResetStatusRejectedTitle;
      description = l10n.authResetStatusRejectedDescription;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
