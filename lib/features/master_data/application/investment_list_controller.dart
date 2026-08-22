import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/investment_model.dart';

final investmentListControllerProvider =
    AsyncNotifierProvider<InvestmentListController, List<InvestmentModel>>(InvestmentListController.new);

/// Read-only — provider investasi is managed by admin via the web app.
class InvestmentListController extends AsyncNotifier<List<InvestmentModel>> {
  @override
  Future<List<InvestmentModel>> build() {
    return ref.read(investmentRepositoryProvider).getInvestments();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(investmentRepositoryProvider).getInvestments());
  }
}
