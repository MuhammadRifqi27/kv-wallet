import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/friend_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/friend_controller.dart';
import 'friend_avatar.dart';

/// Multi-select of accepted friends, used to pick collaborators for a
/// shared savings goal. Resolves to the chosen `user_id`s, or null when
/// dismissed. [excludeUserIds] are people already on the goal (hidden);
/// [maxSelect] is how many more people can still be added.
Future<List<int>?> showFriendPickerSheet(
  BuildContext context, {
  List<int> initiallySelected = const [],
  List<int> excludeUserIds = const [],
  required int maxSelect,
}) {
  return showModalBottomSheet<List<int>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => _FriendPickerSheet(
      initiallySelected: initiallySelected,
      excludeUserIds: excludeUserIds,
      maxSelect: maxSelect,
    ),
  );
}

class _FriendPickerSheet extends ConsumerStatefulWidget {
  const _FriendPickerSheet({required this.initiallySelected, required this.excludeUserIds, required this.maxSelect});

  final List<int> initiallySelected;
  final List<int> excludeUserIds;
  final int maxSelect;

  @override
  ConsumerState<_FriendPickerSheet> createState() => _FriendPickerSheetState();
}

class _FriendPickerSheetState extends ConsumerState<_FriendPickerSheet> {
  late final Set<int> _selected = {...widget.initiallySelected};

  void _toggle(FriendModel friend, bool isSelected) {
    final l10n = AppLocalizations.of(context);
    if (!isSelected && _selected.length >= widget.maxSelect) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sgsPickerLimit(widget.maxSelect))));
      return;
    }
    setState(() {
      if (isSelected) {
        _selected.remove(friend.userId);
      } else {
        _selected.add(friend.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final friendsAsync = ref.watch(friendListControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.sgsPickerTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(l10n.sgsPickerSubtitle(widget.maxSelect), style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const SizedBox(height: 12),
            friendsAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(error.toString(), style: TextStyle(color: AppColors.error)),
              ),
              data: (data) {
                final friends = data.friends.where((f) => !widget.excludeUserIds.contains(f.userId)).toList();
                if (friends.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline_rounded, size: 40, color: AppColors.textDisabled),
                        const SizedBox(height: 8),
                        Text(
                          l10n.sgsPickerNoFriends,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push('/friends/add');
                          },
                          child: Text(l10n.frdAddTitle),
                        ),
                      ],
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final friend in friends)
                        CheckboxListTile(
                          value: _selected.contains(friend.userId),
                          onChanged: (_) => _toggle(friend, _selected.contains(friend.userId)),
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          secondary: FriendAvatar(name: friend.name, url: friend.avatarUrl),
                          title: Text(friend.name, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          subtitle: Text('@${friend.username}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: l10n.sgsPickerDone(_selected.length),
              onPressed: () => Navigator.of(context).pop(_selected.toList()),
            ),
          ],
        ),
      ),
    );
  }
}
