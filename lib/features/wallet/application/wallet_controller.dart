import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/wallet_model.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../portfolio/application/portfolio_list_controller.dart';
import '../../summary/application/summary_controller.dart';

final walletControllerProvider = AsyncNotifierProvider<WalletController, WalletModel>(WalletController.new);

final walletTransactionsControllerProvider =
    AsyncNotifierProvider<WalletTransactionsController, WalletTransactionsState>(WalletTransactionsController.new);

/// One transfer's receipt, fetched on demand (route restored without `extra`).
final walletTransferDetailProvider = FutureProvider.autoDispose.family<WalletTransferModel, int>((ref, id) {
  return ref.read(walletRepositoryProvider).getTransfer(id);
});

class WalletController extends AsyncNotifier<WalletModel> {
  @override
  Future<WalletModel> build() => ref.read(walletRepositoryProvider).getWallet();

  /// Silent by default so pull-to-refresh/returning to a screen keeps the
  /// last balance visible ("terakhir diperbarui") instead of flashing a
  /// spinner; a failed refresh keeps the stale value and surfaces the error
  /// only when there is nothing to show.
  Future<void> refresh() async {
    final next = await AsyncValue.guard(() => ref.read(walletRepositoryProvider).getWallet());
    if (next.hasError && state.hasValue) return;
    state = next;
  }

  /// A wallet money movement also changes: wallet balance + limits, the
  /// mutation list, portfolio balances (topup/withdraw) and net worth
  /// (dashboard/summary — docs "Wallet" rule 5).
  Future<void> syncAfterMovement() async {
    ref.invalidate(walletTransactionsControllerProvider);
    ref.invalidate(portfolioListControllerProvider);
    ref.invalidate(dashboardControllerProvider);
    ref.invalidate(summaryControllerProvider);
    await refresh();
  }

  Future<WalletLookupModel> lookup(String accountNumber) {
    return ref.read(walletRepositoryProvider).lookup(accountNumber);
  }

  /// Left un-guarded so the PIN sheet can inspect the thrown
  /// [ApiException.code].
  Future<WalletTransferModel> transfer({
    required String toAccountNumber,
    required double amount,
    String? note,
    required String pin,
    required String idempotencyKey,
  }) async {
    final result = await ref.read(walletRepositoryProvider).transfer(
          toAccountNumber: toAccountNumber,
          amount: amount,
          note: note,
          pin: pin,
          idempotencyKey: idempotencyKey,
        );
    await syncAfterMovement();
    return result;
  }

  Future<void> topup({required int portfolioId, required double amount, String? description, required String pin}) async {
    await ref
        .read(walletRepositoryProvider)
        .topup(portfolioId: portfolioId, amount: amount, description: description, pin: pin);
    await syncAfterMovement();
  }

  Future<void> withdraw({required int portfolioId, required double amount, String? description, required String pin}) async {
    await ref
        .read(walletRepositoryProvider)
        .withdraw(portfolioId: portfolioId, amount: amount, description: description, pin: pin);
    await syncAfterMovement();
  }
}

class WalletTransactionsState {
  const WalletTransactionsState({
    this.items = const [],
    this.type,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<WalletTransactionModel> items;

  /// Null = all types.
  final WalletTransactionType? type;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  WalletTransactionsState copyWith({
    List<WalletTransactionModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return WalletTransactionsState(
      items: items ?? this.items,
      type: type,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class WalletTransactionsController extends AsyncNotifier<WalletTransactionsState> {
  WalletTransactionType? _type;

  @override
  Future<WalletTransactionsState> build() => _fetchFirstPage();

  Future<WalletTransactionsState> _fetchFirstPage() async {
    final page = await ref.read(walletRepositoryProvider).getTransactions(type: _type?.apiValue);
    return WalletTransactionsState(items: page.items, type: _type, page: page.currentPage, hasMore: page.hasMore);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchFirstPage);
  }

  Future<void> setType(WalletTransactionType? type) async {
    if (_type == type) return;
    _type = type;
    await refresh();
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await ref
          .read(walletRepositoryProvider)
          .getTransactions(type: _type?.apiValue, page: current.page + 1);
      state = AsyncData(current.copyWith(
        items: [...current.items, ...next.items],
        page: next.currentPage,
        hasMore: next.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      // Keep what's already loaded; the user can scroll to retry.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}
