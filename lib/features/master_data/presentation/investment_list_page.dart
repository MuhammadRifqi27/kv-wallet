import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/investment_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../application/investment_list_controller.dart';
import 'category_list_page.dart' show scrollableCenter, ListEmptyState, ListErrorState;

/// Read-only — provider investasi (bank/exchange/broker) is managed by
/// admin via the web app, not from mobile.
class InvestmentListPage extends ConsumerWidget {
  const InvestmentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(investmentListControllerProvider);
    final controller = ref.read(investmentListControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Provider Investasi')),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: investmentsAsync.when(
          loading: () => scrollableCenter(
            const AppLoadingIndicator(),
          ),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : 'Gagal memuat provider investasi.',
              onRetry: controller.refresh,
            ),
          ),
          data: (investments) {
            if (investments.isEmpty) {
              return scrollableCenter(
                const ListEmptyState(
                  icon: Icons.account_balance_outlined,
                  title: 'Belum ada provider investasi',
                  subtitle: 'Provider investasi dikelola oleh admin lewat aplikasi web.',
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: investments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _InvestmentTile(investment: investments[index]),
            );
          },
        ),
      ),
    );
  }
}

class _InvestmentTile extends StatelessWidget {
  const _InvestmentTile({required this.investment});

  final InvestmentModel investment;

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
            decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  investment.name,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  investment.code != null ? '${investment.code} · ${investment.type.label}' : investment.type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                if (investment.description != null)
                  Text(
                    investment.description!,
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
