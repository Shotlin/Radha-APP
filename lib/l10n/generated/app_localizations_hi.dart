// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'RADHA';

  @override
  String get tagline => 'डेटा, स्वास्थ्य और ऑडिट के लिए रिटेल असिस्टेंट।';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'आगे';

  @override
  String get back => 'पीछे';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get edit => 'संपादित करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get search => 'खोजें';

  @override
  String get loading => 'लोड हो रहा है';

  @override
  String get error => 'कुछ गड़बड़ हो गई';

  @override
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String get done => 'पूरा हुआ';

  @override
  String get close => 'बंद करें';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get enterOtp => 'OTP दर्ज करें';

  @override
  String get verifyOtp => 'OTP सत्यापित करें';

  @override
  String get resendOtp => 'OTP फिर से भेजें';

  @override
  String get otpSent => 'हमने आपको 6 अंकों का कोड भेजा है';

  @override
  String get home => 'होम';

  @override
  String get scan => 'स्कैन';

  @override
  String get expiry => 'एक्सपायरी';

  @override
  String get tasks => 'कार्य';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get scanProduct => 'उत्पाद स्कैन करें';

  @override
  String get pointAtBarcode => 'कैमरा बारकोड पर रखें';

  @override
  String get scanAgain => 'फिर से स्कैन करें';

  @override
  String get productNotFound => 'उत्पाद नहीं मिला';

  @override
  String get expiryTracker => 'एक्सपायरी ट्रैकर';

  @override
  String get addExpiry => 'एक्सपायरी जोड़ें';

  @override
  String get expiringSoon => 'जल्द एक्सपायर होगा';

  @override
  String get expired => 'एक्सपायर हो चुका';

  @override
  String get yourTasks => 'आपके कार्य';

  @override
  String get noTasks => 'कोई कार्य नहीं';

  @override
  String get completeTask => 'कार्य पूरा करें';

  @override
  String get welcome => 'स्वागत है';

  @override
  String get welcomeMessage =>
      'स्प्रेडशीट के बिना अपना स्टॉक स्कैन, ट्रैक और ऑडिट करें।';

  @override
  String get referrals => 'रेफरल';

  @override
  String get shareYourCode => 'अपना कोड साझा करें';

  @override
  String get yourReferralCode => 'आपका रेफरल कोड';

  @override
  String get invitees => 'आमंत्रित';

  @override
  String get rewardsEarned => 'अर्जित पुरस्कार';

  @override
  String get redeemCode => 'कोड भुनाएँ';

  @override
  String get enterReferralCode => 'रेफरल कोड दर्ज करें';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get languageUpdated => 'भाषा अपडेट की गई';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हो गई। कृपया पुनः प्रयास करें।';

  @override
  String errorRateLimitOtp(int seconds) {
    return 'बहुत अधिक OTP अनुरोध। $seconds सेकंड में पुनः प्रयास करें।';
  }

  @override
  String get errorOtpInvalid => 'OTP गलत है। कृपया पुनः प्रयास करें।';

  @override
  String get errorOtpExpired =>
      'OTP की समय-सीमा समाप्त हो गई। कृपया नया OTP भेजें।';

  @override
  String get errorAuthRequired => 'जारी रखने के लिए साइन इन करें।';

  @override
  String get errorNotFound => 'नहीं मिला।';

  @override
  String get ingredientExplainerErrorTitle => 'व्याख्या लोड नहीं हो सकी';

  @override
  String get ingredientExplainerHealthConsiderations => 'स्वास्थ्य विचार';

  @override
  String healthyAlternativesTitle(String productName) {
    return '$productName से बेहतर विकल्प';
  }

  @override
  String get healthyAlternativesGenericTitle => 'बेहतर विकल्प';

  @override
  String get healthyAlternativesEmptyTitle => 'अभी कोई स्वस्थ विकल्प नहीं';

  @override
  String get healthyAlternativesEmptyBody =>
      'इसी श्रेणी में अभी तक कोई स्वस्थ विकल्प नहीं मिला।';

  @override
  String get healthyAlternativesErrorTitle => 'विकल्प लोड नहीं हो सके';

  @override
  String get healthyAlternativesAddToList => 'खरीदारी सूची में जोड़ें';

  @override
  String get healthyAlternativesView => 'देखें';

  @override
  String get healthyAlternativesAddedToList => 'खरीदारी सूची में जोड़ा गया';

  @override
  String get healthyAlternativesAddFailed =>
      'खरीदारी सूची में नहीं जोड़ा जा सका';

  @override
  String get savedProductsTitle => 'सहेजे गए उत्पाद';

  @override
  String get savedProductsEmptyTitle => 'सहेजे गए उत्पाद';

  @override
  String get savedProductsEmptyBody =>
      'स्कैन परिणाम स्क्रीन से उत्पाद सहेजें ताकि वे यहाँ दिखें।';

  @override
  String get savedProductsErrorTitle => 'सहेजे गए उत्पाद लोड नहीं हो सके';

  @override
  String savedProductsSavedOn(String date) {
    return '$date को सहेजा गया';
  }

  @override
  String get digestTitle => 'RADHA के साथ आपका सप्ताह';

  @override
  String digestWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String digestSavingsHero(String amount) {
    return '₹$amount की बचत';
  }

  @override
  String digestScansHero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count स्कैन',
      one: '1 स्कैन',
    );
    return '$_temp0';
  }

  @override
  String get digestHeroEmptyHeadline => 'शांत सप्ताह';

  @override
  String get digestScans => 'स्कैन';

  @override
  String get digestSavedProducts => 'सहेजे गए';

  @override
  String get digestExpiringSoon => 'जल्द एक्सपायर';

  @override
  String digestRecallAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉल अलर्ट',
      one: '1 रिकॉल अलर्ट',
    );
    return '$_temp0';
  }

  @override
  String get digestRecallAlertsBody =>
      'इस सप्ताह स्कैन किए गए उत्पादों पर नई सुरक्षा सूचनाएँ हैं।';

  @override
  String get digestRecallAlertsCta => 'देखें';

  @override
  String get digestTopCategoriesHeader => 'आप क्या स्कैन कर रहे हैं';

  @override
  String get digestHighlightsHeader => 'मुख्य बातें';

  @override
  String get digestContinueScanning => 'स्कैन करते रहें';

  @override
  String get digestShare => 'मेरा सप्ताह साझा करें';

  @override
  String digestShareTemplate(int scans, String savings) {
    return 'मैंने इस सप्ताह $scans उत्पाद स्कैन किए और RADHA से ₹$savings बचाए। आप भी आज़माएँ: https://radha.app';
  }

  @override
  String get digestEmptyTitle => 'इस सप्ताह कोई गतिविधि नहीं';

  @override
  String get digestEmptyBody =>
      'अपनी साप्ताहिक कहानी शुरू करने के लिए स्कैन करें।';

  @override
  String get digestErrorTitle => 'साप्ताहिक डाइजेस्ट लोड नहीं हो सका';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsNotifications => 'सूचनाएँ';

  @override
  String get settingsPushNotifications => 'पुश सूचनाएँ';

  @override
  String get settingsPushNotificationsHint => 'अपने फोन पर अलर्ट पाएँ';

  @override
  String get settingsRecallAlerts => 'रिकॉल अलर्ट';

  @override
  String get settingsRecallAlertsHint =>
      'जब स्कैन किया गया उत्पाद रिकॉल हो तो जानें';

  @override
  String get settingsWeeklyDigest => 'साप्ताहिक डाइजेस्ट';

  @override
  String get settingsWeeklyDigestHint =>
      'रविवार को आपके स्कैन और बचत का सारांश';

  @override
  String get settingsAppearance => 'रूप';

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
  String get settingsTextSizeSmall => 'छोटा';

  @override
  String get settingsTextSizeStandard => 'मानक';

  @override
  String get settingsTextSizeLarge => 'बड़ा';

  @override
  String get settingsDataPrivacy => 'डेटा और गोपनीयता';

  @override
  String get settingsAllergens => 'एलर्जी प्रोफ़ाइल';

  @override
  String get settingsAllergensHint =>
      'जिन सामग्रियों से सावधान करना है उन्हें चुनें';

  @override
  String get settingsSignOutAll => 'सभी डिवाइस से साइन आउट';

  @override
  String get settingsSignOutAllConfirmTitle => 'हर जगह से साइन आउट?';

  @override
  String get settingsSignOutAllConfirmBody =>
      'इस अकाउंट का उपयोग करने वाले हर डिवाइस पर आपको फिर से साइन इन करना होगा।';

  @override
  String get settingsDeleteAccount => 'अकाउंट हटाएँ';

  @override
  String get settingsDeleteAccountTitle => 'अकाउंट हटाएँ';

  @override
  String get settingsDeleteAccountBody =>
      'यह आपके डेटा को स्थायी रूप से हटा देगा। पुष्टि करने के लिए DELETE टाइप करें।';

  @override
  String get settingsDeleteAccountConfirm => 'DELETE';

  @override
  String get settingsDeleteAccountUnavailable =>
      'अकाउंट हटाने के लिए सहायता से संपर्क करें।';

  @override
  String get settingsDeleteAccountContact => 'सहायता से संपर्क करें';

  @override
  String get settingsAbout => 'के बारे में';

  @override
  String get settingsTerms => 'सेवा की शर्तें';

  @override
  String get settingsPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get settingsVersion => 'ऐप संस्करण';

  @override
  String settingsVersionValue(String version, String build) {
    return 'संस्करण $version ($build)';
  }

  @override
  String get settingsSupport => 'सहायता';

  @override
  String get settingsSupportHint =>
      'मदद पाएँ, बग रिपोर्ट करें, या प्रतिक्रिया साझा करें';

  @override
  String get settingsLinkOpenFailed => 'लिंक नहीं खोला जा सका';

  @override
  String conflictBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count विरोधों पर ध्यान देना है',
      one: '1 विरोध पर ध्यान देना है',
    );
    return '$_temp0';
  }

  @override
  String get conflictBannerCta => 'हल करें';

  @override
  String get conflictBannerDismiss => 'बंद करें';

  @override
  String get conflictResolveTitle => 'सिंक विरोध हल करें';

  @override
  String get conflictResolveSubtitle =>
      'हर आइटम के लिए कौन सा संस्करण रखना है चुनें।';

  @override
  String get conflictUseMine => 'मेरा संस्करण रखें';

  @override
  String get conflictUseServer => 'सर्वर का संस्करण रखें';

  @override
  String get conflictResolved => 'विरोध हल हुआ';

  @override
  String get conflictResolvedAll => 'सभी विरोध हल हो गए';

  @override
  String conflictAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार कोशिश की',
      one: '1 बार कोशिश की',
    );
    return '$_temp0';
  }

  @override
  String get conflictResourceTask => 'कार्य';

  @override
  String get conflictResourceExpiry => 'एक्सपायरी रिकॉर्ड';

  @override
  String get conflictResourceScan => 'स्कैन';

  @override
  String get conflictResourceInventory => 'स्टॉक समायोजन';

  @override
  String get conflictResourceGrn => 'GRN प्रविष्टि';

  @override
  String get conflictResourceShoppingList => 'खरीदारी सूची आइटम';

  @override
  String get conflictResourceGeneric => 'सिंक परिवर्तन';

  @override
  String conflictLocalChangeSummary(String summary) {
    return 'आपका बदलाव: $summary';
  }

  @override
  String get supportTitle => 'सहायता';

  @override
  String get supportContactUs => 'हमसे संपर्क करें';

  @override
  String get supportEmailUs => 'ईमेल भेजें';

  @override
  String get supportEmailUsHint => 'support@radha.app';

  @override
  String get supportCallUs => 'कॉल करें';

  @override
  String get supportCallUsHint => 'सोम–शुक्र, सुबह 9 से शाम 6, IST';

  @override
  String get supportReportBug => 'बग रिपोर्ट करें';

  @override
  String get supportBugDescription => 'क्या हुआ?';

  @override
  String get supportBugDescriptionHint =>
      'बताएँ कि जब समस्या हुई तब आप क्या कर रहे थे।';

  @override
  String get supportAttachScreenshot => 'स्क्रीनशॉट जोड़ें';

  @override
  String get supportScreenshotAttached => 'स्क्रीनशॉट जोड़ा गया';

  @override
  String get supportRemoveScreenshot => 'हटाएँ';

  @override
  String get supportSubmit => 'रिपोर्ट भेजें';

  @override
  String get supportSubmitted => 'धन्यवाद — हमें आपकी रिपोर्ट मिल गई।';

  @override
  String get supportSubmitFailed => 'भेजा नहीं जा सका। कृपया हमें ईमेल करें।';

  @override
  String get supportBugDescriptionRequired => 'कृपया बताएँ कि क्या हुआ।';

  @override
  String get supportFaq => 'अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get supportFaqQ1 => 'मैं बारकोड कैसे स्कैन करूँ?';

  @override
  String get supportFaqA1 =>
      'स्कैन टैब खोलें, कैमरा बारकोड पर रखें और स्थिर रखें। साफ कोड पढ़ते ही उत्पाद दिखेगा।';

  @override
  String get supportFaqQ2 => 'अगर उत्पाद डेटाबेस में नहीं है तो?';

  @override
  String get supportFaqA2 =>
      'नहीं-मिला स्क्रीन पर \"उत्पाद जोड़ें\" टैप करें। यह आपके स्टोर से जुड़ी नई एंट्री बनाएगा।';

  @override
  String get supportFaqQ3 => 'मैं अपनी सदस्यता कैसे रद्द करूँ?';

  @override
  String get supportFaqA3 =>
      'प्रोफ़ाइल → सदस्यता पर जाएँ। आप कभी भी रद्द कर सकते हैं; अगले बिलिंग चक्र के बाद कोई शुल्क नहीं लगेगा।';

  @override
  String get supportFaqQ4 => 'मुझे रिकॉल अलर्ट क्यों दिख रहा है?';

  @override
  String get supportFaqA4 =>
      'हम हर स्कैन की FSSAI रिकॉल फीड से तुलना करते हैं। यदि आपने जो बैच बेचा वो सूची में है तो हम आपको बताते हैं।';

  @override
  String get supportFaqQ5 =>
      'अपनी एलर्जी प्रोफ़ाइल परिवार के साथ कैसे साझा करूँ?';

  @override
  String get supportFaqA5 =>
      'अभी एलर्जी प्रोफ़ाइल प्रति-अकाउंट होती है। एक ही घरेलू अकाउंट से साइन इन करें या हर फोन पर वही एलर्जी चुनें।';

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
  String get expiryTabNear => 'जल्द समाप्त';

  @override
  String get expiryTabSafe => 'सुरक्षित';

  @override
  String get expiryCalendarTooltip => 'कैलेंडर दृश्य';

  @override
  String get expiryEmptyExpiredTitle => 'कुछ भी एक्सपायर नहीं';

  @override
  String get expiryEmptyNearTitle => 'सब ठीक है';

  @override
  String get expiryEmptyDefaultTitle => 'अभी कोई रिकॉर्ड नहीं';

  @override
  String get expiryEmptyBody => 'इस श्रेणी में कोई रिकॉर्ड नहीं है।';

  @override
  String expiryProductShort(String id) {
    return 'उत्पाद $id';
  }

  @override
  String expiryBatch(String batch) {
    return 'बैच $batch';
  }

  @override
  String expiryQty(String qty) {
    return 'मात्रा $qty';
  }

  @override
  String expiryExp(String date) {
    return 'एक्सपायरी $date';
  }

  @override
  String get expiryPillToday => 'आज';

  @override
  String get expiryPillTomorrow => 'कल';

  @override
  String expiryPillDays(int days) {
    return '${days}d';
  }

  @override
  String get expiryPillSoon => 'जल्द';

  @override
  String get expiryLoadError => 'एक्सपायरी रिकॉर्ड लोड नहीं हो सके।';

  @override
  String get expiryCouldNotLoadSemantic => 'लोड नहीं हो सका';

  @override
  String get inventoryTitle => 'इन्वेंटरी';

  @override
  String get inventorySearchTooltip => 'इन्वेंटरी खोजें';

  @override
  String get inventorySearchHint => 'उत्पाद या EAN से खोजें...';

  @override
  String get inventoryStockMovement => 'स्टॉक मूवमेंट';

  @override
  String get inventoryLowStockAlerts => 'कम स्टॉक अलर्ट';

  @override
  String get inventoryLoadError => 'इन्वेंटरी लोड नहीं हो सकी';

  @override
  String get inventoryEmpty => 'कोई इन्वेंटरी आइटम नहीं मिला';

  @override
  String inventoryNoMatches(String query) {
    return '\"$query\" के लिए कोई मिलान नहीं';
  }

  @override
  String inventoryProductShort(String id) {
    return 'उत्पाद $id';
  }

  @override
  String get inventoryBelowThreshold => 'सीमा से नीचे';

  @override
  String get inventoryInStock => 'स्टॉक में';

  @override
  String get inventoryUnitsLabel => 'यूनिट';

  @override
  String get inventoryTotalQuantity => 'कुल मात्रा';

  @override
  String get inventoryLowStockThreshold => 'कम-स्टॉक सीमा';

  @override
  String inventoryQtyUnits(int count) {
    return '$count यूनिट';
  }

  @override
  String get inventoryBatchLedgerHint =>
      'पूरा बैच लेज़र देखने के लिए \"स्टॉक मूवमेंट\" टैप करें।';

  @override
  String get inventoryLowStockBadge => 'कम स्टॉक';

  @override
  String get tasksTitle => 'कार्य';

  @override
  String get tasksTabMine => 'मेरे कार्य';

  @override
  String get tasksTabAll => 'सभी';

  @override
  String get tasksNewTask => 'नया कार्य';

  @override
  String get tasksEmptyTitle => 'यहाँ कोई कार्य नहीं';

  @override
  String get tasksEmptyBody => 'इस दृश्य को सौंपे गए कार्य यहाँ दिखेंगे।';

  @override
  String get tasksLoadError => 'कार्य लोड नहीं हो सके';

  @override
  String get taskEvidence => 'साक्ष्य';

  @override
  String get priorityHigh => 'उच्च';

  @override
  String get priorityMedium => 'मध्यम';

  @override
  String get priorityLow => 'निम्न';

  @override
  String get priorityUrgent => 'अत्यावश्यक';

  @override
  String get taskStatusOpen => 'खुला';

  @override
  String get taskStatusPending => 'लंबित';

  @override
  String get taskStatusInProgress => 'जारी है';

  @override
  String get taskStatusCompleted => 'पूर्ण';

  @override
  String get taskStatusCancelled => 'रद्द';

  @override
  String get scanTitle => 'उत्पाद स्कैन करें';

  @override
  String get scanAlignHint => 'बारकोड को फ्रेम के भीतर रखें';

  @override
  String scanCandidateVerifying(String code, int streak, int required) {
    return 'Verifying $code — $streak/$required reads agree';
  }

  @override
  String get scanCandidateVerified => 'Verified — ready to proceed';

  @override
  String get scanProceed => 'Proceed';

  @override
  String get scanBatchHint =>
      'बैच मोड — स्कैन करते रहें, आइटम स्वतः जुड़ते जाएँगे';

  @override
  String scanBatchAdded(String code, int count) {
    return '$code जोड़ा · $count स्कैन किए गए';
  }

  @override
  String scanBatchDone(int count) {
    return 'पूर्ण · $count';
  }

  @override
  String get scanLabelAction => 'लेबल स्कैन';

  @override
  String get scanGalleryAction => 'गैलरी';

  @override
  String get scanEnterManually => 'मैन्युअल रूप से दर्ज करें';

  @override
  String get scanBulkAudit => 'बल्क ऑडिट';

  @override
  String get scanHistoryAction => 'इतिहास';

  @override
  String get scanFlash => 'फ्लैश';

  @override
  String get scanTroubleTitle => 'स्कैन करने में परेशानी?';

  @override
  String get scanTroubleBody =>
      'कम रोशनी या खराब बारकोड? फ्लैश चालू करें, या इसके बजाय लेबल पढ़ें।';

  @override
  String get scanGalleryNoBarcode =>
      'कोई बारकोड नहीं मिला। सुझाव: सामग्री पढ़ने के लिए \'लेबल स्कैन\' का उपयोग करें।';

  @override
  String get scanInvalidEan => 'एक वैध EAN-8, EAN-13, या UPC-A कोड दर्ज करें';

  @override
  String get scanWebTitle => 'स्कैन';

  @override
  String get scanWebUnavailable =>
      'वेब पर कैमरा स्कैनिंग उपलब्ध नहीं है।\nबारकोड मैन्युअल रूप से दर्ज करें:';

  @override
  String get scanEanFieldLabel => 'EAN / UPC कोड';

  @override
  String get scanEanHintExample => 'उदा. 5901234123457';

  @override
  String get scanLookUp => 'खोजें';

  @override
  String get scanEnterBarcode => 'बारकोड दर्ज करें';

  @override
  String get scanHistoryTitle => 'स्कैन इतिहास';

  @override
  String get scanNoHistory => 'इस सत्र में अभी तक कोई स्कैन नहीं।';

  @override
  String get homeGreetingMorning => 'सुप्रभात';

  @override
  String get homeGreetingAfternoon => 'शुभ दोपहर';

  @override
  String get homeGreetingEvening => 'शुभ संध्या';

  @override
  String get homeGreetingFallbackName => 'दोस्त';

  @override
  String get homeTrialEnded =>
      'मुफ़्त ट्रायल समाप्त — एक्सेस बनाए रखने के लिए अपग्रेड करें';

  @override
  String homeTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन',
      one: '1 दिन',
    );
    return 'मुफ़्त ट्रायल · $_temp0 शेष';
  }

  @override
  String get homeUpgradeArrow => 'अपग्रेड →';

  @override
  String get homeKpiSaved => 'सहेजे गए';

  @override
  String get homeKpiNearExpiry => 'जल्द समाप्त';

  @override
  String get homeKpiRecallAlerts => 'रिकॉल अलर्ट';

  @override
  String get homeKpiOpenTasks => 'खुले कार्य';

  @override
  String get homeKpiLowStock => 'कम स्टॉक';

  @override
  String get homeEyebrowFoodSafety => 'खाद्य सुरक्षा चेतावनी';

  @override
  String get homeEyebrowToday => 'आज का काम';

  @override
  String get homeEyebrowHealthScan => 'आपका हेल्थ स्कैन';

  @override
  String get homeEyebrowScanToLearn => 'स्कैन करके जानें';

  @override
  String get homeEyebrowAllClear => 'सब ठीक है';

  @override
  String homeStoryRecall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉल किए गए उत्पाद — देखें आपके घर में क्या है',
      one: '1 रिकॉल किया गया उत्पाद — देखें आपके घर में क्या है',
    );
    return '$_temp0';
  }

  @override
  String homeStoryNearExpiryConsumer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count सहेजे आइटम इस सप्ताह समाप्त हो रहे हैं — इन्हें इस्तेमाल करें',
      one: '1 सहेजा आइटम इस सप्ताह समाप्त हो रहा है — इसे इस्तेमाल करें',
    );
    return '$_temp0';
  }

  @override
  String get homeStoryKnowWhatYouEat => 'जानें आप क्या खाते हैं';

  @override
  String get homeStoryScanInside =>
      'किसी भी फूड बारकोड पर कैमरा रखें — देखें अंदर क्या है';

  @override
  String homeStoryNearExpiryBusiness(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम जल्द समाप्त — शेल्फ साफ़ करें',
      one: '1 आइटम जल्द समाप्त — शेल्फ साफ़ करें',
    );
    return '$_temp0';
  }

  @override
  String homeStoryOpenTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्यों को आज आपकी ज़रूरत है',
      one: '1 कार्य को आज आपकी ज़रूरत है',
    );
    return '$_temp0';
  }

  @override
  String homeStoryLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम का स्टॉक कम हो रहा है',
      one: '1 आइटम का स्टॉक कम हो रहा है',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreToday => 'यह रही आज आपकी दुकान';

  @override
  String get homeStoreAllGood => 'शाबाश! आपकी दुकान आज बढ़िया स्थिति में है';

  @override
  String get homeCtaViewRecallAlerts => 'रिकॉल अलर्ट देखें';

  @override
  String get homeCtaCheckExpiry => 'एक्सपायरी देखें';

  @override
  String get homeCtaOpenExpiry => 'एक्सपायरी खोलें';

  @override
  String get homeCtaViewTasks => 'कार्य देखें';

  @override
  String get homeCtaCheckInventory => 'इन्वेंटरी देखें';

  @override
  String get homeCtaOpenTasks => 'कार्य खोलें';

  @override
  String get homeCtaRunAudit => 'एक त्वरित ऑडिट चलाएँ';

  @override
  String get homeQuickActions => 'त्वरित क्रियाएँ';

  @override
  String get homeQuickScan => 'स्कैन';

  @override
  String get homeQuickShopping => 'शॉपिंग';

  @override
  String get homeQuickAddExpiry => 'एक्सपायरी जोड़ें';

  @override
  String get homeQuickNewTask => 'नया कार्य';

  @override
  String get homeRecentTasks => 'हाल के कार्य';

  @override
  String get homeSeeAll => 'सभी देखें';

  @override
  String get homeNoOpenTasks => 'कोई खुला कार्य नहीं — एक बनाएँ';

  @override
  String homeTaskAssignedTo(String name) {
    return '$name को सौंपा गया';
  }

  @override
  String get homeTaskOverdue => 'बकाया';

  @override
  String get homeTaskDueToday => 'आज देय';

  @override
  String get homeTaskDueTomorrow => 'कल देय';

  @override
  String homeTaskDueInDays(int days) {
    return '$days दिनों में देय';
  }

  @override
  String homeTaskDueOn(String date) {
    return 'देय $date';
  }

  @override
  String get homeHowHelps => 'RADHA आपकी कैसे मदद करता है';

  @override
  String get homeScanBarcodeTitle => 'किसी भी फूड बारकोड को स्कैन करें';

  @override
  String get homeScanBarcodeBody =>
      'हेल्थ रेटिंग, सामग्री, और किन बातों का ध्यान रखें — सब देखें।';

  @override
  String get homeRecallTitle => 'सुरक्षा रिकॉल अलर्ट';

  @override
  String get homeRecallBody =>
      'रिकॉल किए गए खाद्य उत्पादों के बारे में सूचित रहें।';

  @override
  String get homePromoKnowFoodEyebrow => 'अपना भोजन जानें';

  @override
  String get homePromoKnowFoodHeadline =>
      'लेबल स्कैन करें — देखें अंदर वास्तव में क्या है';

  @override
  String get homePromoKnowFoodCta => 'स्कैन करें और जानें';

  @override
  String get homePromoExpiryEyebrow => 'कोई तारीख न चूकें';

  @override
  String get homePromoExpiryHeadline => 'हर एक्सपायरी को फिसलने से पहले पकड़ें';

  @override
  String get homePromoExpiryCta => 'एक्सपायरी ट्रैक करें';

  @override
  String get homePromoFestiveEyebrow => 'त्योहारी चुनिंदा';

  @override
  String get homePromoFestiveHeadline =>
      'सीज़न की खरीदारी करें, सेहतमंद तरीके से';

  @override
  String get homePromoFestiveCta => 'उत्पाद ब्राउज़ करें';

  @override
  String get homePromoBazaarEyebrow => 'आज का बाज़ार';

  @override
  String get homePromoBazaarHeadline => 'मिनटों में अपनी शेल्फ का ऑडिट करें';

  @override
  String get homePromoBazaarCta => 'ऑडिट शुरू करें';

  @override
  String get homeShopByCategory => 'श्रेणी से खरीदें';

  @override
  String get homeShopByCategorySubtitle =>
      'स्कैन या ब्राउज़ करने के लिए किसी आइल पर टैप करें';

  @override
  String get onboardingWelcomeValue =>
      'स्कैन करें, ट्रैक करें, अपने स्टॉक का ऑडिट करें — स्प्रेडशीट के बिना।';

  @override
  String get onboardingCapabilitiesTitle =>
      'दुकान के फ़र्श के लिए बना,\nपिछले दफ़्तर के लिए नहीं।';

  @override
  String get onboardingCapScanTitle => 'एक टैप में उत्पाद स्कैन करें';

  @override
  String get onboardingCapScanBody =>
      'EAN लुकअप, हेल्थ और अप्रूवल पहले से जाँचे हुए।';

  @override
  String get onboardingCapExpiryTitle => 'नुकसान से पहले एक्सपायरी पकड़ें';

  @override
  String get onboardingCapExpiryBody =>
      'OCR-सहायता प्राप्त तिथियाँ और प्रति-श्रेणी सीमाएँ।';

  @override
  String get onboardingCapAuditTitle => 'ऐसे ऑडिट चलाएँ जो टीम पूरे कर सके';

  @override
  String get onboardingCapAuditBody => 'कार्य, साक्ष्य और बल्क स्कैन सत्र।';

  @override
  String get onboardingSegmentTitle => 'आप यहाँ किस रूप में हैं?';

  @override
  String get onboardingSegmentSubtitle =>
      'सबसे करीबी विकल्प चुनें। आप बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String get segmentPersonalTitle => 'व्यक्तिगत';

  @override
  String get segmentPersonalBody => 'बस अपने लिए खरीदारी';

  @override
  String get segmentParentTitle => 'अभिभावक';

  @override
  String get segmentParentBody => 'अपने परिवार / बच्चों के लिए खरीदारी';

  @override
  String get segmentBusinessTitle => 'व्यवसाय मालिक';

  @override
  String get segmentBusinessBody => 'मैं एक छोटी रिटेल दुकान चलाता हूँ';

  @override
  String get segmentPharmacyTitle => 'फार्मेसी';

  @override
  String get segmentPharmacyBody => 'मैं एक फार्मेसी / केमिस्ट चलाता हूँ';

  @override
  String get segmentInstitutionTitle => 'संस्थान';

  @override
  String get segmentInstitutionBody => 'स्कूल / छात्रावास / कैंटीन';

  @override
  String get segmentAuditorTitle => 'ऑडिटर (आमंत्रित)';

  @override
  String get segmentAuditorBody => 'मेरे पास एक आमंत्रण कोड है';

  @override
  String get allergenTitle => 'एलर्जेन';

  @override
  String get allergenLoadError => 'आपकी एलर्जेन प्रोफ़ाइल लोड नहीं हो सकी।';

  @override
  String get allergenHeading => 'आपके एलर्जेन';

  @override
  String get allergenIntro =>
      'जिन एलर्जेन से आपको प्रतिक्रिया होती है उन्हें टैप करें। स्कैन किए गए उत्पाद में वे होने पर हम आपको चेतावनी देंगे।';

  @override
  String allergenTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count एलर्जेन ट्रैक किए गए',
      one: '1 एलर्जेन ट्रैक किया गया',
    );
    return '$_temp0';
  }

  @override
  String get allergenNoneTracked => 'अभी तक कोई एलर्जेन ट्रैक नहीं किया गया';

  @override
  String get allergenSavedCleared => 'एलर्जेन प्रोफ़ाइल साफ़ कर दी गई।';

  @override
  String get allergenSaved => 'एलर्जेन प्रोफ़ाइल सहेजी गई।';

  @override
  String get allergenSaveError => 'आपकी एलर्जेन सहेजी नहीं जा सकीं।';

  @override
  String get allergenPeanut => 'मूंगफली';

  @override
  String get allergenTreeNut => 'ट्री नट';

  @override
  String get allergenDairy => 'डेयरी';

  @override
  String get allergenEggs => 'अंडे';

  @override
  String get allergenSoy => 'सोया';

  @override
  String get allergenWheat => 'गेहूँ';

  @override
  String get allergenFish => 'मछली';

  @override
  String get allergenShellfish => 'शेलफिश';

  @override
  String get allergenSesame => 'तिल';

  @override
  String get allergenGluten => 'ग्लूटेन';

  @override
  String get allergenMustard => 'सरसों';

  @override
  String get allergenCelery => 'सेलरी';

  @override
  String get allergenLupin => 'ल्यूपिन';

  @override
  String get allergenMolluscs => 'मोलस्क';

  @override
  String get allergenSulphites => 'सल्फाइट';

  @override
  String get commonSuccess => 'सफल';

  @override
  String lockedFeatureUpgradeTo(String planName) {
    return '$planName में अपग्रेड करें';
  }

  @override
  String lockedFeaturePlan(String planName) {
    return 'यह सुविधा $planName प्लान का हिस्सा है।';
  }

  @override
  String get lockedFeatureViewPlans => 'प्लान देखें';

  @override
  String get notFoundSemantic => 'पेज नहीं मिला';

  @override
  String get notFoundTitle => 'यह पेज कहीं खो गया';

  @override
  String get notFoundBody =>
      'आप जो खोज रहे थे वह नहीं मिला। चलिए आपको वापस होम पर ले चलते हैं।';

  @override
  String get notFoundBackHome => 'होम पर वापस';

  @override
  String get commonCouldNotLoad => 'लोड नहीं हो सका';

  @override
  String get sendOtp => 'OTP भेजें';

  @override
  String get otpUseCode => 'कोड का उपयोग करें';

  @override
  String get ohsPickStore => 'डैशबोर्ड खोलने से पहले एक स्टोर चुनें।';

  @override
  String get profileAccount => 'खाता';

  @override
  String get profileManageStores => 'स्टोर प्रबंधित करें';

  @override
  String get profileSavedProducts => 'सहेजे गए उत्पाद';

  @override
  String get profileSubscription => 'सदस्यता';

  @override
  String get profilePreferences => 'प्राथमिकताएँ';

  @override
  String get profileAllergenProfile => 'एलर्जेन प्रोफ़ाइल';

  @override
  String get profileShoppingList => 'शॉपिंग सूची';

  @override
  String get recallTitle => 'रिकॉल अलर्ट';

  @override
  String recallProductFallback(String id) {
    return 'उत्पाद $id';
  }

  @override
  String recallDate(String date) {
    return 'वापस मँगाया $date';
  }

  @override
  String get recallViewProduct => 'उत्पाद देखें';

  @override
  String get recallLoadError => 'रिकॉल लोड नहीं हो सके।';

  @override
  String get recallEmpty => 'कोई सक्रिय रिकॉल नहीं';

  @override
  String get recallEmptyBody =>
      'नियामक निकायों द्वारा जारी किए जाने पर उत्पाद रिकॉल अलर्ट यहाँ दिखेंगे।';

  @override
  String get referralsLoadError => 'रेफ़रल लोड नहीं हो सके।';

  @override
  String get referralsCopyCode => 'कोड कॉपी करें';

  @override
  String get referralsShareInvite => 'निमंत्रण साझा करें';

  @override
  String get referralsCodeCopied => 'कोड कॉपी हो गया';

  @override
  String get referralsInvitees => 'आमंत्रित';

  @override
  String get referralsRewardsEarned => 'अर्जित पुरस्कार';

  @override
  String get referralsCodeRedeemed => 'कोड रिडीम हो गया';

  @override
  String get referralsEnterCode => 'एक रेफ़रल कोड दर्ज करें';

  @override
  String get referralsRedeem => 'रिडीम करें';

  @override
  String get referralsRedeemError => 'कोड रिडीम नहीं हो सका';

  @override
  String get referralsRedeemSubtitle =>
      'किसी मित्र का निमंत्रण है? नीचे उनका कोड दर्ज करें।';

  @override
  String get commonClear => 'साफ़ करें';

  @override
  String get commonShare => 'शेयर करें';

  @override
  String get healthSugar => 'चीनी';

  @override
  String get healthSalt => 'नमक';

  @override
  String get healthFat => 'वसा';

  @override
  String get healthProcessed => 'प्रोसेस्ड';

  @override
  String get healthChildSuitable => 'बच्चों के लिए उपयुक्त';

  @override
  String get productDetailsTitle => 'उत्पाद विवरण';

  @override
  String get productDetailLoadError => 'यह उत्पाद लोड नहीं हो सका';

  @override
  String get productCheckAllergens => 'एलर्जेन जाँचें';

  @override
  String get productExplainIngredients => 'सामग्री समझाएँ';

  @override
  String get productSeeHealthierOptions => 'स्वास्थ्यकर विकल्प देखें';

  @override
  String get productViewHealthyAlternatives => 'स्वास्थ्यकर विकल्प देखें';

  @override
  String get productHealthAssessment => 'स्वास्थ्य आकलन';

  @override
  String get productNutritionInfo => 'पोषण जानकारी';

  @override
  String get productAllergenCheck => 'एलर्जेन जाँच';

  @override
  String get productSeeFullExplanation => 'पूरा विवरण देखें';

  @override
  String get productHealthierOptions => 'स्वास्थ्यकर विकल्प';

  @override
  String get commonYes => 'हाँ';

  @override
  String get nutritionProtein => 'प्रोटीन';

  @override
  String get nutritionTotalSugars => 'कुल शर्करा';

  @override
  String get nutritionEnergy => 'ऊर्जा';

  @override
  String get nutritionTotalFat => 'कुल वसा';

  @override
  String get nutritionSaturatedFat => 'संतृप्त वसा';

  @override
  String get nutritionCarbohydrates => 'कार्बोहाइड्रेट';

  @override
  String get nutritionFibre => 'फाइबर';

  @override
  String get nutritionSodium => 'सोडियम';

  @override
  String get nutritionAll => 'सभी पोषक तत्व';

  @override
  String get nutritionPer100g => 'प्रति 100 ग्राम';

  @override
  String get nutritionPer50g => 'प्रति 50 ग्राम';

  @override
  String get productDetailSavedAlert =>
      'सहेजा गया — अगर इसे कभी रिकॉल किया गया तो हम आपको सूचित करेंगे।';

  @override
  String get productDetailSaveError =>
      'सहेजा नहीं जा सका। कृपया फिर से कोशिश करें।';

  @override
  String get productDetailWhatYoullLike => 'आपको क्या पसंद आएगा';

  @override
  String get productDetailWhatConcern => 'किस बात की चिंता करें';

  @override
  String get productDetailIngredientDeepDive => 'सामग्री विस्तार से';

  @override
  String get productDetailPersonalisedFlags => 'व्यक्तिगत संकेत';

  @override
  String get productDetailAlreadyBought => 'पहले ही खरीदा';

  @override
  String get productDetailScanToUnlock => 'अनलॉक करने के लिए स्कैन करें';

  @override
  String get productDetailTitle => 'उत्पाद';

  @override
  String get productDetailSave => 'सहेजें';

  @override
  String get productDetailSaved => 'सहेजा गया';

  @override
  String get productDetailHealthNotRated => 'स्वास्थ्य रेटिंग अभी उपलब्ध नहीं';

  @override
  String get productDetailHealthNotRatedBody =>
      'इस उत्पाद की पूरी स्वास्थ्य जानकारी RADHA में लाने के लिए इसे स्कैन करें।';

  @override
  String get productDetailHealthLabel => 'RADHA स्वास्थ्य रेटिंग';

  @override
  String get productDetailHighProtein => 'उच्च प्रोटीन';

  @override
  String get productDetailGoodFibre => 'अच्छा फाइबर';

  @override
  String get productDetailMinimallyProcessed => 'न्यूनतम प्रसंस्करण';

  @override
  String get productDetailHighSugar => 'उच्च चीनी';

  @override
  String get productDetailHighSatFat => 'उच्च संतृप्त वसा';

  @override
  String get productDetailHighSodium => 'उच्च सोडियम';

  @override
  String get productDetailUltraProcessed => 'अत्यधिक प्रसंस्कृत';

  @override
  String get productDetailNutritionNote =>
      'उत्पाद की वास्तविक पोषण (प्रति 100 ग्राम) पर आधारित।';

  @override
  String get productDetailKeyNutrients => 'मुख्य पोषक तत्व';

  @override
  String get productDetailRdaNote => '% संदर्भ दैनिक सेवन (वयस्क)।';

  @override
  String get productDetailForYou => 'आपके लिए';

  @override
  String get productDetailIngredientLockBody =>
      'हर सामग्री का सुरक्षा निर्णय के साथ विवरण देखें — यह क्या है, क्यों है, और चिंता करनी चाहिए या नहीं।';

  @override
  String get productDetailIngredientError =>
      'अभी इन सामग्रियों की व्याख्या नहीं हो सकी।';

  @override
  String get productDetailAllergenLockBody =>
      'इस उत्पाद को अपनी एलर्जी और स्वास्थ्य लक्ष्यों से मिलाएं — हम आपके लिए सही का संकेत देंगे।';

  @override
  String get productDetailAllergenError => 'अभी यह व्यक्तिगत नहीं किया जा सका।';

  @override
  String get productDetailNoAllergens =>
      'इस उत्पाद में कोई एलर्जी तत्व नहीं मिला।';

  @override
  String productDetailAllergenAvoid(String name) {
    return '$name — आप इससे बचते हैं';
  }

  @override
  String productDetailUnlockWith(String plan) {
    return '$plan के साथ अनलॉक करें';
  }

  @override
  String get productDetailWouldYouBuy => 'क्या आप यह उत्पाद खरीदेंगे?';

  @override
  String get productDetailThanksForSharing => 'साझा करने के लिए धन्यवाद!';

  @override
  String get productDetailNutritionNotIn => 'पूरी पोषण जानकारी अभी नहीं';

  @override
  String get productDetailNutritionNotInBody =>
      'असली पोषण और स्वास्थ्य विश्लेषण RADHA में लाने के लिए इस उत्पाद का बारकोड स्कैन करें।';

  @override
  String productDetailShareText(String name) {
    return 'RADHA पर \"$name\" जाँचा।';
  }

  @override
  String productDetailShareTextRated(String name, String rating, String label) {
    return 'RADHA पर \"$name\" जाँचा — RADHA स्वास्थ्य रेटिंग $rating/5 ($label)।';
  }

  @override
  String get catalogSearchBarLabel => 'अपने अनुकूल उत्पाद खोजें';

  @override
  String get catalogSearchPromptTitle => 'कोई उत्पाद खोजें';

  @override
  String get catalogSearchPromptBody =>
      'स्वास्थ्य रेटिंग और सामग्री देखने के लिए उत्पाद नाम या ब्रांड से खोजें।';

  @override
  String get commonNo => 'नहीं';

  @override
  String get scanApprovalNotInAudit => 'अप्रूवल स्थिति — ऑडिट में नहीं';

  @override
  String get scanApprovalChecking => 'अप्रूव्ड सूची जाँच रहे हैं…';

  @override
  String get scanApprovalCheckFailed => 'अप्रूवल जाँच नहीं हो सकी';

  @override
  String get scanApprovalApproved => 'अप्रूव्ड — सूची में';

  @override
  String get scanApprovalNoList => 'कोई अप्रूव्ड सूची सक्रिय नहीं';

  @override
  String get scanApprovalInvalidBarcode => 'अमान्य बारकोड';

  @override
  String get scanApprovalNotInList => 'अप्रूव्ड सूची में नहीं';

  @override
  String scanApprovalStatus(String label) {
    return 'अप्रूवल स्थिति: $label';
  }

  @override
  String get scanResultAddToExpiry => 'एक्सपायरी में जोड़ें';

  @override
  String get scanResultAddToStock => 'स्टॉक में जोड़ें';

  @override
  String get scanResultSaveToList => 'सूची में सहेजें';

  @override
  String get scanResultNoProduct => 'कोई उत्पाद नहीं मिला';

  @override
  String get scanResultScanLabel => 'लेबल स्कैन करें';

  @override
  String get auditRecordError =>
      'स्कैन रिकॉर्ड नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get auditEndError =>
      'ऑडिट समाप्त नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get auditNoStore => 'कोई स्टोर असाइन नहीं';

  @override
  String get auditNoStoreBody =>
      'बल्क ऑडिट स्टोर की अप्रूव्ड EAN सूची के विरुद्ध चलते हैं। किसी एडमिन से आपको स्टोर असाइन करने को कहें, फिर ऑडिट के लिए वापस आएँ।';

  @override
  String get auditMatched => 'मिलान हुआ';

  @override
  String get auditNotInList => 'सूची में नहीं';

  @override
  String get auditNoList => 'कोई सूची नहीं';

  @override
  String get auditInvalid => 'अमान्य';

  @override
  String get auditUnchecked => 'अनचेक्ड';

  @override
  String get commonTotal => 'कुल';

  @override
  String get auditEnterScanEan => 'EAN दर्ज करें या स्कैन करें';

  @override
  String auditStatus(String label) {
    return 'स्थिति: $label';
  }

  @override
  String get auditStartAuditing => 'ऑडिट शुरू करें';

  @override
  String get auditStartBody =>
      'इस स्टोर की अप्रूव्ड सूची से जाँचने के लिए ऊपर EAN स्कैन करें या टाइप करें। हर परिणाम यहाँ मिलान या सूची-में-नहीं स्थिति के साथ आता है।';

  @override
  String get auditTitle => 'बल्क EAN ऑडिट';

  @override
  String get auditEndAction => 'ऑडिट समाप्त करें';

  @override
  String get auditEndingAction => 'समाप्त हो रहा है…';

  @override
  String get auditEanInvalid => 'एक वैध EAN-8, EAN-13, या UPC-A कोड दर्ज करें';

  @override
  String auditEndedSummary(int matched, int notMatched) {
    return 'ऑडिट समाप्त — $matched मिलान, $notMatched सूची में नहीं';
  }

  @override
  String get cameraCapture => 'कैप्चर करें';

  @override
  String get labelScanReadError => 'लेबल पढ़ा नहीं जा सका';

  @override
  String get labelScanReadErrorBody =>
      'बेहतर रोशनी में फिर से कोशिश करें, स्थिर रखें, और फ्रेम को सामग्री पैनल से भरें।';

  @override
  String get labelScanAnalysisFailed => 'विश्लेषण विफल';

  @override
  String get labelScanIntro => 'RADHA आपके लिए लेबल पढ़ता है';

  @override
  String get labelScanTakePhoto => 'फ़ोटो लें';

  @override
  String get labelScanChooseGallery => 'गैलरी से चुनें';

  @override
  String get labelScanAnother => 'दूसरा स्कैन करें';

  @override
  String labelScanSeePlans(String plan) {
    return '$plan प्लान देखें';
  }

  @override
  String get labelScanMaybeLater => 'शायद बाद में';

  @override
  String get labelScanTitle => 'लेबल स्कैन करें';

  @override
  String get labelScanNoBarcode => 'बारकोड नहीं? लेबल पढ़ें';

  @override
  String get labelScanIdleBody =>
      'सामग्री पैनल पर कैमरा लगाएं — हम पढ़कर बताएंगे क्या है। बिना बारकोड के भी काम करता है।';

  @override
  String get labelScanFlashNote =>
      'कम रोशनी में कैमरा फ्लैश अपने आप चालू होती है।';

  @override
  String get labelScanReading => 'लेबल पढ़ा जा रहा है…';

  @override
  String get labelScanAnalyzing => 'सामग्री विश्लेषण हो रहा है…';

  @override
  String get labelScanFallbackError => 'कुछ गलत हुआ। कृपया पुनः प्रयास करें।';

  @override
  String get labelScanResultFallback => 'लेबल विश्लेषण';

  @override
  String get labelScanLowConfidence =>
      'कम सटीकता — स्पष्ट फोटो से बेहतर परिणाम मिल सकते हैं।';

  @override
  String get labelScanWhatToWatch => 'ध्यान देने वाली बातें';

  @override
  String get labelScanIngredients => 'सामग्री';

  @override
  String get labelScanDisclaimer =>
      'RADHA AI द्वारा लेबल पाठ से पढ़ा गया। सटीक जानकारी के लिए पैक जांचें।';

  @override
  String get labelScanUnlockTitle => 'AI लेबल रीडिंग अनलॉक करें';

  @override
  String get labelScanUnlockBody =>
      'हमने लेबल पढ़ लिया, लेकिन पूर्ण सामग्री विश्लेषण प्रीमियम फीचर है।';

  @override
  String scanResultNotFoundBody(String ean) {
    return 'EAN $ean के लिए कैटलॉग में मेल नहीं — लेकिन आप फिर भी लेबल पढ़ सकते हैं। सामग्री पैनल की फ़ोटो लें और हम बताएँगे अंदर क्या है।';
  }

  @override
  String productScore(String score) {
    return 'स्कोर: $score';
  }

  @override
  String get catalogSearchHint => 'उत्पाद या ब्रांड खोजें';

  @override
  String get catalogNoMatches => 'कोई मिलान नहीं';

  @override
  String catalogNoMatchesBody(String query) {
    return 'हमें “$query” के लिए उत्पाद नहीं मिले। कोई दूसरा नाम आज़माएँ, या इसके बजाय आइटम स्कैन करें।';
  }

  @override
  String get browseTitle => 'उत्पाद';

  @override
  String get browseLoadError => 'उत्पाद लोड नहीं हो सके';

  @override
  String browseLoadErrorBody(String category) {
    return '$category लोड करने में दिक्कत आई। कृपया फिर से कोशिश करें।';
  }

  @override
  String get browseSortHealthiest => 'सबसे स्वास्थ्यकर';

  @override
  String get browseSortAZ => 'A–Z';

  @override
  String get browseFilterVegOnly => 'केवल शाकाहारी';

  @override
  String get browseVeg => 'वेज';

  @override
  String get browseEmptyVeg => 'यहाँ अभी कोई शाकाहारी आइटम नहीं';

  @override
  String browseEmptyVegBody(String category) {
    return 'अभी $category में कुछ भी शाकाहारी फ़िल्टर से मेल नहीं खाता।';
  }

  @override
  String get browseShowAll => 'सभी दिखाएँ';

  @override
  String get browseEmpty => 'अभी कोई उत्पाद नहीं';

  @override
  String browseEmptyBody(String category) {
    return 'हम $category सेक्शन भर रहे हैं। तब तक, किसी भी आइटम को स्कैन करके उसकी सेहत और एक्सपायरी जाँचें।';
  }

  @override
  String referralsShareText(String code) {
    return 'RADHA पर मेरे साथ जुड़ें: कोड $code का उपयोग करें';
  }

  @override
  String get selectStoreEmpty => 'अभी तक कोई स्टोर नहीं';

  @override
  String get selectStoreEmptyBody =>
      'किसी स्टोर में जोड़े जाने के लिए अपने मैनेजर से संपर्क करें।';

  @override
  String get selectStoreEmptyDetail =>
      'आपका खाता अभी किसी स्टोर से संबद्ध नहीं है। एक्सेस के लिए अपने मैनेजर से कहें, फिर वापस आकर एक चुनें।';

  @override
  String get selectStoreContactManager => 'अपने मैनेजर से संपर्क करें';

  @override
  String get expiryConsumerTitle => 'व्यापार खाते के लिए';

  @override
  String get expiryConsumerBody =>
      'एक्सपायरी ट्रैकिंग एक रिटेल स्टोर फीचर है। इसे इस्तेमाल करने के लिए, अपने खाते को स्टोर से जोड़ें।';

  @override
  String get tasksConsumerTitle => 'व्यापार खाते के लिए';

  @override
  String get tasksConsumerBody =>
      'टास्क मैनेजमेंट एक रिटेल स्टोर फीचर है। इसे इस्तेमाल करने के लिए, अपने खाते को स्टोर से जोड़ें।';

  @override
  String get languageSavedLocally => 'भाषा केवल स्थानीय रूप से सहेजी गई';

  @override
  String languageSavedLocallyError(String error) {
    return 'भाषा केवल स्थानीय रूप से सहेजी गई: $error';
  }

  @override
  String get signOutConfirmBody =>
      'ऐप का उपयोग करने के लिए आपको OTP के साथ फिर से साइन इन करना होगा।';

  @override
  String get scanResultTitle => 'स्कैन परिणाम';

  @override
  String scanResultShareMessage(String ean) {
    return 'मैंने यह उत्पाद RADHA पर देखा — बारकोड $ean।';
  }

  @override
  String get scanResultHealthHeading => 'स्वास्थ्य';

  @override
  String get scanResultAssessmentPending => 'मूल्यांकन लंबित';

  @override
  String get scanResultNutritionPending =>
      'इस उत्पाद के कैटलॉग में मिलते ही पोषण संकेत यहाँ दिखेंगे। डेटाबेस को समृद्ध करने के लिए और वस्तुएँ स्कैन करें।';

  @override
  String get scanResultExplainIngredients => 'सामग्री समझाएँ';

  @override
  String get scanResultAllergenPrompt =>
      'अपनी एलर्जन प्रोफ़ाइल सेट करें ताकि स्कैन किए गए उत्पाद में आपकी परहेज़ वाली कोई चीज़ होने पर तुरंत चेतावनी मिले।';

  @override
  String scanResultAllergensDeclared(String allergens) {
    return 'Contains: $allergens';
  }

  @override
  String get scanResultNoAllergensDeclared =>
      'No allergens declared on this product\'s label.';

  @override
  String get taskEvidenceRequiredSnack =>
      'इस कार्य को पूरा करने के लिए साक्ष्य आवश्यक है';

  @override
  String taskMovedTo(String status) {
    return 'कार्य $status में ले जाया गया';
  }

  @override
  String get taskUpdateError =>
      'कार्य अपडेट नहीं हो सका। कृपया फिर से प्रयास करें।';

  @override
  String taskAssignedTo(String name) {
    return '$name को सौंपा गया';
  }

  @override
  String taskDueOn(String date) {
    return 'नियत $date';
  }

  @override
  String get taskPriorityLabel => 'प्राथमिकता';

  @override
  String get taskEvidenceLabel => 'साक्ष्य';

  @override
  String get taskEvidencePhotoRequired => 'फ़ोटो आवश्यक';

  @override
  String get taskEvidenceNotRequired => 'आवश्यक नहीं';

  @override
  String taskEvidencePhotosAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो संलग्न',
      one: '1 फ़ोटो संलग्न',
    );
    return '$_temp0';
  }

  @override
  String get taskEvidencePhotoNeeded =>
      'इस कार्य को पूरा करने के लिए एक फ़ोटो आवश्यक है';

  @override
  String get taskTimelineCreated => 'बनाया गया';

  @override
  String get taskTimelineStarted => 'शुरू हुआ';

  @override
  String get taskActionComplete => 'पूर्ण करें';

  @override
  String get taskLoadFailed => 'कार्य लोड नहीं हो सका';

  @override
  String get taskDescriptionLabel => 'विवरण';

  @override
  String get taskTypeLabel => 'प्रकार';

  @override
  String get taskActionStart => 'शुरू करें';

  @override
  String get taskCreateTitle => 'कार्य बनाएँ';

  @override
  String get taskCreateCta => 'कार्य बनाएँ';

  @override
  String get taskCreatedSnack => 'कार्य बनाया गया';

  @override
  String get taskCreateError =>
      'कार्य नहीं बनाया जा सका। कृपया फिर से प्रयास करें।';

  @override
  String get taskNotAuthorizedTitle => 'अनधिकृत';

  @override
  String get taskNotAuthorizedBody =>
      'केवल मैनेजर और एडमिन ही कार्य बना सकते हैं।';

  @override
  String get taskTitleLabel => 'शीर्षक';

  @override
  String get taskTitleHint => 'उदा. डेयरी सेक्शन के EAN ऑडिट करें';

  @override
  String get taskTitleRequired => 'शीर्षक आवश्यक है';

  @override
  String get taskDescriptionHint => 'असाइनी के लिए वैकल्पिक विवरण';

  @override
  String get taskStoreLabel => 'स्टोर';

  @override
  String get taskAssigneeLabel => 'असाइनी (यूज़र ID)';

  @override
  String get taskAssigneeHint => 'यूज़र ID दर्ज करें या खाली छोड़ें';

  @override
  String get taskDueDateLabel => 'नियत तिथि';

  @override
  String get taskSelectDate => 'तिथि चुनें';

  @override
  String get taskRequiresEvidence => 'साक्ष्य आवश्यक';

  @override
  String get taskRequiresEvidenceSubtitle =>
      'पूरा करने के लिए असाइनी को फ़ोटो अपलोड करनी होगी';

  @override
  String get taskTypeEanAudit => 'EAN ऑडिट';

  @override
  String get taskTypeExpiryCheck => 'एक्सपायरी जाँच';

  @override
  String get taskTypeInventoryCount => 'इन्वेंटरी गणना';

  @override
  String get taskTypeDisplayVerification => 'डिस्प्ले सत्यापन';

  @override
  String get taskTypeCustom => 'कस्टम';

  @override
  String get checkoutStartError =>
      'चेकआउट शुरू नहीं हो सका। कृपया फिर से प्रयास करें।';

  @override
  String get paymentResponseIncomplete => 'भुगतान प्रतिक्रिया अधूरी थी।';

  @override
  String get paymentSuccessUpdated => 'भुगतान सफल। प्लान अपडेट हो गया।';

  @override
  String get paymentNotVerified => 'भुगतान सत्यापित नहीं हो सका।';

  @override
  String get paymentVerifyFailed =>
      'भुगतान सत्यापन विफल। कृपया सहायता से संपर्क करें।';

  @override
  String get paymentCancelled => 'भुगतान रद्द किया गया।';

  @override
  String paymentFailed(String message) {
    return 'भुगतान विफल: $message';
  }

  @override
  String paymentOpeningWallet(String wallet) {
    return '$wallet खोल रहे हैं…';
  }

  @override
  String get paymentSheetOpenError => 'भुगतान शीट नहीं खुल सकी।';

  @override
  String get subscriptionLoadError => 'आपकी सदस्यता लोड नहीं हो सकी';

  @override
  String get subscriptionLoadErrorBody =>
      'अपना कनेक्शन जाँचें और फिर से प्रयास करें।';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'आप $plan पर हैं';
  }

  @override
  String subscriptionUpgradeTo(String plan) {
    return '$plan में अपग्रेड करें';
  }

  @override
  String subscriptionChoosePlan(String plan) {
    return '$plan चुनें';
  }

  @override
  String get subscriptionPopular => 'लोकप्रिय';

  @override
  String get subscriptionPerMonth => '/माह';

  @override
  String get subscriptionTitle => 'सदस्यता';

  @override
  String get subscriptionHeadline => 'RADHA की पूरी शक्ति को अनलॉक करें';

  @override
  String get subscriptionChooseAPlan => 'एक प्लान चुनें';

  @override
  String get subscriptionCancelAnytime => 'कभी भी रद्द करें · GST शामिल';

  @override
  String get subscriptionBillingYearly => 'वार्षिक';

  @override
  String get subscriptionBillingMonthly => 'मासिक';

  @override
  String get versionLoading => 'संस्करण लोड हो रहा है…';

  @override
  String get versionUnavailable => 'संस्करण उपलब्ध नहीं';

  @override
  String appVersionBuild(String version, String build) {
    return 'संस्करण $version ($build)';
  }

  @override
  String get shoppingListTitle => 'खरीदारी सूची';

  @override
  String get shoppingAddItem => 'आइटम जोड़ें';

  @override
  String get shoppingLoadError => 'आपकी सूची लोड नहीं हो सकी';

  @override
  String get shoppingLoadErrorBody =>
      'हम आपकी खरीदारी सूची लोड नहीं कर सके। कृपया फिर से प्रयास करें।';

  @override
  String get shoppingEmptyTitle => 'आपकी खरीदारी सूची खाली है';

  @override
  String get shoppingEmptyBody =>
      'आइटम जोड़ने के लिए प्लस बटन दबाएँ, या किसी उत्पाद पेज से स्वस्थ विकल्प सहेजें।';

  @override
  String get shoppingUpdateError =>
      'आइटम अपडेट नहीं हो सका। कृपया फिर से प्रयास करें।';

  @override
  String get shoppingDeleteError =>
      'आइटम हटाया नहीं जा सका। कृपया फिर से प्रयास करें।';

  @override
  String get shoppingAddError =>
      'आइटम जोड़ा नहीं जा सका। कृपया फिर से प्रयास करें।';

  @override
  String get shoppingAllDone => 'सब हो गया — सब कुछ टिक हो गया';

  @override
  String shoppingRemaining(int remaining, int total) {
    return '$total में से $remaining खरीदना बाकी';
  }

  @override
  String shoppingQty(int quantity) {
    return 'मात्रा: $quantity';
  }

  @override
  String get shoppingDeleteItem => 'आइटम हटाएँ';

  @override
  String get shoppingItemNameLabel => 'आइटम का नाम';

  @override
  String get shoppingItemNameHint => 'उदा. होल व्हीट ब्रेड';

  @override
  String get shoppingItemNameRequired => 'आइटम का नाम दर्ज करें';

  @override
  String get shoppingItemNameTooLong => 'इसे 120 अक्षरों से कम रखें';

  @override
  String get shoppingQuantityLabel => 'मात्रा (वैकल्पिक)';

  @override
  String get shoppingQuantityInvalid => 'एक धनात्मक संख्या दर्ज करें';

  @override
  String get shoppingQuantityTooHigh => 'यह असामान्य रूप से अधिक लगता है';

  @override
  String get shoppingAddToList => 'सूची में जोड़ें';

  @override
  String get grnTitle => 'प्राप्त माल';

  @override
  String get grnFilterAll => 'सभी';

  @override
  String get grnFilterDraft => 'ड्राफ्ट';

  @override
  String get grnFilterPendingReview => 'समीक्षा लंबित';

  @override
  String get grnFilterPosted => 'पोस्ट किया गया';

  @override
  String get grnStatusPending => 'लंबित';

  @override
  String get grnEmptyTitle => 'यहाँ कोई GRN नहीं';

  @override
  String get grnEmptyBody =>
      'सप्लायर डिलीवरी दर्ज करने के लिए एक गुड्स-रिसीव्ड नोट बनाएँ।';

  @override
  String get grnNew => 'नया GRN';

  @override
  String get grnLoadError => 'GRN लोड नहीं हो सके';

  @override
  String get grnSupplierFallback => 'सप्लायर';

  @override
  String get categoryBiscuits => 'बिस्किट और स्नैक्स';

  @override
  String get categoryBreakfast => 'नाश्ता और स्प्रेड';

  @override
  String get categoryDairy => 'डेयरी और अंडे';

  @override
  String get categoryBeverages => 'पेय पदार्थ';

  @override
  String get categoryStaples => 'अनाज और स्टेपल';

  @override
  String get categoryPersonalCare => 'पर्सनल केयर';

  @override
  String get categoryHousehold => 'घरेलू सामान';

  @override
  String get categoryFrozen => 'फ्रोज़न';

  @override
  String get lowStockTitle => 'कम स्टॉक अलर्ट';

  @override
  String get lowStockLoadError => 'अलर्ट लोड नहीं हो सके';

  @override
  String get lowStockEmpty => 'सभी स्टॉक स्तर ठीक हैं';

  @override
  String lowStockCurrentThreshold(int quantity, int threshold) {
    return 'वर्तमान: $quantity / सीमा: $threshold';
  }

  @override
  String get lowStockRestock => 'पुनः स्टॉक करें';

  @override
  String get commonRequired => 'आवश्यक';

  @override
  String get commonOptional => 'वैकल्पिक';

  @override
  String get commonQuantity => 'मात्रा';

  @override
  String get smTitle => 'स्टॉक मूवमेंट';

  @override
  String get smStockIn => 'स्टॉक इन';

  @override
  String get smStockOut => 'स्टॉक आउट';

  @override
  String get smProductLabel => 'उत्पाद';

  @override
  String get smProductHint => 'उत्पाद ID या EAN दर्ज करें';

  @override
  String get smReasonLabel => 'कारण';

  @override
  String get smSelectReason => 'कारण चुनें';

  @override
  String get smBatchLabel => 'बैच नंबर';

  @override
  String get smExpiryLabel => 'एक्सपायरी तिथि';

  @override
  String get smExpiryOptionalHint => 'वैकल्पिक — चुनने के लिए टैप करें';

  @override
  String get smNotesLabel => 'नोट्स';

  @override
  String get smNotesHint => 'वैकल्पिक नोट्स';

  @override
  String get smRecordIn => 'स्टॉक इन रिकॉर्ड करें';

  @override
  String get smRecordOut => 'स्टॉक आउट रिकॉर्ड करें';

  @override
  String get smStockInRecorded => 'स्टॉक-इन रिकॉर्ड हुआ';

  @override
  String get smStockOutRecorded => 'स्टॉक-आउट रिकॉर्ड हुआ';

  @override
  String get smRecordError =>
      'स्टॉक मूवमेंट रिकॉर्ड नहीं हो सका। कृपया फिर से प्रयास करें।';

  @override
  String get smInsufficientStock => 'इस मूवमेंट के लिए अपर्याप्त स्टॉक';

  @override
  String get smReasonPurchase => 'खरीद';

  @override
  String get smReasonReturn => 'वापसी';

  @override
  String get smReasonAdjustment => 'समायोजन';

  @override
  String get smReasonTransfer => 'ट्रांसफर';

  @override
  String get smReasonDamage => 'क्षति';

  @override
  String get smReasonExpiryRemoval => 'एक्सपायरी हटाना';

  @override
  String get smReasonOther => 'अन्य';

  @override
  String get grnInvoiceDateRequired => 'इनवॉइस तिथि आवश्यक है';

  @override
  String get grnCreateError =>
      'GRN नहीं बनाया जा सका। कृपया फिर से प्रयास करें।';

  @override
  String get grnSupplierInvoiceSection => 'सप्लायर और इनवॉइस';

  @override
  String get grnSupplierNameLabel => 'सप्लायर का नाम';

  @override
  String get grnSupplierNameHint => 'सप्लायर का नाम दर्ज करें';

  @override
  String get grnSupplierRequired => 'सप्लायर आवश्यक है';

  @override
  String get grnInvoiceNumberLabel => 'इनवॉइस नंबर';

  @override
  String get grnInvoiceNumberHint => 'इनवॉइस नंबर दर्ज करें';

  @override
  String get grnInvoiceNumberRequired => 'इनवॉइस नंबर आवश्यक है';

  @override
  String get grnInvoiceDateLabel => 'इनवॉइस तिथि *';

  @override
  String get grnExpectedDeliveryLabel => 'अपेक्षित डिलीवरी तिथि';

  @override
  String get grnCreateDraft => 'ड्राफ्ट GRN बनाएँ';

  @override
  String get grnSelectDate => 'तिथि चुनें';

  @override
  String get expiryCalendarTitle => 'एक्सपायरी कैलेंडर';

  @override
  String get expiryCalendarLoadError => 'कैलेंडर डेटा लोड नहीं हो सका।';

  @override
  String get expiryCalendarTapHint => 'विवरण देखने के लिए किसी दिन पर टैप करें';

  @override
  String get expiryCalendarNoRecords =>
      'इस दिन के लिए कोई एक्सपायरी रिकॉर्ड नहीं';

  @override
  String expiryCalendarSummaryFor(String date) {
    return '$date का सारांश';
  }

  @override
  String get exTitle => 'नया एक्सपायरी रिकॉर्ड';

  @override
  String get exMfgAfterExpiry =>
      'निर्माण तिथि एक्सपायरी तिथि के बाद नहीं हो सकती';

  @override
  String get exSelectMfg => 'निर्माण तिथि चुनें';

  @override
  String get exSelectExpiry => 'एक्सपायरी तिथि चुनें';

  @override
  String get exExpiryRequired => 'एक्सपायरी तिथि आवश्यक है';

  @override
  String get exCreated => 'एक्सपायरी रिकॉर्ड बनाया गया';

  @override
  String get exOfflineQueued =>
      'आप ऑफ़लाइन हैं — ऑनलाइन होने पर रिकॉर्ड सिंक होगा';

  @override
  String get exSubmitError => 'कुछ गलत हो गया। कृपया फिर से प्रयास करें।';

  @override
  String get exNotSet => 'सेट नहीं';

  @override
  String get exProductIdLabel => 'उत्पाद ID';

  @override
  String get exProductIdHint => 'उत्पाद ID दर्ज करें या बारकोड स्कैन करें';

  @override
  String get exMfgLabel => 'निर्माण तिथि';

  @override
  String get exExpiryLabel => 'एक्सपायरी तिथि *';

  @override
  String get exBatchLabel => 'बैच नंबर';

  @override
  String get exLocationLabel => 'स्थान';

  @override
  String get exLocationHint => 'शेल्फ / गलियारा / ज़ोन';

  @override
  String get exSaveRecord => 'रिकॉर्ड सहेजें';

  @override
  String get exOcrSemantic => 'RADHA आपके लिए तिथि पढ़ता है';

  @override
  String get exOcrTitle => 'पैक से तिथि स्कैन करें';

  @override
  String get exOcrSubtitle => 'हम आपके लिए MFG / EXP पढ़ेंगे';

  @override
  String get grnItemsTitle => 'GRN आइटम';

  @override
  String get grnItemAdded => 'आइटम जोड़ा गया';

  @override
  String get grnItemSavedOffline =>
      'ऑफ़लाइन सहेजा गया — ऑनलाइन होने पर सिंक होगा';

  @override
  String get grnItemAddError =>
      'आइटम नहीं जोड़ा जा सका। कृपया फिर से प्रयास करें।';

  @override
  String get grnAddItemFirst => 'पोस्ट करने से पहले कम से कम एक आइटम जोड़ें';

  @override
  String get grnPosted => 'GRN पोस्ट हुआ — स्टॉक अपडेट हुआ';

  @override
  String get grnPostQueued => 'कतार में — ऑनलाइन होने पर पोस्ट होगा';

  @override
  String get grnPostError => 'GRN पोस्ट नहीं हो सका। कृपया फिर से प्रयास करें।';

  @override
  String get grnNoItems => 'अभी तक कोई आइटम नहीं जोड़ा गया';

  @override
  String get grnNoItemsHint => 'आइटम जोड़ने के लिए नीचे दिए बटन पर टैप करें';

  @override
  String grnTotalQty(String qty) {
    return 'कुल मात्रा: $qty';
  }

  @override
  String grnTotalValue(String value) {
    return 'कुल: ₹$value';
  }

  @override
  String get grnAddItem => 'आइटम जोड़ें';

  @override
  String get grnPostGrn => 'GRN पोस्ट करें';

  @override
  String get grnPostHint =>
      'पोस्ट करने से स्टॉक अपडेट होता है और कम-स्टॉक अलर्ट हल होते हैं।';

  @override
  String grnInvoiceLabel(String number) {
    return 'इनवॉइस $number';
  }

  @override
  String grnBatchTag(String batch) {
    return 'बैच $batch';
  }

  @override
  String get grnBarcodeLabel => 'बारकोड (EAN / UPC)';

  @override
  String get grnBarcodeHint => '8–13 अंक';

  @override
  String get grnProductNameLabel => 'उत्पाद का नाम';

  @override
  String get grnMustBePositive => '0 से अधिक होना चाहिए';

  @override
  String get grnBatchNumberOptional => 'बैच नंबर (वैकल्पिक)';

  @override
  String get grnMfgDateLabel => 'निर्माण तिथि';

  @override
  String get grnExpiryDateLabel => 'एक्सपायरी तिथि';

  @override
  String get grnUnitPriceLabel => 'इकाई मूल्य (₹)';

  @override
  String get grnMustBeNonNeg => '0 या अधिक होना चाहिए';
}
