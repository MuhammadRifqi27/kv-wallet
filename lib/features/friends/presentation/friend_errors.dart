import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';

/// Localized message for a friends [ApiException]; branches on the stable
/// `code` (docs/mobile-api-reference.md "Teman"), never the server text.
String friendErrorMessage(AppLocalizations l10n, ApiException e) {
  switch (e.code) {
    case 'USER_NOT_FOUND':
      return l10n.frdErrUserNotFound;
    case 'SELF_FRIEND':
      return l10n.frdErrSelf;
    case 'ALREADY_FRIENDS':
      return l10n.frdErrAlreadyFriends;
    case 'REQUEST_EXISTS':
      return l10n.frdErrRequestExists;
  }
  if (e.statusCode == 429) return l10n.frdErrRateLimit;
  return e.message;
}
