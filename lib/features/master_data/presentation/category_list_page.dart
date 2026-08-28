import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../application/category_list_controller.dart';

/// Read-only — master data (kategori, provider investasi) is managed by
/// admin via the web app, not from mobile. Only Payroll/Siklus Gajian is
/// editable here (see docs/flutter-mobile-app-development-guide.txt).
class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListControllerProvider);
    final controller = ref.read(categoryListControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kategori')),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: categoriesAsync.when(
          loading: () => scrollableCenter(
            const AppLoadingIndicator(),
          ),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : 'Gagal memuat kategori.',
              onRetry: controller.refresh,
            ),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return scrollableCenter(
                const ListEmptyState(
                  icon: Icons.category_outlined,
                  title: 'Belum ada kategori',
                  subtitle: 'Kategori dikelola oleh admin lewat aplikasi web.',
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _CategoryTile(category: categories[index]),
            );
          },
        ),
      ),
    );
  }
}

/// Wraps content in a scrollable container so `RefreshIndicator`'s pull
/// gesture keeps working even on the loading/error/empty states.
Widget scrollableCenter(Widget child) {
  return LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(child: child),
      ),
    ),
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final CategoryModel category;

  Color get _accentColor => category.type == CategoryType.income ? AppColors.success : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _accentColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              category.type == CategoryType.income
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: _accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  category.description?.isNotEmpty == true ? category.description! : category.type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListEmptyState extends StatelessWidget {
  const ListEmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class ListErrorState extends StatelessWidget {
  const ListErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
