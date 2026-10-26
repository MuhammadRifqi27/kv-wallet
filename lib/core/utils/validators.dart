/// Shared form-field validators — pulled out so the same (correct) check
/// lives in one place instead of being copy-pasted per form. See
/// docs/ide-improvement-fitur-existing.txt BAGIAN D #20/#21.
library;

/// Deliberately not a full RFC 5322 implementation (that's notoriously
/// complex and mostly pointless client-side — the backend is the real
/// authority) — just enough to reject the obviously-wrong inputs the old
/// `value.contains('@')` check let through unchanged, like `"@"` or `"a@"`.
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

/// Accepts an optional leading `+` and 8-15 digits once spaces/dashes/
/// parentheses are stripped — loose on purpose (covers Indonesian numbers
/// with or without the `+62`/`0` prefix, and doesn't try to fully validate
/// international formats), just enough to reject obviously-not-a-phone-
/// number input like letters.
final _phoneDigitsPattern = RegExp(r'^\+?[0-9]{8,15}$');

bool isValidPhoneNumber(String value) {
  final digitsOnly = value.trim().replaceAll(RegExp(r'[\s\-()]'), '');
  return _phoneDigitsPattern.hasMatch(digitsOnly);
}
