// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Mapato Binafsi';

  @override
  String get appSubtitle => 'Usimamizi wa Fedha na Mali Binafsi';

  @override
  String appVersion(Object version) {
    return 'Toleo $version';
  }

  @override
  String get loading => 'Inapakia taarifa zako za fedha…';

  @override
  String get firebaseSetupTitle => 'Unganisha mradi wako wa Firebase';

  @override
  String get firebaseSetupBody =>
      'Programu iko tayari, lakini inahitaji mipangilio ya mradi wako wa Firebase kabla ya kuingia na kutumia taarifa za fedha.';

  @override
  String get firebaseSetupCommand => 'Tekeleza: flutterfire configure';

  @override
  String get firebaseSetupSecurity =>
      'Vitambulisho vya programu hupatikana kupitia FlutterFire. Usiweke taarifa za akaunti ya huduma kwenye programu.';

  @override
  String get unknownPageTitle => 'Ukurasa haupatikani';

  @override
  String get unknownPageBody => 'Ukurasa uliochagua haupatikani.';

  @override
  String get backHome => 'Rudi mwanzo';

  @override
  String get languageTitle => 'Chagua lugha yako';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get continueLabel => 'Endelea';

  @override
  String get skip => 'Ruka';

  @override
  String get next => 'Endelea';

  @override
  String get getStarted => 'Anza sasa';

  @override
  String get onboardingIncomeTitle => 'Fuatilia mapato yako';

  @override
  String get onboardingIncomeBody => 'Fahamu pesa zako zinakotoka.';

  @override
  String get onboardingExpenseTitle => 'Dhibiti matumizi yako';

  @override
  String get onboardingExpenseBody => 'Elewa pesa zako zinatumika wapi.';

  @override
  String get onboardingSavingsTitle => 'Jenga akiba yako';

  @override
  String get onboardingSavingsBody =>
      'Weka malengo na jenga maisha yako ya baadaye.';

  @override
  String get onboardingWealthTitle => 'Simamia mali yako';

  @override
  String get onboardingWealthBody => 'Simamia safari yako ya kifedha.';

  @override
  String get goodMorning => 'asubuhi';

  @override
  String get goodAfternoon => 'mchana';

  @override
  String get goodEvening => 'jioni';

  @override
  String get emailTitle => 'Pesa zako, mpango wako.';

  @override
  String get emailSubtitle =>
      'Ingia kwa usalama kwa kutumia msimbo wa mara moja utakaotumwa kwenye barua pepe yako.';

  @override
  String get emailLabel => 'Anwani ya barua pepe';

  @override
  String get emailHint => 'wewe@mfano.com';

  @override
  String get emailInvalid => 'Weka anwani sahihi ya barua pepe.';

  @override
  String get sendCode => 'Tuma msimbo';

  @override
  String get otpTitle => 'Angalia barua pepe yako';

  @override
  String otpSentTo(Object email) {
    return 'Weka msimbo wa tarakimu sita uliotumwa kwa $email.';
  }

  @override
  String get otpLabel => 'Msimbo wa uthibitisho';

  @override
  String get verifyCode => 'Thibitisha msimbo';

  @override
  String get resendCode => 'Tuma msimbo tena';

  @override
  String resendIn(Object seconds) {
    return 'Tuma tena baada ya sekunde $seconds';
  }

  @override
  String get changeEmail => 'Badilisha barua pepe';

  @override
  String get otpInvalid =>
      'Msimbo si sahihi au muda wake umeisha. Omba msimbo mpya ujaribu tena.';

  @override
  String get genericError =>
      'Hatukuweza kukamilisha ombi. Tafadhali jaribu tena.';

  @override
  String get retry => 'Jaribu tena';

  @override
  String get profileTitle => 'Tengeneza wasifu wako';

  @override
  String get setupWelcomeTitle => 'Karibu Mapato Binafsi';

  @override
  String get setupWelcomeBody =>
      'Tuweke mpango wako binafsi wa fedha. Unaweza kuruka hatua za hiari na kubadilisha taarifa hizi baadaye.';

  @override
  String get setupProfileTitle => 'Wasifu wako';

  @override
  String get setupProfileBody =>
      'Taarifa hizi zinahitajika kubinafsisha dashibodi yako.';

  @override
  String get setupBudgetTitle => 'Weka bajeti ya mwezi';

  @override
  String get setupBudgetBody =>
      'Chagua kikomo cha matumizi ya mwezi. Unaweza kuongeza bajeti za makundi baadaye.';

  @override
  String get setupSavingsTitle => 'Anza lengo la akiba';

  @override
  String get setupSavingsBody =>
      'Weka hatua ya kwanza ya akiba yako. Unaweza kufanya hivi baadaye pia.';

  @override
  String setupStep(Object current, Object total) {
    return 'Hatua ya $current kati ya $total';
  }

  @override
  String get setupFinish => 'Maliza usanidi';

  @override
  String get skipForNow => 'Ruka kwa sasa';

  @override
  String get budgetInvalid =>
      'Weka kiasi sahihi kinachozidi sifuri, au ruka hatua hii.';

  @override
  String get goalOptionalHint =>
      'Weka jina na kiasi lengwa, au ruka hatua hii.';

  @override
  String get fullName => 'Jina kamili';

  @override
  String get currency => 'Sarafu unayopendelea';

  @override
  String get monthlyIncome => 'Makadirio ya mapato ya mwezi';

  @override
  String get financialGoal => 'Lengo lako kuu la kifedha';

  @override
  String get saveProfile => 'Hifadhi wasifu';

  @override
  String get nameRequired => 'Weka jina lako kamili.';

  @override
  String get incomeInvalid => 'Weka kiasi sahihi kisichopungua sifuri.';

  @override
  String get chooseGoal => 'Chagua lengo la kifedha';

  @override
  String get goalEmergency => 'Jenga akiba ya dharura';

  @override
  String get goalDebt => 'Lipa madeni';

  @override
  String get goalHome => 'Weka akiba ya nyumba';

  @override
  String get goalBusiness => 'Kuza biashara';

  @override
  String get goalOther => 'Lingine';

  @override
  String homeGreeting(Object name, Object time) {
    return 'Habari za $time, $name';
  }

  @override
  String get currentBalance => 'Salio la sasa';

  @override
  String get monthlyBudget => 'Bajeti ya mwezi';

  @override
  String get income => 'Mapato';

  @override
  String get expenses => 'Matumizi';

  @override
  String get savings => 'Akiba';

  @override
  String get incomeVsExpenses => 'Mapato na matumizi';

  @override
  String get recentTransactions => 'Miamala ya hivi karibuni';

  @override
  String get viewAll => 'Tazama yote';

  @override
  String get noTransactionsTitle => 'Bado hakuna miamala';

  @override
  String get noTransactionsBody => 'Safari yako ya kifedha inaanza hapa.';

  @override
  String get addTransaction => 'Ongeza muamala';

  @override
  String get transactions => 'Miamala';

  @override
  String get budgets => 'Bajeti';

  @override
  String get goals => 'Malengo';

  @override
  String get more => 'Zaidi';

  @override
  String get home => 'Mwanzo';

  @override
  String get reports => 'Ripoti';

  @override
  String get debts => 'Madeni';

  @override
  String get settings => 'Mipangilio';

  @override
  String get profile => 'Wasifu';

  @override
  String get notifications => 'Arifa';

  @override
  String get security => 'Usalama';

  @override
  String get categories => 'Makundi';

  @override
  String get customCategory => 'Kundi maalum';

  @override
  String get createCategory => 'Ongeza kundi';

  @override
  String get categoryIncome => 'Kundi la mapato';

  @override
  String get categoryExpense => 'Kundi la matumizi';

  @override
  String get categorySaved => 'Kundi limehifadhiwa.';

  @override
  String get exportData => 'Hamisha taarifa';

  @override
  String get helpSupport => 'Msaada na huduma';

  @override
  String get privacyPolicy => 'Sera ya faragha';

  @override
  String get terms => 'Masharti';

  @override
  String get signOut => 'Toka';

  @override
  String get amount => 'Kiasi';

  @override
  String get type => 'Aina';

  @override
  String get category => 'Kundi';

  @override
  String get description => 'Maelezo';

  @override
  String get date => 'Tarehe';

  @override
  String get optionalNote => 'Dokezo (hiari)';

  @override
  String get expense => 'Matumizi';

  @override
  String get salary => 'Mshahara';

  @override
  String get business => 'Biashara';

  @override
  String get freelance => 'Kazi za kujitegemea';

  @override
  String get investment => 'Uwekezaji';

  @override
  String get otherIncome => 'Mapato mengine';

  @override
  String get food => 'Chakula';

  @override
  String get transport => 'Usafiri';

  @override
  String get rent => 'Kodi ya nyumba';

  @override
  String get bills => 'Bili';

  @override
  String get shopping => 'Manunuzi';

  @override
  String get health => 'Afya';

  @override
  String get education => 'Elimu';

  @override
  String get entertainment => 'Burudani';

  @override
  String get family => 'Familia';

  @override
  String get otherExpense => 'Matumizi mengine';

  @override
  String get amountRequired => 'Weka kiasi.';

  @override
  String get amountInvalid => 'Weka kiasi sahihi kinachozidi sifuri.';

  @override
  String get descriptionRequired => 'Weka maelezo.';

  @override
  String get save => 'Hifadhi';

  @override
  String get cancel => 'Ghairi';

  @override
  String get delete => 'Futa';

  @override
  String get edit => 'Hariri';

  @override
  String get search => 'Tafuta miamala';

  @override
  String get newest => 'Mipya kwanza';

  @override
  String get oldest => 'Ya zamani kwanza';

  @override
  String get filterAll => 'Yote';

  @override
  String get filterIncome => 'Mapato';

  @override
  String get filterExpenses => 'Matumizi';

  @override
  String get budgetTitle => 'Bajeti za mwezi';

  @override
  String get noBudgetsTitle => 'Bado hakuna bajeti';

  @override
  String get noBudgetsBody => 'Weka bajeti na dhibiti matumizi yako.';

  @override
  String get createBudget => 'Tengeneza bajeti';

  @override
  String get spent => 'Iliyotumika';

  @override
  String get remaining => 'Iliyobaki';

  @override
  String get budgetAmount => 'Kiasi cha bajeti';

  @override
  String get goalTitle => 'Malengo ya akiba';

  @override
  String get noGoalsTitle => 'Bado hakuna malengo ya akiba';

  @override
  String get noGoalsBody => 'Yape pesa zako kusudi.';

  @override
  String get createGoal => 'Tengeneza lengo';

  @override
  String get targetAmount => 'Kiasi lengwa';

  @override
  String get currentAmount => 'Kiasi cha sasa';

  @override
  String get targetDate => 'Tarehe lengwa';

  @override
  String get addMoney => 'Ongeza pesa';

  @override
  String get withdraw => 'Toa pesa';

  @override
  String get goalHistory => 'Historia ya lengo';

  @override
  String get debtOwe => 'Ninazodaiwa';

  @override
  String get debtOwedToMe => 'Ninazodai';

  @override
  String get personCompany => 'Mtu au kampuni';

  @override
  String get dueDate => 'Tarehe ya mwisho';

  @override
  String get amountPaid => 'Kiasi kilicholipwa';

  @override
  String get reportsTitle => 'Ripoti za fedha';

  @override
  String get thisMonth => 'Mwezi huu';

  @override
  String get threeMonths => 'Miezi 3';

  @override
  String get sixMonths => 'Miezi 6';

  @override
  String get oneYear => 'Mwaka 1';

  @override
  String get savingsRate => 'Kiwango cha akiba';

  @override
  String get topCategories => 'Makundi yaliyotumika zaidi';

  @override
  String get netCashFlow => 'Mtiririko halisi wa fedha';

  @override
  String get budgetPerformance => 'Matumizi ya bajeti';

  @override
  String get incomeSources => 'Vyanzo vya mapato';

  @override
  String get language => 'Lugha';

  @override
  String get currencyTzs => 'TZS — Shilingi ya Tanzania';

  @override
  String get currencyUsd => 'USD — Dola ya Marekani';

  @override
  String get currencyKes => 'KES — Shilingi ya Kenya';

  @override
  String get offline =>
      'Nje ya mtandao · mabadiliko yatasawazishwa ukiunganishwa';

  @override
  String get syncing => 'Inasawazisha mabadiliko…';

  @override
  String get synced => 'Mabadiliko yote yamesawazishwa';

  @override
  String get profileSaved => 'Wasifu umehifadhiwa.';

  @override
  String get transactionSaved => 'Muamala umehifadhiwa.';

  @override
  String get goalSaved => 'Lengo limehifadhiwa.';

  @override
  String get budgetSaved => 'Bajeti imehifadhiwa.';

  @override
  String get debtSaved => 'Deni limehifadhiwa.';

  @override
  String get exportReady => 'Taarifa za miamala ziko tayari kushirikishwa.';

  @override
  String get exportEmpty => 'Bado hakuna miamala ya kuhamisha.';

  @override
  String get exportFailed =>
      'Hatukuweza kuhamisha taarifa zako. Tafadhali jaribu tena.';

  @override
  String get helpBody =>
      'Kwa msaada wa akaunti au taarifa, wasiliana na msimamizi wa mradi wako wa Mapato Binafsi Firebase.';

  @override
  String get securityBody =>
      'Taarifa zako zinatengwa kwa akaunti yako ya Firebase. Toka kwenye vifaa usivyotumia na linda akaunti yako ya barua pepe.';

  @override
  String get privacyBody =>
      'Taarifa za fedha unazoingiza huhifadhiwa kwenye mradi wako wa Firebase na kuhusishwa na akaunti yako. Programu hii haitoi ushauri wa fedha.';

  @override
  String get termsBody =>
      'Tumia programu hii kupanga taarifa binafsi za fedha. Unawajibika kwa usahihi wa taarifa unazoingiza na kulinda akaunti yako.';

  @override
  String get profileRequired => 'Kamilisha wasifu wako ili kuendelea.';

  @override
  String get darkMode => 'Mwonekano wa giza';

  @override
  String get lightMode => 'Mwonekano wa mwanga';

  @override
  String get systemMode => 'Tumia mipangilio ya kifaa';

  @override
  String get confirmDeleteTitle => 'Ufute kipengee hiki?';

  @override
  String get confirmDeleteBody => 'Kitendo hiki hakiwezi kutenduliwa.';

  @override
  String get addAmount => 'Weka kiasi';

  @override
  String get amountTooLarge => 'Kiasi hiki kimezidi kiwango kinachoruhusiwa.';

  @override
  String get financialGoalHint => 'Chagua jambo lako kuu';

  @override
  String get noData => 'Hakuna taarifa za kutosha kuonyesha hili bado.';

  @override
  String get dateFilter => 'Kipindi cha tarehe';

  @override
  String get categoryBudget => 'Bajeti ya kundi';

  @override
  String get goalName => 'Jina la lengo';

  @override
  String get debtName => 'Jina la deni';

  @override
  String get note => 'Dokezo';

  @override
  String get createDebt => 'Ongeza deni';

  @override
  String get totalIncome => 'Jumla ya mapato';

  @override
  String get totalExpenses => 'Jumla ya matumizi';

  @override
  String get categoryOther => 'Mengineyo';
}
