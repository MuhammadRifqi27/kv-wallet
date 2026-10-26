import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';

/// Localized message for a shared-goal [ApiException]; branches on the
/// stable `code` (docs/mobile-api-reference.md "Kode error tabungan
/// bersama"), never the server's text. Plain goal errors (the old
/// `{ "error": "..." }` shape, e.g. withdrawing more than your own share)
/// fall through to the server message.
String sharedGoalErrorMessage(AppLocalizations l10n, ApiException e) {
  switch (e.code) {
    case 'NOT_FRIENDS':
      return l10n.sgsErrNotFriends;
    case 'MEMBER_LIMIT_REACHED':
      return l10n.sgsErrMemberLimit;
    case 'ALREADY_MEMBER':
      return l10n.sgsErrAlreadyMember;
    case 'ALREADY_INVITED':
      return l10n.sgsErrAlreadyInvited;
    case 'GOAL_ARCHIVED':
      return l10n.sgsErrGoalArchived;
    case 'OWNER_CANNOT_LEAVE':
      return l10n.sgsErrOwnerCannotLeave;
    case 'NOT_GOAL_OWNER':
      return l10n.sgsErrNotOwner;
    case 'SHARED_GOAL_HAS_BALANCE':
      return l10n.sgsErrHasBalance;
    case 'INVITATION_EXPIRED':
      return l10n.sgsErrInvitationExpired;
  }
  if (e.statusCode == 429) return l10n.frdErrRateLimit;
  return e.message;
}
