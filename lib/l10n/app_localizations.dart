import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mapato Binafsi'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Finance & Wealth Tracker'**
  String get appSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(Object version);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your finances…'**
  String get loading;

  /// No description provided for @firebaseSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your Firebase project'**
  String get firebaseSetupTitle;

  /// No description provided for @firebaseSetupBody.
  ///
  /// In en, this message translates to:
  /// **'This app is ready to run, but it needs your Firebase project configuration before sign-in and financial data can be enabled.'**
  String get firebaseSetupBody;

  /// No description provided for @firebaseSetupCommand.
  ///
  /// In en, this message translates to:
  /// **'Run: flutterfire configure'**
  String get firebaseSetupCommand;

  /// No description provided for @firebaseSetupSecurity.
  ///
  /// In en, this message translates to:
  /// **'Firebase client identifiers are supplied by FlutterFire. Never add service-account credentials to the app.'**
  String get firebaseSetupSecurity;

  /// No description provided for @unknownPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get unknownPageTitle;

  /// No description provided for @unknownPageBody.
  ///
  /// In en, this message translates to:
  /// **'The page you requested is not available.'**
  String get unknownPageBody;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get swahili;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @onboardingIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your income'**
  String get onboardingIncomeTitle;

  /// No description provided for @onboardingIncomeBody.
  ///
  /// In en, this message translates to:
  /// **'Know exactly where your money comes from.'**
  String get onboardingIncomeBody;

  /// No description provided for @onboardingExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Control your expenses'**
  String get onboardingExpenseTitle;

  /// No description provided for @onboardingExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'Understand where your money goes.'**
  String get onboardingExpenseBody;

  /// No description provided for @onboardingSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your savings'**
  String get onboardingSavingsTitle;

  /// No description provided for @onboardingSavingsBody.
  ///
  /// In en, this message translates to:
  /// **'Set goals and build your future.'**
  String get onboardingSavingsBody;

  /// No description provided for @onboardingWealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your wealth'**
  String get onboardingWealthTitle;

  /// No description provided for @onboardingWealthBody.
  ///
  /// In en, this message translates to:
  /// **'Take control of your financial journey.'**
  String get onboardingWealthBody;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'evening'**
  String get goodEvening;

  /// No description provided for @emailTitle.
  ///
  /// In en, this message translates to:
  /// **'Your money, your plan.'**
  String get emailTitle;

  /// No description provided for @emailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in securely with a one-time code sent to your email.'**
  String get emailSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit code sent to {email}.'**
  String otpSentTo(Object email);

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpLabel;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(Object seconds);

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is invalid or has expired. Request a new code and try again.'**
  String get otpInvalid;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that action. Please try again.'**
  String get genericError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get profileTitle;

  /// No description provided for @setupWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mapato Binafsi'**
  String get setupWelcomeTitle;

  /// No description provided for @setupWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your personal financial plan. You can skip the optional steps and change these details later.'**
  String get setupWelcomeBody;

  /// No description provided for @setupProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get setupProfileTitle;

  /// No description provided for @setupProfileBody.
  ///
  /// In en, this message translates to:
  /// **'These details are needed to personalize your dashboard.'**
  String get setupProfileBody;

  /// No description provided for @setupBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget'**
  String get setupBudgetTitle;

  /// No description provided for @setupBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a monthly spending limit. You can add category budgets later.'**
  String get setupBudgetBody;

  /// No description provided for @setupSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a savings goal'**
  String get setupSavingsTitle;

  /// No description provided for @setupSavingsBody.
  ///
  /// In en, this message translates to:
  /// **'Give your savings a first milestone. You can set this up later, too.'**
  String get setupSavingsBody;

  /// No description provided for @setupStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String setupStep(Object current, Object total);

  /// No description provided for @setupFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get setupFinish;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @budgetInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero, or skip this step.'**
  String get budgetInvalid;

  /// No description provided for @goalOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Add a goal name and target amount, or skip this step.'**
  String get goalOptionalHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Preferred currency'**
  String get currency;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Estimated monthly income'**
  String get monthlyIncome;

  /// No description provided for @financialGoal.
  ///
  /// In en, this message translates to:
  /// **'Main financial goal'**
  String get financialGoal;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get nameRequired;

  /// No description provided for @incomeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than or equal to zero.'**
  String get incomeInvalid;

  /// No description provided for @chooseGoal.
  ///
  /// In en, this message translates to:
  /// **'Choose a financial goal'**
  String get chooseGoal;

  /// No description provided for @goalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Build an emergency fund'**
  String get goalEmergency;

  /// No description provided for @goalDebt.
  ///
  /// In en, this message translates to:
  /// **'Pay off debt'**
  String get goalDebt;

  /// No description provided for @goalHome.
  ///
  /// In en, this message translates to:
  /// **'Save for a home'**
  String get goalHome;

  /// No description provided for @goalBusiness.
  ///
  /// In en, this message translates to:
  /// **'Grow a business'**
  String get goalBusiness;

  /// No description provided for @goalOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get goalOther;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good {time}, {name}'**
  String homeGreeting(Object name, Object time);

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalance;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @incomeVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income vs expenses'**
  String get incomeVsExpenses;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsTitle;

  /// No description provided for @noTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Your financial journey starts here.'**
  String get noTransactionsBody;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @customCategory.
  ///
  /// In en, this message translates to:
  /// **'Custom category'**
  String get customCategory;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get createCategory;

  /// No description provided for @categoryIncome.
  ///
  /// In en, this message translates to:
  /// **'Income category'**
  String get categoryIncome;

  /// No description provided for @categoryExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense category'**
  String get categoryExpense;

  /// No description provided for @categorySaved.
  ///
  /// In en, this message translates to:
  /// **'Category saved.'**
  String get categorySaved;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get optionalNote;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @freelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// No description provided for @investment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get investment;

  /// No description provided for @otherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get otherIncome;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @otherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other expense'**
  String get otherExpense;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount.'**
  String get amountRequired;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero.'**
  String get amountInvalid;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a description.'**
  String get descriptionRequired;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get search;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldest;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// No description provided for @filterExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get filterExpenses;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly budgets'**
  String get budgetTitle;

  /// No description provided for @noBudgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsTitle;

  /// No description provided for @noBudgetsBody.
  ///
  /// In en, this message translates to:
  /// **'Set a budget and take control of your spending.'**
  String get noBudgetsBody;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create budget'**
  String get createBudget;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetAmount;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get goalTitle;

  /// No description provided for @noGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get noGoalsTitle;

  /// No description provided for @noGoalsBody.
  ///
  /// In en, this message translates to:
  /// **'Give your money a purpose.'**
  String get noGoalsBody;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get createGoal;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current amount'**
  String get currentAmount;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get targetDate;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get addMoney;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @goalHistory.
  ///
  /// In en, this message translates to:
  /// **'Goal history'**
  String get goalHistory;

  /// No description provided for @debtOwe.
  ///
  /// In en, this message translates to:
  /// **'Money I owe'**
  String get debtOwe;

  /// No description provided for @debtOwedToMe.
  ///
  /// In en, this message translates to:
  /// **'Money owed to me'**
  String get debtOwedToMe;

  /// No description provided for @personCompany.
  ///
  /// In en, this message translates to:
  /// **'Person or company'**
  String get personCompany;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get amountPaid;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial reports'**
  String get reportsTitle;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get sixMonths;

  /// No description provided for @oneYear.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get oneYear;

  /// No description provided for @savingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings rate'**
  String get savingsRate;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top spending categories'**
  String get topCategories;

  /// No description provided for @netCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Net cash flow'**
  String get netCashFlow;

  /// No description provided for @budgetPerformance.
  ///
  /// In en, this message translates to:
  /// **'Budget performance'**
  String get budgetPerformance;

  /// No description provided for @incomeSources.
  ///
  /// In en, this message translates to:
  /// **'Income sources'**
  String get incomeSources;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currencyTzs.
  ///
  /// In en, this message translates to:
  /// **'TZS — Tanzanian shilling'**
  String get currencyTzs;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'USD — US dollar'**
  String get currencyUsd;

  /// No description provided for @currencyKes.
  ///
  /// In en, this message translates to:
  /// **'KES — Kenyan shilling'**
  String get currencyKes;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline · changes will sync when you reconnect'**
  String get offline;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing changes…'**
  String get syncing;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'All changes synced'**
  String get synced;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @transactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved.'**
  String get transactionSaved;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved.'**
  String get goalSaved;

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved.'**
  String get budgetSaved;

  /// No description provided for @debtSaved.
  ///
  /// In en, this message translates to:
  /// **'Debt saved.'**
  String get debtSaved;

  /// No description provided for @exportReady.
  ///
  /// In en, this message translates to:
  /// **'Your transaction export is ready to share.'**
  String get exportReady;

  /// No description provided for @exportEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no transactions to export yet.'**
  String get exportEmpty;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t export your data. Please try again.'**
  String get exportFailed;

  /// No description provided for @helpBody.
  ///
  /// In en, this message translates to:
  /// **'For account or data support, contact the administrator of your Mapato Binafsi Firebase project.'**
  String get helpBody;

  /// No description provided for @securityBody.
  ///
  /// In en, this message translates to:
  /// **'Your records are isolated by your Firebase account. Sign out on devices you no longer use and keep your email account secure.'**
  String get securityBody;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Financial records you enter are stored in your Firebase project and associated with your account. This application does not provide financial advice.'**
  String get privacyBody;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'Use this application to organize personal financial records. You are responsible for the accuracy of information you enter and for keeping access to your account secure.'**
  String get termsBody;

  /// No description provided for @profileRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to continue.'**
  String get profileRequired;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark appearance'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light appearance'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'Use device setting'**
  String get systemMode;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirmDeleteBody;

  /// No description provided for @addAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get addAmount;

  /// No description provided for @amountTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This amount is above the allowed maximum.'**
  String get amountTooLarge;

  /// No description provided for @financialGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Choose your main focus'**
  String get financialGoalHint;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to show this yet.'**
  String get noData;

  /// No description provided for @dateFilter.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateFilter;

  /// No description provided for @categoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Category budget'**
  String get categoryBudget;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @debtName.
  ///
  /// In en, this message translates to:
  /// **'Debt name'**
  String get debtName;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get note;

  /// No description provided for @createDebt.
  ///
  /// In en, this message translates to:
  /// **'Add debt'**
  String get createDebt;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get totalExpenses;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
