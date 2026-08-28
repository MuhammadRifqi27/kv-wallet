import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../data/models/password_reset_ticket_model.dart';

/// Backs the admin-mediated password-reset ticket flow (submit form ->
/// track status), see docs/password-reset-request-flow.md. Setting the new
/// password itself happens on the web link the admin sends via
/// WhatsApp/telepon, outside the app. autoDispose so a stale ticket/error
/// doesn't leak into the next attempt once the user leaves the flow.
final passwordResetControllerProvider =
    StateNotifierProvider.autoDispose<PasswordResetController, PasswordResetState>((ref) {
  return PasswordResetController(ref);
});

class PasswordResetState {
  const PasswordResetState({this.isLoading = false, this.error, this.ticket});

  final bool isLoading;
  final ApiException? error;
  final PasswordResetTicket? ticket;

  PasswordResetState copyWith({
    bool? isLoading,
    ApiException? error,
    PasswordResetTicket? ticket,
    bool clearError = false,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      ticket: ticket ?? this.ticket,
    );
  }
}

class PasswordResetController extends StateNotifier<PasswordResetState> {
  PasswordResetController(this._ref) : super(const PasswordResetState());

  final Ref _ref;

  Future<bool> submitRequest({required String identifier, required String phone, String? note}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ticket = await _ref.read(authRepositoryProvider).requestPasswordReset(
            identifier: identifier,
            phone: phone,
            note: note,
          );
      state = state.copyWith(isLoading: false, ticket: ticket);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  Future<void> refreshStatus(String identifier) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ticket = await _ref.read(authRepositoryProvider).passwordResetRequestStatus(identifier: identifier);
      state = state.copyWith(isLoading: false, ticket: ticket);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}
