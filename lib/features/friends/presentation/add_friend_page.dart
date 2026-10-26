import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/friend_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/friend_controller.dart';
import 'friend_avatar.dart';
import 'friend_errors.dart';

/// Add a friend: (1) look up a username, (2) send the request. The
/// `relationship` from the lookup disables the button when the two users
/// are already connected. See docs/mobile-api-reference.md "Teman".
class AddFriendPage extends ConsumerStatefulWidget {
  const AddFriendPage({super.key});

  @override
  ConsumerState<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends ConsumerState<AddFriendPage> {
  final _controller = TextEditingController();

  FriendLookupModel? _found;
  bool _isLooking = false;
  bool _isSending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Server ignores case and a leading `@`; trim here only for UX.
  String get _username => _controller.text.trim().replaceFirst(RegExp(r'^@+'), '');

  Future<void> _lookup() async {
    final l10n = AppLocalizations.of(context);
    if (_username.isEmpty) {
      setState(() => _error = l10n.frdAddUsernameRequired);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLooking = true;
      _error = null;
      _found = null;
    });
    try {
      final result = await ref.read(friendActionsProvider).lookup(_username);
      if (mounted) setState(() => _found = result);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = friendErrorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _isLooking = false);
    }
  }

  Future<void> _send(FriendLookupModel found) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSending = true);
    try {
      final accepted = await ref.read(friendActionsProvider).sendRequest(found.username);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accepted ? l10n.frdNowFriends(found.name) : l10n.frdRequestSent(found.name))),
      );
      context.pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendErrorMessage(l10n, e))));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _relationshipLabel(AppLocalizations l10n, FriendRelationship relationship) {
    return switch (relationship) {
      FriendRelationship.friends => l10n.frdRelFriends,
      FriendRelationship.pendingOutgoing => l10n.frdRelPendingOutgoing,
      FriendRelationship.pendingIncoming => l10n.frdRelPendingIncoming,
      FriendRelationship.none => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final found = _found;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.frdAddTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                enableSuggestions: false,
                onSubmitted: (_) => _lookup(),
                onChanged: (_) {
                  if (_error != null || _found != null) {
                    setState(() {
                      _error = null;
                      _found = null;
                    });
                  }
                },
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  labelText: l10n.frdAddUsernameField,
                  helperText: l10n.frdAddUsernameHelper,
                  errorText: _error,
                  prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: l10n.frdAddSearch, isLoading: _isLooking, onPressed: _lookup),
              if (found != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      FriendAvatar(name: found.name, url: found.avatarUrl, radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              found.name,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text('@${found.username}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (found.relationship == FriendRelationship.none)
                  PrimaryButton(label: l10n.frdAddSend, isLoading: _isSending, onPressed: () => _send(found))
                else
                  Text(
                    _relationshipLabel(l10n, found.relationship),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
