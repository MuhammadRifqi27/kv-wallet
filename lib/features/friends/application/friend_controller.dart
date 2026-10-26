import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/friend_model.dart';

/// The user's own username, shown so it can be copied/shared.
final myUsernameProvider = FutureProvider<String>((ref) {
  return ref.read(friendRepositoryProvider).getMyUsername();
});

final friendListControllerProvider =
    AsyncNotifierProvider<FriendListController, FriendsListModel>(FriendListController.new);

final friendRequestsControllerProvider =
    AsyncNotifierProvider<FriendRequestsController, FriendRequestsState>(FriendRequestsController.new);

class FriendListController extends AsyncNotifier<FriendsListModel> {
  @override
  Future<FriendsListModel> build() => ref.read(friendRepositoryProvider).getFriends();

  /// Silent: a failed refresh keeps the stale list instead of an error.
  Future<void> refresh() async {
    final next = await AsyncValue.guard(() => ref.read(friendRepositoryProvider).getFriends());
    if (next.hasError && state.hasValue) return;
    state = next;
  }

  Future<void> remove(int userId) async {
    await ref.read(friendRepositoryProvider).removeFriend(userId);
    await refresh();
  }
}

class FriendRequestsState {
  const FriendRequestsState({this.incoming = const [], this.outgoing = const []});

  final List<FriendRequestModel> incoming;
  final List<FriendRequestModel> outgoing;
}

class FriendRequestsController extends AsyncNotifier<FriendRequestsState> {
  @override
  Future<FriendRequestsState> build() => _load();

  Future<FriendRequestsState> _load() async {
    final repo = ref.read(friendRepositoryProvider);
    final results = await Future.wait([repo.getRequests(incoming: true), repo.getRequests(incoming: false)]);
    return FriendRequestsState(incoming: results[0], outgoing: results[1]);
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(_load);
    if (next.hasError && state.hasValue) return;
    state = next;
  }

  /// Accepting adds a friend and shrinks the pending badge, so both lists
  /// are re-fetched.
  Future<void> accept(int id) async {
    await ref.read(friendRepositoryProvider).acceptRequest(id);
    await _syncAll();
  }

  Future<void> decline(int id) async {
    await ref.read(friendRepositoryProvider).declineRequest(id);
    await _syncAll();
  }

  Future<void> cancel(int id) async {
    await ref.read(friendRepositoryProvider).cancelRequest(id);
    await _syncAll();
  }

  Future<void> _syncAll() async {
    await Future.wait([refresh(), ref.read(friendListControllerProvider.notifier).refresh()]);
  }
}

class FriendActions {
  FriendActions(this._ref);

  final Ref _ref;

  Future<FriendLookupModel> lookup(String username) => _ref.read(friendRepositoryProvider).lookup(username);

  /// Returns true when it was auto-accepted (they had already asked us).
  Future<bool> sendRequest(String username) async {
    final accepted = await _ref.read(friendRepositoryProvider).sendRequest(username);
    await Future.wait([
      _ref.read(friendRequestsControllerProvider.notifier).refresh(),
      _ref.read(friendListControllerProvider.notifier).refresh(),
    ]);
    return accepted;
  }
}

final friendActionsProvider = Provider<FriendActions>(FriendActions.new);
