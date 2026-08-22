import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/portfolio_model.dart';

final portfolioListControllerProvider =
    AsyncNotifierProvider<PortfolioListController, List<PortfolioModel>>(PortfolioListController.new);

/// Full CRUD — a portfolio is the user's own account/wallet, so unlike
/// [CategoryListController]/investment list, mutations live here too.
class PortfolioListController extends AsyncNotifier<List<PortfolioModel>> {
  @override
  Future<List<PortfolioModel>> build() {
    return ref.read(portfolioRepositoryProvider).getPortfolios();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(portfolioRepositoryProvider).getPortfolios());
  }

  /// Left un-guarded (unlike [refresh]) so the calling form can catch
  /// [ApiException] itself and show field-level validation errors.
  Future<void> addPortfolio({
    required int financeInvestmentId,
    required String accountName,
    required bool isInvestmentAccount,
    String? accountNumber,
    String? description,
  }) async {
    await ref.read(portfolioRepositoryProvider).createPortfolio(
          financeInvestmentId: financeInvestmentId,
          accountName: accountName,
          isInvestmentAccount: isInvestmentAccount,
          accountNumber: accountNumber,
          description: description,
        );
    await refresh();
  }

  Future<void> editPortfolio({
    required int id,
    required int financeInvestmentId,
    required String accountName,
    required bool isInvestmentAccount,
    String? accountNumber,
    String? description,
  }) async {
    await ref.read(portfolioRepositoryProvider).updatePortfolio(
          id: id,
          financeInvestmentId: financeInvestmentId,
          accountName: accountName,
          isInvestmentAccount: isInvestmentAccount,
          accountNumber: accountNumber,
          description: description,
        );
    await refresh();
  }

  Future<void> removePortfolio(int id) async {
    await ref.read(portfolioRepositoryProvider).deletePortfolio(id);
    await refresh();
  }
}
