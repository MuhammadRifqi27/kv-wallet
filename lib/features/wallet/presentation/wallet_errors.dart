import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';

/// Localized message for a wallet [ApiException]. Branches on the stable
/// `code` (docs/mobile-api-reference.md "Wallet" — never the server's
/// `message` text), falling back to that message for anything unmapped.
String walletErrorMessage(AppLocalizations l10n, ApiException e) {
  switch (e.code) {
    case 'PIN_INVALID':
      return l10n.wltErrPinInvalid;
    case 'PIN_NOT_SET':
      return l10n.wltPinNotSet;
    case 'PIN_LOCKED':
      final seconds = e.retryAfter ?? 0;
      return l10n.wltPinLocked((seconds / 60).ceil().clamp(1, 999));
    case 'ACCOUNT_NOT_FOUND':
      return l10n.wltErrAccountNotFound;
    case 'SELF_TRANSFER':
      return l10n.wltErrSelfTransfer;
    case 'AMOUNT_TOO_SMALL':
    case 'AMOUNT_TOO_LARGE':
      return l10n.wltErrAmountOutOfRange;
    case 'WALLET_FROZEN':
      return l10n.wltErrFrozen;
    case 'INSUFFICIENT_BALANCE':
      return l10n.wltErrInsufficientBalance;
    case 'INSUFFICIENT_PORTFOLIO_BALANCE':
      return l10n.wltErrInsufficientPortfolio;
    case 'DAILY_LIMIT_EXCEEDED':
      return l10n.wltErrDailyLimit;
  }
  if (e.statusCode == 429) return l10n.wltErrRateLimit;
  return e.message;
}
