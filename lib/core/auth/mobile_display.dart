// Shared mobile-number display helpers.
//
// Previously duplicated ad hoc inside `otp_verify_screen.dart`. Extracted
// so the Profile screen (which shows the signed-in user's mobile as their
// identity — see `AuthSession.mobile`) formats it identically instead of
// falling back to the raw account UUID, which read as a broken/demo
// placeholder to users.

/// Masks a mobile number as `+91 •••••X XXXX` (last 4 digits visible, one
/// extra digit visible just before them for a bit of texture). Falls back
/// to returning [mobile] unchanged if it's too short to mask meaningfully.
String maskMobileForDisplay(String mobile) {
  final digits = mobile.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return mobile;
  final last4 = digits.substring(digits.length - 4);
  final secondLast = digits.length >= 5 ? digits[digits.length - 5] : '';
  return '+91 •••••$secondLast $last4';
}
