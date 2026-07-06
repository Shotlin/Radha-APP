// Razorpay credentials and plan IDs.
//
// All values are injected at compile time via --dart-define so that no
// credentials appear in source control. Example build command:
//
//   flutter build apk \
//     --dart-define=RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxx \
//     --dart-define=RAZORPAY_MONTHLY_STARTER_PLAN_ID=plan_xxxxxxxx \
//     --dart-define=RAZORPAY_MONTHLY_GROWTH_PLAN_ID=plan_xxxxxxxx \
//     --dart-define=RAZORPAY_MONTHLY_GROWTH_PLUS_PLAN_ID=plan_xxxxxxxx \
//     --dart-define=RAZORPAY_MONTHLY_PREMIUM_PLAN_ID=plan_xxxxxxxx \
//     --dart-define=RAZORPAY_DAY_STARTER_PLAN_ID=plan_xxxxxxxx \
//     --dart-define=RAZORPAY_DAY_GROWTH_PLAN_ID=plan_xxxxxxxx \
//     --dart-define=RAZORPAY_DAY_PREMIUM_PLAN_ID=plan_xxxxxxxx
//
// Store the actual values in CI secrets or a local .env file (see .env.example).
// NEVER commit real credentials to the repository.

class RazorpayConfig {
  RazorpayConfig._();

  /// Public key ID — safe to compile into the app binary.
  /// The Key Secret must remain server-side only.
  static const String keyId = String.fromEnvironment('RAZORPAY_KEY_ID');

  // ── Monthly subscription plan IDs (from Razorpay Dashboard → Plans) ─────

  static const String _monthlyStarter = String.fromEnvironment(
    'RAZORPAY_MONTHLY_STARTER_PLAN_ID',
  );
  static const String _monthlyGrowth = String.fromEnvironment(
    'RAZORPAY_MONTHLY_GROWTH_PLAN_ID',
  );
  static const String _monthlyGrowthPlus = String.fromEnvironment(
    'RAZORPAY_MONTHLY_GROWTH_PLUS_PLAN_ID',
  );
  static const String _monthlyPremium = String.fromEnvironment(
    'RAZORPAY_MONTHLY_PREMIUM_PLAN_ID',
  );

  // ── 1-day pass plan IDs ──────────────────────────────────────────────────

  static const String _dayStarter = String.fromEnvironment(
    'RAZORPAY_DAY_STARTER_PLAN_ID',
  );
  static const String _dayGrowth = String.fromEnvironment(
    'RAZORPAY_DAY_GROWTH_PLAN_ID',
  );
  static const String _dayPremium = String.fromEnvironment(
    'RAZORPAY_DAY_PREMIUM_PLAN_ID',
  );

  // Map from app plan ID → Razorpay plan ID.
  // 'pro' is the backend code for the Premium tier.
  static const Map<String, String> _planIdMap = {
    'starter': _monthlyStarter,
    'growth': _monthlyGrowth,
    'growth_plus': _monthlyGrowthPlus,
    'pro': _monthlyPremium,
    'starter_day': _dayStarter,
    'growth_day': _dayGrowth,
    'pro_day': _dayPremium,
  };

  /// Returns the Razorpay plan ID for a given app plan ID (e.g. 'starter',
  /// 'growth_day'). Returns an empty string until --dart-define values are set.
  static String planIdFor(String appPlanId) => _planIdMap[appPlanId] ?? '';
}
