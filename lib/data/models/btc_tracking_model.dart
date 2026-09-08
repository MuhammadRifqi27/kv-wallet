import '../../core/utils/json_parsing.dart';
import 'investment_model.dart';
import 'portfolio_model.dart';

/// Crypto accounts only [InvestmentType.crypto] out of a user's full
/// portfolio list — shared by the Transfer form (to decide whether to show
/// the Aset field) and the Investment feature (to pick a target account).
List<PortfolioModel> filterCryptoPortfolios(List<PortfolioModel> portfolios, List<InvestmentModel> investments) {
  final cryptoInvestmentIds = investments.where((i) => i.type == InvestmentType.crypto).map((i) => i.id).toSet();
  return portfolios.where((p) => cryptoInvestmentIds.contains(p.financeInvestmentId)).toList();
}

/// `GET /money-management/btc-tracking` — overview for the Investment
/// dashboard: total value + per-asset breakdown. Not a transaction list —
/// see [BtcActivityItem] for that.
class BtcOverview {
  const BtcOverview({required this.portfolios, required this.totalValue, required this.assetBalances});

  factory BtcOverview.fromJson(Map<String, dynamic> json) {
    return BtcOverview(
      portfolios: parseList(json['btc_portfolios'])
          .map((item) => PortfolioModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalValue: parseDouble(json['total_btc_value']),
      assetBalances: parseList(json['asset_balances'])
          .map((item) => AssetBalance.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<PortfolioModel> portfolios;
  final double totalValue;
  final List<AssetBalance> assetBalances;
}

class AssetBalance {
  const AssetBalance({required this.asset, required this.balance});

  factory AssetBalance.fromJson(Map<String, dynamic> json) {
    return AssetBalance(asset: json['asset'] as String? ?? '-', balance: parseDouble(json['balance']));
  }

  final String asset;
  final double balance;
}

/// Only the types the mobile "+" form on Investment actually creates
/// (Profit/Loss) — deposit/withdrawal happen via Transfer Antar Akun
/// instead (money actually moving between accounts), see
/// InvestmentDashboardPage's doc comment. [BtcActivityItem.type] stays a
/// plain string since the activity feed can show deposit/withdrawal rows
/// created elsewhere (web admin, or historically) plus a 5th `transfer`
/// value that isn't one of these four at all.
enum BtcEntryType { profit, loss }

extension BtcEntryTypeLabel on BtcEntryType {
  String get label => switch (this) {
        BtcEntryType.profit => 'Profit',
        BtcEntryType.loss => 'Loss',
      };

  String get apiValue => name;
}

/// One row from `GET /money-management/btc-tracking/activity` — a combined
/// feed of `source_type: "investment"` entries (manageable here) and
/// `source_type: "transfer"` entries (manage from Transfer Antar Akun
/// instead — see docs/mobile-api-reference.md).
class BtcActivityItem {
  const BtcActivityItem({
    required this.id,
    required this.portfolioId,
    required this.asset,
    required this.date,
    required this.type,
    required this.amount,
    required this.isFromTransfer,
    this.portfolioName,
    this.description,
  });

  factory BtcActivityItem.fromJson(Map<String, dynamic> json) {
    final portfolio = json['portfolio'] as Map<String, dynamic>?;
    return BtcActivityItem(
      id: json['id'] as int? ?? 0,
      portfolioId: json['finance_investment_id'] as int? ?? 0,
      asset: json['asset'] as String? ?? '-',
      date: parseDate(json['date']) ?? DateTime.now(),
      type: json['type'] as String? ?? '-',
      amount: parseDouble(json['amount']),
      isFromTransfer: json['source_type'] == 'transfer',
      portfolioName: portfolio?['account_name'] as String?,
      description: json['description'] as String?,
    );
  }

  final int id;
  final int portfolioId;
  final String asset;
  final DateTime date;

  /// Raw string, not [BtcEntryType] — the feed can show `deposit`/
  /// `withdrawal` (created elsewhere) and `transfer`, none of which the
  /// mobile create/edit form itself produces.
  final String type;
  final double amount;
  final bool isFromTransfer;
  final String? portfolioName;
  final String? description;
}

/// Net holding of [asset] per portfolio (account id → Rupiah value),
/// computed client-side from the activity feed since `GET /btc-tracking`
/// only gives a global total per asset, not a per-account split.
///
/// ⚠️ Sign convention — **unverified assumption**, check against real data:
/// - `investment`-source rows: unsigned `amount`, direction comes from
///   `type` (`deposit`/`profit` add, `withdrawal`/`loss` subtract) — this
///   part matches the documented request validation (`amount` min `0`).
/// - `transfer`-source rows: `amount` is trusted to already carry its own
///   sign (negative = left this account, positive = arrived), mirroring
///   how `finance_transactions` stores transfer legs elsewhere in this API
///   (see TransferModel's note on why `.abs()` is needed there). If a
///   crypto withdrawal-via-transfer row comes back positive instead, these
///   per-account totals will be wrong even though the global
///   `asset_balances` total (server-computed) stays correct — cross-check
///   the two if the numbers look off.
Map<int, double> computePortfolioBalancesForAsset(List<BtcActivityItem> activity, String asset) {
  final balances = <int, double>{};
  for (final item in activity) {
    if (item.asset.toUpperCase() != asset.toUpperCase()) continue;

    final double signedAmount;
    if (item.isFromTransfer) {
      signedAmount = item.amount;
    } else {
      signedAmount = switch (item.type) {
        'deposit' || 'profit' => item.amount,
        'withdrawal' || 'loss' => -item.amount,
        _ => 0,
      };
    }
    balances.update(item.portfolioId, (value) => value + signedAmount, ifAbsent: () => signedAmount);
  }
  return balances;
}
