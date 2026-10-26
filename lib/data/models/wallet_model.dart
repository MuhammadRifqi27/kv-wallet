import '../../core/utils/json_parsing.dart';

/// All wallet amounts are integer Rupiah in JSON — see
/// docs/mobile-api-reference.md "Wallet" rule 4. Parsed through
/// [parseDouble] anyway so the rest of the app can keep one numeric type.
class WalletLimits {
  const WalletLimits({
    required this.minTransfer,
    required this.maxTransfer,
    required this.dailyLimit,
    required this.sentToday,
    required this.remainingToday,
  });

  factory WalletLimits.fromJson(Map<String, dynamic> json) {
    return WalletLimits(
      minTransfer: parseDouble(json['min_transfer']),
      maxTransfer: parseDouble(json['max_transfer']),
      dailyLimit: parseDouble(json['daily_limit']),
      sentToday: parseDouble(json['sent_today']),
      remainingToday: parseDouble(json['remaining_today']),
    );
  }

  final double minTransfer;
  final double maxTransfer;
  final double dailyLimit;
  final double sentToday;
  final double remainingToday;
}

/// `GET /money-management/wallet`. [accountNumber] is the full 12-digit
/// number — only ever returned for the user's own wallet.
class WalletModel {
  const WalletModel({
    required this.accountNumber,
    required this.balance,
    required this.status,
    required this.limits,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final limits = data['limits'];
    return WalletModel(
      accountNumber: data['account_number'] as String? ?? '',
      balance: parseDouble(data['balance']),
      status: data['status'] as String? ?? 'active',
      limits: WalletLimits.fromJson(limits is Map<String, dynamic> ? limits : const {}),
    );
  }

  final String accountNumber;
  final double balance;
  final String status;
  final WalletLimits limits;

  bool get isFrozen => status != 'active';

  /// `881234567890` -> `8812 3456 7890` for display and copy-friendliness.
  String get formattedAccountNumber => formatAccountNumber(accountNumber);
}

String formatAccountNumber(String raw) {
  if (raw.length != 12) return raw;
  return '${raw.substring(0, 4)} ${raw.substring(4, 8)} ${raw.substring(8)}';
}

enum WalletTransactionType {
  transferOut('transfer_out'),
  transferIn('transfer_in'),
  topupFromPortfolio('topup_from_portfolio'),
  withdrawToPortfolio('withdraw_to_portfolio'),
  reversal('reversal'),
  adjustment('adjustment');

  const WalletTransactionType(this.apiValue);

  final String apiValue;

  static WalletTransactionType parse(Object? value) {
    for (final type in values) {
      if (type.apiValue == value) return type;
    }
    return WalletTransactionType.adjustment;
  }
}

class WalletCounterparty {
  const WalletCounterparty({required this.name, required this.accountNumber});

  factory WalletCounterparty.fromJson(Map<String, dynamic> json) {
    return WalletCounterparty(
      name: json['name'] as String? ?? '-',
      accountNumber: json['account_number'] as String? ?? '',
    );
  }

  final String name;

  /// Already masked by the server (`88******7890`).
  final String accountNumber;
}

/// A transfer sent or received by the logged-in user. `direction` is
/// relative to that user. [balanceAfter] only exists on the `POST /transfer`
/// response.
class WalletTransferModel {
  const WalletTransferModel({
    required this.id,
    required this.referenceNo,
    required this.isOutgoing,
    required this.amount,
    this.note,
    required this.status,
    required this.counterparty,
    required this.createdAt,
    this.balanceAfter,
  });

  factory WalletTransferModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final counterparty = data['counterparty'];
    return WalletTransferModel(
      id: data['id'] as int,
      referenceNo: data['reference_no'] as String? ?? '-',
      isOutgoing: data['direction'] != 'in',
      amount: parseDouble(data['amount']),
      note: data['note'] as String?,
      status: data['status'] as String? ?? 'completed',
      counterparty: WalletCounterparty.fromJson(counterparty is Map<String, dynamic> ? counterparty : const {}),
      createdAt: parseDate(data['created_at']) ?? DateTime.now(),
      balanceAfter: data['balance_after'] == null ? null : parseDouble(data['balance_after']),
    );
  }

  final int id;
  final String referenceNo;
  final bool isOutgoing;
  final double amount;
  final String? note;
  final String status;
  final WalletCounterparty counterparty;
  final DateTime createdAt;
  final double? balanceAfter;
}

/// One row of the wallet mutation list (also the `POST /topup`/`/withdraw`
/// response). [transfer] is null for topup/withdraw rows.
class WalletTransactionModel {
  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.isIncoming,
    required this.amount,
    required this.balanceAfter,
    this.description,
    this.transfer,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final transfer = data['transfer'];
    return WalletTransactionModel(
      id: data['id'] as int,
      type: WalletTransactionType.parse(data['type']),
      isIncoming: data['direction'] == 'in',
      amount: parseDouble(data['amount']),
      balanceAfter: parseDouble(data['balance_after']),
      description: data['description'] as String?,
      transfer: transfer is Map<String, dynamic> ? WalletTransferModel.fromJson(transfer) : null,
      createdAt: parseDate(data['created_at']) ?? DateTime.now(),
    );
  }

  final int id;
  final WalletTransactionType type;
  final bool isIncoming;
  final double amount;
  final double balanceAfter;
  final String? description;
  final WalletTransferModel? transfer;
  final DateTime createdAt;
}

class WalletTransactionsPage {
  const WalletTransactionsPage({required this.items, required this.currentPage, required this.lastPage});

  factory WalletTransactionsPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    return WalletTransactionsPage(
      items: parseList(json['data'])
          .map((item) => WalletTransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: meta is Map ? meta['current_page'] as int? ?? 1 : 1,
      lastPage: meta is Map ? meta['last_page'] as int? ?? 1 : 1,
    );
  }

  final List<WalletTransactionModel> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

/// `POST /wallet/lookup` — recipient preview before sending.
class WalletLookupModel {
  const WalletLookupModel({required this.accountNumber, required this.maskedAccountNumber, required this.name});

  factory WalletLookupModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    return WalletLookupModel(
      accountNumber: data['account_number'] as String? ?? '',
      maskedAccountNumber: data['masked_account_number'] as String? ?? '',
      name: data['name'] as String? ?? '-',
    );
  }

  final String accountNumber;
  final String maskedAccountNumber;
  final String name;
}
