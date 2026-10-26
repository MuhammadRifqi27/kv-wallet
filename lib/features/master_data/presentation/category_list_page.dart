import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/list_states.dart';
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.investCategoryListTitle)),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: categoriesAsync.when(
          loading: () => scrollableCenter(
            const AppLoadingIndicator(),
          ),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : l10n.investCategoryLoadError,
              onRetry: controller.refresh,
            ),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return scrollableCenter(
                ListEmptyState(
                  icon: Icons.category_outlined,
                  title: l10n.investCategoryEmptyTitle,
                  subtitle: l10n.investCategoryEmptySubtitle,
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final CategoryModel category;

  Color get _accentColor => category.type == CategoryType.income ? AppColors.success : AppColors.error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // No more CategoryTypeLabel.label on the model — a data model can't
    // hold localized strings. See
    // docs/ide-improvement-fitur-existing.txt BAGIAN B #7.
    final typeLabel = category.type == CategoryType.income ? l10n.txnCategoryTypeIncome : l10n.txnCategoryTypeExpense;
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
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  category.description?.isNotEmpty == true ? category.description! : typeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ListEmptyState/ListErrorState/scrollableCenter moved to
// lib/shared/widgets/list_states.dart — see
// docs/ide-improvement-fitur-existing.txt BAGIAN E #36.
