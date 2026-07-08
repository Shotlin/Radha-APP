// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'RADHA';

  @override
  String get tagline => 'डेटा, आरोग्य आणि ऑडिटसाठी रिटेल असिस्टंट.';

  @override
  String get continueLabel => 'सुरू ठेवा';

  @override
  String get getStarted => 'सुरू करा';

  @override
  String get skip => 'वगळा';

  @override
  String get next => 'पुढे';

  @override
  String get back => 'मागे';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get save => 'जतन करा';

  @override
  String get delete => 'हटवा';

  @override
  String get edit => 'संपादन';

  @override
  String get add => 'जोडा';

  @override
  String get search => 'शोधा';

  @override
  String get loading => 'लोड होत आहे';

  @override
  String get error => 'काहीतरी चूक झाली';

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get done => 'पूर्ण';

  @override
  String get close => 'बंद करा';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get enterOtp => 'OTP प्रविष्ट करा';

  @override
  String get verifyOtp => 'OTP सत्यापित करा';

  @override
  String get resendOtp => 'OTP पुन्हा पाठवा';

  @override
  String get otpSent => 'आम्ही तुम्हाला 6 अंकी कोड पाठवला आहे';

  @override
  String get home => 'होम';

  @override
  String get scan => 'स्कॅन';

  @override
  String get expiry => 'एक्स्पायरी';

  @override
  String get tasks => 'कामे';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get language => 'भाषा';

  @override
  String get scanProduct => 'उत्पादन स्कॅन करा';

  @override
  String get pointAtBarcode => 'तुमचा कॅमेरा बारकोडवर ठेवा';

  @override
  String get scanAgain => 'पुन्हा स्कॅन करा';

  @override
  String get productNotFound => 'उत्पादन सापडले नाही';

  @override
  String get expiryTracker => 'एक्स्पायरी ट्रॅकर';

  @override
  String get addExpiry => 'एक्स्पायरी जोडा';

  @override
  String get expiringSoon => 'लवकरच एक्स्पायर होईल';

  @override
  String get expired => 'एक्स्पायर झाले';

  @override
  String get yourTasks => 'तुमची कामे';

  @override
  String get noTasks => 'कोणतीही कामे नाहीत';

  @override
  String get completeTask => 'काम पूर्ण करा';

  @override
  String get welcome => 'स्वागत आहे';

  @override
  String get welcomeMessage =>
      'स्प्रेडशीटशिवाय तुमचा साठा स्कॅन, ट्रॅक आणि ऑडिट करा.';

  @override
  String get referrals => 'रेफरल';

  @override
  String get shareYourCode => 'तुमचा कोड शेअर करा';

  @override
  String get yourReferralCode => 'तुमचा रेफरल कोड';

  @override
  String get invitees => 'आमंत्रित';

  @override
  String get rewardsEarned => 'मिळवलेले पुरस्कार';

  @override
  String get redeemCode => 'कोड रिडीम करा';

  @override
  String get enterReferralCode => 'रेफरल कोड प्रविष्ट करा';

  @override
  String get chooseLanguage => 'भाषा निवडा';

  @override
  String get languageUpdated => 'भाषा अद्यतनित केली';

  @override
  String get errorGeneric => 'काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.';

  @override
  String errorRateLimitOtp(int seconds) {
    return 'खूप जास्त OTP विनंत्या. $seconds सेकंदात पुन्हा प्रयत्न करा.';
  }

  @override
  String get errorOtpInvalid => 'OTP चुकीचा आहे. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorOtpExpired => 'OTP ची मुदत संपली. नवीन विनंती करा.';

  @override
  String get errorAuthRequired => 'सुरू ठेवण्यासाठी साइन इन करा.';

  @override
  String get errorNotFound => 'सापडले नाही.';

  @override
  String get ingredientExplainerErrorTitle => 'स्पष्टीकरण लोड होऊ शकले नाही';

  @override
  String get ingredientExplainerHealthConsiderations => 'आरोग्य विचार';

  @override
  String healthyAlternativesTitle(String productName) {
    return '$productName पेक्षा चांगले पर्याय';
  }

  @override
  String get healthyAlternativesGenericTitle => 'चांगले पर्याय';

  @override
  String get healthyAlternativesEmptyTitle => 'अद्याप आरोग्यकारक पर्याय नाहीत';

  @override
  String get healthyAlternativesEmptyBody =>
      'त्याच श्रेणीत अद्याप आरोग्यकारक पर्याय सापडलेले नाहीत.';

  @override
  String get healthyAlternativesErrorTitle => 'पर्याय लोड होऊ शकले नाहीत';

  @override
  String get healthyAlternativesAddToList => 'खरेदी यादीत जोडा';

  @override
  String get healthyAlternativesView => 'पहा';

  @override
  String get healthyAlternativesAddedToList => 'खरेदी यादीत जोडले';

  @override
  String get healthyAlternativesAddFailed => 'खरेदी यादीत जोडता आले नाही';

  @override
  String get savedProductsTitle => 'जतन केलेली उत्पादने';

  @override
  String get savedProductsEmptyTitle => 'जतन केलेली उत्पादने';

  @override
  String get savedProductsEmptyBody =>
      'स्कॅन निकाल स्क्रीनवरून उत्पादने जतन करा म्हणजे ती येथे दिसतील.';

  @override
  String get savedProductsErrorTitle =>
      'जतन केलेली उत्पादने लोड करता आली नाहीत';

  @override
  String savedProductsSavedOn(String date) {
    return '$date रोजी जतन केले';
  }

  @override
  String get digestTitle => 'RADHA सोबत तुमचा आठवडा';

  @override
  String digestWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String digestSavingsHero(String amount) {
    return '₹$amount वाचवले';
  }

  @override
  String digestScansHero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count स्कॅन्स',
      one: '1 स्कॅन',
    );
    return '$_temp0';
  }

  @override
  String get digestHeroEmptyHeadline => 'एक शांत आठवडा';

  @override
  String get digestScans => 'स्कॅन्स';

  @override
  String get digestSavedProducts => 'जतन केलेले';

  @override
  String get digestExpiringSoon => 'लवकरच एक्स्पायर';

  @override
  String digestRecallAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉल अलर्ट्स',
      one: '1 रिकॉल अलर्ट',
    );
    return '$_temp0';
  }

  @override
  String get digestRecallAlertsBody =>
      'या आठवड्यात तुम्ही स्कॅन केलेल्या उत्पादनांसाठी नवीन सुरक्षा सूचना आहेत.';

  @override
  String get digestRecallAlertsCta => 'पाहा';

  @override
  String get digestTopCategoriesHeader => 'तुम्ही काय स्कॅन करत आहात';

  @override
  String get digestHighlightsHeader => 'ठळक मुद्दे';

  @override
  String get digestContinueScanning => 'स्कॅन सुरू ठेवा';

  @override
  String get digestShare => 'माझा आठवडा शेअर करा';

  @override
  String digestShareTemplate(int scans, String savings) {
    return 'या आठवड्यात मी $scans उत्पादने स्कॅन केली आणि RADHA सोबत ₹$savings वाचवले. तुम्हीही करून पहा: https://radha.app';
  }

  @override
  String get digestEmptyTitle => 'या आठवड्यात कोणतीही क्रिया नाही';

  @override
  String get digestEmptyBody =>
      'तुमची साप्ताहिक कथा तयार करण्यासाठी स्कॅन सुरू करा.';

  @override
  String get digestErrorTitle => 'साप्ताहिक सारांश लोड करू शकलो नाही';

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get settingsNotifications => 'सूचना';

  @override
  String get settingsPushNotifications => 'पुश सूचना';

  @override
  String get settingsPushNotificationsHint => 'तुमच्या फोनवर अलर्ट मिळवा';

  @override
  String get settingsRecallAlerts => 'रिकॉल अलर्ट';

  @override
  String get settingsRecallAlertsHint =>
      'तुम्ही स्कॅन केलेले उत्पादन रिकॉल झाल्यावर कळवा';

  @override
  String get settingsWeeklyDigest => 'साप्ताहिक सारांश';

  @override
  String get settingsWeeklyDigestHint =>
      'रविवारी तुमचे स्कॅन्स आणि बचतीचा सारांश';

  @override
  String get settingsAppearance => 'स्वरूप';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsThemeLight => 'लाइट';

  @override
  String get settingsThemeDark => 'डार्क';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsTextSize => 'टेक्स्ट आकार';

  @override
  String get settingsTextSizeSmall => 'लहान';

  @override
  String get settingsTextSizeStandard => 'मानक';

  @override
  String get settingsTextSizeLarge => 'मोठा';

  @override
  String get settingsDataPrivacy => 'डेटा आणि गोपनीयता';

  @override
  String get settingsAllergens => 'अॅलर्जी प्रोफाइल';

  @override
  String get settingsAllergensHint => 'ज्या घटकांची सावधगिरी हवी ती निवडा';

  @override
  String get settingsSignOutAll => 'सर्व डिव्हाइसमधून साइन आउट करा';

  @override
  String get settingsSignOutAllConfirmTitle => 'सर्वत्र साइन आउट?';

  @override
  String get settingsSignOutAllConfirmBody =>
      'हे खाते वापरणाऱ्या प्रत्येक डिव्हाइसवर तुम्हाला पुन्हा साइन इन करावे लागेल.';

  @override
  String get settingsDeleteAccount => 'खाते हटवा';

  @override
  String get settingsDeleteAccountTitle => 'खाते हटवा';

  @override
  String get settingsDeleteAccountBody =>
      'हे तुमचा डेटा कायमचा हटवेल. पुष्टी करण्यासाठी DELETE टाइप करा.';

  @override
  String get settingsDeleteAccountConfirm => 'DELETE';

  @override
  String get settingsDeleteAccountUnavailable =>
      'खाते हटवण्यासाठी सपोर्टशी संपर्क साधा.';

  @override
  String get settingsDeleteAccountContact => 'सपोर्टशी संपर्क साधा';

  @override
  String get settingsAbout => 'बद्दल';

  @override
  String get settingsTerms => 'सेवेच्या अटी';

  @override
  String get settingsPrivacyPolicy => 'गोपनीयता धोरण';

  @override
  String get settingsVersion => 'अॅप आवृत्ती';

  @override
  String settingsVersionValue(String version, String build) {
    return 'आवृत्ती $version ($build)';
  }

  @override
  String get settingsSupport => 'सपोर्ट';

  @override
  String get settingsSupportHint => 'मदत मिळवा, बग नोंदवा किंवा अभिप्राय द्या';

  @override
  String get settingsLinkOpenFailed => 'लिंक उघडता आली नाही';

  @override
  String conflictBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count विरोधांना तुमचे लक्ष हवे आहे',
      one: '1 विरोधाला तुमचे लक्ष हवे आहे',
    );
    return '$_temp0';
  }

  @override
  String get conflictBannerCta => 'सोडवा';

  @override
  String get conflictBannerDismiss => 'बंद करा';

  @override
  String get conflictResolveTitle => 'सिंक विरोध सोडवा';

  @override
  String get conflictResolveSubtitle =>
      'प्रत्येक आयटमसाठी कोणती आवृत्ती ठेवायची ते निवडा.';

  @override
  String get conflictUseMine => 'माझी आवृत्ती ठेवा';

  @override
  String get conflictUseServer => 'सर्व्हर आवृत्ती ठेवा';

  @override
  String get conflictResolved => 'विरोध सोडवला';

  @override
  String get conflictResolvedAll => 'सर्व विरोध सोडवले';

  @override
  String conflictAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वेळा प्रयत्न केला',
      one: '1 वेळा प्रयत्न केला',
    );
    return '$_temp0';
  }

  @override
  String get conflictResourceTask => 'कार्य';

  @override
  String get conflictResourceExpiry => 'एक्स्पायरी रेकॉर्ड';

  @override
  String get conflictResourceScan => 'स्कॅन';

  @override
  String get conflictResourceInventory => 'स्टॉक समायोजन';

  @override
  String get conflictResourceGrn => 'GRN नोंद';

  @override
  String get conflictResourceShoppingList => 'खरेदी यादी आयटम';

  @override
  String get conflictResourceGeneric => 'सिंक बदल';

  @override
  String conflictLocalChangeSummary(String summary) {
    return 'तुमचा बदल: $summary';
  }

  @override
  String get supportTitle => 'सपोर्ट';

  @override
  String get supportContactUs => 'आमच्याशी संपर्क साधा';

  @override
  String get supportEmailUs => 'ईमेल करा';

  @override
  String get supportEmailUsHint => 'support@radha.app';

  @override
  String get supportCallUs => 'सपोर्टला कॉल करा';

  @override
  String get supportCallUsHint => 'सोम–शुक्र, सकाळी 9 – संध्याकाळी 6 IST';

  @override
  String get supportReportBug => 'बग नोंदवा';

  @override
  String get supportBugDescription => 'काय झाले?';

  @override
  String get supportBugDescriptionHint =>
      'जेव्हा अडचण आली तेव्हा तुम्ही काय करत होता ते सांगा.';

  @override
  String get supportAttachScreenshot => 'स्क्रीनशॉट जोडा';

  @override
  String get supportScreenshotAttached => 'स्क्रीनशॉट जोडला';

  @override
  String get supportRemoveScreenshot => 'काढा';

  @override
  String get supportSubmit => 'अहवाल पाठवा';

  @override
  String get supportSubmitted => 'धन्यवाद — तुमचा अहवाल मिळाला.';

  @override
  String get supportSubmitFailed => 'पाठवू शकलो नाही. कृपया आम्हाला ईमेल करा.';

  @override
  String get supportBugDescriptionRequired => 'कृपया काय झाले ते सांगा.';

  @override
  String get supportFaq => 'वारंवार विचारले जाणारे प्रश्न';

  @override
  String get supportFaqQ1 => 'बारकोड कसा स्कॅन करावा?';

  @override
  String get supportFaqA1 =>
      'स्कॅन टॅब उघडा, कॅमेरा बारकोडवर ठेवा आणि स्थिर ठेवा. स्पष्ट कोड वाचताच उत्पादन दिसेल.';

  @override
  String get supportFaqQ2 => 'उत्पादन डेटाबेसमध्ये नसल्यास?';

  @override
  String get supportFaqA2 =>
      'सापडले-नाही स्क्रीनवर \"उत्पादन जोडा\" टॅप करा. हे तुमच्या स्टोअरशी जोडलेली नवीन नोंद तयार करेल.';

  @override
  String get supportFaqQ3 => 'मी माझे सबस्क्रिप्शन कसे रद्द करू?';

  @override
  String get supportFaqA3 =>
      'प्रोफाइल → सबस्क्रिप्शनवर जा. कधीही रद्द करू शकता; पुढील बिलिंग चक्रानंतर शुल्क नाही.';

  @override
  String get supportFaqQ4 => 'मला रिकॉल अलर्ट का दिसत आहे?';

  @override
  String get supportFaqA4 =>
      'प्रत्येक स्कॅन FSSAI रिकॉल फीडशी जुळवतो. विकलेला बॅच यादीत असेल तर आम्ही कळवतो.';

  @override
  String get supportFaqQ5 => 'माझी अॅलर्जी प्रोफाइल कुटुंबासह कशी शेअर करू?';

  @override
  String get supportFaqA5 =>
      'अॅलर्जी प्रोफाइल सध्या प्रत्येक खात्यासाठी असते. एकाच घराच्या खात्यावर साइन इन करा किंवा प्रत्येक फोनवर तीच अॅलर्जी निवडा.';

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
  String get expiryTabNear => 'लवकर संपणारे';

  @override
  String get expiryTabSafe => 'सुरक्षित';

  @override
  String get expiryCalendarTooltip => 'कॅलेंडर दृश्य';

  @override
  String get expiryEmptyExpiredTitle => 'काहीही एक्स्पायर नाही';

  @override
  String get expiryEmptyNearTitle => 'सर्व काही ठीक आहे';

  @override
  String get expiryEmptyDefaultTitle => 'अद्याप कोणतेही रेकॉर्ड नाही';

  @override
  String get expiryEmptyBody => 'या श्रेणीत कोणतेही रेकॉर्ड नाही.';

  @override
  String expiryProductShort(String id) {
    return 'उत्पादन $id';
  }

  @override
  String expiryBatch(String batch) {
    return 'बॅच $batch';
  }

  @override
  String expiryQty(String qty) {
    return 'प्रमाण $qty';
  }

  @override
  String expiryExp(String date) {
    return 'एक्स्पायरी $date';
  }

  @override
  String get expiryPillToday => 'आज';

  @override
  String get expiryPillTomorrow => 'उद्या';

  @override
  String expiryPillDays(int days) {
    return '${days}d';
  }

  @override
  String get expiryPillSoon => 'लवकर';

  @override
  String get expiryLoadError => 'एक्स्पायरी रेकॉर्ड लोड करता आले नाहीत.';

  @override
  String get expiryCouldNotLoadSemantic => 'लोड करता आले नाही';

  @override
  String get inventoryTitle => 'इन्व्हेंटरी';

  @override
  String get inventorySearchTooltip => 'इन्व्हेंटरी शोधा';

  @override
  String get inventorySearchHint => 'उत्पादन किंवा EAN ने शोधा...';

  @override
  String get inventoryStockMovement => 'स्टॉक हालचाल';

  @override
  String get inventoryLowStockAlerts => 'कमी स्टॉक सूचना';

  @override
  String get inventoryLoadError => 'इन्व्हेंटरी लोड करता आली नाही';

  @override
  String get inventoryEmpty => 'कोणतेही इन्व्हेंटरी आयटम सापडले नाही';

  @override
  String inventoryNoMatches(String query) {
    return '\"$query\" साठी जुळणी नाही';
  }

  @override
  String inventoryProductShort(String id) {
    return 'उत्पादन $id';
  }

  @override
  String get inventoryBelowThreshold => 'मर्यादेपेक्षा कमी';

  @override
  String get inventoryInStock => 'स्टॉकमध्ये';

  @override
  String get inventoryUnitsLabel => 'युनिट्स';

  @override
  String get inventoryTotalQuantity => 'एकूण प्रमाण';

  @override
  String get inventoryLowStockThreshold => 'कमी-स्टॉक मर्यादा';

  @override
  String inventoryQtyUnits(int count) {
    return '$count युनिट्स';
  }

  @override
  String get inventoryBatchLedgerHint =>
      'संपूर्ण बॅच लेजर पाहण्यासाठी \"स्टॉक हालचाल\" टॅप करा.';

  @override
  String get inventoryLowStockBadge => 'कमी स्टॉक';

  @override
  String get tasksTitle => 'कार्ये';

  @override
  String get tasksTabMine => 'माझी कार्ये';

  @override
  String get tasksTabAll => 'सर्व';

  @override
  String get tasksNewTask => 'नवीन कार्य';

  @override
  String get tasksEmptyTitle => 'इथे कोणतीही कार्ये नाहीत';

  @override
  String get tasksEmptyBody => 'या दृश्याला नियुक्त केलेली कार्ये येथे दिसतील.';

  @override
  String get tasksLoadError => 'कार्ये लोड करता आली नाहीत';

  @override
  String get taskEvidence => 'पुरावा';

  @override
  String get priorityHigh => 'उच्च';

  @override
  String get priorityMedium => 'मध्यम';

  @override
  String get priorityLow => 'कमी';

  @override
  String get priorityUrgent => 'तातडीचे';

  @override
  String get taskStatusOpen => 'खुले';

  @override
  String get taskStatusPending => 'प्रलंबित';

  @override
  String get taskStatusInProgress => 'सुरू आहे';

  @override
  String get taskStatusCompleted => 'पूर्ण';

  @override
  String get taskStatusCancelled => 'रद्द';

  @override
  String get scanTitle => 'उत्पादन स्कॅन करा';

  @override
  String get scanAlignHint => 'बारकोड फ्रेममध्ये संरेखित करा';

  @override
  String get scanBatchHint =>
      'बॅच मोड — स्कॅन करत राहा, आयटम आपोआप जोडले जातील';

  @override
  String scanBatchAdded(String code, int count) {
    return '$code जोडले · $count स्कॅन केले';
  }

  @override
  String scanBatchDone(int count) {
    return 'पूर्ण · $count';
  }

  @override
  String get scanLabelAction => 'लेबल स्कॅन';

  @override
  String get scanGalleryAction => 'गॅलरी';

  @override
  String get scanEnterManually => 'मॅन्युअली प्रविष्ट करा';

  @override
  String get scanBulkAudit => 'बल्क ऑडिट';

  @override
  String get scanHistoryAction => 'इतिहास';

  @override
  String get scanFlash => 'फ्लॅश';

  @override
  String get scanTroubleTitle => 'स्कॅन करताना अडचण?';

  @override
  String get scanTroubleBody =>
      'कमी प्रकाश किंवा खराब बारकोड? फ्लॅश चालू करा, किंवा त्याऐवजी लेबल वाचा.';

  @override
  String get scanGalleryNoBarcode =>
      'बारकोड सापडला नाही. टीप: घटक वाचण्यासाठी \'लेबल स्कॅन\' वापरा.';

  @override
  String get scanInvalidEan =>
      'वैध EAN-8, EAN-13, किंवा UPC-A कोड प्रविष्ट करा';

  @override
  String get scanWebTitle => 'स्कॅन';

  @override
  String get scanWebUnavailable =>
      'वेबवर कॅमेरा स्कॅनिंग उपलब्ध नाही.\nबारकोड मॅन्युअली प्रविष्ट करा:';

  @override
  String get scanEanFieldLabel => 'EAN / UPC कोड';

  @override
  String get scanEanHintExample => 'उदा. 5901234123457';

  @override
  String get scanLookUp => 'शोधा';

  @override
  String get scanEnterBarcode => 'बारकोड प्रविष्ट करा';

  @override
  String get scanHistoryTitle => 'स्कॅन इतिहास';

  @override
  String get scanNoHistory => 'या सत्रात अद्याप कोणतेही स्कॅन नाही.';

  @override
  String get homeGreetingMorning => 'शुभ सकाळ';

  @override
  String get homeGreetingAfternoon => 'शुभ दुपार';

  @override
  String get homeGreetingEvening => 'शुभ संध्याकाळ';

  @override
  String get homeGreetingFallbackName => 'मित्रा';

  @override
  String get homeTrialEnded =>
      'मोफत ट्रायल संपली — प्रवेश सुरू ठेवण्यासाठी अपग्रेड करा';

  @override
  String homeTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिवस',
      one: '1 दिवस',
    );
    return 'मोफत ट्रायल · $_temp0 शिल्लक';
  }

  @override
  String get homeUpgradeArrow => 'अपग्रेड →';

  @override
  String get homeKpiSaved => 'जतन केलेले';

  @override
  String get homeKpiNearExpiry => 'लवकर संपणारे';

  @override
  String get homeKpiRecallAlerts => 'रिकॉल सूचना';

  @override
  String get homeKpiOpenTasks => 'खुली कार्ये';

  @override
  String get homeKpiLowStock => 'कमी स्टॉक';

  @override
  String get homeEyebrowFoodSafety => 'अन्न सुरक्षा इशारा';

  @override
  String get homeEyebrowToday => 'आजचे काम';

  @override
  String get homeEyebrowHealthScan => 'तुमचा हेल्थ स्कॅन';

  @override
  String get homeEyebrowScanToLearn => 'स्कॅन करून जाणून घ्या';

  @override
  String get homeEyebrowAllClear => 'सर्व काही ठीक आहे';

  @override
  String homeStoryRecall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉल केलेली उत्पादने — तुमच्या घरात काय आहे ते पाहा',
      one: '1 रिकॉल केलेले उत्पादन — तुमच्या घरात काय आहे ते पाहा',
    );
    return '$_temp0';
  }

  @override
  String homeStoryNearExpiryConsumer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जतन केलेल्या वस्तू या आठवड्यात संपत आहेत — वापरून टाका',
      one: '1 जतन केलेली वस्तू या आठवड्यात संपत आहे — वापरून टाका',
    );
    return '$_temp0';
  }

  @override
  String get homeStoryKnowWhatYouEat => 'तुम्ही काय खाता ते जाणून घ्या';

  @override
  String get homeStoryScanInside =>
      'कोणत्याही फूड बारकोडवर कॅमेरा धरा — आत काय आहे ते पाहा';

  @override
  String homeStoryNearExpiryBusiness(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू लवकर संपणार — शेल्फ साफ करा',
      one: '1 वस्तू लवकर संपणार — शेल्फ साफ करा',
    );
    return '$_temp0';
  }

  @override
  String homeStoryOpenTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्यांना आज तुमची गरज आहे',
      one: '1 कार्याला आज तुमची गरज आहे',
    );
    return '$_temp0';
  }

  @override
  String homeStoryLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तूंचा स्टॉक कमी होत आहे',
      one: '1 वस्तूचा स्टॉक कमी होत आहे',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreToday => 'हे पाहा आज तुमचे दुकान';

  @override
  String get homeStoreAllGood => 'शाब्बास! तुमचे दुकान आज उत्तम स्थितीत आहे';

  @override
  String get homeCtaViewRecallAlerts => 'रिकॉल सूचना पाहा';

  @override
  String get homeCtaCheckExpiry => 'एक्स्पायरी पाहा';

  @override
  String get homeCtaOpenExpiry => 'एक्स्पायरी उघडा';

  @override
  String get homeCtaViewTasks => 'कार्ये पाहा';

  @override
  String get homeCtaCheckInventory => 'इन्व्हेंटरी पाहा';

  @override
  String get homeCtaOpenTasks => 'कार्ये उघडा';

  @override
  String get homeCtaRunAudit => 'एक झटपट ऑडिट चालवा';

  @override
  String get homeQuickActions => 'झटपट क्रिया';

  @override
  String get homeQuickScan => 'स्कॅन';

  @override
  String get homeQuickShopping => 'शॉपिंग';

  @override
  String get homeQuickAddExpiry => 'एक्स्पायरी जोडा';

  @override
  String get homeQuickNewTask => 'नवीन कार्य';

  @override
  String get homeRecentTasks => 'अलीकडील कार्ये';

  @override
  String get homeSeeAll => 'सर्व पाहा';

  @override
  String get homeNoOpenTasks => 'कोणतेही खुले कार्य नाही — एक तयार करा';

  @override
  String homeTaskAssignedTo(String name) {
    return '$name ला नियुक्त केले';
  }

  @override
  String get homeTaskOverdue => 'थकीत';

  @override
  String get homeTaskDueToday => 'आज देय';

  @override
  String get homeTaskDueTomorrow => 'उद्या देय';

  @override
  String homeTaskDueInDays(int days) {
    return '$days दिवसांत देय';
  }

  @override
  String homeTaskDueOn(String date) {
    return 'देय $date';
  }

  @override
  String get homeHowHelps => 'RADHA तुम्हाला कशी मदत करते';

  @override
  String get homeScanBarcodeTitle => 'कोणताही फूड बारकोड स्कॅन करा';

  @override
  String get homeScanBarcodeBody =>
      'हेल्थ रेटिंग, घटक, आणि कशाकडे लक्ष द्यायचे — सर्व पाहा.';

  @override
  String get homeRecallTitle => 'सुरक्षा रिकॉल सूचना';

  @override
  String get homeRecallBody =>
      'रिकॉल केलेल्या अन्न उत्पादनांबद्दल माहिती ठेवा.';

  @override
  String get homePromoKnowFoodEyebrow => 'तुमचे अन्न जाणून घ्या';

  @override
  String get homePromoKnowFoodHeadline =>
      'लेबल स्कॅन करा — आत खरोखर काय आहे ते पाहा';

  @override
  String get homePromoKnowFoodCta => 'स्कॅन करा आणि जाणून घ्या';

  @override
  String get homePromoExpiryEyebrow => 'कोणतीही तारीख चुकवू नका';

  @override
  String get homePromoExpiryHeadline => 'प्रत्येक एक्स्पायरी निसटण्याआधी पकडा';

  @override
  String get homePromoExpiryCta => 'एक्स्पायरी ट्रॅक करा';

  @override
  String get homePromoFestiveEyebrow => 'सणाच्या निवडी';

  @override
  String get homePromoFestiveHeadline =>
      'हंगामाची खरेदी करा, आरोग्यदायी पद्धतीने';

  @override
  String get homePromoFestiveCta => 'उत्पादने ब्राउझ करा';

  @override
  String get homePromoBazaarEyebrow => 'आजचा बाजार';

  @override
  String get homePromoBazaarHeadline => 'मिनिटांत तुमच्या शेल्फचे ऑडिट करा';

  @override
  String get homePromoBazaarCta => 'ऑडिट सुरू करा';

  @override
  String get homeShopByCategory => 'श्रेणीनुसार खरेदी करा';

  @override
  String get homeShopByCategorySubtitle =>
      'स्कॅन किंवा ब्राउझ करण्यासाठी एखाद्या विभागावर टॅप करा';

  @override
  String get onboardingWelcomeValue =>
      'स्कॅन करा, ट्रॅक करा, तुमच्या स्टॉकचे ऑडिट करा — स्प्रेडशीटशिवाय.';

  @override
  String get onboardingCapabilitiesTitle =>
      'दुकानाच्या मजल्यासाठी बनवले,\nबॅक ऑफिससाठी नाही.';

  @override
  String get onboardingCapScanTitle => 'एका टॅपमध्ये उत्पादने स्कॅन करा';

  @override
  String get onboardingCapScanBody =>
      'हेल्थ आणि मंजुरी आधीच तपासलेले EAN लुकअप.';

  @override
  String get onboardingCapExpiryTitle => 'नुकसान होण्याआधी एक्स्पायरी पकडा';

  @override
  String get onboardingCapExpiryBody =>
      'OCR-सहाय्यित तारखा आणि श्रेणीनिहाय मर्यादा.';

  @override
  String get onboardingCapAuditTitle => 'संघ पूर्ण करू शकेल असे ऑडिट चालवा';

  @override
  String get onboardingCapAuditBody => 'कार्ये, पुरावे आणि बल्क स्कॅन सत्रे.';

  @override
  String get onboardingSegmentTitle => 'तुम्ही इथे कोण म्हणून आहात?';

  @override
  String get onboardingSegmentSubtitle =>
      'सर्वात जवळचा पर्याय निवडा. तुम्ही नंतर सेटिंग्जमध्ये बदलू शकता.';

  @override
  String get segmentPersonalTitle => 'वैयक्तिक';

  @override
  String get segmentPersonalBody => 'फक्त स्वतःसाठी खरेदी';

  @override
  String get segmentParentTitle => 'पालक';

  @override
  String get segmentParentBody => 'माझ्या कुटुंबासाठी / मुलांसाठी खरेदी';

  @override
  String get segmentBusinessTitle => 'व्यवसाय मालक';

  @override
  String get segmentBusinessBody => 'मी एक लहान रिटेल दुकान चालवतो';

  @override
  String get segmentPharmacyTitle => 'फार्मसी';

  @override
  String get segmentPharmacyBody => 'मी फार्मसी / केमिस्ट चालवतो';

  @override
  String get segmentInstitutionTitle => 'संस्था';

  @override
  String get segmentInstitutionBody => 'शाळा / वसतिगृह / कॅन्टीन';

  @override
  String get segmentAuditorTitle => 'लेखापरीक्षक (आमंत्रित)';

  @override
  String get segmentAuditorBody => 'माझ्याकडे आमंत्रण कोड आहे';

  @override
  String get allergenTitle => 'अॅलर्जन';

  @override
  String get allergenLoadError => 'तुमचे अॅलर्जन प्रोफाइल लोड करता आले नाही.';

  @override
  String get allergenHeading => 'तुमचे अॅलर्जन';

  @override
  String get allergenIntro =>
      'तुम्हाला ज्यांची प्रतिक्रिया होते त्या अॅलर्जनवर टॅप करा. स्कॅन केलेल्या उत्पादनात ते असल्यास आम्ही तुम्हाला सावध करू.';

  @override
  String allergenTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अॅलर्जन ट्रॅक केले',
      one: '1 अॅलर्जन ट्रॅक केले',
    );
    return '$_temp0';
  }

  @override
  String get allergenNoneTracked => 'अद्याप कोणतेही अॅलर्जन ट्रॅक केले नाही';

  @override
  String get allergenSavedCleared => 'अॅलर्जन प्रोफाइल साफ केले.';

  @override
  String get allergenSaved => 'अॅलर्जन प्रोफाइल जतन केले.';

  @override
  String get allergenSaveError => 'तुमचे अॅलर्जन जतन करता आले नाहीत.';

  @override
  String get allergenPeanut => 'शेंगदाणा';

  @override
  String get allergenTreeNut => 'ट्री नट';

  @override
  String get allergenDairy => 'दुग्धजन्य';

  @override
  String get allergenEggs => 'अंडी';

  @override
  String get allergenSoy => 'सोया';

  @override
  String get allergenWheat => 'गहू';

  @override
  String get allergenFish => 'मासे';

  @override
  String get allergenShellfish => 'शेलफिश';

  @override
  String get allergenSesame => 'तीळ';

  @override
  String get allergenGluten => 'ग्लूटेन';

  @override
  String get allergenMustard => 'मोहरी';

  @override
  String get allergenCelery => 'सेलरी';

  @override
  String get allergenLupin => 'ल्युपिन';

  @override
  String get allergenMolluscs => 'मोलस्क';

  @override
  String get allergenSulphites => 'सल्फाइट';

  @override
  String get commonSuccess => 'यशस्वी';

  @override
  String lockedFeatureUpgradeTo(String planName) {
    return '$planName वर अपग्रेड करा';
  }

  @override
  String lockedFeaturePlan(String planName) {
    return 'हे वैशिष्ट्य $planName प्लॅनचा भाग आहे.';
  }

  @override
  String get lockedFeatureViewPlans => 'प्लॅन पाहा';

  @override
  String get notFoundSemantic => 'पृष्ठ सापडले नाही';

  @override
  String get notFoundTitle => 'हे पृष्ठ हरवले';

  @override
  String get notFoundBody =>
      'तुम्ही जे शोधत होता ते आम्हाला सापडले नाही. चला तुम्हाला पुन्हा होमवर नेऊया.';

  @override
  String get notFoundBackHome => 'होमवर परत';

  @override
  String get commonCouldNotLoad => 'लोड करता आले नाही';

  @override
  String get sendOtp => 'OTP पाठवा';

  @override
  String get otpUseCode => 'कोड वापरा';

  @override
  String get ohsPickStore => 'डॅशबोर्ड उघडण्यापूर्वी एक स्टोअर निवडा.';

  @override
  String get profileAccount => 'खाते';

  @override
  String get profileManageStores => 'स्टोअर व्यवस्थापित करा';

  @override
  String get profileSavedProducts => 'जतन केलेली उत्पादने';

  @override
  String get profileSubscription => 'सदस्यता';

  @override
  String get profilePreferences => 'प्राधान्ये';

  @override
  String get profileAllergenProfile => 'अॅलर्जन प्रोफाइल';

  @override
  String get profileShoppingList => 'शॉपिंग यादी';

  @override
  String get recallTitle => 'रिकॉल सूचना';

  @override
  String recallProductFallback(String id) {
    return 'उत्पादन $id';
  }

  @override
  String recallDate(String date) {
    return 'परत मागवले $date';
  }

  @override
  String get recallViewProduct => 'उत्पादन पाहा';

  @override
  String get recallLoadError => 'रिकॉल लोड करता आले नाहीत.';

  @override
  String get recallEmpty => 'कोणतेही सक्रिय रिकॉल नाहीत';

  @override
  String get recallEmptyBody =>
      'नियामक संस्थांकडून जारी केल्यावर उत्पादन रिकॉल सूचना येथे दिसतील.';

  @override
  String get referralsLoadError => 'रेफरल लोड करता आले नाहीत.';

  @override
  String get referralsCopyCode => 'कोड कॉपी करा';

  @override
  String get referralsShareInvite => 'आमंत्रण शेअर करा';

  @override
  String get referralsCodeCopied => 'कोड कॉपी झाला';

  @override
  String get referralsInvitees => 'आमंत्रित';

  @override
  String get referralsRewardsEarned => 'मिळवलेली बक्षिसे';

  @override
  String get referralsCodeRedeemed => 'कोड रिडीम झाला';

  @override
  String get referralsEnterCode => 'एक रेफरल कोड प्रविष्ट करा';

  @override
  String get referralsRedeem => 'रिडीम करा';

  @override
  String get referralsRedeemError => 'कोड रिडीम करता आला नाही';

  @override
  String get referralsRedeemSubtitle =>
      'मित्राचे आमंत्रण आहे? खाली त्यांचा कोड प्रविष्ट करा.';

  @override
  String get commonClear => 'साफ करा';

  @override
  String get commonShare => 'शेअर करा';

  @override
  String get healthSugar => 'साखर';

  @override
  String get healthSalt => 'मीठ';

  @override
  String get healthFat => 'चरबी';

  @override
  String get healthProcessed => 'प्रक्रिया केलेले';

  @override
  String get healthChildSuitable => 'मुलांसाठी योग्य';

  @override
  String get productDetailsTitle => 'उत्पादन तपशील';

  @override
  String get productDetailLoadError => 'हे उत्पादन लोड करता आले नाही';

  @override
  String get productCheckAllergens => 'अॅलर्जन तपासा';

  @override
  String get productExplainIngredients => 'घटक समजावा';

  @override
  String get productSeeHealthierOptions => 'आरोग्यदायी पर्याय पाहा';

  @override
  String get productViewHealthyAlternatives => 'आरोग्यदायी पर्याय पाहा';

  @override
  String get productHealthAssessment => 'आरोग्य मूल्यांकन';

  @override
  String get productNutritionInfo => 'पोषण माहिती';

  @override
  String get productAllergenCheck => 'अॅलर्जन तपासणी';

  @override
  String get productSeeFullExplanation => 'संपूर्ण स्पष्टीकरण पाहा';

  @override
  String get productHealthierOptions => 'आरोग्यदायी पर्याय';

  @override
  String get commonYes => 'होय';

  @override
  String get nutritionProtein => 'प्रथिने';

  @override
  String get nutritionTotalSugars => 'एकूण साखर';

  @override
  String get nutritionEnergy => 'ऊर्जा';

  @override
  String get nutritionTotalFat => 'एकूण चरबी';

  @override
  String get nutritionSaturatedFat => 'संतृप्त चरबी';

  @override
  String get nutritionCarbohydrates => 'कार्बोहायड्रेट';

  @override
  String get nutritionFibre => 'फायबर';

  @override
  String get nutritionSodium => 'सोडियम';

  @override
  String get nutritionAll => 'सर्व पोषक घटक';

  @override
  String get nutritionPer100g => 'प्रति 100 ग्रॅम';

  @override
  String get nutritionPer50g => 'प्रति 50 ग्रॅम';

  @override
  String get productDetailSavedAlert =>
      'जतन केले — कधी रिकॉल झाल्यास आम्ही तुम्हाला सूचित करू.';

  @override
  String get productDetailSaveError =>
      'जतन करता आले नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get productDetailWhatYoullLike => 'तुम्हाला काय आवडेल';

  @override
  String get productDetailWhatConcern => 'कशाची काळजी घ्यावी';

  @override
  String get productDetailIngredientDeepDive => 'घटकांचा सखोल आढावा';

  @override
  String get productDetailPersonalisedFlags => 'वैयक्तिक सूचना';

  @override
  String get productDetailAlreadyBought => 'आधीच खरेदी केले';

  @override
  String get productDetailScanToUnlock => 'अनलॉक करण्यासाठी स्कॅन करा';

  @override
  String get productDetailTitle => 'उत्पादन';

  @override
  String get productDetailSave => 'जतन करा';

  @override
  String get productDetailSaved => 'जतन केले';

  @override
  String get productDetailHealthNotRated => 'आरोग्य रेटिंग अद्याप नाही';

  @override
  String get productDetailHealthNotRatedBody =>
      'या उत्पादनाचे संपूर्ण आरोग्य विश्लेषण RADHA मध्ये आणण्यासाठी स्कॅन करा.';

  @override
  String get productDetailHealthLabel => 'RADHA आरोग्य रेटिंग';

  @override
  String get productDetailHighProtein => 'उच्च प्रथिने';

  @override
  String get productDetailGoodFibre => 'चांगले फायबर';

  @override
  String get productDetailMinimallyProcessed => 'कमी प्रक्रिया केलेले';

  @override
  String get productDetailHighSugar => 'उच्च साखर';

  @override
  String get productDetailHighSatFat => 'उच्च संतृप्त चरबी';

  @override
  String get productDetailHighSodium => 'उच्च सोडियम';

  @override
  String get productDetailUltraProcessed => 'अति-प्रक्रिया केलेले';

  @override
  String get productDetailNutritionNote =>
      'उत्पादनाच्या वास्तविक पोषण (प्रति 100 ग्रॅम) वर आधारित.';

  @override
  String get productDetailKeyNutrients => 'मुख्य पोषक';

  @override
  String get productDetailRdaNote => '% संदर्भ दैनिक सेवन (प्रौढ).';

  @override
  String get productDetailForYou => 'तुमच्यासाठी';

  @override
  String get productDetailIngredientLockBody =>
      'प्रत्येक घटकाचे सुरक्षा निर्णयासह स्पष्टीकरण पाहा.';

  @override
  String get productDetailIngredientError =>
      'आत्ता हे घटक स्पष्ट करता आले नाहीत.';

  @override
  String get productDetailAllergenLockBody =>
      'या उत्पादनाची तुमच्या जतन केलेल्या अॅलर्जन्स आणि आरोग्य उद्दिष्टांशी तुलना करा.';

  @override
  String get productDetailAllergenError => 'आत्ता वैयक्तिकृत करता आले नाही.';

  @override
  String get productDetailNoAllergens =>
      'या उत्पादनात कोणतेही अॅलर्जन आढळले नाहीत.';

  @override
  String productDetailAllergenAvoid(String name) {
    return '$name — तुम्ही हे टाळता';
  }

  @override
  String productDetailUnlockWith(String plan) {
    return '$plan सोबत अनलॉक करा';
  }

  @override
  String get productDetailWouldYouBuy => 'तुम्ही हे उत्पादन खरेदी कराल का?';

  @override
  String get productDetailThanksForSharing => 'सामायिक केल्याबद्दल धन्यवाद!';

  @override
  String get productDetailNutritionNotIn => 'संपूर्ण पोषण अद्याप नाही';

  @override
  String get productDetailNutritionNotInBody =>
      'खरे पोषण आणि आरोग्य विश्लेषण RADHA मध्ये आणण्यासाठी या उत्पादनाचा बारकोड स्कॅन करा.';

  @override
  String productDetailShareText(String name) {
    return 'RADHA वर \"$name\" तपासले.';
  }

  @override
  String productDetailShareTextRated(String name, String rating, String label) {
    return 'RADHA वर \"$name\" तपासले — RADHA आरोग्य रेटिंग $rating/5 ($label).';
  }

  @override
  String get catalogSearchBarLabel => 'तुम्हाला योग्य उत्पादने शोधा';

  @override
  String get catalogSearchPromptTitle => 'उत्पादन शोधा';

  @override
  String get catalogSearchPromptBody =>
      'आरोग्य रेटिंग आणि आतमध्ये काय आहे ते पाहण्यासाठी उत्पादनाचे नाव किंवा ब्रँडने शोधा.';

  @override
  String get commonNo => 'नाही';

  @override
  String get scanApprovalNotInAudit => 'मंजुरी स्थिती — ऑडिटमध्ये नाही';

  @override
  String get scanApprovalChecking => 'मंजूर यादी तपासत आहे…';

  @override
  String get scanApprovalCheckFailed => 'मंजुरी तपासता आली नाही';

  @override
  String get scanApprovalApproved => 'मंजूर — यादीत';

  @override
  String get scanApprovalNoList => 'कोणतीही मंजूर यादी सक्रिय नाही';

  @override
  String get scanApprovalInvalidBarcode => 'अवैध बारकोड';

  @override
  String get scanApprovalNotInList => 'मंजूर यादीत नाही';

  @override
  String scanApprovalStatus(String label) {
    return 'मंजुरी स्थिती: $label';
  }

  @override
  String get scanResultAddToExpiry => 'एक्स्पायरीमध्ये जोडा';

  @override
  String get scanResultAddToStock => 'स्टॉकमध्ये जोडा';

  @override
  String get scanResultSaveToList => 'यादीत जतन करा';

  @override
  String get scanResultNoProduct => 'कोणतेही उत्पादन सापडले नाही';

  @override
  String get scanResultScanLabel => 'लेबल स्कॅन करा';

  @override
  String get auditRecordError =>
      'स्कॅन रेकॉर्ड करता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get auditEndError => 'ऑडिट संपवता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get auditNoStore => 'कोणतेही स्टोअर नियुक्त नाही';

  @override
  String get auditNoStoreBody =>
      'बल्क ऑडिट स्टोअरच्या मंजूर EAN यादीवर चालतात. अ‍ॅडमिनला तुम्हाला स्टोअर नियुक्त करण्यास सांगा, नंतर ऑडिटसाठी परत या.';

  @override
  String get auditMatched => 'जुळले';

  @override
  String get auditNotInList => 'यादीत नाही';

  @override
  String get auditNoList => 'यादी नाही';

  @override
  String get auditInvalid => 'अवैध';

  @override
  String get auditUnchecked => 'अनचेक्ड';

  @override
  String get commonTotal => 'एकूण';

  @override
  String get auditEnterScanEan => 'EAN प्रविष्ट करा किंवा स्कॅन करा';

  @override
  String auditStatus(String label) {
    return 'स्थिती: $label';
  }

  @override
  String get auditStartAuditing => 'ऑडिट सुरू करा';

  @override
  String get auditStartBody =>
      'या स्टोअरच्या मंजूर यादीशी तपासण्यासाठी वर EAN स्कॅन करा किंवा टाइप करा. प्रत्येक निकाल जुळले किंवा यादीत-नाही स्थितीसह येथे येतो.';

  @override
  String get auditTitle => 'बल्क EAN ऑडिट';

  @override
  String get auditEndAction => 'ऑडिट संपवा';

  @override
  String get auditEndingAction => 'संपत आहे…';

  @override
  String get auditEanInvalid =>
      'वैध EAN-8, EAN-13, किंवा UPC-A कोड प्रविष्ट करा';

  @override
  String auditEndedSummary(int matched, int notMatched) {
    return 'ऑडिट संपले — $matched जुळले, $notMatched यादीत नाही';
  }

  @override
  String get cameraCapture => 'कॅप्चर करा';

  @override
  String get labelScanReadError => 'लेबल वाचता आले नाही';

  @override
  String get labelScanReadErrorBody =>
      'चांगल्या प्रकाशात पुन्हा प्रयत्न करा, स्थिर ठेवा, आणि फ्रेम घटक पॅनेलने भरा.';

  @override
  String get labelScanAnalysisFailed => 'विश्लेषण अयशस्वी';

  @override
  String get labelScanIntro => 'RADHA तुमच्यासाठी लेबल वाचते';

  @override
  String get labelScanTakePhoto => 'फोटो घ्या';

  @override
  String get labelScanChooseGallery => 'गॅलरीमधून निवडा';

  @override
  String get labelScanAnother => 'दुसरे स्कॅन करा';

  @override
  String labelScanSeePlans(String plan) {
    return '$plan प्लॅन पाहा';
  }

  @override
  String get labelScanMaybeLater => 'कदाचित नंतर';

  @override
  String get labelScanTitle => 'लेबल स्कॅन करा';

  @override
  String get labelScanNoBarcode => 'बारकोड नाही? लेबल वाचा';

  @override
  String get labelScanIdleBody =>
      'घटक पॅनेलकडे निर्देश करा — आम्ही वाचून सांगू आत काय आहे. बारकोडशिवाय उत्पादनांसाठीही काम करते.';

  @override
  String get labelScanFlashNote => 'कमी प्रकाशात कॅमेरा फ्लॅश आपोआप चालू होते.';

  @override
  String get labelScanReading => 'लेबल वाचत आहोत…';

  @override
  String get labelScanAnalyzing => 'घटकांचे विश्लेषण करत आहोत…';

  @override
  String get labelScanFallbackError =>
      'काहीतरी चुकले. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get labelScanResultFallback => 'लेबल विश्लेषण';

  @override
  String get labelScanLowConfidence =>
      'कमी विश्वासार्हता — स्पष्ट फोटो चांगला परिणाम देऊ शकतो.';

  @override
  String get labelScanWhatToWatch => 'लक्ष द्यावयाचे';

  @override
  String get labelScanIngredients => 'घटक';

  @override
  String get labelScanDisclaimer =>
      'RADHA AI ने लेबल मजकुरातून वाचले. अचूक माहितीसाठी पॅक तपासा.';

  @override
  String get labelScanUnlockTitle => 'AI लेबल रीडिंग अनलॉक करा';

  @override
  String get labelScanUnlockBody =>
      'आम्ही लेबल वाचले, पण संपूर्ण विश्लेषण प्रीमियम वैशिष्ट्य आहे.';

  @override
  String scanResultNotFoundBody(String ean) {
    return 'EAN $ean साठी कॅटलॉगमध्ये जुळणी नाही — पण तुम्ही तरीही लेबल वाचू शकता. घटक पॅनेलचा फोटो घ्या, आत काय आहे ते सांगू.';
  }

  @override
  String productScore(String score) {
    return 'स्कोअर: $score';
  }

  @override
  String get catalogSearchHint => 'उत्पादने किंवा ब्रँड शोधा';

  @override
  String get catalogNoMatches => 'जुळणी नाही';

  @override
  String catalogNoMatchesBody(String query) {
    return '“$query” साठी आम्हाला उत्पादने सापडली नाहीत. वेगळे नाव वापरून पहा, किंवा त्याऐवजी आयटम स्कॅन करा.';
  }

  @override
  String get browseTitle => 'उत्पादने';

  @override
  String get browseLoadError => 'उत्पादने लोड करता आली नाहीत';

  @override
  String browseLoadErrorBody(String category) {
    return '$category लोड करताना अडचण आली. कृपया पुन्हा प्रयत्न करा.';
  }

  @override
  String get browseSortHealthiest => 'सर्वात आरोग्यदायी';

  @override
  String get browseSortAZ => 'A–Z';

  @override
  String get browseFilterVegOnly => 'फक्त शाकाहारी';

  @override
  String get browseVeg => 'व्हेज';

  @override
  String get browseEmptyVeg => 'इथे अद्याप कोणतेही शाकाहारी आयटम नाही';

  @override
  String browseEmptyVegBody(String category) {
    return 'सध्या $category मध्ये काहीही शाकाहारी फिल्टरशी जुळत नाही.';
  }

  @override
  String get browseShowAll => 'सर्व दाखवा';

  @override
  String get browseEmpty => 'अद्याप कोणतीही उत्पादने नाहीत';

  @override
  String browseEmptyBody(String category) {
    return 'आम्ही $category विभाग भरत आहोत. तोपर्यंत, कोणताही आयटम स्कॅन करून त्याचे आरोग्य आणि एक्स्पायरी तपासा.';
  }

  @override
  String referralsShareText(String code) {
    return 'RADHA वर माझ्यासोबत सामील व्हा: $code कोड वापरा';
  }

  @override
  String get selectStoreEmpty => 'अद्याप कोणतेही स्टोअर नाही';

  @override
  String get selectStoreEmptyBody =>
      'एखाद्या स्टोअरमध्ये जोडले जाण्यासाठी तुमच्या व्यवस्थापकाशी संपर्क साधा.';

  @override
  String get selectStoreEmptyDetail =>
      'तुमचे खाते अद्याप कोणत्याही स्टोअरशी संबंधित नाही. प्रवेशासाठी तुमच्या व्यवस्थापकाला सांगा, नंतर परत येऊन एक निवडा.';

  @override
  String get selectStoreContactManager => 'तुमच्या व्यवस्थापकाशी संपर्क साधा';

  @override
  String get expiryConsumerTitle => 'व्यवसाय खात्यांसाठी';

  @override
  String get expiryConsumerBody =>
      'मुदत संपण्याचे ट्रॅकिंग हे किरकोळ दुकानाचे वैशिष्ट्य आहे. हे वापरण्यासाठी तुमचे खाते दुकानाशी जोडा.';

  @override
  String get tasksConsumerTitle => 'व्यवसाय खात्यांसाठी';

  @override
  String get tasksConsumerBody =>
      'कार्य व्यवस्थापन हे किरकोळ दुकानाचे वैशिष्ट्य आहे. हे वापरण्यासाठी तुमचे खाते दुकानाशी जोडा.';

  @override
  String get languageSavedLocally => 'भाषा फक्त स्थानिकरित्या जतन केली';

  @override
  String languageSavedLocallyError(String error) {
    return 'भाषा फक्त स्थानिकरित्या जतन केली: $error';
  }

  @override
  String get signOutConfirmBody =>
      'अ‍ॅप वापरण्यासाठी तुम्हाला OTP सह पुन्हा साइन इन करावे लागेल.';

  @override
  String get scanResultTitle => 'स्कॅन निकाल';

  @override
  String scanResultShareMessage(String ean) {
    return 'मी हे उत्पादन RADHA वर तपासले — बारकोड $ean.';
  }

  @override
  String get scanResultHealthHeading => 'आरोग्य';

  @override
  String get scanResultAssessmentPending => 'मूल्यांकन प्रलंबित';

  @override
  String get scanResultNutritionPending =>
      'हे उत्पादन कॅटलॉगमध्ये जुळताच पोषण संकेत येथे दिसतील. डेटाबेस समृद्ध करण्यासाठी आणखी वस्तू स्कॅन करा.';

  @override
  String get scanResultExplainIngredients => 'घटक समजावून सांगा';

  @override
  String get scanResultAllergenPrompt =>
      'तुम्ही टाळता ती एखादी गोष्ट स्कॅन केलेल्या उत्पादनात असल्यास त्वरित इशारा मिळण्यासाठी तुमची अ‍ॅलर्जन प्रोफाइल सेट करा.';

  @override
  String scanResultAllergensDeclared(String allergens) {
    return 'Contains: $allergens';
  }

  @override
  String get scanResultNoAllergensDeclared =>
      'No allergens declared on this product\'s label.';

  @override
  String get taskEvidenceRequiredSnack =>
      'हे कार्य पूर्ण करण्यासाठी पुरावा आवश्यक आहे';

  @override
  String taskMovedTo(String status) {
    return 'कार्य $status मध्ये हलवले';
  }

  @override
  String get taskUpdateError =>
      'कार्य अद्यतनित करता आले नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String taskAssignedTo(String name) {
    return '$name यांना नियुक्त केले';
  }

  @override
  String taskDueOn(String date) {
    return 'मुदत $date';
  }

  @override
  String get taskPriorityLabel => 'प्राधान्य';

  @override
  String get taskEvidenceLabel => 'पुरावा';

  @override
  String get taskEvidencePhotoRequired => 'फोटो आवश्यक';

  @override
  String get taskEvidenceNotRequired => 'आवश्यक नाही';

  @override
  String taskEvidencePhotosAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो जोडले',
      one: '1 फोटो जोडला',
    );
    return '$_temp0';
  }

  @override
  String get taskEvidencePhotoNeeded =>
      'हे कार्य पूर्ण करण्यासाठी एक फोटो आवश्यक आहे';

  @override
  String get taskTimelineCreated => 'तयार केले';

  @override
  String get taskTimelineStarted => 'सुरू झाले';

  @override
  String get taskActionComplete => 'पूर्ण करा';

  @override
  String get taskLoadFailed => 'कार्य लोड करता आले नाही';

  @override
  String get taskDescriptionLabel => 'तपशील';

  @override
  String get taskTypeLabel => 'प्रकार';

  @override
  String get taskActionStart => 'सुरू करा';

  @override
  String get taskCreateTitle => 'कार्य तयार करा';

  @override
  String get taskCreateCta => 'कार्य तयार करा';

  @override
  String get taskCreatedSnack => 'कार्य तयार केले';

  @override
  String get taskCreateError =>
      'कार्य तयार करता आले नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get taskNotAuthorizedTitle => 'अधिकृत नाही';

  @override
  String get taskNotAuthorizedBody =>
      'फक्त व्यवस्थापक आणि अ‍ॅडमिन कार्ये तयार करू शकतात.';

  @override
  String get taskTitleLabel => 'शीर्षक';

  @override
  String get taskTitleHint => 'उदा. डेअरी विभागाचे EAN ऑडिट';

  @override
  String get taskTitleRequired => 'शीर्षक आवश्यक आहे';

  @override
  String get taskDescriptionHint => 'नियुक्त व्यक्तीसाठी पर्यायी तपशील';

  @override
  String get taskStoreLabel => 'स्टोअर';

  @override
  String get taskAssigneeLabel => 'नियुक्त व्यक्ती (यूजर ID)';

  @override
  String get taskAssigneeHint => 'यूजर ID टाका किंवा रिकामे ठेवा';

  @override
  String get taskDueDateLabel => 'मुदत तारीख';

  @override
  String get taskSelectDate => 'तारीख निवडा';

  @override
  String get taskRequiresEvidence => 'पुरावा आवश्यक';

  @override
  String get taskRequiresEvidenceSubtitle =>
      'पूर्ण करण्यासाठी नियुक्त व्यक्तीने फोटो अपलोड करावा';

  @override
  String get taskTypeEanAudit => 'EAN ऑडिट';

  @override
  String get taskTypeExpiryCheck => 'एक्स्पायरी तपासणी';

  @override
  String get taskTypeInventoryCount => 'इन्व्हेंटरी मोजणी';

  @override
  String get taskTypeDisplayVerification => 'डिस्प्ले पडताळणी';

  @override
  String get taskTypeCustom => 'कस्टम';

  @override
  String get checkoutStartError =>
      'चेकआउट सुरू करता आले नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get paymentResponseIncomplete => 'पेमेंट प्रतिसाद अपूर्ण होता.';

  @override
  String get paymentSuccessUpdated => 'पेमेंट यशस्वी. प्लॅन अद्यतनित झाला.';

  @override
  String get paymentNotVerified => 'पेमेंट सत्यापित करता आले नाही.';

  @override
  String get paymentVerifyFailed =>
      'पेमेंट सत्यापन अयशस्वी. कृपया सहाय्याशी संपर्क साधा.';

  @override
  String get paymentCancelled => 'पेमेंट रद्द केले.';

  @override
  String paymentFailed(String message) {
    return 'पेमेंट अयशस्वी: $message';
  }

  @override
  String paymentOpeningWallet(String wallet) {
    return '$wallet उघडत आहे…';
  }

  @override
  String get paymentSheetOpenError => 'पेमेंट शीट उघडता आली नाही.';

  @override
  String get subscriptionLoadError => 'तुमची सदस्यता लोड करता आली नाही';

  @override
  String get subscriptionLoadErrorBody =>
      'तुमचे कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'तुम्ही $plan वर आहात';
  }

  @override
  String subscriptionUpgradeTo(String plan) {
    return '$plan मध्ये अपग्रेड करा';
  }

  @override
  String subscriptionChoosePlan(String plan) {
    return '$plan निवडा';
  }

  @override
  String get subscriptionPopular => 'लोकप्रिय';

  @override
  String get subscriptionPerMonth => '/महिना';

  @override
  String get subscriptionTitle => 'सदस्यता';

  @override
  String get subscriptionHeadline => 'RADHA ची संपूर्ण ताकद अनलॉक करा';

  @override
  String get subscriptionChooseAPlan => 'एक प्लान निवडा';

  @override
  String get subscriptionCancelAnytime => 'कधीही रद्द करा · GST समाविष्ट';

  @override
  String get subscriptionBillingYearly => 'वार्षिक';

  @override
  String get subscriptionBillingMonthly => 'मासिक';

  @override
  String get versionLoading => 'आवृत्ती लोड होत आहे…';

  @override
  String get versionUnavailable => 'आवृत्ती उपलब्ध नाही';

  @override
  String appVersionBuild(String version, String build) {
    return 'आवृत्ती $version ($build)';
  }

  @override
  String get shoppingListTitle => 'खरेदी यादी';

  @override
  String get shoppingAddItem => 'आयटम जोडा';

  @override
  String get shoppingLoadError => 'तुमची यादी लोड करता आली नाही';

  @override
  String get shoppingLoadErrorBody =>
      'तुमची खरेदी यादी लोड करता आली नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get shoppingEmptyTitle => 'तुमची खरेदी यादी रिकामी आहे';

  @override
  String get shoppingEmptyBody =>
      'आयटम जोडण्यासाठी प्लस बटण दाबा, किंवा उत्पादन पृष्ठावरून आरोग्यदायी पर्याय जतन करा.';

  @override
  String get shoppingUpdateError =>
      'आयटम अद्यतनित करता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get shoppingDeleteError =>
      'आयटम हटवता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get shoppingAddError =>
      'आयटम जोडता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get shoppingAllDone => 'सर्व झाले — सर्वकाही टिक केले';

  @override
  String shoppingRemaining(int remaining, int total) {
    return '$total पैकी $remaining खरेदी करायचे आहे';
  }

  @override
  String shoppingQty(int quantity) {
    return 'प्रमाण: $quantity';
  }

  @override
  String get shoppingDeleteItem => 'आयटम हटवा';

  @override
  String get shoppingItemNameLabel => 'आयटमचे नाव';

  @override
  String get shoppingItemNameHint => 'उदा. होल व्हीट ब्रेड';

  @override
  String get shoppingItemNameRequired => 'आयटमचे नाव टाका';

  @override
  String get shoppingItemNameTooLong => 'ते 120 अक्षरांच्या आत ठेवा';

  @override
  String get shoppingQuantityLabel => 'प्रमाण (पर्यायी)';

  @override
  String get shoppingQuantityInvalid => 'धन संख्या टाका';

  @override
  String get shoppingQuantityTooHigh => 'हे असामान्यपणे जास्त वाटते';

  @override
  String get shoppingAddToList => 'यादीत जोडा';

  @override
  String get grnTitle => 'प्राप्त माल';

  @override
  String get grnFilterAll => 'सर्व';

  @override
  String get grnFilterDraft => 'मसुदा';

  @override
  String get grnFilterPendingReview => 'पुनरावलोकन प्रलंबित';

  @override
  String get grnFilterPosted => 'पोस्ट केले';

  @override
  String get grnStatusPending => 'प्रलंबित';

  @override
  String get grnEmptyTitle => 'येथे कोणतेही GRN नाहीत';

  @override
  String get grnEmptyBody =>
      'पुरवठादार वितरण नोंदवण्यासाठी गुड्स-रिसीव्ड नोट तयार करा.';

  @override
  String get grnNew => 'नवीन GRN';

  @override
  String get grnLoadError => 'GRN लोड करता आले नाहीत';

  @override
  String get grnSupplierFallback => 'पुरवठादार';

  @override
  String get categoryBiscuits => 'बिस्किटे आणि स्नॅक्स';

  @override
  String get categoryBreakfast => 'न्याहारी आणि स्प्रेड';

  @override
  String get categoryDairy => 'दुग्धजन्य आणि अंडी';

  @override
  String get categoryBeverages => 'पेये';

  @override
  String get categoryStaples => 'मुख्य धान्य';

  @override
  String get categoryPersonalCare => 'वैयक्तिक काळजी';

  @override
  String get categoryHousehold => 'घरगुती';

  @override
  String get categoryFrozen => 'गोठवलेले';

  @override
  String get lowStockTitle => 'कमी स्टॉक सूचना';

  @override
  String get lowStockLoadError => 'सूचना लोड करता आल्या नाहीत';

  @override
  String get lowStockEmpty => 'सर्व स्टॉक पातळी निरोगी आहेत';

  @override
  String lowStockCurrentThreshold(int quantity, int threshold) {
    return 'सध्या: $quantity / मर्यादा: $threshold';
  }

  @override
  String get lowStockRestock => 'पुन्हा स्टॉक करा';

  @override
  String get commonRequired => 'आवश्यक';

  @override
  String get commonOptional => 'पर्यायी';

  @override
  String get commonQuantity => 'प्रमाण';

  @override
  String get smTitle => 'स्टॉक हालचाल';

  @override
  String get smStockIn => 'स्टॉक इन';

  @override
  String get smStockOut => 'स्टॉक आउट';

  @override
  String get smProductLabel => 'उत्पादन';

  @override
  String get smProductHint => 'उत्पादन ID किंवा EAN टाका';

  @override
  String get smReasonLabel => 'कारण';

  @override
  String get smSelectReason => 'कारण निवडा';

  @override
  String get smBatchLabel => 'बॅच नंबर';

  @override
  String get smExpiryLabel => 'एक्स्पायरी तारीख';

  @override
  String get smExpiryOptionalHint => 'पर्यायी — निवडण्यासाठी टॅप करा';

  @override
  String get smNotesLabel => 'नोट्स';

  @override
  String get smNotesHint => 'पर्यायी नोट्स';

  @override
  String get smRecordIn => 'स्टॉक इन नोंदवा';

  @override
  String get smRecordOut => 'स्टॉक आउट नोंदवा';

  @override
  String get smStockInRecorded => 'स्टॉक-इन नोंदवले';

  @override
  String get smStockOutRecorded => 'स्टॉक-आउट नोंदवले';

  @override
  String get smRecordError =>
      'स्टॉक हालचाल नोंदवता आली नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get smInsufficientStock => 'या हालचालीसाठी अपुरा स्टॉक';

  @override
  String get smReasonPurchase => 'खरेदी';

  @override
  String get smReasonReturn => 'परतावा';

  @override
  String get smReasonAdjustment => 'समायोजन';

  @override
  String get smReasonTransfer => 'हस्तांतरण';

  @override
  String get smReasonDamage => 'नुकसान';

  @override
  String get smReasonExpiryRemoval => 'एक्स्पायरी काढणे';

  @override
  String get smReasonOther => 'इतर';

  @override
  String get grnInvoiceDateRequired => 'इनव्हॉइस तारीख आवश्यक आहे';

  @override
  String get grnCreateError =>
      'GRN तयार करता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get grnSupplierInvoiceSection => 'पुरवठादार आणि इनव्हॉइस';

  @override
  String get grnSupplierNameLabel => 'पुरवठादाराचे नाव';

  @override
  String get grnSupplierNameHint => 'पुरवठादाराचे नाव टाका';

  @override
  String get grnSupplierRequired => 'पुरवठादार आवश्यक आहे';

  @override
  String get grnInvoiceNumberLabel => 'इनव्हॉइस क्रमांक';

  @override
  String get grnInvoiceNumberHint => 'इनव्हॉइस क्रमांक टाका';

  @override
  String get grnInvoiceNumberRequired => 'इनव्हॉइस क्रमांक आवश्यक आहे';

  @override
  String get grnInvoiceDateLabel => 'इनव्हॉइस तारीख *';

  @override
  String get grnExpectedDeliveryLabel => 'अपेक्षित वितरण तारीख';

  @override
  String get grnCreateDraft => 'मसुदा GRN तयार करा';

  @override
  String get grnSelectDate => 'तारीख निवडा';

  @override
  String get expiryCalendarTitle => 'एक्स्पायरी कॅलेंडर';

  @override
  String get expiryCalendarLoadError => 'कॅलेंडर डेटा लोड करता आला नाही.';

  @override
  String get expiryCalendarTapHint => 'तपशील पाहण्यासाठी एखाद्या दिवशी टॅप करा';

  @override
  String get expiryCalendarNoRecords =>
      'या दिवसासाठी कोणतेही एक्स्पायरी रेकॉर्ड नाहीत';

  @override
  String expiryCalendarSummaryFor(String date) {
    return '$date चा सारांश';
  }

  @override
  String get exTitle => 'नवीन एक्स्पायरी रेकॉर्ड';

  @override
  String get exMfgAfterExpiry =>
      'उत्पादन तारीख एक्स्पायरी तारखेनंतर असू शकत नाही';

  @override
  String get exSelectMfg => 'उत्पादन तारीख निवडा';

  @override
  String get exSelectExpiry => 'एक्स्पायरी तारीख निवडा';

  @override
  String get exExpiryRequired => 'एक्स्पायरी तारीख आवश्यक आहे';

  @override
  String get exCreated => 'एक्स्पायरी रेकॉर्ड तयार केले';

  @override
  String get exOfflineQueued =>
      'तुम्ही ऑफलाइन आहात — ऑनलाइन आल्यावर रेकॉर्ड सिंक होईल';

  @override
  String get exSubmitError => 'काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get exNotSet => 'सेट केले नाही';

  @override
  String get exProductIdLabel => 'उत्पादन ID';

  @override
  String get exProductIdHint => 'उत्पादन ID टाका किंवा बारकोड स्कॅन करा';

  @override
  String get exMfgLabel => 'उत्पादन तारीख';

  @override
  String get exExpiryLabel => 'एक्स्पायरी तारीख *';

  @override
  String get exBatchLabel => 'बॅच नंबर';

  @override
  String get exLocationLabel => 'स्थान';

  @override
  String get exLocationHint => 'शेल्फ / गल्ली / झोन';

  @override
  String get exSaveRecord => 'रेकॉर्ड जतन करा';

  @override
  String get exOcrSemantic => 'RADHA तुमच्यासाठी तारीख वाचते';

  @override
  String get exOcrTitle => 'पॅकवरून तारीख स्कॅन करा';

  @override
  String get exOcrSubtitle => 'आम्ही तुमच्यासाठी MFG / EXP वाचू';

  @override
  String get grnItemsTitle => 'GRN आयटम';

  @override
  String get grnItemAdded => 'आयटम जोडले';

  @override
  String get grnItemSavedOffline =>
      'ऑफलाइन जतन केले — ऑनलाइन आल्यावर सिंक होईल';

  @override
  String get grnItemAddError =>
      'आयटम जोडता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get grnAddItemFirst => 'पोस्ट करण्यापूर्वी किमान एक आयटम जोडा';

  @override
  String get grnPosted => 'GRN पोस्ट केले — स्टॉक अद्यतनित झाला';

  @override
  String get grnPostQueued => 'रांगेत — ऑनलाइन आल्यावर पोस्ट होईल';

  @override
  String get grnPostError =>
      'GRN पोस्ट करता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get grnNoItems => 'अद्याप कोणतेही आयटम जोडलेले नाहीत';

  @override
  String get grnNoItemsHint => 'आयटम जोडण्यासाठी खालील बटणावर टॅप करा';

  @override
  String grnTotalQty(String qty) {
    return 'एकूण प्रमाण: $qty';
  }

  @override
  String grnTotalValue(String value) {
    return 'एकूण: ₹$value';
  }

  @override
  String get grnAddItem => 'आयटम जोडा';

  @override
  String get grnPostGrn => 'GRN पोस्ट करा';

  @override
  String get grnPostHint =>
      'पोस्ट केल्याने स्टॉक अद्यतनित होतो आणि कमी-स्टॉक सूचना सोडवल्या जातात.';

  @override
  String grnInvoiceLabel(String number) {
    return 'इनव्हॉइस $number';
  }

  @override
  String grnBatchTag(String batch) {
    return 'बॅच $batch';
  }

  @override
  String get grnBarcodeLabel => 'बारकोड (EAN / UPC)';

  @override
  String get grnBarcodeHint => '8–13 अंक';

  @override
  String get grnProductNameLabel => 'उत्पादनाचे नाव';

  @override
  String get grnMustBePositive => '0 पेक्षा जास्त असावे';

  @override
  String get grnBatchNumberOptional => 'बॅच नंबर (पर्यायी)';

  @override
  String get grnMfgDateLabel => 'उत्पादन तारीख';

  @override
  String get grnExpiryDateLabel => 'एक्स्पायरी तारीख';

  @override
  String get grnUnitPriceLabel => 'एकक किंमत (₹)';

  @override
  String get grnMustBeNonNeg => '0 किंवा अधिक असावे';
}
