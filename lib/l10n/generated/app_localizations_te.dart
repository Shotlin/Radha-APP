// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'RADHA';

  @override
  String get tagline => 'డేటా, ఆరోగ్యం మరియు ఆడిట్‌ల కోసం రిటైల్ అసిస్టెంట్.';

  @override
  String get continueLabel => 'కొనసాగించు';

  @override
  String get getStarted => 'ప్రారంభించండి';

  @override
  String get skip => 'దాటవేయి';

  @override
  String get next => 'తదుపరి';

  @override
  String get back => 'వెనుకకు';

  @override
  String get cancel => 'రద్దు చేయి';

  @override
  String get save => 'సేవ్ చేయి';

  @override
  String get delete => 'తొలగించు';

  @override
  String get edit => 'సవరించు';

  @override
  String get add => 'జోడించు';

  @override
  String get search => 'వెతుకు';

  @override
  String get loading => 'లోడ్ అవుతోంది';

  @override
  String get error => 'ఏదో తప్పు జరిగింది';

  @override
  String get tryAgain => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get done => 'పూర్తయింది';

  @override
  String get close => 'మూసివేయి';

  @override
  String get signIn => 'సైన్ ఇన్ చేయండి';

  @override
  String get signOut => 'సైన్ అవుట్ చేయండి';

  @override
  String get mobileNumber => 'మొబైల్ నంబర్';

  @override
  String get enterOtp => 'OTP నమోదు చేయండి';

  @override
  String get verifyOtp => 'OTP ధృవీకరించండి';

  @override
  String get resendOtp => 'OTP మళ్ళీ పంపండి';

  @override
  String get otpSent => 'మేము మీకు 6-అంకెల కోడ్ పంపాము';

  @override
  String get home => 'హోమ్';

  @override
  String get scan => 'స్కాన్';

  @override
  String get expiry => 'గడువు';

  @override
  String get tasks => 'పనులు';

  @override
  String get profile => 'ప్రొఫైల్';

  @override
  String get settings => 'సెట్టింగ్‌లు';

  @override
  String get language => 'భాష';

  @override
  String get scanProduct => 'ఉత్పత్తిని స్కాన్ చేయండి';

  @override
  String get pointAtBarcode => 'మీ కెమెరాను బార్‌కోడ్ వద్ద ఉంచండి';

  @override
  String get scanAgain => 'మళ్ళీ స్కాన్ చేయండి';

  @override
  String get productNotFound => 'ఉత్పత్తి కనుగొనబడలేదు';

  @override
  String get expiryTracker => 'గడువు ట్రాకర్';

  @override
  String get addExpiry => 'గడువు జోడించు';

  @override
  String get expiringSoon => 'త్వరలో గడువు ముగుస్తుంది';

  @override
  String get expired => 'గడువు ముగిసింది';

  @override
  String get yourTasks => 'మీ పనులు';

  @override
  String get noTasks => 'ఇంకా పనులు లేవు';

  @override
  String get completeTask => 'పనిని పూర్తి చేయండి';

  @override
  String get welcome => 'స్వాగతం';

  @override
  String get welcomeMessage =>
      'స్ప్రెడ్‌షీట్‌లు లేకుండా మీ స్టాక్‌ను స్కాన్, ట్రాక్, ఆడిట్ చేయండి.';

  @override
  String get referrals => 'రిఫరల్‌లు';

  @override
  String get shareYourCode => 'మీ కోడ్‌ను షేర్ చేయండి';

  @override
  String get yourReferralCode => 'మీ రిఫరల్ కోడ్';

  @override
  String get invitees => 'ఆహ్వానితులు';

  @override
  String get rewardsEarned => 'సంపాదించిన బహుమతులు';

  @override
  String get redeemCode => 'కోడ్ రీడీమ్ చేయండి';

  @override
  String get enterReferralCode => 'రిఫరల్ కోడ్ నమోదు చేయండి';

  @override
  String get chooseLanguage => 'భాషను ఎంచుకోండి';

  @override
  String get languageUpdated => 'భాష నవీకరించబడింది';

  @override
  String get errorGeneric => 'ఏదో తప్పు జరిగింది. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String errorRateLimitOtp(int seconds) {
    return 'చాలా ఎక్కువ OTP అభ్యర్థనలు. $seconds సెకన్లలో మళ్ళీ ప్రయత్నించండి.';
  }

  @override
  String get errorOtpInvalid => 'OTP తప్పు. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get errorOtpExpired =>
      'OTP గడువు ముగిసింది. కొత్తదాన్ని అభ్యర్థించండి.';

  @override
  String get errorAuthRequired => 'కొనసాగించడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get errorNotFound => 'కనుగొనబడలేదు.';

  @override
  String get ingredientExplainerErrorTitle => 'వివరణను లోడ్ చేయలేకపోయాము';

  @override
  String get ingredientExplainerHealthConsiderations => 'ఆరోగ్య పరిగణనలు';

  @override
  String healthyAlternativesTitle(String productName) {
    return '$productName కంటే మంచి ఎంపికలు';
  }

  @override
  String get healthyAlternativesGenericTitle => 'మంచి ఎంపికలు';

  @override
  String get healthyAlternativesEmptyTitle =>
      'ఆరోగ్యకరమైన ప్రత్యామ్నాయాలు ఇంకా లేవు';

  @override
  String get healthyAlternativesEmptyBody =>
      'ఇదే వర్గంలో ఇంకా ఆరోగ్యకరమైన ప్రత్యామ్నాయాలు దొరకలేదు.';

  @override
  String get healthyAlternativesErrorTitle =>
      'ప్రత్యామ్నాయాలను లోడ్ చేయలేకపోయాము';

  @override
  String get healthyAlternativesAddToList => 'షాపింగ్ జాబితాకు జోడించు';

  @override
  String get healthyAlternativesView => 'చూడు';

  @override
  String get healthyAlternativesAddedToList => 'షాపింగ్ జాబితాకు జోడించబడింది';

  @override
  String get healthyAlternativesAddFailed =>
      'షాపింగ్ జాబితాకు జోడించడం సాధ్యం కాలేదు';

  @override
  String get savedProductsTitle => 'సేవ్ చేసిన ఉత్పత్తులు';

  @override
  String get savedProductsEmptyTitle => 'సేవ్ చేసిన ఉత్పత్తులు';

  @override
  String get savedProductsEmptyBody =>
      'స్కాన్ ఫలితం స్క్రీన్ నుండి ఉత్పత్తులను సేవ్ చేయండి, అవి ఇక్కడ కనిపిస్తాయి.';

  @override
  String get savedProductsErrorTitle =>
      'సేవ్ చేసిన ఉత్పత్తులను లోడ్ చేయలేకపోయాము';

  @override
  String savedProductsSavedOn(String date) {
    return '$date న సేవ్ చేయబడింది';
  }

  @override
  String get digestTitle => 'RADHA తో మీ వారం';

  @override
  String digestWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String digestSavingsHero(String amount) {
    return '₹$amount ఆదా';
  }

  @override
  String digestScansHero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count స్కాన్‌లు',
      one: '1 స్కాన్',
    );
    return '$_temp0';
  }

  @override
  String get digestHeroEmptyHeadline => 'ప్రశాంత వారం';

  @override
  String get digestScans => 'స్కాన్‌లు';

  @override
  String get digestSavedProducts => 'సేవ్ చేసినవి';

  @override
  String get digestExpiringSoon => 'త్వరలో గడువు';

  @override
  String digestRecallAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రీకాల్ అలర్ట్‌లు',
      one: '1 రీకాల్ అలర్ట్',
    );
    return '$_temp0';
  }

  @override
  String get digestRecallAlertsBody =>
      'ఈ వారం మీరు స్కాన్ చేసిన ఉత్పత్తులకు కొత్త భద్రతా సూచనలు ఉన్నాయి.';

  @override
  String get digestRecallAlertsCta => 'సమీక్షించండి';

  @override
  String get digestTopCategoriesHeader => 'మీరు ఏం స్కాన్ చేస్తున్నారు';

  @override
  String get digestHighlightsHeader => 'ముఖ్యాంశాలు';

  @override
  String get digestContinueScanning => 'స్కాన్ కొనసాగించండి';

  @override
  String get digestShare => 'నా వారాన్ని షేర్ చేయండి';

  @override
  String digestShareTemplate(int scans, String savings) {
    return 'ఈ వారం నేను $scans ఉత్పత్తులను స్కాన్ చేసి RADHA తో ₹$savings ఆదా చేశాను. మీరు కూడా ప్రయత్నించండి: https://radha.app';
  }

  @override
  String get digestEmptyTitle => 'ఈ వారం ఏ కార్యకలాపం లేదు';

  @override
  String get digestEmptyBody =>
      'మీ వారపు కథను నిర్మించడానికి స్కాన్ చేయడం ప్రారంభించండి.';

  @override
  String get digestErrorTitle => 'వారపు సారాంశాన్ని లోడ్ చేయలేకపోయాము';

  @override
  String get settingsTitle => 'సెట్టింగ్‌లు';

  @override
  String get settingsNotifications => 'నోటిఫికేషన్‌లు';

  @override
  String get settingsPushNotifications => 'పుష్ నోటిఫికేషన్‌లు';

  @override
  String get settingsPushNotificationsHint => 'మీ ఫోన్‌లో అలర్ట్‌లను పొందండి';

  @override
  String get settingsRecallAlerts => 'రీకాల్ అలర్ట్‌లు';

  @override
  String get settingsRecallAlertsHint =>
      'మీరు స్కాన్ చేసిన ఉత్పత్తి రీకాల్ అయితే తెలియజేస్తాం';

  @override
  String get settingsWeeklyDigest => 'వారపు సారాంశం';

  @override
  String get settingsWeeklyDigestHint =>
      'ఆదివారం మీ స్కాన్‌లు మరియు పొదుపుల సారాంశం';

  @override
  String get settingsAppearance => 'రూపం';

  @override
  String get settingsTheme => 'థీమ్';

  @override
  String get settingsThemeSystem => 'సిస్టమ్';

  @override
  String get settingsThemeLight => 'లైట్';

  @override
  String get settingsThemeDark => 'డార్క్';

  @override
  String get settingsLanguage => 'భాష';

  @override
  String get settingsTextSize => 'టెక్స్ట్ పరిమాణం';

  @override
  String get settingsTextSizeSmall => 'చిన్న';

  @override
  String get settingsTextSizeStandard => 'ప్రామాణికం';

  @override
  String get settingsTextSizeLarge => 'పెద్ద';

  @override
  String get settingsDataPrivacy => 'డేటా & గోప్యత';

  @override
  String get settingsAllergens => 'అలెర్జీ ప్రొఫైల్';

  @override
  String get settingsAllergensHint =>
      'మనం హెచ్చరించాల్సిన పదార్థాలను ఎంచుకోండి';

  @override
  String get settingsSignOutAll => 'అన్ని పరికరాల నుండి సైన్ అవుట్ చేయండి';

  @override
  String get settingsSignOutAllConfirmTitle => 'ప్రతిచోటి నుంచీ సైన్ అవుట్?';

  @override
  String get settingsSignOutAllConfirmBody =>
      'ఈ ఖాతాను ఉపయోగించే ప్రతి పరికరంలోనూ మళ్లీ సైన్ ఇన్ చేయాలి.';

  @override
  String get settingsDeleteAccount => 'ఖాతాను తొలగించండి';

  @override
  String get settingsDeleteAccountTitle => 'ఖాతాను తొలగించండి';

  @override
  String get settingsDeleteAccountBody =>
      'ఇది మీ డేటాను శాశ్వతంగా తొలగిస్తుంది. ధృవీకరించడానికి DELETE అని టైప్ చేయండి.';

  @override
  String get settingsDeleteAccountConfirm => 'DELETE';

  @override
  String get settingsDeleteAccountUnavailable =>
      'మీ ఖాతాను తొలగించడానికి సహాయాన్ని సంప్రదించండి.';

  @override
  String get settingsDeleteAccountContact => 'సహాయాన్ని సంప్రదించండి';

  @override
  String get settingsAbout => 'గురించి';

  @override
  String get settingsTerms => 'సేవా నిబంధనలు';

  @override
  String get settingsPrivacyPolicy => 'గోప్యతా విధానం';

  @override
  String get settingsVersion => 'యాప్ సంస్కరణ';

  @override
  String settingsVersionValue(String version, String build) {
    return 'సంస్కరణ $version ($build)';
  }

  @override
  String get settingsSupport => 'సహాయం';

  @override
  String get settingsSupportHint =>
      'సహాయం పొందండి, బగ్‌ను నివేదించండి, లేదా ఫీడ్‌బ్యాక్ ఇవ్వండి';

  @override
  String get settingsLinkOpenFailed => 'లింక్‌ను తెరవలేకపోయాము';

  @override
  String conflictBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count వైరుధ్యాలకు మీ దృష్టి అవసరం',
      one: '1 వైరుధ్యానికి మీ దృష్టి అవసరం',
    );
    return '$_temp0';
  }

  @override
  String get conflictBannerCta => 'పరిష్కరించండి';

  @override
  String get conflictBannerDismiss => 'మూసివేయి';

  @override
  String get conflictResolveTitle => 'సింక్ వైరుధ్యాలను పరిష్కరించండి';

  @override
  String get conflictResolveSubtitle =>
      'ప్రతి అంశానికి ఏ సంస్కరణను ఉంచాలో ఎంచుకోండి.';

  @override
  String get conflictUseMine => 'నా సంస్కరణను ఉంచు';

  @override
  String get conflictUseServer => 'సర్వర్ సంస్కరణను ఉంచు';

  @override
  String get conflictResolved => 'వైరుధ్యం పరిష్కరించబడింది';

  @override
  String get conflictResolvedAll => 'అన్ని వైరుధ్యాలు పరిష్కరించబడ్డాయి';

  @override
  String conflictAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సార్లు ప్రయత్నించబడింది',
      one: '1 సారి ప్రయత్నించబడింది',
    );
    return '$_temp0';
  }

  @override
  String get conflictResourceTask => 'పని';

  @override
  String get conflictResourceExpiry => 'గడువు రికార్డ్';

  @override
  String get conflictResourceScan => 'స్కాన్';

  @override
  String get conflictResourceInventory => 'స్టాక్ సర్దుబాటు';

  @override
  String get conflictResourceGrn => 'GRN ఎంట్రీ';

  @override
  String get conflictResourceShoppingList => 'షాపింగ్ జాబితా అంశం';

  @override
  String get conflictResourceGeneric => 'సింక్ మార్పు';

  @override
  String conflictLocalChangeSummary(String summary) {
    return 'మీ మార్పు: $summary';
  }

  @override
  String get supportTitle => 'సహాయం';

  @override
  String get supportContactUs => 'మమ్మల్ని సంప్రదించండి';

  @override
  String get supportEmailUs => 'ఇమెయిల్ పంపండి';

  @override
  String get supportEmailUsHint => 'support@radha.app';

  @override
  String get supportCallUs => 'సహాయానికి కాల్ చేయండి';

  @override
  String get supportCallUsHint => 'సోమ–శుక్ర, ఉదయం 9 – సాయంత్రం 6 IST';

  @override
  String get supportReportBug => 'బగ్‌ను నివేదించండి';

  @override
  String get supportBugDescription => 'ఏం జరిగింది?';

  @override
  String get supportBugDescriptionHint =>
      'సమస్య ఏర్పడినప్పుడు మీరు ఏం చేస్తున్నారో వివరించండి.';

  @override
  String get supportAttachScreenshot => 'స్క్రీన్‌షాట్‌ను జతచేయండి';

  @override
  String get supportScreenshotAttached => 'స్క్రీన్‌షాట్ జతచేయబడింది';

  @override
  String get supportRemoveScreenshot => 'తొలగించు';

  @override
  String get supportSubmit => 'నివేదికను పంపు';

  @override
  String get supportSubmitted => 'ధన్యవాదాలు — మీ నివేదికను అందుకున్నాము.';

  @override
  String get supportSubmitFailed => 'పంపలేకపోయాము. దయచేసి మాకు ఇమెయిల్ పంపండి.';

  @override
  String get supportBugDescriptionRequired => 'ఏమి జరిగిందో వివరించండి.';

  @override
  String get supportFaq => 'తరచుగా అడిగే ప్రశ్నలు';

  @override
  String get supportFaqQ1 => 'బార్‌కోడ్‌ను ఎలా స్కాన్ చేయాలి?';

  @override
  String get supportFaqA1 =>
      'స్కాన్ ట్యాబ్‌ను తెరవండి, కెమెరాను బార్‌కోడ్‌పై ఉంచి స్థిరంగా ఉంచండి. స్పష్టంగా చదివిన క్షణంలో ఉత్పత్తి కనిపిస్తుంది.';

  @override
  String get supportFaqQ2 => 'ఉత్పత్తి డేటాబేస్‌లో లేకపోతే ఏమి?';

  @override
  String get supportFaqA2 =>
      'కనుగొనబడలేదు స్క్రీన్‌లో \"ఉత్పత్తి జోడించు\" నొక్కండి. మీ స్టోర్‌తో అనుసంధానించబడిన కొత్త ఎంట్రీని సృష్టిస్తుంది.';

  @override
  String get supportFaqQ3 => 'నా సబ్‌స్క్రిప్షన్‌ను ఎలా రద్దు చేయాలి?';

  @override
  String get supportFaqA3 =>
      'ప్రొఫైల్ → సబ్‌స్క్రిప్షన్‌కి వెళ్లండి. ఎప్పుడైనా రద్దు చేయవచ్చు; తదుపరి బిల్లింగ్ చక్రం తర్వాత ఛార్జీలు ఉండవు.';

  @override
  String get supportFaqQ4 => 'నాకు రీకాల్ అలర్ట్ ఎందుకు కనిపిస్తుంది?';

  @override
  String get supportFaqA4 =>
      'ప్రతి స్కాన్‌ను FSSAI రీకాల్ ఫీడ్‌తో పోలుస్తాము. మీరు అమ్మిన బ్యాచ్ జాబితాలో ఉంటే మీకు తెలియజేస్తాము.';

  @override
  String get supportFaqQ5 =>
      'నా అలెర్జీ ప్రొఫైల్‌ను కుటుంబంతో ఎలా షేర్ చేయాలి?';

  @override
  String get supportFaqA5 =>
      'ప్రస్తుతం అలెర్జీ ప్రొఫైల్ ప్రతి ఖాతాకు ఒకటే. ఒకే గృహ ఖాతాలో సైన్ ఇన్ చేయండి లేదా ప్రతి ఫోన్‌లో ఒకే అలెర్జీలను ఎంచుకోండి.';

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
  String get expiryTabNear => 'త్వరలో గడువు';

  @override
  String get expiryTabSafe => 'సురక్షితం';

  @override
  String get expiryCalendarTooltip => 'క్యాలెండర్ వీక్షణ';

  @override
  String get expiryEmptyExpiredTitle => 'ఏదీ గడువు ముగియలేదు';

  @override
  String get expiryEmptyNearTitle => 'అంతా సవ్యంగా ఉంది';

  @override
  String get expiryEmptyDefaultTitle => 'ఇంకా రికార్డులు లేవు';

  @override
  String get expiryEmptyBody => 'ఈ విభాగంలో రికార్డులు లేవు.';

  @override
  String expiryProductShort(String id) {
    return 'ఉత్పత్తి $id';
  }

  @override
  String expiryBatch(String batch) {
    return 'బ్యాచ్ $batch';
  }

  @override
  String expiryQty(String qty) {
    return 'పరిమాణం $qty';
  }

  @override
  String expiryExp(String date) {
    return 'గడువు $date';
  }

  @override
  String get expiryPillToday => 'ఈ రోజు';

  @override
  String get expiryPillTomorrow => 'రేపు';

  @override
  String expiryPillDays(int days) {
    return '${days}d';
  }

  @override
  String get expiryPillSoon => 'త్వరలో';

  @override
  String get expiryLoadError => 'గడువు రికార్డులను లోడ్ చేయలేకపోయాం.';

  @override
  String get expiryCouldNotLoadSemantic => 'లోడ్ చేయలేకపోయాం';

  @override
  String get inventoryTitle => 'ఇన్వెంటరీ';

  @override
  String get inventorySearchTooltip => 'ఇన్వెంటరీ శోధించండి';

  @override
  String get inventorySearchHint => 'ఉత్పత్తి లేదా EAN ద్వారా శోధించండి...';

  @override
  String get inventoryStockMovement => 'స్టాక్ కదలిక';

  @override
  String get inventoryLowStockAlerts => 'తక్కువ స్టాక్ హెచ్చరికలు';

  @override
  String get inventoryLoadError => 'ఇన్వెంటరీ లోడ్ చేయడం విఫలమైంది';

  @override
  String get inventoryEmpty => 'ఇన్వెంటరీ అంశాలు ఏవీ కనుగొనబడలేదు';

  @override
  String inventoryNoMatches(String query) {
    return '\"$query\" కోసం సరిపోలికలు లేవు';
  }

  @override
  String inventoryProductShort(String id) {
    return 'ఉత్పత్తి $id';
  }

  @override
  String get inventoryBelowThreshold => 'పరిమితి కంటే తక్కువ';

  @override
  String get inventoryInStock => 'స్టాక్‌లో ఉంది';

  @override
  String get inventoryUnitsLabel => 'యూనిట్లు';

  @override
  String get inventoryTotalQuantity => 'మొత్తం పరిమాణం';

  @override
  String get inventoryLowStockThreshold => 'తక్కువ స్టాక్ పరిమితి';

  @override
  String inventoryQtyUnits(int count) {
    return '$count యూనిట్లు';
  }

  @override
  String get inventoryBatchLedgerHint =>
      'పూర్తి బ్యాచ్ లెడ్జర్ చూడటానికి \"స్టాక్ కదలిక\" నొక్కండి.';

  @override
  String get inventoryLowStockBadge => 'తక్కువ స్టాక్';

  @override
  String get tasksTitle => 'పనులు';

  @override
  String get tasksTabMine => 'నా పనులు';

  @override
  String get tasksTabAll => 'అన్నీ';

  @override
  String get tasksNewTask => 'కొత్త పని';

  @override
  String get tasksEmptyTitle => 'ఇక్కడ పనులు లేవు';

  @override
  String get tasksEmptyBody => 'ఈ వీక్షణకు కేటాయించిన పనులు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get tasksLoadError => 'పనులను లోడ్ చేయడం విఫలమైంది';

  @override
  String get taskEvidence => 'సాక్ష్యం';

  @override
  String get priorityHigh => 'అధిక';

  @override
  String get priorityMedium => 'మధ్యస్థ';

  @override
  String get priorityLow => 'తక్కువ';

  @override
  String get priorityUrgent => 'అత్యవసరం';

  @override
  String get taskStatusOpen => 'తెరిచి ఉంది';

  @override
  String get taskStatusPending => 'పెండింగ్‌లో';

  @override
  String get taskStatusInProgress => 'పురోగతిలో ఉంది';

  @override
  String get taskStatusCompleted => 'పూర్తయింది';

  @override
  String get taskStatusCancelled => 'రద్దు చేయబడింది';

  @override
  String get scanTitle => 'ఉత్పత్తిని స్కాన్ చేయండి';

  @override
  String get scanAlignHint => 'బార్‌కోడ్‌ను ఫ్రేమ్‌లో సరిచేయండి';

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
      'బ్యాచ్ మోడ్ — స్కాన్ చేస్తూ ఉండండి, అంశాలు ఆటోమేటిక్‌గా జోడించబడతాయి';

  @override
  String scanBatchAdded(String code, int count) {
    return '$code జోడించబడింది · $count స్కాన్ చేయబడ్డాయి';
  }

  @override
  String scanBatchDone(int count) {
    return 'పూర్తయింది · $count';
  }

  @override
  String get scanLabelAction => 'లేబుల్ స్కాన్';

  @override
  String get scanGalleryAction => 'గ్యాలరీ';

  @override
  String get scanEnterManually => 'మాన్యువల్‌గా నమోదు చేయండి';

  @override
  String get scanBulkAudit => 'బల్క్ ఆడిట్';

  @override
  String get scanHistoryAction => 'చరిత్ర';

  @override
  String get scanFlash => 'ఫ్లాష్';

  @override
  String get scanTroubleTitle => 'స్కాన్ చేయడంలో సమస్యా?';

  @override
  String get scanTroubleBody =>
      'తక్కువ వెలుతురు లేదా దెబ్బతిన్న బార్‌కోడా? ఫ్లాష్ ఆన్ చేయండి, లేదా బదులుగా లేబుల్ చదవండి.';

  @override
  String get scanGalleryNoBarcode =>
      'బార్‌కోడ్ కనుగొనబడలేదు. చిట్కా: పదార్థాలను చదవడానికి \'లేబుల్ స్కాన్\' ఉపయోగించండి.';

  @override
  String get scanInvalidEan =>
      'చెల్లుబాటు అయ్యే EAN-8, EAN-13, లేదా UPC-A కోడ్‌ను నమోదు చేయండి';

  @override
  String get scanWebTitle => 'స్కాన్';

  @override
  String get scanWebUnavailable =>
      'వెబ్‌లో కెమెరా స్కానింగ్ అందుబాటులో లేదు.\nబార్‌కోడ్‌ను మాన్యువల్‌గా నమోదు చేయండి:';

  @override
  String get scanEanFieldLabel => 'EAN / UPC కోడ్';

  @override
  String get scanEanHintExample => 'ఉదా. 5901234123457';

  @override
  String get scanLookUp => 'వెతకండి';

  @override
  String get scanEnterBarcode => 'బార్‌కోడ్‌ను నమోదు చేయండి';

  @override
  String get scanHistoryTitle => 'స్కాన్ చరిత్ర';

  @override
  String get scanNoHistory => 'ఈ సెషన్‌లో ఇంకా స్కాన్‌లు లేవు.';

  @override
  String get homeGreetingMorning => 'శుభోదయం';

  @override
  String get homeGreetingAfternoon => 'శుభ మధ్యాహ్నం';

  @override
  String get homeGreetingEvening => 'శుభ సాయంత్రం';

  @override
  String get homeGreetingFallbackName => 'మిత్రమా';

  @override
  String get homeTrialEnded =>
      'ఉచిత ట్రయల్ ముగిసింది — యాక్సెస్ కొనసాగించడానికి అప్‌గ్రేడ్ చేయండి';

  @override
  String homeTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days రోజులు',
      one: '1 రోజు',
    );
    return 'ఉచిత ట్రయల్ · $_temp0 మిగిలి ఉంది';
  }

  @override
  String get homeUpgradeArrow => 'అప్‌గ్రేడ్ →';

  @override
  String get homeKpiSaved => 'సేవ్ చేసినవి';

  @override
  String get homeKpiNearExpiry => 'త్వరలో గడువు';

  @override
  String get homeKpiRecallAlerts => 'రీకాల్ హెచ్చరికలు';

  @override
  String get homeKpiOpenTasks => 'తెరిచిన పనులు';

  @override
  String get homeKpiLowStock => 'తక్కువ స్టాక్';

  @override
  String get homeEyebrowFoodSafety => 'ఆహార భద్రత హెచ్చరిక';

  @override
  String get homeEyebrowToday => 'నేటి పని';

  @override
  String get homeEyebrowHealthScan => 'మీ హెల్త్ స్కాన్';

  @override
  String get homeEyebrowScanToLearn => 'స్కాన్ చేసి తెలుసుకోండి';

  @override
  String get homeEyebrowAllClear => 'అంతా సవ్యంగా ఉంది';

  @override
  String homeStoryRecall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రీకాల్ చేయబడిన ఉత్పత్తులు — మీ ఇంట్లో ఏముందో చూడండి',
      one: '1 రీకాల్ చేయబడిన ఉత్పత్తి — మీ ఇంట్లో ఏముందో చూడండి',
    );
    return '$_temp0';
  }

  @override
  String homeStoryNearExpiryConsumer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సేవ్ చేసిన అంశాలు ఈ వారం గడువు ముగుస్తాయి — వాడేయండి',
      one: '1 సేవ్ చేసిన అంశం ఈ వారం గడువు ముగుస్తుంది — వాడేయండి',
    );
    return '$_temp0';
  }

  @override
  String get homeStoryKnowWhatYouEat => 'మీరు తినేది తెలుసుకోండి';

  @override
  String get homeStoryScanInside =>
      'ఏదైనా ఆహార బార్‌కోడ్‌పై కెమెరా ఉంచండి — లోపల ఏముందో చూడండి';

  @override
  String homeStoryNearExpiryBusiness(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అంశాలు త్వరలో గడువు — షెల్ఫ్ క్లియర్ చేయండి',
      one: '1 అంశం త్వరలో గడువు — షెల్ఫ్ క్లియర్ చేయండి',
    );
    return '$_temp0';
  }

  @override
  String homeStoryOpenTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పనులకు ఈ రోజు మీరు అవసరం',
      one: '1 పనికి ఈ రోజు మీరు అవసరం',
    );
    return '$_temp0';
  }

  @override
  String homeStoryLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అంశాల స్టాక్ తక్కువగా ఉంది',
      one: '1 అంశం స్టాక్ తక్కువగా ఉంది',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreToday => 'ఇదిగో ఈ రోజు మీ స్టోర్';

  @override
  String get homeStoreAllGood => 'శభాష్! మీ స్టోర్ ఈ రోజు చక్కటి స్థితిలో ఉంది';

  @override
  String get homeCtaViewRecallAlerts => 'రీకాల్ హెచ్చరికలను చూడండి';

  @override
  String get homeCtaCheckExpiry => 'గడువును చూడండి';

  @override
  String get homeCtaOpenExpiry => 'గడువును తెరవండి';

  @override
  String get homeCtaViewTasks => 'పనులను చూడండి';

  @override
  String get homeCtaCheckInventory => 'ఇన్వెంటరీని చూడండి';

  @override
  String get homeCtaOpenTasks => 'పనులను తెరవండి';

  @override
  String get homeCtaRunAudit => 'ఒక శీఘ్ర ఆడిట్ అమలు చేయండి';

  @override
  String get homeQuickActions => 'శీఘ్ర చర్యలు';

  @override
  String get homeQuickScan => 'స్కాన్';

  @override
  String get homeQuickShopping => 'షాపింగ్';

  @override
  String get homeQuickAddExpiry => 'గడువు జోడించండి';

  @override
  String get homeQuickNewTask => 'కొత్త పని';

  @override
  String get homeRecentTasks => 'ఇటీవలి పనులు';

  @override
  String get homeSeeAll => 'అన్నీ చూడండి';

  @override
  String get homeNoOpenTasks => 'తెరిచిన పనులు లేవు — ఒకటి సృష్టించండి';

  @override
  String homeTaskAssignedTo(String name) {
    return '$name కి కేటాయించబడింది';
  }

  @override
  String get homeTaskOverdue => 'గడువు మించింది';

  @override
  String get homeTaskDueToday => 'ఈ రోజు గడువు';

  @override
  String get homeTaskDueTomorrow => 'రేపు గడువు';

  @override
  String homeTaskDueInDays(int days) {
    return '$days రోజుల్లో గడువు';
  }

  @override
  String homeTaskDueOn(String date) {
    return 'గడువు $date';
  }

  @override
  String get homeHowHelps => 'RADHA మీకు ఎలా సహాయపడుతుంది';

  @override
  String get homeScanBarcodeTitle => 'ఏదైనా ఆహార బార్‌కోడ్‌ను స్కాన్ చేయండి';

  @override
  String get homeScanBarcodeBody =>
      'హెల్త్ రేటింగ్, పదార్థాలు, దేని గురించి జాగ్రత్త వహించాలి — అన్నీ చూడండి.';

  @override
  String get homeRecallTitle => 'భద్రతా రీకాల్ హెచ్చరికలు';

  @override
  String get homeRecallBody =>
      'రీకాల్ చేయబడిన ఆహార ఉత్పత్తుల గురించి తెలుసుకోండి.';

  @override
  String get homePromoKnowFoodEyebrow => 'మీ ఆహారాన్ని తెలుసుకోండి';

  @override
  String get homePromoKnowFoodHeadline =>
      'లేబుల్ స్కాన్ చేయండి — నిజంగా లోపల ఏముందో చూడండి';

  @override
  String get homePromoKnowFoodCta => 'స్కాన్ చేసి తెలుసుకోండి';

  @override
  String get homePromoExpiryEyebrow => 'ఏ తేదీని మిస్ కాకండి';

  @override
  String get homePromoExpiryHeadline => 'ప్రతి గడువును జారిపోకముందే పట్టుకోండి';

  @override
  String get homePromoExpiryCta => 'గడువును ట్రాక్ చేయండి';

  @override
  String get homePromoFestiveEyebrow => 'పండుగ ఎంపికలు';

  @override
  String get homePromoFestiveHeadline =>
      'సీజన్‌ను ఆరోగ్యకరమైన మార్గంలో షాపింగ్ చేయండి';

  @override
  String get homePromoFestiveCta => 'ఉత్పత్తులను బ్రౌజ్ చేయండి';

  @override
  String get homePromoBazaarEyebrow => 'నేటి బజార్';

  @override
  String get homePromoBazaarHeadline => 'నిమిషాల్లో మీ షెల్ఫ్‌లను ఆడిట్ చేయండి';

  @override
  String get homePromoBazaarCta => 'ఆడిట్ ప్రారంభించండి';

  @override
  String get homeShopByCategory => 'వర్గం వారీగా షాపింగ్ చేయండి';

  @override
  String get homeShopByCategorySubtitle =>
      'స్కాన్ చేయడానికి లేదా బ్రౌజ్ చేయడానికి ఒక విభాగాన్ని నొక్కండి';

  @override
  String get onboardingWelcomeValue =>
      'స్కాన్ చేయండి, ట్రాక్ చేయండి, మీ స్టాక్‌ను ఆడిట్ చేయండి — స్ప్రెడ్‌షీట్‌లు లేకుండా.';

  @override
  String get onboardingCapabilitiesTitle =>
      'షాప్ ఫ్లోర్ కోసం రూపొందించబడింది,\nబ్యాక్ ఆఫీస్ కోసం కాదు.';

  @override
  String get onboardingCapScanTitle =>
      'ఒక్క ట్యాప్‌లో ఉత్పత్తులను స్కాన్ చేయండి';

  @override
  String get onboardingCapScanBody =>
      'హెల్త్ మరియు ఆమోదం ముందుగా తనిఖీ చేయబడిన EAN లుకప్.';

  @override
  String get onboardingCapExpiryTitle =>
      'మీకు నష్టం కలిగించక ముందే గడువును పట్టుకోండి';

  @override
  String get onboardingCapExpiryBody =>
      'OCR-సహాయక తేదీలు మరియు వర్గం వారీ పరిమితులు.';

  @override
  String get onboardingCapAuditTitle =>
      'బృందం పూర్తి చేయగల ఆడిట్‌లను అమలు చేయండి';

  @override
  String get onboardingCapAuditBody =>
      'పనులు, సాక్ష్యం మరియు బల్క్ స్కాన్ సెషన్‌లు.';

  @override
  String get onboardingSegmentTitle => 'మీరు ఇక్కడ ఎవరిగా ఉన్నారు?';

  @override
  String get onboardingSegmentSubtitle =>
      'దగ్గరగా సరిపోయేదాన్ని ఎంచుకోండి. తర్వాత సెట్టింగ్‌లలో మార్చవచ్చు.';

  @override
  String get segmentPersonalTitle => 'వ్యక్తిగత';

  @override
  String get segmentPersonalBody => 'నా కోసమే షాపింగ్';

  @override
  String get segmentParentTitle => 'తల్లిదండ్రి';

  @override
  String get segmentParentBody => 'నా కుటుంబం / పిల్లల కోసం షాపింగ్';

  @override
  String get segmentBusinessTitle => 'వ్యాపార యజమాని';

  @override
  String get segmentBusinessBody => 'నేను ఒక చిన్న రిటైల్ స్టోర్ నడుపుతున్నాను';

  @override
  String get segmentPharmacyTitle => 'ఫార్మసీ';

  @override
  String get segmentPharmacyBody => 'నేను ఫార్మసీ / కెమిస్ట్ నడుపుతున్నాను';

  @override
  String get segmentInstitutionTitle => 'సంస్థ';

  @override
  String get segmentInstitutionBody => 'పాఠశాల / హాస్టల్ / క్యాంటీన్';

  @override
  String get segmentAuditorTitle => 'ఆడిటర్ (ఆహ్వానించబడిన)';

  @override
  String get segmentAuditorBody => 'నా దగ్గర ఆహ్వాన కోడ్ ఉంది';

  @override
  String get allergenTitle => 'అలెర్జెన్‌లు';

  @override
  String get allergenLoadError => 'మీ అలెర్జెన్ ప్రొఫైల్‌ను లోడ్ చేయలేకపోయాం.';

  @override
  String get allergenHeading => 'మీ అలెర్జెన్‌లు';

  @override
  String get allergenIntro =>
      'మీకు అలెర్జీ కలిగించే వాటిని నొక్కండి. స్కాన్ చేసిన ఉత్పత్తిలో అవి ఉంటే మేము మిమ్మల్ని హెచ్చరిస్తాం.';

  @override
  String allergenTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అలెర్జెన్‌లు ట్రాక్ చేయబడ్డాయి',
      one: '1 అలెర్జెన్ ట్రాక్ చేయబడింది',
    );
    return '$_temp0';
  }

  @override
  String get allergenNoneTracked => 'ఇంకా అలెర్జెన్‌లు ఏవీ ట్రాక్ చేయబడలేదు';

  @override
  String get allergenSavedCleared => 'అలెర్జెన్ ప్రొఫైల్ క్లియర్ చేయబడింది.';

  @override
  String get allergenSaved => 'అలెర్జెన్ ప్రొఫైల్ సేవ్ చేయబడింది.';

  @override
  String get allergenSaveError => 'మీ అలెర్జెన్‌లను సేవ్ చేయలేకపోయాం.';

  @override
  String get allergenPeanut => 'వేరుశెనగ';

  @override
  String get allergenTreeNut => 'చెట్టు గింజలు';

  @override
  String get allergenDairy => 'పాల ఉత్పత్తులు';

  @override
  String get allergenEggs => 'గుడ్లు';

  @override
  String get allergenSoy => 'సోయా';

  @override
  String get allergenWheat => 'గోధుమ';

  @override
  String get allergenFish => 'చేప';

  @override
  String get allergenShellfish => 'షెల్‌ఫిష్';

  @override
  String get allergenSesame => 'నువ్వులు';

  @override
  String get allergenGluten => 'గ్లూటెన్';

  @override
  String get allergenMustard => 'ఆవాలు';

  @override
  String get allergenCelery => 'సెలెరీ';

  @override
  String get allergenLupin => 'లుపిన్';

  @override
  String get allergenMolluscs => 'మొలస్క్‌లు';

  @override
  String get allergenSulphites => 'సల్ఫైట్‌లు';

  @override
  String get commonSuccess => 'విజయం';

  @override
  String lockedFeatureUpgradeTo(String planName) {
    return '$planName కు అప్‌గ్రేడ్ చేయండి';
  }

  @override
  String lockedFeaturePlan(String planName) {
    return 'ఈ ఫీచర్ $planName ప్లాన్‌లో భాగం.';
  }

  @override
  String get lockedFeatureViewPlans => 'ప్లాన్‌లను చూడండి';

  @override
  String get notFoundSemantic => 'పేజీ కనుగొనబడలేదు';

  @override
  String get notFoundTitle => 'ఈ పేజీ తప్పిపోయింది';

  @override
  String get notFoundBody =>
      'మీరు వెతుకుతున్నది మాకు కనుగొనబడలేదు. మిమ్మల్ని తిరిగి హోమ్‌కు తీసుకెళ్తాం.';

  @override
  String get notFoundBackHome => 'హోమ్‌కు తిరిగి';

  @override
  String get commonCouldNotLoad => 'లోడ్ చేయలేకపోయాం';

  @override
  String get sendOtp => 'OTP పంపండి';

  @override
  String get otpUseCode => 'కోడ్ ఉపయోగించండి';

  @override
  String get ohsPickStore =>
      'డాష్‌బోర్డ్ తెరవడానికి ముందు ఒక స్టోర్‌ను ఎంచుకోండి.';

  @override
  String get profileAccount => 'ఖాతా';

  @override
  String get profileManageStores => 'స్టోర్‌లను నిర్వహించండి';

  @override
  String get profileSavedProducts => 'సేవ్ చేసిన ఉత్పత్తులు';

  @override
  String get profileSubscription => 'సబ్‌స్క్రిప్షన్';

  @override
  String get profilePreferences => 'ప్రాధాన్యతలు';

  @override
  String get profileAllergenProfile => 'అలెర్జెన్ ప్రొఫైల్';

  @override
  String get profileShoppingList => 'షాపింగ్ జాబితా';

  @override
  String get recallTitle => 'రీకాల్ హెచ్చరికలు';

  @override
  String recallProductFallback(String id) {
    return 'ఉత్పత్తి $id';
  }

  @override
  String recallDate(String date) {
    return 'వెనక్కి పిలవబడింది $date';
  }

  @override
  String get recallViewProduct => 'ఉత్పత్తి చూడండి';

  @override
  String get recallLoadError => 'రీకాల్‌లను లోడ్ చేయలేకపోయాం.';

  @override
  String get recallEmpty => 'క్రియాశీల రీకాల్‌లు లేవు';

  @override
  String get recallEmptyBody =>
      'నియంత్రణ సంస్థలు జారీ చేసినప్పుడు ఉత్పత్తి రీకాల్ హెచ్చరికలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get referralsLoadError => 'రెఫరల్‌లను లోడ్ చేయలేకపోయాం.';

  @override
  String get referralsCopyCode => 'కోడ్ కాపీ చేయండి';

  @override
  String get referralsShareInvite => 'ఆహ్వానాన్ని షేర్ చేయండి';

  @override
  String get referralsCodeCopied => 'కోడ్ కాపీ చేయబడింది';

  @override
  String get referralsInvitees => 'ఆహ్వానితులు';

  @override
  String get referralsRewardsEarned => 'సంపాదించిన రివార్డ్‌లు';

  @override
  String get referralsCodeRedeemed => 'కోడ్ రిడీమ్ చేయబడింది';

  @override
  String get referralsEnterCode => 'ఒక రెఫరల్ కోడ్‌ను నమోదు చేయండి';

  @override
  String get referralsRedeem => 'రిడీమ్ చేయండి';

  @override
  String get referralsRedeemError => 'కోడ్ రిడీమ్ చేయలేకపోయాం';

  @override
  String get referralsRedeemSubtitle =>
      'స్నేహితుడి ఆహ్వానం ఉందా? క్రింద వారి కోడ్‌ను నమోదు చేయండి.';

  @override
  String get commonClear => 'క్లియర్ చేయి';

  @override
  String get commonShare => 'షేర్ చేయండి';

  @override
  String get healthSugar => 'చక్కెర';

  @override
  String get healthSalt => 'ఉప్పు';

  @override
  String get healthFat => 'కొవ్వు';

  @override
  String get healthProcessed => 'ప్రాసెస్ చేయబడింది';

  @override
  String get healthChildSuitable => 'పిల్లలకు అనుకూలం';

  @override
  String get productDetailsTitle => 'ఉత్పత్తి వివరాలు';

  @override
  String get productDetailLoadError => 'ఈ ఉత్పత్తిని లోడ్ చేయలేకపోయాం';

  @override
  String get productCheckAllergens => 'అలెర్జెన్‌లను తనిఖీ చేయండి';

  @override
  String get productExplainIngredients => 'పదార్థాలను వివరించండి';

  @override
  String get productSeeHealthierOptions => 'ఆరోగ్యకరమైన ఎంపికలను చూడండి';

  @override
  String get productViewHealthyAlternatives =>
      'ఆరోగ్యకర ప్రత్యామ్నాయాలను చూడండి';

  @override
  String get productHealthAssessment => 'ఆరోగ్య అంచనా';

  @override
  String get productNutritionInfo => 'పోషకాహార సమాచారం';

  @override
  String get productAllergenCheck => 'అలెర్జెన్ తనిఖీ';

  @override
  String get productSeeFullExplanation => 'పూర్తి వివరణ చూడండి';

  @override
  String get productHealthierOptions => 'ఆరోగ్యకరమైన ఎంపికలు';

  @override
  String get commonYes => 'అవును';

  @override
  String get nutritionProtein => 'ప్రొటీన్';

  @override
  String get nutritionTotalSugars => 'మొత్తం చక్కెరలు';

  @override
  String get nutritionEnergy => 'శక్తి';

  @override
  String get nutritionTotalFat => 'మొత్తం కొవ్వు';

  @override
  String get nutritionSaturatedFat => 'సంతృప్త కొవ్వు';

  @override
  String get nutritionCarbohydrates => 'కార్బోహైడ్రేట్లు';

  @override
  String get nutritionFibre => 'ఫైబర్';

  @override
  String get nutritionSodium => 'సోడియం';

  @override
  String get nutritionAll => 'అన్ని పోషకాలు';

  @override
  String get nutritionPer100g => '100 గ్రా కు';

  @override
  String get nutritionPer50g => '50 గ్రా కు';

  @override
  String get productDetailSavedAlert =>
      'సేవ్ చేయబడింది — ఇది ఎప్పుడైనా రీకాల్ చేయబడితే మేము మీకు తెలియజేస్తాం.';

  @override
  String get productDetailSaveError =>
      'సేవ్ చేయలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get productDetailWhatYoullLike => 'మీకు ఏది నచ్చుతుంది';

  @override
  String get productDetailWhatConcern => 'మిమ్మల్ని ఏది ఆందోళనపరచాలి';

  @override
  String get productDetailIngredientDeepDive => 'పదార్థాల లోతైన విశ్లేషణ';

  @override
  String get productDetailPersonalisedFlags => 'వ్యక్తిగతీకరించిన ఫ్లాగ్‌లు';

  @override
  String get productDetailAlreadyBought => 'ఇప్పటికే కొన్నారు';

  @override
  String get productDetailScanToUnlock => 'అన్‌లాక్ చేయడానికి స్కాన్ చేయండి';

  @override
  String get productDetailTitle => 'ఉత్పత్తి';

  @override
  String get productDetailSave => 'సేవ్ చేయి';

  @override
  String get productDetailSaved => 'సేవ్ అయింది';

  @override
  String get productDetailHealthNotRated => 'ఆరోగ్య రేటింగ్ ఇంకా రాలేదు';

  @override
  String get productDetailHealthNotRatedBody =>
      'ఈ ఉత్పత్తి యొక్క పూర్తి ఆరోగ్య విశ్లేషణను RADHA లోకి తీసుకు రావడానికి స్కాన్ చేయండి.';

  @override
  String get productDetailHealthLabel => 'RADHA ఆరోగ్య రేటింగ్';

  @override
  String get productDetailHighProtein => 'అధిక ప్రొటీన్';

  @override
  String get productDetailGoodFibre => 'మంచి ఫైబర్';

  @override
  String get productDetailMinimallyProcessed => 'తక్కువ ప్రాసెస్ చేయబడింది';

  @override
  String get productDetailHighSugar => 'అధిక చక్కెర';

  @override
  String get productDetailHighSatFat => 'అధిక సంతృప్త కొవ్వు';

  @override
  String get productDetailHighSodium => 'అధిక సోడియం';

  @override
  String get productDetailUltraProcessed => 'అల్ట్రా-ప్రాసెస్డ్';

  @override
  String get productDetailNutritionNote =>
      'ఉత్పత్తి యొక్క నిజమైన పోషకాహారం (100 గ్రా కి) ఆధారంగా.';

  @override
  String get productDetailKeyNutrients => 'ముఖ్య పోషకాలు';

  @override
  String get productDetailRdaNote =>
      '% రోజువారీ నిర్దేశ తీసుకోవడం (పెద్దవారు).';

  @override
  String get productDetailForYou => 'మీ కోసం';

  @override
  String get productDetailIngredientLockBody =>
      'ప్రతి పదార్థానికి భద్రతా తీర్పుతో వివరణ చూడండి — అది ఏమిటో, ఎందుకు ఉందో, ఆందోళన చెందాల్సిందా అని తెలుసుకోండి.';

  @override
  String get productDetailIngredientError =>
      'ఇప్పుడు ఈ పదార్థాలను వివరించలేకపోయాం.';

  @override
  String get productDetailAllergenLockBody =>
      'ఈ ఉత్పత్తిని మీ సేవ్ చేసిన అలెర్జెన్లు మరియు ఆరోగ్య లక్ష్యాలతో పోల్చండి.';

  @override
  String get productDetailAllergenError => 'ఇప్పుడు వ్యక్తిగతీకరించలేకపోయాం.';

  @override
  String get productDetailNoAllergens =>
      'ఈ ఉత్పత్తిలో అలెర్జెన్లు కనుగొనబడలేదు.';

  @override
  String productDetailAllergenAvoid(String name) {
    return '$name — మీరు దీన్ని నివారిస్తారు';
  }

  @override
  String productDetailUnlockWith(String plan) {
    return '$planతో అన్‌లాక్ చేయండి';
  }

  @override
  String get productDetailWouldYouBuy => 'మీరు ఈ ఉత్పత్తిని కొంటారా?';

  @override
  String get productDetailThanksForSharing => 'పంచుకున్నందుకు ధన్యవాదాలు!';

  @override
  String get productDetailNutritionNotIn => 'పూర్తి పోషకాహారం ఇంకా రాలేదు';

  @override
  String get productDetailNutritionNotInBody =>
      'నిజమైన పోషకాహారం మరియు ఆరోగ్య విశ్లేషణను RADHA లోకి తీసుకు రావడానికి ఈ ఉత్పత్తి బార్‌కోడ్ స్కాన్ చేయండి.';

  @override
  String productDetailShareText(String name) {
    return 'RADHA లో \"$name\" తనిఖీ చేయబడింది.';
  }

  @override
  String productDetailShareTextRated(String name, String rating, String label) {
    return 'RADHA లో \"$name\" తనిఖీ చేయబడింది — RADHA ఆరోగ్య రేటింగ్ $rating/5 ($label).';
  }

  @override
  String get catalogSearchBarLabel => 'మీకు సరిపోయే ఉత్పత్తులు వెతకండి';

  @override
  String get catalogSearchPromptTitle => 'ఒక ఉత్పత్తి వెతకండి';

  @override
  String get catalogSearchPromptBody =>
      'ఆరోగ్య రేటింగ్ మరియు లోపలేమి ఉందో చూడటానికి ఉత్పత్తి పేరు లేదా బ్రాండ్ ద్వారా వెతకండి.';

  @override
  String get commonNo => 'లేదు';

  @override
  String get scanApprovalNotInAudit => 'ఆమోద స్థితి — ఆడిట్‌లో లేదు';

  @override
  String get scanApprovalChecking => 'ఆమోదిత జాబితాను తనిఖీ చేస్తోంది…';

  @override
  String get scanApprovalCheckFailed => 'ఆమోదాన్ని తనిఖీ చేయలేకపోయాం';

  @override
  String get scanApprovalApproved => 'ఆమోదించబడింది — జాబితాలో';

  @override
  String get scanApprovalNoList => 'క్రియాశీల ఆమోదిత జాబితా లేదు';

  @override
  String get scanApprovalInvalidBarcode => 'చెల్లని బార్‌కోడ్';

  @override
  String get scanApprovalNotInList => 'ఆమోదిత జాబితాలో లేదు';

  @override
  String scanApprovalStatus(String label) {
    return 'ఆమోద స్థితి: $label';
  }

  @override
  String get scanResultAddToExpiry => 'గడువుకు జోడించు';

  @override
  String get scanResultAddToStock => 'స్టాక్‌కు జోడించు';

  @override
  String get scanResultSaveToList => 'జాబితాకు సేవ్ చేయి';

  @override
  String get scanResultNoProduct => 'ఉత్పత్తి కనుగొనబడలేదు';

  @override
  String get scanResultScanLabel => 'లేబుల్ స్కాన్ చేయండి';

  @override
  String get auditRecordError =>
      'స్కాన్‌ను రికార్డ్ చేయలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get auditEndError =>
      'ఆడిట్‌ను ముగించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get auditNoStore => 'స్టోర్ కేటాయించబడలేదు';

  @override
  String get auditNoStoreBody =>
      'బల్క్ ఆడిట్‌లు స్టోర్ ఆమోదిత EAN జాబితాకు వ్యతిరేకంగా అమలవుతాయి. మీకు స్టోర్ కేటాయించమని అడ్మిన్‌ను అడగండి, తర్వాత ఆడిట్ కోసం తిరిగి రండి.';

  @override
  String get auditMatched => 'సరిపోలింది';

  @override
  String get auditNotInList => 'జాబితాలో లేదు';

  @override
  String get auditNoList => 'జాబితా లేదు';

  @override
  String get auditInvalid => 'చెల్లదు';

  @override
  String get auditUnchecked => 'తనిఖీ చేయని';

  @override
  String get commonTotal => 'మొత్తం';

  @override
  String get auditEnterScanEan => 'EAN నమోదు చేయండి లేదా స్కాన్ చేయండి';

  @override
  String auditStatus(String label) {
    return 'స్థితి: $label';
  }

  @override
  String get auditStartAuditing => 'ఆడిట్ ప్రారంభించండి';

  @override
  String get auditStartBody =>
      'ఈ స్టోర్ ఆమోదిత జాబితాతో తనిఖీ చేయడానికి పైన EAN స్కాన్ చేయండి లేదా టైప్ చేయండి. ప్రతి ఫలితం సరిపోలింది లేదా జాబితాలో-లేదు స్థితితో ఇక్కడ వస్తుంది.';

  @override
  String get auditTitle => 'బల్క్ EAN ఆడిట్';

  @override
  String get auditEndAction => 'ఆడిట్ ముగించు';

  @override
  String get auditEndingAction => 'ముగుస్తోంది…';

  @override
  String get auditEanInvalid =>
      'చెల్లుబాటు అయ్యే EAN-8, EAN-13, లేదా UPC-A కోడ్ నమోదు చేయండి';

  @override
  String auditEndedSummary(int matched, int notMatched) {
    return 'ఆడిట్ ముగిసింది — $matched సరిపోలాయి, $notMatched జాబితాలో లేవు';
  }

  @override
  String get cameraCapture => 'క్యాప్చర్ చేయి';

  @override
  String get labelScanReadError => 'లేబుల్ చదవలేకపోయాం';

  @override
  String get labelScanReadErrorBody =>
      'మెరుగైన వెలుతురులో మళ్లీ ప్రయత్నించండి, స్థిరంగా పట్టుకోండి, ఫ్రేమ్‌ను పదార్థాల ప్యానెల్‌తో నింపండి.';

  @override
  String get labelScanAnalysisFailed => 'విశ్లేషణ విఫలమైంది';

  @override
  String get labelScanIntro => 'RADHA మీ కోసం లేబుల్‌ను చదువుతుంది';

  @override
  String get labelScanTakePhoto => 'ఫోటో తీయండి';

  @override
  String get labelScanChooseGallery => 'గ్యాలరీ నుండి ఎంచుకోండి';

  @override
  String get labelScanAnother => 'మరొకటి స్కాన్ చేయండి';

  @override
  String labelScanSeePlans(String plan) {
    return '$plan ప్లాన్‌లను చూడండి';
  }

  @override
  String get labelScanMaybeLater => 'బహుశా తర్వాత';

  @override
  String get labelScanTitle => 'లేబల్ స్కాన్ చేయండి';

  @override
  String get labelScanNoBarcode => 'బార్‌కోడ్ లేదా? లేబల్ చదవండి';

  @override
  String get labelScanIdleBody =>
      'పదార్థాల ప్యానెల్ వైపు చూపించండి — మేము చదివి చెప్తాము. బార్‌కోడ్ లేని ఉత్పత్తులకు కూడా పని చేస్తుంది.';

  @override
  String get labelScanFlashNote =>
      'తక్కువ వెలుతురులో కెమెరా ఫ్లాష్ స్వయంచాలకంగా వెలుగుతుంది.';

  @override
  String get labelScanReading => 'లేబల్ చదువుతున్నాము…';

  @override
  String get labelScanAnalyzing => 'పదార్థాలు విశ్లేషిస్తున్నాము…';

  @override
  String get labelScanFallbackError =>
      'ఏదో తప్పు జరిగింది. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get labelScanResultFallback => 'లేబల్ విశ్లేషణ';

  @override
  String get labelScanLowConfidence =>
      'తక్కువ నమ్మకం — స్పష్టమైన ఫోటో మెరుగైన ఫలితం ఇవ్వవచ్చు.';

  @override
  String get labelScanWhatToWatch => 'గమనించాల్సినవి';

  @override
  String get labelScanIngredients => 'పదార్థాలు';

  @override
  String get labelScanDisclaimer =>
      'RADHA AI లేబల్ వచనం నుండి చదివింది. ఖచ్చితమైన సమాచారానికి ప్యాక్ తనిఖీ చేయండి.';

  @override
  String get labelScanUnlockTitle => 'AI లేబల్ రీడింగ్ అన్‌లాక్ చేయండి';

  @override
  String get labelScanUnlockBody =>
      'మేము లేబల్ చదివాం, కానీ పూర్తి విశ్లేషణ ప్రీమియం ఫీచర్.';

  @override
  String scanResultNotFoundBody(String ean) {
    return 'EAN $ean కు క్యాటలాగ్‌లో సరిపోలిక లేదు — కానీ మీరు ఇప్పటికీ లేబుల్ చదవవచ్చు. పదార్థాల ప్యానెల్ ఫోటో తీయండి, లోపల ఏముందో చెబుతాం.';
  }

  @override
  String productScore(String score) {
    return 'స్కోర్: $score';
  }

  @override
  String get catalogSearchHint => 'ఉత్పత్తులు లేదా బ్రాండ్‌లను శోధించండి';

  @override
  String get catalogNoMatches => 'సరిపోలికలు లేవు';

  @override
  String catalogNoMatchesBody(String query) {
    return '“$query” కోసం ఉత్పత్తులు మాకు కనుగొనబడలేదు. వేరే పేరును ప్రయత్నించండి, లేదా అంశాన్ని స్కాన్ చేయండి.';
  }

  @override
  String get browseTitle => 'ఉత్పత్తులు';

  @override
  String get browseLoadError => 'ఉత్పత్తులను లోడ్ చేయలేకపోయాం';

  @override
  String browseLoadErrorBody(String category) {
    return '$category లోడ్ చేయడంలో సమస్య. దయచేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get browseSortHealthiest => 'అత్యంత ఆరోగ్యకరం';

  @override
  String get browseSortAZ => 'A–Z';

  @override
  String get browseFilterVegOnly => 'శాకాహారం మాత్రమే';

  @override
  String get browseVeg => 'వెజ్';

  @override
  String get browseEmptyVeg => 'ఇక్కడ ఇంకా శాకాహార అంశాలు లేవు';

  @override
  String browseEmptyVegBody(String category) {
    return 'ప్రస్తుతం $categoryలో ఏదీ శాకాహార ఫిల్టర్‌కు సరిపోలడం లేదు.';
  }

  @override
  String get browseShowAll => 'అన్నీ చూపించు';

  @override
  String get browseEmpty => 'ఇంకా ఉత్పత్తులు లేవు';

  @override
  String browseEmptyBody(String category) {
    return 'మేము $category విభాగాన్ని నింపుతున్నాం. ఈలోగా, ఏదైనా అంశాన్ని స్కాన్ చేసి దాని ఆరోగ్యం మరియు గడువును తనిఖీ చేయండి.';
  }

  @override
  String referralsShareText(String code) {
    return 'RADHAలో నాతో చేరండి: $code కోడ్ ఉపయోగించండి';
  }

  @override
  String get selectStoreEmpty => 'ఇంకా స్టోర్‌లు లేవు';

  @override
  String get selectStoreEmptyBody =>
      'ఒక స్టోర్‌కు జోడించబడటానికి మీ మేనేజర్‌ను సంప్రదించండి.';

  @override
  String get selectStoreEmptyDetail =>
      'మీ ఖాతా ఇంకా ఏ స్టోర్‌తోనూ అనుబంధించబడలేదు. యాక్సెస్ కోసం మీ మేనేజర్‌ను అడగండి, తర్వాత తిరిగి వచ్చి ఒకదాన్ని ఎంచుకోండి.';

  @override
  String get selectStoreContactManager => 'మీ మేనేజర్‌ను సంప్రదించండి';

  @override
  String get expiryConsumerTitle => 'వ్యాపార ఖాతాలకు';

  @override
  String get expiryConsumerBody =>
      'గడువు ట్రాకింగ్ రిటైల్ స్టోర్ ఫీచర్. దీన్ని ఉపయోగించడానికి మీ ఖాతాను స్టోర్‌తో అనుసంధానించండి.';

  @override
  String get tasksConsumerTitle => 'వ్యాపార ఖాతాలకు';

  @override
  String get tasksConsumerBody =>
      'టాస్క్ నిర్వహణ రిటైల్ స్టోర్ ఫీచర్. దీన్ని ఉపయోగించడానికి మీ ఖాతాను స్టోర్‌తో అనుసంధానించండి.';

  @override
  String get languageSavedLocally => 'భాష స్థానికంగా మాత్రమే సేవ్ చేయబడింది';

  @override
  String languageSavedLocallyError(String error) {
    return 'భాష స్థానికంగా మాత్రమే సేవ్ చేయబడింది: $error';
  }

  @override
  String get signOutConfirmBody =>
      'యాప్‌ను ఉపయోగించడానికి మీరు OTP తో మళ్లీ సైన్ ఇన్ చేయాలి.';

  @override
  String get scanResultTitle => 'స్కాన్ ఫలితం';

  @override
  String scanResultShareMessage(String ean) {
    return 'ఈ ఉత్పత్తిని నేను RADHAలో తనిఖీ చేశాను — బార్‌కోడ్ $ean.';
  }

  @override
  String get scanResultHealthHeading => 'ఆరోగ్యం';

  @override
  String get scanResultAssessmentPending => 'మూల్యాంకనం పెండింగ్‌లో ఉంది';

  @override
  String get scanResultNutritionPending =>
      'ఈ ఉత్పత్తి కేటలాగ్‌లో సరిపోలగానే పోషక సంకేతాలు ఇక్కడ కనిపిస్తాయి. డేటాబేస్‌ను సుసంపన్నం చేయడానికి మరిన్ని వస్తువులను స్కాన్ చేయండి.';

  @override
  String get scanResultExplainIngredients => 'పదార్థాలను వివరించండి';

  @override
  String get scanResultAllergenPrompt =>
      'మీరు నివారించే ఏదైనా స్కాన్ చేసిన ఉత్పత్తిలో ఉంటే తక్షణ హెచ్చరికలు పొందడానికి మీ అలర్జెన్ ప్రొఫైల్‌ను సెటప్ చేయండి.';

  @override
  String scanResultAllergensDeclared(String allergens) {
    return 'Contains: $allergens';
  }

  @override
  String get scanResultNoAllergensDeclared =>
      'No allergens declared on this product\'s label.';

  @override
  String get taskEvidenceRequiredSnack =>
      'ఈ పనిని పూర్తి చేయడానికి సాక్ష్యం అవసరం';

  @override
  String taskMovedTo(String status) {
    return 'పని $status స్థితికి మార్చబడింది';
  }

  @override
  String get taskUpdateError =>
      'పనిని నవీకరించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String taskAssignedTo(String name) {
    return '$name కు కేటాయించబడింది';
  }

  @override
  String taskDueOn(String date) {
    return 'గడువు $date';
  }

  @override
  String get taskPriorityLabel => 'ప్రాధాన్యత';

  @override
  String get taskEvidenceLabel => 'సాక్ష్యం';

  @override
  String get taskEvidencePhotoRequired => 'ఫోటో అవసరం';

  @override
  String get taskEvidenceNotRequired => 'అవసరం లేదు';

  @override
  String taskEvidencePhotosAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఫోటోలు జతచేయబడ్డాయి',
      one: '1 ఫోటో జతచేయబడింది',
    );
    return '$_temp0';
  }

  @override
  String get taskEvidencePhotoNeeded =>
      'ఈ పనిని పూర్తి చేయడానికి ఒక ఫోటో అవసరం';

  @override
  String get taskTimelineCreated => 'సృష్టించబడింది';

  @override
  String get taskTimelineStarted => 'ప్రారంభమైంది';

  @override
  String get taskActionComplete => 'పూర్తి చేయి';

  @override
  String get taskLoadFailed => 'పనిని లోడ్ చేయలేకపోయాం';

  @override
  String get taskDescriptionLabel => 'వివరణ';

  @override
  String get taskTypeLabel => 'రకం';

  @override
  String get taskActionStart => 'ప్రారంభించు';

  @override
  String get taskCreateTitle => 'పనిని సృష్టించు';

  @override
  String get taskCreateCta => 'పనిని సృష్టించు';

  @override
  String get taskCreatedSnack => 'పని సృష్టించబడింది';

  @override
  String get taskCreateError =>
      'పనిని సృష్టించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get taskNotAuthorizedTitle => 'అనుమతి లేదు';

  @override
  String get taskNotAuthorizedBody =>
      'మేనేజర్లు మరియు అడ్మిన్‌లు మాత్రమే పనులను సృష్టించగలరు.';

  @override
  String get taskTitleLabel => 'శీర్షిక';

  @override
  String get taskTitleHint => 'ఉదా. డెయిరీ విభాగం EAN ఆడిట్';

  @override
  String get taskTitleRequired => 'శీర్షిక అవసరం';

  @override
  String get taskDescriptionHint => 'కేటాయించిన వ్యక్తికి ఐచ్ఛిక వివరాలు';

  @override
  String get taskStoreLabel => 'స్టోర్';

  @override
  String get taskAssigneeLabel => 'కేటాయించినవారు (యూజర్ ID)';

  @override
  String get taskAssigneeHint => 'యూజర్ ID నమోదు చేయండి లేదా ఖాళీగా ఉంచండి';

  @override
  String get taskDueDateLabel => 'గడువు తేదీ';

  @override
  String get taskSelectDate => 'తేదీని ఎంచుకోండి';

  @override
  String get taskRequiresEvidence => 'సాక్ష్యం అవసరం';

  @override
  String get taskRequiresEvidenceSubtitle =>
      'పూర్తి చేయడానికి కేటాయించినవారు ఫోటో అప్‌లోడ్ చేయాలి';

  @override
  String get taskTypeEanAudit => 'EAN ఆడిట్';

  @override
  String get taskTypeExpiryCheck => 'గడువు తనిఖీ';

  @override
  String get taskTypeInventoryCount => 'ఇన్వెంటరీ లెక్కింపు';

  @override
  String get taskTypeDisplayVerification => 'డిస్‌ప్లే ధృవీకరణ';

  @override
  String get taskTypeCustom => 'అనుకూలం';

  @override
  String get checkoutStartError =>
      'చెకౌట్ ప్రారంభించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get paymentResponseIncomplete =>
      'చెల్లింపు ప్రతిస్పందన అసంపూర్ణంగా ఉంది.';

  @override
  String get paymentSuccessUpdated =>
      'చెల్లింపు విజయవంతం. ప్లాన్ నవీకరించబడింది.';

  @override
  String get paymentNotVerified => 'చెల్లింపును ధృవీకరించలేకపోయాం.';

  @override
  String get paymentVerifyFailed =>
      'చెల్లింపు ధృవీకరణ విఫలమైంది. దయచేసి మద్దతును సంప్రదించండి.';

  @override
  String get paymentCancelled => 'చెల్లింపు రద్దు చేయబడింది.';

  @override
  String paymentFailed(String message) {
    return 'చెల్లింపు విఫలమైంది: $message';
  }

  @override
  String paymentOpeningWallet(String wallet) {
    return '$wallet తెరుస్తోంది…';
  }

  @override
  String get paymentSheetOpenError => 'చెల్లింపు షీట్‌ను తెరవలేకపోయాం.';

  @override
  String get subscriptionLoadError => 'మీ సబ్‌స్క్రిప్షన్‌ను లోడ్ చేయలేకపోయాం';

  @override
  String get subscriptionLoadErrorBody =>
      'మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'మీరు $plan ప్లాన్‌లో ఉన్నారు';
  }

  @override
  String subscriptionUpgradeTo(String plan) {
    return '$plan కి అప్‌గ్రేడ్ చేయండి';
  }

  @override
  String subscriptionChoosePlan(String plan) {
    return '$plan ఎంచుకోండి';
  }

  @override
  String get subscriptionPopular => 'ప్రముఖం';

  @override
  String get subscriptionPerMonth => '/నెల';

  @override
  String get subscriptionTitle => 'సభ్యత్వం';

  @override
  String get subscriptionHeadline =>
      'RADHA యొక్క పూర్తి సామర్థ్యాన్ని అన్‌లాక్ చేయండి';

  @override
  String get subscriptionChooseAPlan => 'ఒక ప్లాన్ ఎంచుకోండి';

  @override
  String get subscriptionCancelAnytime =>
      'ఎప్పుడైనా రద్దు చేయండి · GST వర్తిస్తుంది';

  @override
  String get subscriptionBillingYearly => 'వార్షిక';

  @override
  String get subscriptionBillingMonthly => 'నెలవారీ';

  @override
  String get versionLoading => 'వెర్షన్ లోడ్ అవుతోంది…';

  @override
  String get versionUnavailable => 'వెర్షన్ అందుబాటులో లేదు';

  @override
  String appVersionBuild(String version, String build) {
    return 'వెర్షన్ $version ($build)';
  }

  @override
  String get shoppingListTitle => 'షాపింగ్ జాబితా';

  @override
  String get shoppingAddItem => 'వస్తువును జోడించు';

  @override
  String get shoppingLoadError => 'మీ జాబితాను లోడ్ చేయలేకపోయాం';

  @override
  String get shoppingLoadErrorBody =>
      'మీ షాపింగ్ జాబితాను లోడ్ చేయలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get shoppingEmptyTitle => 'మీ షాపింగ్ జాబితా ఖాళీగా ఉంది';

  @override
  String get shoppingEmptyBody =>
      'వస్తువును జోడించడానికి ప్లస్ బటన్‌ను నొక్కండి, లేదా ఉత్పత్తి పేజీ నుండి ఆరోగ్యకరమైన ప్రత్యామ్నాయాలను సేవ్ చేయండి.';

  @override
  String get shoppingUpdateError =>
      'వస్తువును నవీకరించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get shoppingDeleteError =>
      'వస్తువును తొలగించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get shoppingAddError =>
      'వస్తువును జోడించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get shoppingAllDone => 'అంతా పూర్తయింది — అన్నీ టిక్ చేయబడ్డాయి';

  @override
  String shoppingRemaining(int remaining, int total) {
    return '$totalలో $remaining కొనాల్సి ఉంది';
  }

  @override
  String shoppingQty(int quantity) {
    return 'పరిమాణం: $quantity';
  }

  @override
  String get shoppingDeleteItem => 'వస్తువును తొలగించు';

  @override
  String get shoppingItemNameLabel => 'వస్తువు పేరు';

  @override
  String get shoppingItemNameHint => 'ఉదా. హోల్ వీట్ బ్రెడ్';

  @override
  String get shoppingItemNameRequired => 'వస్తువు పేరును నమోదు చేయండి';

  @override
  String get shoppingItemNameTooLong => 'దీన్ని 120 అక్షరాలలోపు ఉంచండి';

  @override
  String get shoppingQuantityLabel => 'పరిమాణం (ఐచ్ఛికం)';

  @override
  String get shoppingQuantityInvalid => 'ధన సంఖ్యను నమోదు చేయండి';

  @override
  String get shoppingQuantityTooHigh => 'ఇది అసాధారణంగా ఎక్కువగా ఉంది';

  @override
  String get shoppingAddToList => 'జాబితాకు జోడించు';

  @override
  String get grnTitle => 'స్వీకరించిన సరుకులు';

  @override
  String get grnFilterAll => 'అన్నీ';

  @override
  String get grnFilterDraft => 'డ్రాఫ్ట్';

  @override
  String get grnFilterPendingReview => 'సమీక్ష పెండింగ్';

  @override
  String get grnFilterPosted => 'పోస్ట్ చేయబడింది';

  @override
  String get grnStatusPending => 'పెండింగ్';

  @override
  String get grnEmptyTitle => 'ఇక్కడ GRN లేవు';

  @override
  String get grnEmptyBody =>
      'సరఫరాదారు డెలివరీని నమోదు చేయడానికి గూడ్స్-రిసీవ్డ్ నోట్‌ను సృష్టించండి.';

  @override
  String get grnNew => 'కొత్త GRN';

  @override
  String get grnLoadError => 'GRN-లను లోడ్ చేయలేకపోయాం';

  @override
  String get grnSupplierFallback => 'సరఫరాదారు';

  @override
  String get categoryBiscuits => 'బిస్కెట్లు & స్నాక్స్';

  @override
  String get categoryBreakfast => 'అల్పాహారం & స్ప్రెడ్స్';

  @override
  String get categoryDairy => 'పాల ఉత్పత్తులు & గుడ్లు';

  @override
  String get categoryBeverages => 'పానీయాలు';

  @override
  String get categoryStaples => 'నిత్యావసరాలు & ధాన్యాలు';

  @override
  String get categoryPersonalCare => 'వ్యక్తిగత సంరక్షణ';

  @override
  String get categoryHousehold => 'గృహోపకరణాలు';

  @override
  String get categoryFrozen => 'ఫ్రోజెన్';

  @override
  String get lowStockTitle => 'తక్కువ స్టాక్ హెచ్చరికలు';

  @override
  String get lowStockLoadError => 'హెచ్చరికలను లోడ్ చేయలేకపోయాం';

  @override
  String get lowStockEmpty => 'అన్ని స్టాక్ స్థాయిలు ఆరోగ్యంగా ఉన్నాయి';

  @override
  String lowStockCurrentThreshold(int quantity, int threshold) {
    return 'ప్రస్తుతం: $quantity / పరిమితి: $threshold';
  }

  @override
  String get lowStockRestock => 'తిరిగి స్టాక్ చేయి';

  @override
  String get commonRequired => 'అవసరం';

  @override
  String get commonOptional => 'ఐచ్ఛికం';

  @override
  String get commonQuantity => 'పరిమాణం';

  @override
  String get smTitle => 'స్టాక్ కదలిక';

  @override
  String get smStockIn => 'స్టాక్ ఇన్';

  @override
  String get smStockOut => 'స్టాక్ అవుట్';

  @override
  String get smProductLabel => 'ఉత్పత్తి';

  @override
  String get smProductHint => 'ఉత్పత్తి ID లేదా EAN నమోదు చేయండి';

  @override
  String get smReasonLabel => 'కారణం';

  @override
  String get smSelectReason => 'కారణాన్ని ఎంచుకోండి';

  @override
  String get smBatchLabel => 'బ్యాచ్ నంబర్';

  @override
  String get smExpiryLabel => 'గడువు తేదీ';

  @override
  String get smExpiryOptionalHint => 'ఐచ్ఛికం — ఎంచుకోవడానికి నొక్కండి';

  @override
  String get smNotesLabel => 'గమనికలు';

  @override
  String get smNotesHint => 'ఐచ్ఛిక గమనికలు';

  @override
  String get smRecordIn => 'స్టాక్ ఇన్ నమోదు చేయి';

  @override
  String get smRecordOut => 'స్టాక్ అవుట్ నమోదు చేయి';

  @override
  String get smStockInRecorded => 'స్టాక్-ఇన్ నమోదు చేయబడింది';

  @override
  String get smStockOutRecorded => 'స్టాక్-అవుట్ నమోదు చేయబడింది';

  @override
  String get smRecordError =>
      'స్టాక్ కదలికను నమోదు చేయలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get smInsufficientStock => 'ఈ కదలికకు తగినంత స్టాక్ లేదు';

  @override
  String get smReasonPurchase => 'కొనుగోలు';

  @override
  String get smReasonReturn => 'తిరిగి ఇవ్వడం';

  @override
  String get smReasonAdjustment => 'సర్దుబాటు';

  @override
  String get smReasonTransfer => 'బదిలీ';

  @override
  String get smReasonDamage => 'నష్టం';

  @override
  String get smReasonExpiryRemoval => 'గడువు తొలగింపు';

  @override
  String get smReasonOther => 'ఇతర';

  @override
  String get grnInvoiceDateRequired => 'ఇన్‌వాయిస్ తేదీ అవసరం';

  @override
  String get grnCreateError =>
      'GRN ను సృష్టించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get grnSupplierInvoiceSection => 'సరఫరాదారు & ఇన్‌వాయిస్';

  @override
  String get grnSupplierNameLabel => 'సరఫరాదారు పేరు';

  @override
  String get grnSupplierNameHint => 'సరఫరాదారు పేరును నమోదు చేయండి';

  @override
  String get grnSupplierRequired => 'సరఫరాదారు అవసరం';

  @override
  String get grnInvoiceNumberLabel => 'ఇన్‌వాయిస్ నంబర్';

  @override
  String get grnInvoiceNumberHint => 'ఇన్‌వాయిస్ నంబర్ నమోదు చేయండి';

  @override
  String get grnInvoiceNumberRequired => 'ఇన్‌వాయిస్ నంబర్ అవసరం';

  @override
  String get grnInvoiceDateLabel => 'ఇన్‌వాయిస్ తేదీ *';

  @override
  String get grnExpectedDeliveryLabel => 'ఆశించిన డెలివరీ తేదీ';

  @override
  String get grnCreateDraft => 'డ్రాఫ్ట్ GRN సృష్టించు';

  @override
  String get grnSelectDate => 'తేదీని ఎంచుకోండి';

  @override
  String get expiryCalendarTitle => 'గడువు క్యాలెండర్';

  @override
  String get expiryCalendarLoadError => 'క్యాలెండర్ డేటాను లోడ్ చేయలేకపోయాం.';

  @override
  String get expiryCalendarTapHint => 'వివరాలను చూడటానికి ఒక రోజును నొక్కండి';

  @override
  String get expiryCalendarNoRecords => 'ఈ రోజుకు గడువు రికార్డులు లేవు';

  @override
  String expiryCalendarSummaryFor(String date) {
    return '$date సారాంశం';
  }

  @override
  String get exTitle => 'కొత్త గడువు రికార్డు';

  @override
  String get exMfgAfterExpiry => 'తయారీ తేదీ గడువు తేదీ తర్వాత ఉండకూడదు';

  @override
  String get exSelectMfg => 'తయారీ తేదీని ఎంచుకోండి';

  @override
  String get exSelectExpiry => 'గడువు తేదీని ఎంచుకోండి';

  @override
  String get exExpiryRequired => 'గడువు తేదీ అవసరం';

  @override
  String get exCreated => 'గడువు రికార్డు సృష్టించబడింది';

  @override
  String get exOfflineQueued =>
      'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు — ఆన్‌లైన్‌కు వచ్చినప్పుడు రికార్డు సింక్ అవుతుంది';

  @override
  String get exSubmitError => 'ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get exNotSet => 'సెట్ చేయలేదు';

  @override
  String get exProductIdLabel => 'ఉత్పత్తి ID';

  @override
  String get exProductIdHint =>
      'ఉత్పత్తి ID నమోదు చేయండి లేదా బార్‌కోడ్ స్కాన్ చేయండి';

  @override
  String get exMfgLabel => 'తయారీ తేదీ';

  @override
  String get exExpiryLabel => 'గడువు తేదీ *';

  @override
  String get exBatchLabel => 'బ్యాచ్ నంబర్';

  @override
  String get exLocationLabel => 'స్థానం';

  @override
  String get exLocationHint => 'షెల్ఫ్ / అంగడి వరుస / జోన్';

  @override
  String get exSaveRecord => 'రికార్డును సేవ్ చేయి';

  @override
  String get exOcrSemantic => 'RADHA మీ కోసం తేదీని చదువుతుంది';

  @override
  String get exOcrTitle => 'ప్యాక్ నుండి తేదీని స్కాన్ చేయండి';

  @override
  String get exOcrSubtitle => 'మేము మీ కోసం MFG / EXP చదువుతాము';

  @override
  String get grnItemsTitle => 'GRN వస్తువులు';

  @override
  String get grnItemAdded => 'వస్తువు జోడించబడింది';

  @override
  String get grnItemSavedOffline =>
      'ఆఫ్‌లైన్‌లో సేవ్ చేయబడింది — ఆన్‌లైన్‌కు వచ్చినప్పుడు సింక్ అవుతుంది';

  @override
  String get grnItemAddError =>
      'వస్తువును జోడించలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get grnAddItemFirst =>
      'పోస్ట్ చేయడానికి ముందు కనీసం ఒక వస్తువును జోడించండి';

  @override
  String get grnPosted => 'GRN పోస్ట్ చేయబడింది — స్టాక్ నవీకరించబడింది';

  @override
  String get grnPostQueued =>
      'క్యూలో — ఆన్‌లైన్‌కు వచ్చినప్పుడు పోస్ట్ అవుతుంది';

  @override
  String get grnPostError =>
      'GRN ను పోస్ట్ చేయలేకపోయాం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get grnNoItems => 'ఇంకా వస్తువులు జోడించబడలేదు';

  @override
  String get grnNoItemsHint => 'వస్తువులను జోడించడానికి దిగువ బటన్‌ను నొక్కండి';

  @override
  String grnTotalQty(String qty) {
    return 'మొత్తం పరిమాణం: $qty';
  }

  @override
  String grnTotalValue(String value) {
    return 'మొత్తం: ₹$value';
  }

  @override
  String get grnAddItem => 'వస్తువును జోడించు';

  @override
  String get grnPostGrn => 'GRN పోస్ట్ చేయి';

  @override
  String get grnPostHint =>
      'పోస్ట్ చేయడం స్టాక్‌ను నవీకరిస్తుంది మరియు తక్కువ-స్టాక్ హెచ్చరికలను పరిష్కరిస్తుంది.';

  @override
  String grnInvoiceLabel(String number) {
    return 'ఇన్‌వాయిస్ $number';
  }

  @override
  String grnBatchTag(String batch) {
    return 'బ్యాచ్ $batch';
  }

  @override
  String get grnBarcodeLabel => 'బార్‌కోడ్ (EAN / UPC)';

  @override
  String get grnBarcodeHint => '8–13 అంకెలు';

  @override
  String get grnProductNameLabel => 'ఉత్పత్తి పేరు';

  @override
  String get grnMustBePositive => '0 కంటే ఎక్కువ ఉండాలి';

  @override
  String get grnBatchNumberOptional => 'బ్యాచ్ నంబర్ (ఐచ్ఛికం)';

  @override
  String get grnMfgDateLabel => 'తయారీ తేదీ';

  @override
  String get grnExpiryDateLabel => 'గడువు తేదీ';

  @override
  String get grnUnitPriceLabel => 'యూనిట్ ధర (₹)';

  @override
  String get grnMustBeNonNeg => '0 లేదా అంతకంటే ఎక్కువ ఉండాలి';
}
