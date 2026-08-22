import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/summary_model.dart';

/// Only month/year matter here — day is ignored.
final selectedSummaryPeriodProvider = StateProvider<DateTime>((ref) => DateTime.now());

final summaryControllerProvider = AsyncNotifierProvider<SummaryController, SummaryModel>(SummaryController.new);

class SummaryController extends AsyncNotifier<SummaryModel> {
  @override
  Future<SummaryModel> build() {
    final period = ref.watch(selectedSummaryPeriodProvider);
    return ref.read(summaryRepositoryProvider).getSummary(month: period.month, year: period.year);
  }

  Future<void> refresh() async {
    final period = ref.read(selectedSummaryPeriodProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(summaryRepositoryProvider).getSummary(month: period.month, year: period.year),
    );
  }
}
