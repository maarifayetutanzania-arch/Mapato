// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mapato Binafsi';

  @override
  String get appSubtitle => 'Personal Finance & Wealth Tracker';

  @override
  String appVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get loading => 'Loading your finances…';

  @override
  String get firebaseSetupTitle => 'Connect your Firebase project';

  @override
  String get firebaseSetupBody =>
      'This app is ready to run, but it needs your Firebase project configuration before sign-in and financial data can be enabled.';

  @override
  String get firebaseSetupCommand => 'Run: flutterfire configure';

  @override
  String get firebaseSetupSecurity =>
      'Firebase client identifiers are supplied by FlutterFire. Never add service-account credentials to the app.';

  @override
  String get unknownPageTitle => 'Page not found';

  @override
  String get unknownPageBody => 'The page you requested is not available.';

  @override
  String get backHome => 'Back to home';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get continueLabel => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardingIncomeTitle => 'Track your income';

  @override
  String get onboardingIncomeBody =>
      'Know exactly where your money comes from.';

  @override
  String get onboardingExpenseTitle => 'Control your expenses';

  @override
  String get onboardingExpenseBody => 'Understand where your money goes.';

  @override
  String get onboardingSavingsTitle => 'Build your savings';

  @override
  String get onboardingSavingsBody => 'Set goals and build your future.';

  @override
  String get onboardingWealthTitle => 'Manage your wealth';

  @override
  String get onboardingWealthBody => 'Take control of your financial journey.';

  @override
  String get goodMorning => 'morning';

  @override
  String get goodAfternoon => 'afternoon';

  @override
  String get goodEvening => 'evening';

  @override
  String get emailTitle => 'Your money, your plan.';

  @override
  String get emailSubtitle =>
      'Sign in securely with a one-time code sent to your email.';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Check your email';

  @override
  String otpSentTo(Object email) {
    return 'Enter the six-digit code sent to $email.';
  }

  @override
  String get otpLabel => 'Verification code';

  @override
  String get verifyCode => 'Verify code';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get changeEmail => 'Change email';

  @override
  String get otpInvalid =>
      'That code is invalid or has expired. Request a new code and try again.';

  @override
  String get genericError =>
      'We couldn\'t complete that action. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get profileTitle => 'Create your profile';

  @override
  String get setupWelcomeTitle => 'Welcome to Mapato Binafsi';

  @override
  String get setupWelcomeBody =>
      'Let\'s set up your personal financial plan. You can skip the optional steps and change these details later.';

  @override
  String get setupProfileTitle => 'Your profile';

  @override
  String get setupProfileBody =>
      'These details are needed to personalize your dashboard.';

  @override
  String get setupBudgetTitle => 'Set a monthly budget';

  @override
  String get setupBudgetBody =>
      'Choose a monthly spending limit. You can add category budgets later.';

  @override
  String get setupSavingsTitle => 'Start a savings goal';

  @override
  String get setupSavingsBody =>
      'Give your savings a first milestone. You can set this up later, too.';

  @override
  String setupStep(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get setupFinish => 'Finish setup';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get budgetInvalid =>
      'Enter a valid amount greater than zero, or skip this step.';

  @override
  String get goalOptionalHint =>
      'Add a goal name and target amount, or skip this step.';

  @override
  String get fullName => 'Full name';

  @override
  String get currency => 'Preferred currency';

  @override
  String get monthlyIncome => 'Estimated monthly income';

  @override
  String get financialGoal => 'Main financial goal';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get nameRequired => 'Enter your full name.';

  @override
  String get incomeInvalid =>
      'Enter a valid amount greater than or equal to zero.';

  @override
  String get chooseGoal => 'Choose a financial goal';

  @override
  String get goalEmergency => 'Build an emergency fund';

  @override
  String get goalDebt => 'Pay off debt';

  @override
  String get goalHome => 'Save for a home';

  @override
  String get goalBusiness => 'Grow a business';

  @override
  String get goalOther => 'Other';

  @override
  String homeGreeting(Object name, Object time) {
    return 'Good $time, $name';
  }

  @override
  String get currentBalance => 'Current balance';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get savings => 'Savings';

  @override
  String get incomeVsExpenses => 'Income vs expenses';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get viewAll => 'View all';

  @override
  String get noTransactionsTitle => 'No transactions yet';

  @override
  String get noTransactionsBody => 'Your financial journey starts here.';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get transactions => 'Transactions';

  @override
  String get budgets => 'Budgets';

  @override
  String get goals => 'Goals';

  @override
  String get more => 'More';

  @override
  String get home => 'Home';

  @override
  String get reports => 'Reports';

  @override
  String get debts => 'Debts';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Security';

  @override
  String get categories => 'Categories';

  @override
  String get customCategory => 'Custom category';

  @override
  String get createCategory => 'Add category';

  @override
  String get categoryIncome => 'Income category';

  @override
  String get categoryExpense => 'Expense category';

  @override
  String get categorySaved => 'Category saved.';

  @override
  String get exportData => 'Export data';

  @override
  String get helpSupport => 'Help & support';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get terms => 'Terms';

  @override
  String get signOut => 'Sign out';

  @override
  String get amount => 'Amount';

  @override
  String get type => 'Type';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get optionalNote => 'Note (optional)';

  @override
  String get expense => 'Expense';

  @override
  String get salary => 'Salary';

  @override
  String get business => 'Business';

  @override
  String get freelance => 'Freelance';

  @override
  String get investment => 'Investment';

  @override
  String get otherIncome => 'Other income';

  @override
  String get food => 'Food';

  @override
  String get transport => 'Transport';

  @override
  String get rent => 'Rent';

  @override
  String get bills => 'Bills';

  @override
  String get shopping => 'Shopping';

  @override
  String get health => 'Health';

  @override
  String get education => 'Education';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get family => 'Family';

  @override
  String get otherExpense => 'Other expense';

  @override
  String get amountRequired => 'Enter an amount.';

  @override
  String get amountInvalid => 'Enter a valid amount greater than zero.';

  @override
  String get descriptionRequired => 'Enter a description.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search transactions';

  @override
  String get newest => 'Newest first';

  @override
  String get oldest => 'Oldest first';

  @override
  String get filterAll => 'All';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterExpenses => 'Expenses';

  @override
  String get budgetTitle => 'Monthly budgets';

  @override
  String get noBudgetsTitle => 'No budgets yet';

  @override
  String get noBudgetsBody => 'Set a budget and take control of your spending.';

  @override
  String get createBudget => 'Create budget';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get goalTitle => 'Savings goals';

  @override
  String get noGoalsTitle => 'No savings goals yet';

  @override
  String get noGoalsBody => 'Give your money a purpose.';

  @override
  String get createGoal => 'Create goal';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get currentAmount => 'Current amount';

  @override
  String get targetDate => 'Target date';

  @override
  String get addMoney => 'Add money';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get goalHistory => 'Goal history';

  @override
  String get debtOwe => 'Money I owe';

  @override
  String get debtOwedToMe => 'Money owed to me';

  @override
  String get personCompany => 'Person or company';

  @override
  String get dueDate => 'Due date';

  @override
  String get amountPaid => 'Amount paid';

  @override
  String get reportsTitle => 'Financial reports';

  @override
  String get thisMonth => 'This month';

  @override
  String get threeMonths => '3 months';

  @override
  String get sixMonths => '6 months';

  @override
  String get oneYear => '1 year';

  @override
  String get savingsRate => 'Savings rate';

  @override
  String get topCategories => 'Top spending categories';

  @override
  String get netCashFlow => 'Net cash flow';

  @override
  String get budgetPerformance => 'Budget performance';

  @override
  String get incomeSources => 'Income sources';

  @override
  String get language => 'Language';

  @override
  String get currencyTzs => 'TZS — Tanzanian shilling';

  @override
  String get currencyUsd => 'USD — US dollar';

  @override
  String get currencyKes => 'KES — Kenyan shilling';

  @override
  String get offline => 'Offline · changes will sync when you reconnect';

  @override
  String get syncing => 'Syncing changes…';

  @override
  String get synced => 'All changes synced';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get transactionSaved => 'Transaction saved.';

  @override
  String get goalSaved => 'Goal saved.';

  @override
  String get budgetSaved => 'Budget saved.';

  @override
  String get debtSaved => 'Debt saved.';

  @override
  String get exportReady => 'Your transaction export is ready to share.';

  @override
  String get exportEmpty => 'There are no transactions to export yet.';

  @override
  String get exportFailed => 'We couldn\'t export your data. Please try again.';

  @override
  String get helpBody =>
      'For account or data support, contact the administrator of your Mapato Binafsi Firebase project.';

  @override
  String get securityBody =>
      'Your records are isolated by your Firebase account. Sign out on devices you no longer use and keep your email account secure.';

  @override
  String get privacyBody =>
      'Financial records you enter are stored in your Firebase project and associated with your account. This application does not provide financial advice.';

  @override
  String get termsBody =>
      'Use this application to organize personal financial records. You are responsible for the accuracy of information you enter and for keeping access to your account secure.';

  @override
  String get profileRequired => 'Complete your profile to continue.';

  @override
  String get darkMode => 'Dark appearance';

  @override
  String get lightMode => 'Light appearance';

  @override
  String get systemMode => 'Use device setting';

  @override
  String get confirmDeleteTitle => 'Delete this item?';

  @override
  String get confirmDeleteBody => 'This action cannot be undone.';

  @override
  String get addAmount => 'Enter amount';

  @override
  String get amountTooLarge => 'This amount is above the allowed maximum.';

  @override
  String get financialGoalHint => 'Choose your main focus';

  @override
  String get noData => 'Not enough data to show this yet.';

  @override
  String get dateFilter => 'Date range';

  @override
  String get categoryBudget => 'Category budget';

  @override
  String get goalName => 'Goal name';

  @override
  String get debtName => 'Debt name';

  @override
  String get note => 'Notes';

  @override
  String get createDebt => 'Add debt';

  @override
  String get totalIncome => 'Total income';

  @override
  String get totalExpenses => 'Total expenses';

  @override
  String get categoryOther => 'Other';
}
