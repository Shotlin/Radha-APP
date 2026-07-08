// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RADHA';

  @override
  String get tagline => 'Retail Assistant for Data, Health & Audits.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get getStarted => 'Get started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading';

  @override
  String get error => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get otpSent => 'We sent you a 6-digit code';

  @override
  String get home => 'Home';

  @override
  String get scan => 'Scan';

  @override
  String get expiry => 'Expiry';

  @override
  String get tasks => 'Tasks';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get scanProduct => 'Scan a product';

  @override
  String get pointAtBarcode => 'Point your camera at a barcode';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get expiryTracker => 'Expiry tracker';

  @override
  String get addExpiry => 'Add expiry';

  @override
  String get expiringSoon => 'Expiring soon';

  @override
  String get expired => 'Expired';

  @override
  String get yourTasks => 'Your tasks';

  @override
  String get noTasks => 'No tasks yet';

  @override
  String get completeTask => 'Complete task';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeMessage =>
      'Scan, track, audit your stock without the spreadsheets.';

  @override
  String get referrals => 'Referrals';

  @override
  String get shareYourCode => 'Share your code';

  @override
  String get yourReferralCode => 'Your referral code';

  @override
  String get invitees => 'Invitees';

  @override
  String get rewardsEarned => 'Rewards earned';

  @override
  String get redeemCode => 'Redeem code';

  @override
  String get enterReferralCode => 'Enter a referral code';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String errorRateLimitOtp(int seconds) {
    return 'Too many OTP requests. Try again in $seconds seconds.';
  }

  @override
  String get errorOtpInvalid => 'Invalid OTP. Please try again.';

  @override
  String get errorOtpExpired => 'OTP expired. Please request a new one.';

  @override
  String get errorAuthRequired => 'Please sign in to continue.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get ingredientExplainerErrorTitle => 'Could not load explanation';

  @override
  String get ingredientExplainerHealthConsiderations => 'Health considerations';

  @override
  String healthyAlternativesTitle(String productName) {
    return 'Better choices than $productName';
  }

  @override
  String get healthyAlternativesGenericTitle => 'Better choices';

  @override
  String get healthyAlternativesEmptyTitle => 'No healthier alternatives yet';

  @override
  String get healthyAlternativesEmptyBody =>
      'No healthier alternatives found in the same category yet.';

  @override
  String get healthyAlternativesErrorTitle => 'Could not load alternatives';

  @override
  String get healthyAlternativesAddToList => 'Add to shopping list';

  @override
  String get healthyAlternativesView => 'View';

  @override
  String get healthyAlternativesAddedToList => 'Added to your shopping list';

  @override
  String get healthyAlternativesAddFailed => 'Could not add to shopping list';

  @override
  String get savedProductsTitle => 'Saved products';

  @override
  String get savedProductsEmptyTitle => 'Saved products';

  @override
  String get savedProductsEmptyBody =>
      'Save products from the scan result screen to see them here.';

  @override
  String get savedProductsErrorTitle => 'Could not load saved products';

  @override
  String savedProductsSavedOn(String date) {
    return 'Saved $date';
  }

  @override
  String get digestTitle => 'Your week with RADHA';

  @override
  String digestWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String digestSavingsHero(String amount) {
    return '₹$amount saved';
  }

  @override
  String digestScansHero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scans',
      one: '1 scan',
    );
    return '$_temp0';
  }

  @override
  String get digestHeroEmptyHeadline => 'A quiet week';

  @override
  String get digestScans => 'Scans';

  @override
  String get digestSavedProducts => 'Saved';

  @override
  String get digestExpiringSoon => 'Expiring soon';

  @override
  String digestRecallAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recall alerts',
      one: '1 recall alert',
    );
    return '$_temp0';
  }

  @override
  String get digestRecallAlertsBody =>
      'Products you scanned this week have new safety advisories.';

  @override
  String get digestRecallAlertsCta => 'Review';

  @override
  String get digestTopCategoriesHeader => 'What you\'re scanning';

  @override
  String get digestHighlightsHeader => 'Highlights';

  @override
  String get digestContinueScanning => 'Continue scanning';

  @override
  String get digestShare => 'Share my week';

  @override
  String digestShareTemplate(int scans, String savings) {
    return 'I scanned $scans products this week and saved ₹$savings with RADHA. Try it: https://radha.app';
  }

  @override
  String get digestEmptyTitle => 'No activity this week';

  @override
  String get digestEmptyBody => 'Start scanning to build your weekly story.';

  @override
  String get digestErrorTitle => 'Could not load your weekly digest';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPushNotifications => 'Push notifications';

  @override
  String get settingsPushNotificationsHint => 'Get alerts on your phone';

  @override
  String get settingsRecallAlerts => 'Recall alerts';

  @override
  String get settingsRecallAlertsHint =>
      'Be told when a product you scanned is recalled';

  @override
  String get settingsWeeklyDigest => 'Weekly digest';

  @override
  String get settingsWeeklyDigestHint =>
      'Sunday summary of your scans and savings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsTextSizeSmall => 'Small';

  @override
  String get settingsTextSizeStandard => 'Standard';

  @override
  String get settingsTextSizeLarge => 'Large';

  @override
  String get settingsDataPrivacy => 'Data & privacy';

  @override
  String get settingsAllergens => 'Allergen profile';

  @override
  String get settingsAllergensHint =>
      'Pick the ingredients we should warn you about';

  @override
  String get settingsSignOutAll => 'Sign out from all devices';

  @override
  String get settingsSignOutAllConfirmTitle => 'Sign out everywhere?';

  @override
  String get settingsSignOutAllConfirmBody =>
      'You\'ll need to sign in again on every device that uses this account.';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountTitle => 'Delete account';

  @override
  String get settingsDeleteAccountBody =>
      'This will permanently delete your data. Type DELETE to confirm.';

  @override
  String get settingsDeleteAccountConfirm => 'DELETE';

  @override
  String get settingsDeleteAccountUnavailable =>
      'Contact support to delete your account.';

  @override
  String get settingsDeleteAccountContact => 'Contact support';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsTerms => 'Terms of service';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsVersion => 'App version';

  @override
  String settingsVersionValue(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsSupportHint => 'Get help, report a bug, or share feedback';

  @override
  String get settingsLinkOpenFailed => 'Could not open link';

  @override
  String conflictBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflicts need your attention',
      one: '1 conflict needs your attention',
    );
    return '$_temp0';
  }

  @override
  String get conflictBannerCta => 'Resolve';

  @override
  String get conflictBannerDismiss => 'Dismiss';

  @override
  String get conflictResolveTitle => 'Resolve sync conflicts';

  @override
  String get conflictResolveSubtitle =>
      'Pick which version to keep for each item.';

  @override
  String get conflictUseMine => 'Use my version';

  @override
  String get conflictUseServer => 'Use server version';

  @override
  String get conflictResolved => 'Conflict resolved';

  @override
  String get conflictResolvedAll => 'All conflicts resolved';

  @override
  String conflictAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return 'Tried $_temp0';
  }

  @override
  String get conflictResourceTask => 'Task';

  @override
  String get conflictResourceExpiry => 'Expiry record';

  @override
  String get conflictResourceScan => 'Scan';

  @override
  String get conflictResourceInventory => 'Stock adjustment';

  @override
  String get conflictResourceGrn => 'GRN entry';

  @override
  String get conflictResourceShoppingList => 'Shopping list item';

  @override
  String get conflictResourceGeneric => 'Sync change';

  @override
  String conflictLocalChangeSummary(String summary) {
    return 'Your change: $summary';
  }

  @override
  String get supportTitle => 'Support';

  @override
  String get supportContactUs => 'Contact us';

  @override
  String get supportEmailUs => 'Email us';

  @override
  String get supportEmailUsHint => 'support@radha.app';

  @override
  String get supportCallUs => 'Call support';

  @override
  String get supportCallUsHint => 'Mon–Fri, 9am–6pm IST';

  @override
  String get supportReportBug => 'Report a bug';

  @override
  String get supportBugDescription => 'What happened?';

  @override
  String get supportBugDescriptionHint =>
      'Describe what you were doing when it broke.';

  @override
  String get supportAttachScreenshot => 'Attach screenshot';

  @override
  String get supportScreenshotAttached => 'Screenshot attached';

  @override
  String get supportRemoveScreenshot => 'Remove';

  @override
  String get supportSubmit => 'Send report';

  @override
  String get supportSubmitted => 'Thanks — we received your report.';

  @override
  String get supportSubmitFailed => 'Could not send. Please email us instead.';

  @override
  String get supportBugDescriptionRequired => 'Please describe what happened.';

  @override
  String get supportFaq => 'Frequently asked questions';

  @override
  String get supportFaqQ1 => 'How do I scan a barcode?';

  @override
  String get supportFaqA1 =>
      'Open the Scan tab, point your camera at the barcode, and hold steady. We\'ll find the product the moment we read a clean code.';

  @override
  String get supportFaqQ2 => 'What if a product isn\'t in the database?';

  @override
  String get supportFaqA2 =>
      'Tap \"Add product\" on the not-found screen and we\'ll create a new entry tied to your store. The catalog grows for everyone over time.';

  @override
  String get supportFaqQ3 => 'How do I cancel my subscription?';

  @override
  String get supportFaqA3 =>
      'Go to Profile → Subscription. You can cancel anytime; we don\'t charge after the next billing cycle starts.';

  @override
  String get supportFaqQ4 => 'Why am I seeing a recall alert?';

  @override
  String get supportFaqA4 =>
      'We match every scan against the FSSAI recall feed. If a batch you sold is on the list, we surface it so you can pull stock and notify customers.';

  @override
  String get supportFaqQ5 => 'How do I share my allergen profile with family?';

  @override
  String get supportFaqA5 =>
      'Allergen profiles are per-account today. Share them with family by signing in on the same household account, or pick the same allergens on each phone.';

  @override
  String get reportsTitle => 'Reports & exports';

  @override
  String get reportsTabAvailable => 'Available';

  @override
  String get reportsTabScheduled => 'Scheduled';

  @override
  String get reportsTabHistory => 'History';

  @override
  String get reportsQuickExportsHeader => 'Quick exports';

  @override
  String get reportsInventorySnapshot => 'Inventory snapshot';

  @override
  String get reportsExpiringItems => 'Expiring items';

  @override
  String get reportsSalesSummary => 'Sales summary';

  @override
  String get reportsAuditLog => 'Audit log';

  @override
  String get reportsGenerate => 'Generate';

  @override
  String get reportsGenerateSuccess => 'Report ready';

  @override
  String get reportsGenerateQueued =>
      'Generation started — we\'ll notify you when it\'s ready';

  @override
  String get reportsGenerateFailed => 'Could not start the report';

  @override
  String get reportsDownloadFailed => 'Could not open the download';

  @override
  String get reportsScheduleNew => 'New schedule';

  @override
  String get reportsScheduleCreate => 'Create schedule';

  @override
  String get reportsScheduleSuccess => 'Schedule created';

  @override
  String get reportsScheduleReportLabel => 'Report';

  @override
  String get reportsScheduleDayOfWeek => 'Day of week';

  @override
  String get reportsScheduleDayOfMonth => 'Day of month';

  @override
  String get reportsScheduleTime => 'Time';

  @override
  String get reportsScheduleFormat => 'Format';

  @override
  String get reportsScheduleActionsTooltip => 'Schedule actions';

  @override
  String get reportsFrequency => 'Frequency';

  @override
  String get reportsFrequencyDaily => 'Daily';

  @override
  String get reportsFrequencyWeekly => 'Weekly';

  @override
  String get reportsFrequencyMonthly => 'Monthly';

  @override
  String get reportsPause => 'Pause';

  @override
  String get reportsResume => 'Resume';

  @override
  String get reportsDelete => 'Delete';

  @override
  String get reportsDeleteScheduleTitle => 'Delete schedule?';

  @override
  String get reportsDeleteScheduleBody =>
      'This recurring schedule will stop firing. Past runs stay in your history.';

  @override
  String reportsLastRun(String when) {
    return 'Last run $when';
  }

  @override
  String get reportsLastRunNever => 'Hasn\'t run yet';

  @override
  String reportsNextRun(String when) {
    return 'Next run $when';
  }

  @override
  String get reportsDownload => 'Download';

  @override
  String get reportsStatusCompleted => 'Ready';

  @override
  String get reportsStatusGenerating => 'Generating';

  @override
  String get reportsStatusFailed => 'Failed';

  @override
  String get reportsStatusCancelled => 'Cancelled';

  @override
  String get reportsStatusExpired => 'Expired';

  @override
  String get reportsEmptyTitle => 'No exports yet';

  @override
  String get reportsEmptyBody =>
      'Generate a report from the Available tab and it\'ll show up here.';

  @override
  String get reportsScheduledEmptyTitle => 'No scheduled reports';

  @override
  String get reportsScheduledEmptyBody =>
      'Tap New schedule to have a report run automatically.';

  @override
  String get reportsErrorTitle => 'Could not load reports';

  @override
  String get ohsTitle => 'Operational health';

  @override
  String get ohsScoreCaption => 'OHS score';

  @override
  String ohsScore(int score) {
    return '$score';
  }

  @override
  String ohsDeltaUp(int value) {
    return '+$value from last week';
  }

  @override
  String ohsDeltaDown(int value) {
    return '-$value from last week';
  }

  @override
  String get ohsDeltaSame => 'No change from last week';

  @override
  String get ohsDeltaUnavailable =>
      'Not enough data for a week-over-week comparison yet';

  @override
  String get ohsCompliance => 'Compliance';

  @override
  String get ohsInventoryHygiene => 'Inventory hygiene';

  @override
  String get ohsAuditCompletion => 'Audit completion';

  @override
  String get ohsActionItemsHeader => 'Action items';

  @override
  String ohsActionExpiry(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expiry alerts need a review',
      one: '1 expiry alert needs a review',
    );
    return '$_temp0';
  }

  @override
  String ohsActionLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count low-stock alerts are unresolved',
      one: '1 low-stock alert is unresolved',
    );
    return '$_temp0';
  }

  @override
  String get ohsActionTasks => 'Review open tasks for your store';

  @override
  String get ohsActionNoneBody =>
      'Everything looks good — keep scanning to maintain your score.';

  @override
  String get ohsTrendHeader => 'Trend';

  @override
  String get ohsViewDetailedReports => 'View detailed reports';

  @override
  String get ohsEmptyTitle => 'Build your operational health score';

  @override
  String get ohsEmptyBody => 'Start scanning to build your OHS score.';

  @override
  String get ohsErrorTitle => 'Could not load your dashboard';

  @override
  String get expiryTabNear => 'Near-expiry';

  @override
  String get expiryTabSafe => 'Safe';

  @override
  String get expiryCalendarTooltip => 'Calendar view';

  @override
  String get expiryEmptyExpiredTitle => 'Nothing expired';

  @override
  String get expiryEmptyNearTitle => 'All clear';

  @override
  String get expiryEmptyDefaultTitle => 'No records yet';

  @override
  String get expiryEmptyBody => 'No records in this category.';

  @override
  String expiryProductShort(String id) {
    return 'Product $id';
  }

  @override
  String expiryBatch(String batch) {
    return 'Batch $batch';
  }

  @override
  String expiryQty(String qty) {
    return 'Qty $qty';
  }

  @override
  String expiryExp(String date) {
    return 'Exp $date';
  }

  @override
  String get expiryPillToday => 'Today';

  @override
  String get expiryPillTomorrow => 'Tomorrow';

  @override
  String expiryPillDays(int days) {
    return '${days}d';
  }

  @override
  String get expiryPillSoon => 'Soon';

  @override
  String get expiryLoadError => 'Couldn\'t load expiry records.';

  @override
  String get expiryCouldNotLoadSemantic => 'Could not load';

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get inventorySearchTooltip => 'Search inventory';

  @override
  String get inventorySearchHint => 'Search by product or EAN...';

  @override
  String get inventoryStockMovement => 'Stock Movement';

  @override
  String get inventoryLowStockAlerts => 'Low Stock Alerts';

  @override
  String get inventoryLoadError => 'Failed to load inventory';

  @override
  String get inventoryEmpty => 'No inventory items found';

  @override
  String inventoryNoMatches(String query) {
    return 'No matches for \"$query\"';
  }

  @override
  String inventoryProductShort(String id) {
    return 'Product $id';
  }

  @override
  String get inventoryBelowThreshold => 'Below threshold';

  @override
  String get inventoryInStock => 'In stock';

  @override
  String get inventoryUnitsLabel => 'units';

  @override
  String get inventoryTotalQuantity => 'Total quantity';

  @override
  String get inventoryLowStockThreshold => 'Low-stock threshold';

  @override
  String inventoryQtyUnits(int count) {
    return '$count units';
  }

  @override
  String get inventoryBatchLedgerHint =>
      'Tap \"Stock movement\" to view the full batch ledger.';

  @override
  String get inventoryLowStockBadge => 'Low Stock';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksTabMine => 'My Tasks';

  @override
  String get tasksTabAll => 'All';

  @override
  String get tasksNewTask => 'New task';

  @override
  String get tasksEmptyTitle => 'No tasks here';

  @override
  String get tasksEmptyBody => 'Tasks assigned to this view will show up here.';

  @override
  String get tasksLoadError => 'Failed to load tasks';

  @override
  String get taskEvidence => 'Evidence';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get taskStatusOpen => 'Open';

  @override
  String get taskStatusPending => 'Pending';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String get taskStatusCancelled => 'Cancelled';

  @override
  String get scanTitle => 'Scan a product';

  @override
  String get scanAlignHint => 'Align the barcode within the frame';

  @override
  String get scanBatchHint =>
      'Batch mode — keep scanning, items add automatically';

  @override
  String scanBatchAdded(String code, int count) {
    return 'Added $code · $count scanned';
  }

  @override
  String scanBatchDone(int count) {
    return 'Done · $count';
  }

  @override
  String get scanLabelAction => 'Scan label';

  @override
  String get scanGalleryAction => 'Gallery';

  @override
  String get scanEnterManually => 'Enter manually';

  @override
  String get scanBulkAudit => 'Bulk audit';

  @override
  String get scanHistoryAction => 'History';

  @override
  String get scanFlash => 'Flash';

  @override
  String get scanTroubleTitle => 'Trouble scanning?';

  @override
  String get scanTroubleBody =>
      'Low light or a damaged barcode? Turn on the flash, or read the label instead.';

  @override
  String get scanGalleryNoBarcode =>
      'No barcode found. Tip: use \'Scan label\' to read the ingredients.';

  @override
  String get scanInvalidEan => 'Enter a valid EAN-8, EAN-13, or UPC-A code';

  @override
  String get scanWebTitle => 'Scan';

  @override
  String get scanWebUnavailable =>
      'Camera scanning is not available on web.\nEnter a barcode manually:';

  @override
  String get scanEanFieldLabel => 'EAN / UPC Code';

  @override
  String get scanEanHintExample => 'e.g. 5901234123457';

  @override
  String get scanLookUp => 'Look up';

  @override
  String get scanEnterBarcode => 'Enter barcode';

  @override
  String get scanHistoryTitle => 'Scan history';

  @override
  String get scanNoHistory => 'No scans yet this session.';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeGreetingFallbackName => 'there';

  @override
  String get homeTrialEnded => 'Free trial ended — upgrade to keep access';

  @override
  String homeTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Free trial · $_temp0 left';
  }

  @override
  String get homeUpgradeArrow => 'Upgrade →';

  @override
  String get homeKpiSaved => 'Saved';

  @override
  String get homeKpiNearExpiry => 'Near expiry';

  @override
  String get homeKpiRecallAlerts => 'Recall alerts';

  @override
  String get homeKpiOpenTasks => 'Open tasks';

  @override
  String get homeKpiLowStock => 'Low stock';

  @override
  String get homeEyebrowFoodSafety => 'FOOD SAFETY ALERT';

  @override
  String get homeEyebrowToday => 'AAJ KA KAAM · TODAY';

  @override
  String get homeEyebrowHealthScan => 'YOUR HEALTH SCAN';

  @override
  String get homeEyebrowScanToLearn => 'SCAN TO LEARN';

  @override
  String get homeEyebrowAllClear => 'ALL CLEAR';

  @override
  String homeStoryRecall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recalled products — check what you have at home',
      one: '1 recalled product — check what you have at home',
    );
    return '$_temp0';
  }

  @override
  String homeStoryNearExpiryConsumer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved items expire this week — use them up',
      one: '1 saved item expires this week — use it up',
    );
    return '$_temp0';
  }

  @override
  String get homeStoryKnowWhatYouEat => 'Know what you eat';

  @override
  String get homeStoryScanInside =>
      'Point your camera at any food barcode — see what\'s inside';

  @override
  String homeStoryNearExpiryBusiness(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items near expiry — clear the shelf',
      one: '1 item near expiry — clear the shelf',
    );
    return '$_temp0';
  }

  @override
  String homeStoryOpenTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks need you today',
      one: '1 task needs you today',
    );
    return '$_temp0';
  }

  @override
  String homeStoryLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items running low on stock',
      one: '1 item running low on stock',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreToday => 'Here\'s your store today';

  @override
  String get homeStoreAllGood => 'Shabaash! Your store\'s in great shape today';

  @override
  String get homeCtaViewRecallAlerts => 'View recall alerts';

  @override
  String get homeCtaCheckExpiry => 'Check expiry';

  @override
  String get homeCtaOpenExpiry => 'Open expiry';

  @override
  String get homeCtaViewTasks => 'View tasks';

  @override
  String get homeCtaCheckInventory => 'Check inventory';

  @override
  String get homeCtaOpenTasks => 'Open tasks';

  @override
  String get homeCtaRunAudit => 'Run a quick audit';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeQuickScan => 'Scan';

  @override
  String get homeQuickShopping => 'Shopping';

  @override
  String get homeQuickAddExpiry => 'Add Expiry';

  @override
  String get homeQuickNewTask => 'New Task';

  @override
  String get homeRecentTasks => 'Recent tasks';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeNoOpenTasks => 'No open tasks — create one';

  @override
  String homeTaskAssignedTo(String name) {
    return 'Assigned to $name';
  }

  @override
  String get homeTaskOverdue => 'Overdue';

  @override
  String get homeTaskDueToday => 'Due today';

  @override
  String get homeTaskDueTomorrow => 'Due tomorrow';

  @override
  String homeTaskDueInDays(int days) {
    return 'Due in $days days';
  }

  @override
  String homeTaskDueOn(String date) {
    return 'Due $date';
  }

  @override
  String get homeHowHelps => 'How RADHA helps you';

  @override
  String get homeScanBarcodeTitle => 'Scan any food barcode';

  @override
  String get homeScanBarcodeBody =>
      'See the health rating, ingredients, and what to watch out for.';

  @override
  String get homeRecallTitle => 'Safety recall alerts';

  @override
  String get homeRecallBody => 'Stay informed about recalled food products.';

  @override
  String get homePromoKnowFoodEyebrow => 'KNOW YOUR FOOD';

  @override
  String get homePromoKnowFoodHeadline =>
      'Scan the label — see what\'s really inside';

  @override
  String get homePromoKnowFoodCta => 'Scan & learn';

  @override
  String get homePromoExpiryEyebrow => 'NEVER MISS A DATE';

  @override
  String get homePromoExpiryHeadline =>
      'Catch every expiry before it slips away';

  @override
  String get homePromoExpiryCta => 'Track expiry';

  @override
  String get homePromoFestiveEyebrow => 'FESTIVE PICKS';

  @override
  String get homePromoFestiveHeadline => 'Shop the season, the healthy way';

  @override
  String get homePromoFestiveCta => 'Browse products';

  @override
  String get homePromoBazaarEyebrow => 'AAJ KA BAZAAR';

  @override
  String get homePromoBazaarHeadline => 'Audit your shelves in minutes';

  @override
  String get homePromoBazaarCta => 'Start an audit';

  @override
  String get homeShopByCategory => 'Shop by category';

  @override
  String get homeShopByCategorySubtitle =>
      'Tap an aisle to scan or browse its products';

  @override
  String get onboardingWelcomeValue =>
      'Scan, track, audit your stock without the spreadsheets.';

  @override
  String get onboardingCapabilitiesTitle =>
      'Built for the floor,\nnot the back office.';

  @override
  String get onboardingCapScanTitle => 'Scan products in one tap';

  @override
  String get onboardingCapScanBody =>
      'EAN lookup with health and approval pre-checked.';

  @override
  String get onboardingCapExpiryTitle => 'Catch expiry before it costs you';

  @override
  String get onboardingCapExpiryBody =>
      'OCR-assisted dates and per-category thresholds.';

  @override
  String get onboardingCapAuditTitle => 'Run audits the team can finish';

  @override
  String get onboardingCapAuditBody =>
      'Tasks, evidence and bulk scan sessions.';

  @override
  String get onboardingSegmentTitle => 'Who are you here as?';

  @override
  String get onboardingSegmentSubtitle =>
      'Pick the closest fit. You can change later in Settings.';

  @override
  String get segmentPersonalTitle => 'Personal';

  @override
  String get segmentPersonalBody => 'Just shopping for myself';

  @override
  String get segmentParentTitle => 'Parent';

  @override
  String get segmentParentBody => 'Shopping for my family / kids';

  @override
  String get segmentBusinessTitle => 'Business owner';

  @override
  String get segmentBusinessBody => 'I run a small retail store';

  @override
  String get segmentPharmacyTitle => 'Pharmacy';

  @override
  String get segmentPharmacyBody => 'I run a pharmacy / chemist';

  @override
  String get segmentInstitutionTitle => 'Institution';

  @override
  String get segmentInstitutionBody => 'School / hostel / canteen';

  @override
  String get segmentAuditorTitle => 'Auditor (invited)';

  @override
  String get segmentAuditorBody => 'I have an invite code';

  @override
  String get allergenTitle => 'Allergens';

  @override
  String get allergenLoadError => 'Could not load your allergen profile.';

  @override
  String get allergenHeading => 'Your allergens';

  @override
  String get allergenIntro =>
      'Tap any allergens you react to. We will warn you when a scanned product contains them.';

  @override
  String allergenTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count allergens tracked',
      one: '1 allergen tracked',
    );
    return '$_temp0';
  }

  @override
  String get allergenNoneTracked => 'No allergens tracked yet';

  @override
  String get allergenSavedCleared => 'Allergen profile cleared.';

  @override
  String get allergenSaved => 'Allergen profile saved.';

  @override
  String get allergenSaveError => 'Could not save your allergens.';

  @override
  String get allergenPeanut => 'Peanut';

  @override
  String get allergenTreeNut => 'Tree nut';

  @override
  String get allergenDairy => 'Dairy';

  @override
  String get allergenEggs => 'Eggs';

  @override
  String get allergenSoy => 'Soy';

  @override
  String get allergenWheat => 'Wheat';

  @override
  String get allergenFish => 'Fish';

  @override
  String get allergenShellfish => 'Shellfish';

  @override
  String get allergenSesame => 'Sesame';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenMustard => 'Mustard';

  @override
  String get allergenCelery => 'Celery';

  @override
  String get allergenLupin => 'Lupin';

  @override
  String get allergenMolluscs => 'Molluscs';

  @override
  String get allergenSulphites => 'Sulphites';

  @override
  String get commonSuccess => 'Success';

  @override
  String lockedFeatureUpgradeTo(String planName) {
    return 'Upgrade to $planName';
  }

  @override
  String lockedFeaturePlan(String planName) {
    return 'This feature is part of the $planName plan.';
  }

  @override
  String get lockedFeatureViewPlans => 'View plans';

  @override
  String get notFoundSemantic => 'Page not found';

  @override
  String get notFoundTitle => 'This page wandered off';

  @override
  String get notFoundBody =>
      'We couldn\'t find what you were looking for. Let\'s get you back home.';

  @override
  String get notFoundBackHome => 'Back to home';

  @override
  String get commonCouldNotLoad => 'Could not load';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get otpUseCode => 'Use code';

  @override
  String get ohsPickStore => 'Pick a store before opening the dashboard.';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileManageStores => 'Manage stores';

  @override
  String get profileSavedProducts => 'Saved products';

  @override
  String get profileSubscription => 'Subscription';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileAllergenProfile => 'Allergen profile';

  @override
  String get profileShoppingList => 'Shopping list';

  @override
  String get recallTitle => 'Recall alerts';

  @override
  String recallProductFallback(String id) {
    return 'Product $id';
  }

  @override
  String recallDate(String date) {
    return 'Recalled $date';
  }

  @override
  String get recallViewProduct => 'View product';

  @override
  String get recallLoadError => 'Could not load recalls.';

  @override
  String get recallEmpty => 'No active recalls';

  @override
  String get recallEmptyBody =>
      'You will see product recall alerts here as they are issued by regulatory bodies.';

  @override
  String get referralsLoadError => 'Could not load referrals.';

  @override
  String get referralsCopyCode => 'Copy code';

  @override
  String get referralsShareInvite => 'Share invite';

  @override
  String get referralsCodeCopied => 'Code copied';

  @override
  String get referralsInvitees => 'Invitees';

  @override
  String get referralsRewardsEarned => 'Rewards earned';

  @override
  String get referralsCodeRedeemed => 'Code redeemed';

  @override
  String get referralsEnterCode => 'Enter a referral code';

  @override
  String get referralsRedeem => 'Redeem';

  @override
  String get referralsRedeemError => 'Could not redeem code';

  @override
  String get referralsRedeemSubtitle =>
      'Have a friend\'s invite? Enter their code below.';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonShare => 'Share';

  @override
  String get healthSugar => 'Sugar';

  @override
  String get healthSalt => 'Salt';

  @override
  String get healthFat => 'Fat';

  @override
  String get healthProcessed => 'Processed';

  @override
  String get healthChildSuitable => 'Child-suitable';

  @override
  String get productDetailsTitle => 'Product Details';

  @override
  String get productDetailLoadError => 'Couldn\'t load this product';

  @override
  String get productCheckAllergens => 'Check allergens';

  @override
  String get productExplainIngredients => 'Explain ingredients';

  @override
  String get productSeeHealthierOptions => 'See healthier options';

  @override
  String get productViewHealthyAlternatives => 'View healthy alternatives';

  @override
  String get productHealthAssessment => 'Health Assessment';

  @override
  String get productNutritionInfo => 'Nutrition Info';

  @override
  String get productAllergenCheck => 'Allergen Check';

  @override
  String get productSeeFullExplanation => 'See full explanation';

  @override
  String get productHealthierOptions => 'Healthier Options';

  @override
  String get commonYes => 'Yes';

  @override
  String get nutritionProtein => 'Protein';

  @override
  String get nutritionTotalSugars => 'Total Sugars';

  @override
  String get nutritionEnergy => 'Energy';

  @override
  String get nutritionTotalFat => 'Total Fat';

  @override
  String get nutritionSaturatedFat => 'Saturated Fat';

  @override
  String get nutritionCarbohydrates => 'Carbohydrates';

  @override
  String get nutritionFibre => 'Fibre';

  @override
  String get nutritionSodium => 'Sodium';

  @override
  String get nutritionAll => 'All nutrients';

  @override
  String get nutritionPer100g => 'Per 100 g';

  @override
  String get nutritionPer50g => 'Per 50 g';

  @override
  String get productDetailSavedAlert =>
      'Saved — we\'ll alert you if it\'s ever recalled.';

  @override
  String get productDetailSaveError => 'Could not save. Please try again.';

  @override
  String get productDetailWhatYoullLike => 'What you\'ll like';

  @override
  String get productDetailWhatConcern => 'What should concern you';

  @override
  String get productDetailIngredientDeepDive => 'Ingredient deep-dive';

  @override
  String get productDetailPersonalisedFlags => 'Personalised flags';

  @override
  String get productDetailAlreadyBought => 'Already bought';

  @override
  String get productDetailScanToUnlock => 'Scan to unlock';

  @override
  String get productDetailTitle => 'Product';

  @override
  String get productDetailSave => 'Save';

  @override
  String get productDetailSaved => 'Saved';

  @override
  String get productDetailHealthNotRated => 'Health rating not in yet';

  @override
  String get productDetailHealthNotRatedBody =>
      'Scan this product to pull its full health analysis into RADHA.';

  @override
  String get productDetailHealthLabel => 'RADHA Health Rating';

  @override
  String get productDetailHighProtein => 'High protein';

  @override
  String get productDetailGoodFibre => 'Good fibre';

  @override
  String get productDetailMinimallyProcessed => 'Minimally processed';

  @override
  String get productDetailHighSugar => 'High sugar';

  @override
  String get productDetailHighSatFat => 'High saturated fat';

  @override
  String get productDetailHighSodium => 'High sodium';

  @override
  String get productDetailUltraProcessed => 'Ultra-processed';

  @override
  String get productDetailNutritionNote =>
      'Based on the product\'s real nutrition (per 100 g).';

  @override
  String get productDetailKeyNutrients => 'Key nutrients';

  @override
  String get productDetailRdaNote => '% of reference daily intake (adult).';

  @override
  String get productDetailForYou => 'For you';

  @override
  String get productDetailIngredientLockBody =>
      'See every ingredient explained with a safety verdict — what it is, why it\'s there, and whether to worry.';

  @override
  String get productDetailIngredientError =>
      'We couldn\'t explain these ingredients right now.';

  @override
  String get productDetailAllergenLockBody =>
      'Match this product against your saved allergens & health goals — we\'ll flag what\'s right (or wrong) for you.';

  @override
  String get productDetailAllergenError =>
      'We couldn\'t personalise this right now.';

  @override
  String get productDetailNoAllergens =>
      'No allergens detected in this product.';

  @override
  String productDetailAllergenAvoid(String name) {
    return '$name — you avoid this';
  }

  @override
  String productDetailUnlockWith(String plan) {
    return 'Unlock with $plan';
  }

  @override
  String get productDetailWouldYouBuy => 'Would you buy this product?';

  @override
  String get productDetailThanksForSharing => 'Thanks for sharing!';

  @override
  String get productDetailNutritionNotIn => 'Full nutrition isn\'t in yet';

  @override
  String get productDetailNutritionNotInBody =>
      'Scan this product\'s barcode to pull its real nutrition & health analysis into RADHA — it only takes a second.';

  @override
  String productDetailShareText(String name) {
    return 'Checked \"$name\" on RADHA.';
  }

  @override
  String productDetailShareTextRated(String name, String rating, String label) {
    return 'Checked \"$name\" on RADHA — RADHA health rating $rating/5 ($label).';
  }

  @override
  String get catalogSearchBarLabel => 'Search products to find what fits you';

  @override
  String get catalogSearchPromptTitle => 'Find a product';

  @override
  String get catalogSearchPromptBody =>
      'Search by product name or brand to see its health rating and what\'s inside.';

  @override
  String get commonNo => 'No';

  @override
  String get scanApprovalNotInAudit => 'Approval status — not in an audit';

  @override
  String get scanApprovalChecking => 'Checking approved list…';

  @override
  String get scanApprovalCheckFailed => 'Couldn\'t check approval';

  @override
  String get scanApprovalApproved => 'Approved — in list';

  @override
  String get scanApprovalNoList => 'No approved list active';

  @override
  String get scanApprovalInvalidBarcode => 'Invalid barcode';

  @override
  String get scanApprovalNotInList => 'Not in approved list';

  @override
  String scanApprovalStatus(String label) {
    return 'Approval status: $label';
  }

  @override
  String get scanResultAddToExpiry => 'Add to expiry';

  @override
  String get scanResultAddToStock => 'Add to stock';

  @override
  String get scanResultSaveToList => 'Save to list';

  @override
  String get scanResultNoProduct => 'No product found';

  @override
  String get scanResultScanLabel => 'Scan the label';

  @override
  String get auditRecordError => 'Could not record the scan. Please try again.';

  @override
  String get auditEndError => 'Could not end the audit. Please try again.';

  @override
  String get auditNoStore => 'No store assigned';

  @override
  String get auditNoStoreBody =>
      'Bulk audits run against a store\'s approved EAN list. Ask an admin to assign you a store, then come back to audit.';

  @override
  String get auditMatched => 'Matched';

  @override
  String get auditNotInList => 'Not in list';

  @override
  String get auditNoList => 'No list';

  @override
  String get auditInvalid => 'Invalid';

  @override
  String get auditUnchecked => 'Unchecked';

  @override
  String get commonTotal => 'Total';

  @override
  String get auditEnterScanEan => 'Enter or scan EAN';

  @override
  String auditStatus(String label) {
    return 'Status: $label';
  }

  @override
  String get auditStartAuditing => 'Start auditing';

  @override
  String get auditStartBody =>
      'Scan or type an EAN above to check it against this store\'s approved list. Each result lands here with a matched or not-in-list status.';

  @override
  String get auditTitle => 'Bulk EAN Audit';

  @override
  String get auditEndAction => 'End audit';

  @override
  String get auditEndingAction => 'Ending…';

  @override
  String get auditEanInvalid => 'Enter a valid EAN-8, EAN-13, or UPC-A code';

  @override
  String auditEndedSummary(int matched, int notMatched) {
    return 'Audit ended — $matched matched, $notMatched not in list';
  }

  @override
  String get cameraCapture => 'Capture';

  @override
  String get labelScanReadError => 'Couldn\'t read the label';

  @override
  String get labelScanReadErrorBody =>
      'Try again in better light, hold steady, and fill the frame with the ingredients panel.';

  @override
  String get labelScanAnalysisFailed => 'Analysis failed';

  @override
  String get labelScanIntro => 'RADHA reads the label for you';

  @override
  String get labelScanTakePhoto => 'Take a photo';

  @override
  String get labelScanChooseGallery => 'Choose from gallery';

  @override
  String get labelScanAnother => 'Scan another';

  @override
  String labelScanSeePlans(String plan) {
    return 'See $plan plans';
  }

  @override
  String get labelScanMaybeLater => 'Maybe later';

  @override
  String get labelScanTitle => 'Scan the label';

  @override
  String get labelScanNoBarcode => 'No barcode? Read the label instead';

  @override
  String get labelScanIdleBody =>
      'Point at the ingredients panel — we\'ll read it and tell you what\'s inside. Works on products without a barcode.';

  @override
  String get labelScanFlashNote =>
      'In low light your camera flash turns on automatically.';

  @override
  String get labelScanReading => 'Reading the label…';

  @override
  String get labelScanAnalyzing => 'Analyzing ingredients…';

  @override
  String get labelScanFallbackError =>
      'Something went wrong. Please try again.';

  @override
  String get labelScanResultFallback => 'Label analysis';

  @override
  String get labelScanLowConfidence =>
      'Low confidence — a clearer photo may improve this.';

  @override
  String get labelScanWhatToWatch => 'What to watch';

  @override
  String get labelScanIngredients => 'Ingredients';

  @override
  String get labelScanDisclaimer =>
      'Read by RADHA AI from the label text. Always check the pack for the most accurate information.';

  @override
  String get labelScanUnlockTitle => 'Unlock AI label reading';

  @override
  String get labelScanUnlockBody =>
      'We read the label, but the full ingredient & health breakdown is a premium feature.';

  @override
  String scanResultNotFoundBody(String ean) {
    return 'No catalog match for EAN $ean — but you can still read the label. Snap the ingredients panel and we\'ll tell you what\'s inside.';
  }

  @override
  String productScore(String score) {
    return 'Score: $score';
  }

  @override
  String get catalogSearchHint => 'Search products or brands';

  @override
  String get catalogNoMatches => 'No matches';

  @override
  String catalogNoMatchesBody(String query) {
    return 'We couldn\'t find products for “$query”. Try a different name, or scan the item instead.';
  }

  @override
  String get browseTitle => 'Products';

  @override
  String get browseLoadError => 'Couldn\'t load products';

  @override
  String browseLoadErrorBody(String category) {
    return 'We hit a snag loading $category. Please try again.';
  }

  @override
  String get browseSortHealthiest => 'Healthiest';

  @override
  String get browseSortAZ => 'A–Z';

  @override
  String get browseFilterVegOnly => 'Veg only';

  @override
  String get browseVeg => 'Veg';

  @override
  String get browseEmptyVeg => 'No veg items here yet';

  @override
  String browseEmptyVegBody(String category) {
    return 'Nothing in $category matches the veg filter right now.';
  }

  @override
  String get browseShowAll => 'Show all';

  @override
  String get browseEmpty => 'No products yet';

  @override
  String browseEmptyBody(String category) {
    return 'We\'re stocking the $category aisle. Meanwhile, scan any item to check its health and expiry.';
  }

  @override
  String referralsShareText(String code) {
    return 'Join me on RADHA: use code $code';
  }

  @override
  String get selectStoreEmpty => 'No stores yet';

  @override
  String get selectStoreEmptyBody =>
      'Reach out to your manager to be added to a store.';

  @override
  String get selectStoreEmptyDetail =>
      'Your account is not associated with any store yet. Ask your manager to grant access, then come back to pick one.';

  @override
  String get selectStoreContactManager => 'Contact your manager';

  @override
  String get expiryConsumerTitle => 'For business accounts';

  @override
  String get expiryConsumerBody =>
      'Expiry tracking is a retail-store feature. To use it, connect your account to a store.';

  @override
  String get tasksConsumerTitle => 'For business accounts';

  @override
  String get tasksConsumerBody =>
      'Task management is a retail-store feature. To use it, connect your account to a store.';

  @override
  String get languageSavedLocally => 'Language saved locally only';

  @override
  String languageSavedLocallyError(String error) {
    return 'Language saved locally only: $error';
  }

  @override
  String get signOutConfirmBody =>
      'You will need to sign in again with an OTP to use the app.';

  @override
  String get scanResultTitle => 'Scan result';

  @override
  String scanResultShareMessage(String ean) {
    return 'I checked this product on RADHA — barcode $ean.';
  }

  @override
  String get scanResultHealthHeading => 'Health';

  @override
  String get scanResultAssessmentPending => 'Assessment pending';

  @override
  String get scanResultNutritionPending =>
      'Nutrition flags appear here once this product is matched in the catalog. Scan more items to enrich the database.';

  @override
  String get scanResultExplainIngredients => 'Explain ingredients';

  @override
  String get scanResultAllergenPrompt =>
      'Set up your allergen profile to get instant warnings when a scanned product contains something you avoid.';

  @override
  String scanResultAllergensDeclared(String allergens) {
    return 'Contains: $allergens';
  }

  @override
  String get scanResultNoAllergensDeclared =>
      'No allergens declared on this product\'s label.';

  @override
  String get taskEvidenceRequiredSnack =>
      'Evidence is required to complete this task';

  @override
  String taskMovedTo(String status) {
    return 'Task moved to $status';
  }

  @override
  String get taskUpdateError => 'Could not update the task. Please try again.';

  @override
  String taskAssignedTo(String name) {
    return 'Assigned to $name';
  }

  @override
  String taskDueOn(String date) {
    return 'Due $date';
  }

  @override
  String get taskPriorityLabel => 'Priority';

  @override
  String get taskEvidenceLabel => 'Evidence';

  @override
  String get taskEvidencePhotoRequired => 'Photo required';

  @override
  String get taskEvidenceNotRequired => 'Not required';

  @override
  String taskEvidencePhotosAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos attached',
      one: '1 photo attached',
    );
    return '$_temp0';
  }

  @override
  String get taskEvidencePhotoNeeded =>
      'A photo is required to complete this task';

  @override
  String get taskTimelineCreated => 'Created';

  @override
  String get taskTimelineStarted => 'Started';

  @override
  String get taskActionComplete => 'Complete';

  @override
  String get taskLoadFailed => 'Failed to load task';

  @override
  String get taskDescriptionLabel => 'Description';

  @override
  String get taskTypeLabel => 'Type';

  @override
  String get taskActionStart => 'Start';

  @override
  String get taskCreateTitle => 'Create task';

  @override
  String get taskCreateCta => 'Create Task';

  @override
  String get taskCreatedSnack => 'Task created';

  @override
  String get taskCreateError => 'Could not create the task. Please try again.';

  @override
  String get taskNotAuthorizedTitle => 'Not authorized';

  @override
  String get taskNotAuthorizedBody =>
      'Only managers and admins can create tasks.';

  @override
  String get taskTitleLabel => 'Title';

  @override
  String get taskTitleHint => 'e.g. Audit dairy aisle EANs';

  @override
  String get taskTitleRequired => 'Title is required';

  @override
  String get taskDescriptionHint => 'Optional details for the assignee';

  @override
  String get taskStoreLabel => 'Store';

  @override
  String get taskAssigneeLabel => 'Assignee (user ID)';

  @override
  String get taskAssigneeHint => 'Enter user ID or leave blank';

  @override
  String get taskDueDateLabel => 'Due date';

  @override
  String get taskSelectDate => 'Select a date';

  @override
  String get taskRequiresEvidence => 'Requires evidence';

  @override
  String get taskRequiresEvidenceSubtitle =>
      'Assignee must upload a photo to complete';

  @override
  String get taskTypeEanAudit => 'EAN Audit';

  @override
  String get taskTypeExpiryCheck => 'Expiry Check';

  @override
  String get taskTypeInventoryCount => 'Inventory Count';

  @override
  String get taskTypeDisplayVerification => 'Display Verification';

  @override
  String get taskTypeCustom => 'Custom';

  @override
  String get checkoutStartError =>
      'Could not start checkout. Please try again.';

  @override
  String get paymentResponseIncomplete => 'Payment response was incomplete.';

  @override
  String get paymentSuccessUpdated => 'Payment successful. Plan updated.';

  @override
  String get paymentNotVerified => 'Payment could not be verified.';

  @override
  String get paymentVerifyFailed =>
      'Payment verification failed. Please contact support.';

  @override
  String get paymentCancelled => 'Payment cancelled.';

  @override
  String paymentFailed(String message) {
    return 'Payment failed: $message';
  }

  @override
  String paymentOpeningWallet(String wallet) {
    return 'Opening $wallet…';
  }

  @override
  String get paymentSheetOpenError => 'Could not open the payment sheet.';

  @override
  String get subscriptionLoadError => 'Couldn\'t load your subscription';

  @override
  String get subscriptionLoadErrorBody =>
      'Check your connection and try again.';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'You\'re on $plan';
  }

  @override
  String subscriptionUpgradeTo(String plan) {
    return 'Upgrade to $plan';
  }

  @override
  String subscriptionChoosePlan(String plan) {
    return 'Choose $plan';
  }

  @override
  String get subscriptionPopular => 'Popular';

  @override
  String get subscriptionPerMonth => '/mo';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionHeadline => 'Unlock RADHA\'s full picture';

  @override
  String get subscriptionChooseAPlan => 'Choose a plan';

  @override
  String get subscriptionCancelAnytime => 'Cancel anytime · GST included';

  @override
  String get subscriptionBillingYearly => 'yearly';

  @override
  String get subscriptionBillingMonthly => 'monthly';

  @override
  String get versionLoading => 'Loading version…';

  @override
  String get versionUnavailable => 'Version unavailable';

  @override
  String appVersionBuild(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get shoppingListTitle => 'Shopping list';

  @override
  String get shoppingAddItem => 'Add item';

  @override
  String get shoppingLoadError => 'Could not load your list';

  @override
  String get shoppingLoadErrorBody =>
      'We couldn\'t load your shopping list. Please try again.';

  @override
  String get shoppingEmptyTitle => 'Your shopping list is empty';

  @override
  String get shoppingEmptyBody =>
      'Tap the plus button to add an item, or save healthy alternatives from a product page.';

  @override
  String get shoppingUpdateError =>
      'Could not update the item. Please try again.';

  @override
  String get shoppingDeleteError =>
      'Could not delete the item. Please try again.';

  @override
  String get shoppingAddError => 'Could not add the item. Please try again.';

  @override
  String get shoppingAllDone => 'All done — everything ticked off';

  @override
  String shoppingRemaining(int remaining, int total) {
    return '$remaining of $total left to buy';
  }

  @override
  String shoppingQty(int quantity) {
    return 'Qty: $quantity';
  }

  @override
  String get shoppingDeleteItem => 'Delete item';

  @override
  String get shoppingItemNameLabel => 'Item name';

  @override
  String get shoppingItemNameHint => 'e.g. Whole wheat bread';

  @override
  String get shoppingItemNameRequired => 'Enter an item name';

  @override
  String get shoppingItemNameTooLong => 'Keep it under 120 characters';

  @override
  String get shoppingQuantityLabel => 'Quantity (optional)';

  @override
  String get shoppingQuantityInvalid => 'Enter a positive number';

  @override
  String get shoppingQuantityTooHigh => 'That seems unreasonably high';

  @override
  String get shoppingAddToList => 'Add to list';

  @override
  String get grnTitle => 'Goods received';

  @override
  String get grnFilterAll => 'All';

  @override
  String get grnFilterDraft => 'Draft';

  @override
  String get grnFilterPendingReview => 'Pending Review';

  @override
  String get grnFilterPosted => 'Posted';

  @override
  String get grnStatusPending => 'Pending';

  @override
  String get grnEmptyTitle => 'No GRNs here';

  @override
  String get grnEmptyBody =>
      'Create a goods-received note to log a supplier delivery.';

  @override
  String get grnNew => 'New GRN';

  @override
  String get grnLoadError => 'Failed to load GRNs';

  @override
  String get grnSupplierFallback => 'Supplier';

  @override
  String get categoryBiscuits => 'Biscuits & Snacks';

  @override
  String get categoryBreakfast => 'Breakfast & Spreads';

  @override
  String get categoryDairy => 'Dairy & Eggs';

  @override
  String get categoryBeverages => 'Beverages';

  @override
  String get categoryStaples => 'Staples & Grains';

  @override
  String get categoryPersonalCare => 'Personal Care';

  @override
  String get categoryHousehold => 'Household';

  @override
  String get categoryFrozen => 'Frozen';

  @override
  String get lowStockTitle => 'Low stock alerts';

  @override
  String get lowStockLoadError => 'Failed to load alerts';

  @override
  String get lowStockEmpty => 'All stock levels are healthy';

  @override
  String lowStockCurrentThreshold(int quantity, int threshold) {
    return 'Current: $quantity / Threshold: $threshold';
  }

  @override
  String get lowStockRestock => 'Restock';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonQuantity => 'Quantity';

  @override
  String get smTitle => 'Stock movement';

  @override
  String get smStockIn => 'Stock In';

  @override
  String get smStockOut => 'Stock Out';

  @override
  String get smProductLabel => 'Product';

  @override
  String get smProductHint => 'Enter product ID or EAN';

  @override
  String get smReasonLabel => 'Reason';

  @override
  String get smSelectReason => 'Select reason';

  @override
  String get smBatchLabel => 'Batch number';

  @override
  String get smExpiryLabel => 'Expiry date';

  @override
  String get smExpiryOptionalHint => 'Optional — tap to select';

  @override
  String get smNotesLabel => 'Notes';

  @override
  String get smNotesHint => 'Optional notes';

  @override
  String get smRecordIn => 'Record stock in';

  @override
  String get smRecordOut => 'Record stock out';

  @override
  String get smStockInRecorded => 'Stock-in recorded';

  @override
  String get smStockOutRecorded => 'Stock-out recorded';

  @override
  String get smRecordError =>
      'Could not record the stock movement. Please try again.';

  @override
  String get smInsufficientStock => 'Insufficient stock for this movement';

  @override
  String get smReasonPurchase => 'Purchase';

  @override
  String get smReasonReturn => 'Return';

  @override
  String get smReasonAdjustment => 'Adjustment';

  @override
  String get smReasonTransfer => 'Transfer';

  @override
  String get smReasonDamage => 'Damage';

  @override
  String get smReasonExpiryRemoval => 'Expiry removal';

  @override
  String get smReasonOther => 'Other';

  @override
  String get grnInvoiceDateRequired => 'Invoice date is required';

  @override
  String get grnCreateError => 'Could not create the GRN. Please try again.';

  @override
  String get grnSupplierInvoiceSection => 'Supplier & invoice';

  @override
  String get grnSupplierNameLabel => 'Supplier name';

  @override
  String get grnSupplierNameHint => 'Enter supplier name';

  @override
  String get grnSupplierRequired => 'Supplier is required';

  @override
  String get grnInvoiceNumberLabel => 'Invoice number';

  @override
  String get grnInvoiceNumberHint => 'Enter invoice number';

  @override
  String get grnInvoiceNumberRequired => 'Invoice number is required';

  @override
  String get grnInvoiceDateLabel => 'Invoice date *';

  @override
  String get grnExpectedDeliveryLabel => 'Expected delivery date';

  @override
  String get grnCreateDraft => 'Create Draft GRN';

  @override
  String get grnSelectDate => 'Select date';

  @override
  String get expiryCalendarTitle => 'Expiry calendar';

  @override
  String get expiryCalendarLoadError => 'Failed to load calendar data.';

  @override
  String get expiryCalendarTapHint => 'Tap a day to see details';

  @override
  String get expiryCalendarNoRecords => 'No expiry records for this day';

  @override
  String expiryCalendarSummaryFor(String date) {
    return 'Summary for $date';
  }

  @override
  String get exTitle => 'New Expiry Record';

  @override
  String get exMfgAfterExpiry =>
      'Manufacturing date cannot be after expiry date';

  @override
  String get exSelectMfg => 'Select manufacturing date';

  @override
  String get exSelectExpiry => 'Select expiry date';

  @override
  String get exExpiryRequired => 'Expiry date is required';

  @override
  String get exCreated => 'Expiry record created';

  @override
  String get exOfflineQueued =>
      'You\'re offline — record will sync when you\'re back online';

  @override
  String get exSubmitError => 'Something went wrong. Please try again.';

  @override
  String get exNotSet => 'Not set';

  @override
  String get exProductIdLabel => 'Product ID';

  @override
  String get exProductIdHint => 'Enter product ID or scan barcode';

  @override
  String get exMfgLabel => 'Manufacturing Date';

  @override
  String get exExpiryLabel => 'Expiry Date *';

  @override
  String get exBatchLabel => 'Batch Number';

  @override
  String get exLocationLabel => 'Location';

  @override
  String get exLocationHint => 'Shelf / aisle / zone';

  @override
  String get exSaveRecord => 'Save Record';

  @override
  String get exOcrSemantic => 'RADHA reads the date for you';

  @override
  String get exOcrTitle => 'Scan the date off the pack';

  @override
  String get exOcrSubtitle => 'We\'ll read MFG / EXP for you';

  @override
  String get grnItemsTitle => 'GRN items';

  @override
  String get grnItemAdded => 'Item added';

  @override
  String get grnItemSavedOffline =>
      'Saved offline — it\'ll sync when you\'re back online';

  @override
  String get grnItemAddError => 'Could not add item. Please try again.';

  @override
  String get grnAddItemFirst => 'Add at least one item before posting';

  @override
  String get grnPosted => 'GRN posted — stock updated';

  @override
  String get grnPostQueued => 'Queued — it\'ll post when you\'re back online';

  @override
  String get grnPostError => 'Could not post GRN. Please try again.';

  @override
  String get grnNoItems => 'No items added yet';

  @override
  String get grnNoItemsHint => 'Tap the button below to add items';

  @override
  String grnTotalQty(String qty) {
    return 'Total Qty: $qty';
  }

  @override
  String grnTotalValue(String value) {
    return 'Total: ₹$value';
  }

  @override
  String get grnAddItem => 'Add Item';

  @override
  String get grnPostGrn => 'Post GRN';

  @override
  String get grnPostHint =>
      'Posting updates stock & resolves low-stock alerts.';

  @override
  String grnInvoiceLabel(String number) {
    return 'Invoice $number';
  }

  @override
  String grnBatchTag(String batch) {
    return 'Batch $batch';
  }

  @override
  String get grnBarcodeLabel => 'Barcode (EAN / UPC)';

  @override
  String get grnBarcodeHint => '8–13 digits';

  @override
  String get grnProductNameLabel => 'Product name';

  @override
  String get grnMustBePositive => 'Must be > 0';

  @override
  String get grnBatchNumberOptional => 'Batch number (optional)';

  @override
  String get grnMfgDateLabel => 'Manufacturing date';

  @override
  String get grnExpiryDateLabel => 'Expiry date';

  @override
  String get grnUnitPriceLabel => 'Unit price (₹)';

  @override
  String get grnMustBeNonNeg => 'Must be >= 0';
}
