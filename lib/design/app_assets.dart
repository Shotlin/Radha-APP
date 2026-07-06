// RADHA bundled visual assets (Bible v2.1 — the upgraded "v2" set).
//
// Typed catalog of every shipped image asset under `assets/v2/`.
// Screens and widgets MUST reference these constants — never a raw string
// path — so a renamed or missing asset is a compile-time concern, not a
// runtime surprise.

/// Mor's emotional states (see CHARACTER_STORYTELLING_BIBLE.md §4.5).
enum MorMood {
  idle,
  greet,
  think,
  work,
  celebrate,
  shelter,
  concern,
  guard,
  sleep,
}

/// Canonical paths to bundled v2 assets.
class RadhaAssets {
  RadhaAssets._();

  static const String _v2 = 'assets/v2';

  // --- Mor — static mood frames (nine states) ----------------------------
  static const String morIdle = '$_v2/character/mor/static/idle.png';
  static const String morGreet = '$_v2/character/mor/static/greet.png';
  static const String morThink = '$_v2/character/mor/static/think.png';
  static const String morWork = '$_v2/character/mor/static/work.png';
  static const String morCelebrate = '$_v2/character/mor/static/celebrate.png';
  static const String morShelter = '$_v2/character/mor/static/shelter.png';
  static const String morConcern = '$_v2/character/mor/static/concern.png';
  static const String morGuard = '$_v2/character/mor/static/guard.png';
  static const String morSleep = '$_v2/character/mor/static/sleep.png';

  /// Resolve a [MorMood] to its static frame path.
  static String morMoodFrame(MorMood mood) => switch (mood) {
    MorMood.idle => morIdle,
    MorMood.greet => morGreet,
    MorMood.think => morThink,
    MorMood.work => morWork,
    MorMood.celebrate => morCelebrate,
    MorMood.shelter => morShelter,
    MorMood.concern => morConcern,
    MorMood.guard => morGuard,
    MorMood.sleep => morSleep,
  };

  // --- Mor scenes (full-figure companion moments — WebP) -----------------
  static const String morSceneSplash =
      '$_v2/character/mor/scenes/hero-splash.webp';
  static const String morSceneOffline =
      '$_v2/character/mor/scenes/hero-offline.webp';
  static const String morSceneWin = '$_v2/character/mor/scenes/hero-win.webp';
  static const String morSceneSearch =
      '$_v2/character/mor/scenes/search-think.webp';
  static const String morSceneScanning =
      '$_v2/character/mor/scenes/scanning.webp';

  // --- App state illustrations (WebP) ------------------------------------
  static const String stateNoResults = '$_v2/states/no-results.webp';
  static const String stateEmptyList = '$_v2/states/empty-list.webp';
  static const String stateErrorRetry = '$_v2/states/error-retry.webp';
  static const String stateOffline = '$_v2/states/offline.webp';

  // --- Home illustrations -------------------------------------------------
  static const String illoHomeStorefront =
      '$_v2/illustration/home-storefront.png';

  // --- Home promo banners (editorial photos with bottom gradient scrim) ---
  static const String bannerHomeMission =
      '$_v2/illustration/home-mission-v3.jpg';
  static const String bannerHomePromoConsumer =
      '$_v2/illustration/home-promo-consumer-v3.jpg';

  // --- Home promo carousel banners (WebP) --------------------------------
  static const String bannerHealthMission = '$_v2/banners/health-mission.webp';
  static const String bannerExpiryMission = '$_v2/banners/expiry-mission.webp';
  static const String bannerFestive = '$_v2/banners/festive-store-pride.webp';

  // --- Category cutouts (v3 — shop-by-category rail) ---------------------
  static const String catBiscuits = '$_v2/illustrations/cat-biscuits.png';
  static const String catBreakfast = '$_v2/illustrations/cat-breakfast.png';
  static const String catDairy = '$_v2/illustrations/cat-dairy.png';
  static const String catBeverages = '$_v2/illustrations/cat-beverages.png';
  static const String catPersonalCare =
      '$_v2/illustrations/cat-personal-care.png';
  static const String catHousehold = '$_v2/illustrations/cat-household.png';
  static const String catStaples = '$_v2/illustrations/cat-staples.png';
  static const String catFrozen = '$_v2/illustrations/cat-frozen.png';

  // --- Health-flag badges (scan result / ingredient deep-dive — WebP) ----
  static const String hiSugarHigh = '$_v2/icons/health/sugar-high.webp';
  static const String hiFatHigh = '$_v2/icons/health/fat-high.webp';
  static const String hiSodiumHigh = '$_v2/icons/health/sodium-high.webp';
  static const String hiFiberGood = '$_v2/icons/health/fiber-good.webp';
  static const String hiProteinGood = '$_v2/icons/health/protein-good.webp';
  static const String hiAdditiveWarning =
      '$_v2/icons/health/additive-warning.webp';
  static const String hiAllergenFlag = '$_v2/icons/health/allergen-flag.webp';
  static const String hiUltraProcessed =
      '$_v2/icons/health/ultra-processed.webp';

  // --- Onboarding hero illustrations -------------------------------------
  static const String heroOnboardingWelcome =
      '$_v2/illustrations/hero_onboarding_welcome.png';
  static const String heroOnboardingCapabilities =
      '$_v2/illustrations/hero_onboarding_capabilities.png';

  // --- Segment selection card backgrounds (onboarding page 3) ------------
  static const String segPersonal = '$_v2/illustrations/seg_personal.png';
  static const String segBusiness = '$_v2/illustrations/seg_business.png';

  // --- Auth hero illustrations -------------------------------------------
  static const String heroSignin = '$_v2/illustrations/hero_signin.png';
  static const String heroOtpVerify = '$_v2/illustrations/hero_otp_verify.png';

  // --- RADHA Plus paywall + brand splash ---------------------------------
  static const String paywallHero = '$_v2/plus/paywall-hero.webp';
  static const String splashLockup = '$_v2/brand/splash-lockup.webp';

  // --- Business module hero scenes (v3 — photorealistic kirana owner + Mor)
  static const String heroBusinessHome =
      '$_v2/illustration/business/business-home-hero.webp';
  static const String heroBusinessProfile =
      '$_v2/illustration/business/business-profile-hero.webp';
  static const String heroInventory =
      '$_v2/illustration/business/inventory-hero.webp';
  static const String heroExpiryIntelligence =
      '$_v2/illustration/business/expiry-intelligence-hero.webp';
  static const String heroTeamTasks =
      '$_v2/illustration/business/team-tasks-hero.webp';
  static const String heroGoodsReceiving =
      '$_v2/illustration/business/goods-receiving-grn-hero.webp';
  static const String heroStoreHealth =
      '$_v2/illustration/business/store-health-hero.webp';
  static const String heroStoreAudit =
      '$_v2/illustration/business/store-audit-hero.webp';
  static const String heroReportsExports =
      '$_v2/illustration/business/reports-exports-hero.webp';
}
