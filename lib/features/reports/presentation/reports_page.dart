import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'cash_flow_tab.dart';
import 'category_tab.dart';
import 'compare_tab.dart';
import 'savings_rate_tab.dart';
import 'tax_tab.dart';
import 'unexpected_tab.dart';
import 'year_review_tab.dart';

/// Laporan (docs/mobile-api-report.md) — reached from the card on the
/// Summary tab, so it shares the `summary` permission. One tab per report;
/// each tab only fetches when it's first shown (autoDispose providers
/// watched from inside the tab body), never all seven up front.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.rptPageTitle),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: l10n.rptTabCashFlow),
              Tab(text: l10n.rptTabSavings),
              Tab(text: l10n.rptTabCompare),
              Tab(text: l10n.rptTabCategory),
              Tab(text: l10n.rptTabUnexpected),
              Tab(text: l10n.rptTabYear),
              Tab(text: l10n.rptTabTax),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CashFlowTab(),
            SavingsRateTab(),
            CompareTab(),
            CategoryTab(),
            UnexpectedTab(),
            YearReviewTab(),
            TaxTab(),
          ],
        ),
      ),
    );
  }
}
