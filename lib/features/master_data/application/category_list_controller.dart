import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/category_model.dart';

final categoryListControllerProvider =
    AsyncNotifierProvider<CategoryListController, List<CategoryModel>>(CategoryListController.new);

/// Read-only — categories are managed by admin via the web app.
class CategoryListController extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() {
    return ref.read(categoryRepositoryProvider).getCategories();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(categoryRepositoryProvider).getCategories());
  }
}
