// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profileAppBarTitle => 'Profile';

  @override
  String get profileSectionPortfolio => 'Portfolio';

  @override
  String get profilePortfolioTileTitle => 'My Portfolio';

  @override
  String get profilePortfolioTileSubtitle =>
      'Your accounts, wallets, and investments';

  @override
  String get profileSavingsGoalTileTitle => 'Savings Goals';

  @override
  String get profileSavingsGoalTileSubtitle =>
      'Set goals and track deposits/withdrawals';

  @override
  String get profileInvestmentTileTitle => 'Investment / BTC Tracking';

  @override
  String get profileInvestmentTileSubtitle =>
      'Track crypto assets and log profit/loss';

  @override
  String get profileSectionDisplay => 'Display';

  @override
  String get profileThemeTitle => 'App Theme';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileLanguageTitle => 'App Language';

  @override
  String get profileLanguageSystem => 'System';

  @override
  String get profileLanguageIndonesian => 'Indonesian';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileSectionMasterData => 'Master Data';

  @override
  String get profileCategoryTileTitle => 'Categories';

  @override
  String get profileCategoryTileSubtitle => 'Income & expense categories';

  @override
  String get profileInvestmentProviderTileTitle => 'Investment Providers';

  @override
  String get profileInvestmentProviderTileSubtitle =>
      'Banks, exchanges, and brokers';

  @override
  String get profileSectionOther => 'Other';

  @override
  String get profilePayrollTileTitle => 'Payroll Cycle';

  @override
  String get profilePayrollTileSubtitle => 'Set the payroll period start date';

  @override
  String get profileCustomerServiceTileTitle => 'Contact Customer Service';

  @override
  String get profileCustomerServiceTileSubtitle => 'Fill out the help form';

  @override
  String get profileCustomerServiceLaunchFailed => 'Couldn\'t open the form.';

  @override
  String get profileSectionSecurity => 'Security';

  @override
  String get profileChangePasswordTileTitle => 'Change Password';

  @override
  String get profileChangePasswordTileSubtitle =>
      'Change your account password';

  @override
  String get profileChangePinTileTitle => 'Change PIN';

  @override
  String get profileChangePinTileSubtitle =>
      'Change the 6-digit PIN used to unlock the app';

  @override
  String get profileBiometricTitle => 'Biometric Login';

  @override
  String get profileBiometricSubtitleEnabled =>
      'Enabled — tap \"Use Biometrics\" on the lock screen to sign in without typing your PIN';

  @override
  String get profileBiometricSubtitleDisabled =>
      'Unlock the app with your fingerprint/Face ID instead of typing your PIN';

  @override
  String get profileBiometricUnsupported =>
      'This device doesn\'t support biometrics or none are enrolled yet.';

  @override
  String get profileBiometricEnrollReason => 'Enable biometric login for Flowr';

  @override
  String get profileBiometricEnrolledSuccess =>
      'Biometrics enabled. From now on just tap \"Use Biometrics\" on the lock screen to sign in without a PIN.';

  @override
  String get profileBiometricEnrollFailed =>
      'Biometric verification failed or was cancelled.';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileLogoutTileTitle => 'Log Out';

  @override
  String get profileLogoutTileSubtitle => 'Sign out of this account';

  @override
  String get profileLogoutDialogTitle => 'Log out?';

  @override
  String get profileLogoutDialogContent =>
      'You\'ll need to log in again to access the app.';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileLogoutConfirm => 'Log Out';

  @override
  String get profileEditTooltip => 'Edit Profile';

  @override
  String get profileMembershipFallback => 'Member';

  @override
  String get profileMembershipFree => 'Free — membership not upgraded yet';

  @override
  String profileAppVersion(String version) {
    return 'Version $version';
  }

  @override
  String get emergencyFundTitle => 'Emergency Fund Calculator';

  @override
  String get emergencyFundLoadError => 'Failed to load expense data.';

  @override
  String get emergencyFundRetry => 'Retry';

  @override
  String get emergencyFundTargetLabel => 'Target (months of expense)';

  @override
  String get emergencyFundCreateGoalButton => 'Create Emergency Fund Goal';

  @override
  String get emergencyFundGoalName => 'Emergency Fund';

  @override
  String get emergencyFundAverageLabel => 'Average Monthly Expense';

  @override
  String emergencyFundAverageBasis(int months) {
    return 'Based on the last $months recorded months';
  }

  @override
  String get emergencyFundManualHint =>
      'Your transaction data isn\'t enough yet to calculate an automatic average. Enter it manually below:';

  @override
  String get emergencyFundManualLabel => 'Average monthly expense (Rp)';

  @override
  String emergencyFundRecommendationLabel(int multiplier) {
    return 'Emergency Fund Recommendation (${multiplier}x monthly expense)';
  }

  @override
  String emergencyFundExistingGoalProgress(String name) {
    return 'Progress on \"$name\"';
  }

  @override
  String emergencyFundExistingGoalAmounts(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get summaryAppBarTitle => 'Summary';

  @override
  String get summaryLoadError => 'Failed to load summary.';

  @override
  String get summaryIncomeLabel => 'Income';

  @override
  String get summaryExpenseLabel => 'Expense';

  @override
  String get summaryNetProfitLabel => 'Net Profit';

  @override
  String get summarySectionAssetAllocation => 'Asset Allocation';

  @override
  String get summarySectionExpenseBreakdown => 'Expense Breakdown';

  @override
  String get summarySectionMonthlyTrend => 'Income vs Expense Trend';

  @override
  String get summarySectionSmartAdvisor => 'Smart Advisor';

  @override
  String get summaryNetWorthTitle => 'Total Net Worth';

  @override
  String summaryNetWorthDelta(String sign, String amount) {
    return '$sign $amount from last month';
  }

  @override
  String summaryChangeBadge(String percent) {
    return '$percent% vs last';
  }

  @override
  String get summarySavingsRateTitle => 'Savings Rate';

  @override
  String get summaryBudgetAllOk => 'All categories are within budget';

  @override
  String summaryBudgetOverCount(int over, int total) {
    return '$over of $total categories are over budget';
  }

  @override
  String get summaryEmergencyFundCardSubtitle =>
      'Calculate the ideal recommended amount';

  @override
  String notificationBudgetExceededTitle(String category) {
    return '$category Budget Exceeded';
  }

  @override
  String notificationBudgetExceededBody(
    String spent,
    String budget,
    String month,
    int year,
  ) {
    return 'Used $spent of the $budget budget for $month $year.';
  }

  @override
  String get appChangePasswordSuccessMessage =>
      'Password updated successfully.';

  @override
  String get appChangePasswordAppBarTitle => 'Change Password';

  @override
  String get appChangePasswordCurrentLabel => 'Current password';

  @override
  String get appChangePasswordCurrentRequired => 'Current password is required';

  @override
  String get appChangePasswordNewLabel => 'New password';

  @override
  String get appChangePasswordNewRequired => 'New password is required';

  @override
  String get appChangePasswordMinLength => 'Minimum 8 characters';

  @override
  String get appChangePasswordConfirmLabel => 'Confirm new password';

  @override
  String get appChangePasswordMismatch => 'Passwords don\'t match';

  @override
  String get appChangePasswordSaveButton => 'Save';

  @override
  String get appEditProfileSuccessMessage => 'Profile updated successfully.';

  @override
  String get appEditProfileAppBarTitle => 'Edit Profile';

  @override
  String get appEditProfileNameLabel => 'Full name';

  @override
  String get appEditProfileNameRequired => 'Name is required';

  @override
  String get appEditProfileUsernameLabel => 'Username';

  @override
  String get appEditProfileUsernameRequired => 'Username is required';

  @override
  String get appEditProfileUsernameNoSpaces => 'Username cannot contain spaces';

  @override
  String get appEditProfileEmailLabel => 'Email';

  @override
  String get appEditProfileEmailRequired => 'Email is required';

  @override
  String get appEditProfileEmailInvalid => 'Invalid email format';

  @override
  String get appEditProfileSaveButton => 'Save';

  @override
  String get appEditProfileSecuritySectionLabel => 'Security';

  @override
  String get appEditProfileChangePasswordTitle => 'Change Password';

  @override
  String get appEditProfileChangePasswordSubtitle =>
      'Change your account password';

  @override
  String get appEditProfileChangePinTitle => 'Change PIN';

  @override
  String get appEditProfileChangePinSubtitle =>
      'Change the 6-digit PIN used to unlock the app';

  @override
  String get appCyclePeriodThisMonth => 'This Month';

  @override
  String get appCyclePeriodLastMonth => 'Last Month';

  @override
  String get appCyclePeriodSelectMonth => 'Select Month';

  @override
  String get appNavDashboard => 'Dashboard';

  @override
  String get appNavTransactions => 'Transactions';

  @override
  String get appNavSummary => 'Summary';

  @override
  String get appNavBudgets => 'Budget';

  @override
  String get appNavInvestment => 'Investment';

  @override
  String get appNavProfile => 'Profile';

  @override
  String get appNavUpgradeRequired =>
      'This feature requires a membership upgrade';

  @override
  String get authLoginWelcomeTitle => 'Welcome back';

  @override
  String get authLoginWelcomeSubtitle =>
      'Log in to continue managing your finances';

  @override
  String get authLoginEmailOrUsernameLabel => 'Email or Username';

  @override
  String get authLoginEmailOrUsernameRequired =>
      'Email or username is required';

  @override
  String get authLoginPasswordLabel => 'Password';

  @override
  String get authLoginPasswordRequired => 'Password is required';

  @override
  String get authLoginForgotPasswordLink => 'Forgot password?';

  @override
  String get authLoginSubmitButton => 'Log In';

  @override
  String get authLoginNoAccountPrompt => 'Don\'t have an account?';

  @override
  String get authLoginRegisterLink => 'Sign Up';

  @override
  String get authRegisterTitle => 'Create a new account';

  @override
  String get authRegisterSubtitle => 'Start managing your income & expenses';

  @override
  String get authRegisterInfoBanner =>
      'Your account is active immediately after signing up — you\'ll be asked to create a 6-digit PIN next.';

  @override
  String get authRegisterNameLabel => 'Full name';

  @override
  String get authRegisterNameRequired => 'Name is required';

  @override
  String get authRegisterUsernameLabel => 'Username';

  @override
  String get authRegisterUsernameRequired => 'Username is required';

  @override
  String get authRegisterUsernameNoSpaces => 'Username cannot contain spaces';

  @override
  String get authRegisterEmailLabel => 'Email';

  @override
  String get authRegisterEmailRequired => 'Email is required';

  @override
  String get authRegisterEmailInvalid => 'Invalid email format';

  @override
  String get authRegisterPasswordLabel => 'Password';

  @override
  String get authRegisterPasswordRequired => 'Password is required';

  @override
  String get authRegisterPasswordMinLength => 'Minimum 8 characters';

  @override
  String get authRegisterConfirmPasswordLabel => 'Confirm password';

  @override
  String get authRegisterPasswordMismatch => 'Passwords don\'t match';

  @override
  String get authRegisterSubmitButton => 'Sign Up';

  @override
  String get authRegisterHaveAccountPrompt => 'Already have an account?';

  @override
  String get authRegisterLoginLink => 'Log In';

  @override
  String get authForgotPasswordTitle => 'Forgot Password';

  @override
  String get authForgotPasswordSubtitle =>
      'Fill in the form below, an admin will process your request';

  @override
  String get authForgotPasswordInfoBanner =>
      'There\'s no automatic email reset yet. An admin will contact you via WhatsApp/phone to send the password reset link.';

  @override
  String get authForgotPasswordIdentifierLabel => 'Email or Username';

  @override
  String get authForgotPasswordIdentifierRequired =>
      'Email or username is required';

  @override
  String get authForgotPasswordPhoneLabel => 'WhatsApp/phone number';

  @override
  String get authForgotPasswordPhoneRequired =>
      'WhatsApp/phone number is required';

  @override
  String get authForgotPasswordNoteLabel => 'Note (optional)';

  @override
  String get authForgotPasswordSubmitButton => 'Submit Request';

  @override
  String get authForgotPasswordCheckStatusLink =>
      'Already submitted a request? Check status';

  @override
  String get authResetStatusAppBarTitle => 'Check Request Status';

  @override
  String get authResetStatusDescription =>
      'Enter the email or username you used when submitting the password reset request.';

  @override
  String get authResetStatusIdentifierLabel => 'Email or Username';

  @override
  String get authResetStatusIdentifierRequired =>
      'Email or username is required';

  @override
  String get authResetStatusCheckButton => 'Check Status';

  @override
  String get authResetStatusPendingTitle => 'Waiting for Admin Review';

  @override
  String get authResetStatusPendingDescription =>
      'An admin will contact you via WhatsApp/phone at the number you registered to send the password reset link.';

  @override
  String get authResetStatusProcessedTitle => 'Already Processed';

  @override
  String get authResetStatusProcessedDescription =>
      'An admin has created the password reset link and should have already sent it via WhatsApp/phone. Open that link to set your new password.';

  @override
  String get authResetStatusRejectedTitle => 'Request Rejected';

  @override
  String get authResetStatusRejectedDescription =>
      'The admin rejected this password reset request. Please submit a new request via the form.';

  @override
  String get authOnboardingSlide1Title => 'Welcome to Flowr';

  @override
  String get authOnboardingSlide1Description =>
      'Manage your income, expenses, and investments in one app.';

  @override
  String get authOnboardingSlide2Title => 'Track All Transactions';

  @override
  String get authOnboardingSlide2Description =>
      'Log daily transactions, view financial summaries, and monitor your investment portfolio anytime.';

  @override
  String get authOnboardingSlide3Title => 'Set Budgets & Get Alerts';

  @override
  String get authOnboardingSlide3Description =>
      'Set spending limits per category and get notified as soon as you start going over.';

  @override
  String get authOnboardingSlide4Title => 'Secured with a PIN';

  @override
  String get authOnboardingSlide4Description =>
      'Your account is protected by a 6-digit PIN every time you open the app, just like a mobile banking app.';

  @override
  String get authOnboardingSkipButton => 'Skip';

  @override
  String get authOnboardingStartButton => 'Get Started';

  @override
  String get authOnboardingNextButton => 'Next';

  @override
  String get authSplashTagline => 'Manage your finances with ease';

  @override
  String get authConfirmPinTitle => 'Confirm Your PIN';

  @override
  String get authConfirmPinSubtitle =>
      'Enter your current 6-digit PIN to enable biometric login';

  @override
  String get authChangePinMismatch => 'PINs don\'t match, try again';

  @override
  String get authChangePinSuccessSnackbar => 'PIN updated successfully.';

  @override
  String get authChangePinAppBarTitle => 'Change PIN';

  @override
  String get authChangePinStepCurrentTitle => 'Enter Current PIN';

  @override
  String get authChangePinStepNewTitle => 'Create New PIN';

  @override
  String get authChangePinStepConfirmTitle => 'Confirm New PIN';

  @override
  String get authChangePinStepCurrentSubtitle =>
      'Enter the 6-digit PIN you\'re currently using';

  @override
  String get authChangePinStepNewSubtitle => 'Enter your new 6-digit PIN';

  @override
  String get authChangePinStepConfirmSubtitle =>
      'Re-enter the new PIN to confirm';

  @override
  String get authVerifyPinBiometricReason => 'Unlock Flowr with biometrics';

  @override
  String authVerifyPinGreeting(String userName) {
    return 'Hi, $userName';
  }

  @override
  String get authVerifyPinEnterPinTitle => 'Enter PIN';

  @override
  String get authVerifyPinSubtitleBiometric =>
      'Enter your PIN or use fingerprint/Face ID to unlock the app';

  @override
  String get authVerifyPinSubtitleDefault =>
      'Enter your 6-digit PIN to unlock the app';

  @override
  String get authVerifyPinUseBiometricButton => 'Use Biometrics';

  @override
  String get authVerifyPinNotYouLogout => 'Not you? Log out';

  @override
  String get authVerifyPinLogoutDialogTitle => 'Not you?';

  @override
  String get authVerifyPinLogoutDialogContent =>
      'You\'ll be logged out and will need to log in again with your email/username & password.';

  @override
  String get authVerifyPinLogoutDialogCancel => 'Cancel';

  @override
  String get authVerifyPinLogoutDialogConfirm => 'Log Out';

  @override
  String get authSetPinMismatch => 'PINs don\'t match, try again';

  @override
  String get authSetPinConfirmTitle => 'Confirm PIN';

  @override
  String get authSetPinCreateTitle => 'Create a 6-Digit PIN';

  @override
  String get authSetPinConfirmSubtitle => 'Re-enter the same PIN to confirm';

  @override
  String get authSetPinCreateSubtitle =>
      'This PIN is used to unlock the app every time you open it, just like a mobile banking app';

  @override
  String get authSetPinRestartButton => 'Start over';

  @override
  String get authBiometricPromptTitle => 'Log in faster with biometrics?';

  @override
  String get authBiometricPromptContent =>
      'Unlock Flowr with your fingerprint or Face ID, without typing your PIN every time. You can turn it on or off anytime from Profile.';

  @override
  String get authBiometricPromptLater => 'Maybe later';

  @override
  String get authBiometricPromptEnable => 'Enable';

  @override
  String get authBiometricPromptEnrollReason =>
      'Enable biometric login for Flowr';

  @override
  String get authBiometricPromptSuccessTitle => 'Biometrics enabled!';

  @override
  String get authBiometricPromptFailedTitle => 'Failed to enable';

  @override
  String get authBiometricPromptSuccessContent =>
      'Next time you can log in to Flowr without typing your PIN.';

  @override
  String get authBiometricPromptFailedContent =>
      'Biometric verification failed or was cancelled. You can try again anytime from Profile.';

  @override
  String get authBiometricPromptOkButton => 'OK';

  @override
  String get walletPortfolioListUpgradeRequired =>
      'This feature requires a membership upgrade';

  @override
  String get walletPortfolioListTitle => 'Portfolio';

  @override
  String get walletPortfolioListLoadError => 'Failed to load portfolio.';

  @override
  String get walletPortfolioListEmptyTitle => 'No accounts yet';

  @override
  String get walletPortfolioListEmptySubtitle =>
      'Tap the + button to add your first account/wallet.';

  @override
  String get walletPortfolioListTransferTitle => 'Transfer Between Accounts';

  @override
  String get walletPortfolioListTransferSubtitle =>
      'Move funds between your accounts/wallets';

  @override
  String get walletPortfolioListDeleteDialogTitle => 'Delete account?';

  @override
  String walletPortfolioListDeleteDialogContent(String accountName) {
    return 'The account \"$accountName\" will be permanently deleted.';
  }

  @override
  String get walletPortfolioListCancel => 'Cancel';

  @override
  String get walletPortfolioListDeleteConfirm => 'Delete';

  @override
  String walletPortfolioListProviderFallback(int id) {
    return 'Provider #$id';
  }

  @override
  String get walletPortfolioListEditAction => 'Edit';

  @override
  String get walletPortfolioFormProviderRequired =>
      'Please select an investment provider first.';

  @override
  String get walletPortfolioFormEditTitle => 'Edit Account';

  @override
  String get walletPortfolioFormCreateTitle => 'Add Account';

  @override
  String get walletPortfolioFormProviderLabel => 'Provider';

  @override
  String get walletPortfolioFormLoadProvidersError =>
      'Failed to load the list of providers.';

  @override
  String get walletPortfolioFormAccountNameLabel => 'Account name';

  @override
  String get walletPortfolioFormAccountNameRequired =>
      'Account name is required';

  @override
  String get walletPortfolioFormAccountNumberLabel =>
      'Account number (optional)';

  @override
  String get walletPortfolioFormDescriptionLabel => 'Description (optional)';

  @override
  String get walletPortfolioFormInvestmentAccountTitle => 'Investment account';

  @override
  String get walletPortfolioFormInvestmentAccountSubtitle =>
      'Money in/out is recorded as deposit/profit/withdrawal/loss, separate from regular transactions';

  @override
  String get walletPortfolioFormSaveChanges => 'Save Changes';

  @override
  String get walletPortfolioFormNoProviders => 'No investment providers yet';

  @override
  String get walletPortfolioFormSelectProvider => 'Select provider';

  @override
  String get walletPortfolioFormSelectProviderSheetTitle =>
      'Select investment provider';

  @override
  String get walletSavingsGoalListTitle => 'Savings Goals';

  @override
  String get walletSavingsGoalListLoadError => 'Failed to load savings goals.';

  @override
  String get walletSavingsGoalListEmptyTitle => 'No savings goals yet';

  @override
  String get walletSavingsGoalListEmptySubtitle =>
      'Tap the + button to create your first goal.';

  @override
  String get walletSavingsGoalListActiveLabel => 'Active';

  @override
  String get walletSavingsGoalListAchievedLabel => 'Achieved';

  @override
  String walletSavingsGoalListSummarySuffix(String label) {
    return '$label Goal';
  }

  @override
  String get walletSavingsGoalListDeleteDialogTitle => 'Delete goal?';

  @override
  String walletSavingsGoalListDeleteDialogContent(String name) {
    return 'The goal \"$name\" and all its deposit/withdrawal history will be permanently deleted.';
  }

  @override
  String get walletSavingsGoalListCancel => 'Cancel';

  @override
  String get walletSavingsGoalListDeleteConfirm => 'Delete';

  @override
  String get walletSavingsGoalListArchiveDialogTitle => 'Archive goal?';

  @override
  String get walletSavingsGoalListArchiveDialogContent =>
      'The goal will stop counting as active/achieved, but its history stays saved. This can\'t be undone from the app.';

  @override
  String get walletSavingsGoalListArchiveConfirm => 'Archive';

  @override
  String get walletSavingsGoalListEditAction => 'Edit';

  @override
  String walletSavingsGoalListProgressAmounts(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get walletSavingsGoalListOverAllocatedWarning =>
      'Total allocation to this account exceeds its actual balance.';

  @override
  String get walletSavingsGoalFormEditTitle => 'Edit Savings Goal';

  @override
  String get walletSavingsGoalFormCreateTitle => 'New Savings Goal';

  @override
  String get walletSavingsGoalFormNameLabel => 'Goal name';

  @override
  String get walletSavingsGoalFormNameRequired => 'Goal name is required';

  @override
  String get walletSavingsGoalFormPurposeLabel => 'Purpose (optional)';

  @override
  String get walletSavingsGoalFormTargetAmountLabel => 'Target Amount (Rp)';

  @override
  String get walletSavingsGoalFormTargetAmountRequired =>
      'Target amount is required';

  @override
  String get walletSavingsGoalFormAmountInvalid => 'Invalid amount';

  @override
  String get walletSavingsGoalFormDeadlineLabel => 'Deadline (optional)';

  @override
  String get walletSavingsGoalFormNoDeadline => 'No deadline';

  @override
  String get walletSavingsGoalFormSourceAccountLabel =>
      'Funding source account (optional)';

  @override
  String get walletSavingsGoalFormLoadAccountsError =>
      'Failed to load the list of accounts.';

  @override
  String get walletSavingsGoalFormNoAccounts => 'No accounts yet';

  @override
  String get walletSavingsGoalFormNoAccountBound => 'Not tied to any account';

  @override
  String get walletSavingsGoalFormColorLabel => 'Color';

  @override
  String get walletSavingsGoalFormIconLabel => 'Icon';

  @override
  String get walletSavingsGoalFormSaveChanges => 'Save Changes';

  @override
  String get walletSavingsGoalFormCreateAction => 'Create Goal';

  @override
  String get walletSavingsGoalFormPickAccountSheetTitle =>
      'Select funding source account';

  @override
  String get walletSavingsGoalDetailAddEntryTooltip => 'Log Deposit/Withdrawal';

  @override
  String get walletSavingsGoalDetailHistoryTitle =>
      'Deposit/Withdrawal History';

  @override
  String get walletSavingsGoalDetailLoadHistoryError =>
      'Failed to load history.';

  @override
  String get walletSavingsGoalDetailEmptyTitle => 'No history yet';

  @override
  String get walletSavingsGoalDetailEmptySubtitle =>
      'Tap the + button to log your first deposit/withdrawal.';

  @override
  String get walletSavingsGoalDetailCollectedLabel => 'Collected';

  @override
  String walletSavingsGoalDetailTargetAmount(String amount) {
    return 'Target $amount';
  }

  @override
  String walletSavingsGoalDetailRemainingAmount(String amount) {
    return '$amount left to go';
  }

  @override
  String walletSavingsGoalDetailDeadline(String date) {
    return 'Deadline $date';
  }

  @override
  String walletSavingsGoalDetailDefaultAccount(String name) {
    return 'Default account: $name';
  }

  @override
  String get walletSavingsGoalDetailOverAllocatedWarning =>
      'Total allocation to this account from all goals already exceeds its actual balance.';

  @override
  String get walletSavingsGoalDetailDeleteEntryTitle => 'Delete this entry?';

  @override
  String get walletSavingsGoalDetailDeleteEntryContent =>
      'This history entry will be permanently deleted and the goal\'s progress recalculated.';

  @override
  String get walletSavingsGoalDetailCancel => 'Cancel';

  @override
  String get walletSavingsGoalDetailDeleteConfirm => 'Delete';

  @override
  String get walletSavingsGoalDetailWithdrawLabel => 'Withdraw';

  @override
  String get walletSavingsGoalDetailContributeLabel => 'Deposit';

  @override
  String get walletSavingsGoalDetailDateLabel => 'Date';

  @override
  String get walletSavingsGoalDetailAmountLabel => 'Amount (Rp)';

  @override
  String get walletSavingsGoalDetailAmountRequired => 'Amount is required';

  @override
  String get walletSavingsGoalDetailAmountInvalid => 'Invalid amount';

  @override
  String get walletSavingsGoalDetailAccountLabel => 'Account (optional)';

  @override
  String get walletSavingsGoalDetailLoadAccountsError =>
      'Failed to load the list of accounts.';

  @override
  String get walletSavingsGoalDetailNoAccounts => 'No accounts yet';

  @override
  String get walletSavingsGoalDetailNoAccountRecorded =>
      'Not recorded to any account';

  @override
  String get walletSavingsGoalDetailNoteLabel => 'Note (optional)';

  @override
  String get walletSavingsGoalDetailSaveAction => 'Save';

  @override
  String get walletSavingsGoalDetailPickAccountSheetTitle => 'Select account';

  @override
  String get walletGoalStatusAchieved => 'Achieved';

  @override
  String get walletGoalStatusArchived => 'Archived';

  @override
  String get walletGoalStatusActive => 'Active';

  @override
  String get walletDashboardLoadError => 'Failed to load dashboard.';

  @override
  String get walletDashboardCashBalanceLabel => 'Cash Balance';

  @override
  String get walletDashboardInvestmentBalanceLabel => 'Investment Balance';

  @override
  String get walletDashboardIncomeLabel => 'Income';

  @override
  String get walletDashboardExpenseLabel => 'Expense';

  @override
  String get walletDashboardDailyAccountsTitle => 'Daily Accounts';

  @override
  String get walletDashboardInvestmentAccountsTitle => 'Investment Accounts';

  @override
  String get walletDashboardIncomeSourcesTitle => 'Income Sources';

  @override
  String get walletDashboardTopCategoriesTitle => 'Top Categories';

  @override
  String get walletDashboardRecentTransactionsTitle => 'Recent Transactions';

  @override
  String walletDashboardGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String walletDashboardCycleRange(String start, String end) {
    return 'Cycle $start — $end';
  }

  @override
  String get walletDashboardNetWorthLabel => 'Total Net Worth';

  @override
  String get walletDashboardSavingsGoalsCardTitle => 'Savings Goals';

  @override
  String walletDashboardSavingsGoalsSummary(int active, int achieved) {
    return '$active active · $achieved achieved';
  }

  @override
  String walletDashboardSavingsGoalProgress(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get txnCommonCancel => 'Cancel';

  @override
  String get txnCommonDelete => 'Delete';

  @override
  String get txnCommonEdit => 'Edit';

  @override
  String get txnIncomeLabel => 'Income';

  @override
  String get txnExpenseLabel => 'Expense';

  @override
  String get txnFilterAll => 'All';

  @override
  String get txnCommonSaveChanges => 'Save Changes';

  @override
  String get txnCommonAmountRequired => 'Amount is required';

  @override
  String get txnCommonAmountInvalid => 'Invalid amount';

  @override
  String get txnCommonSelectCategoryFirst => 'Please select a category first.';

  @override
  String get txnCommonCategoryLoadError => 'Failed to load categories.';

  @override
  String get txnCommonAccountLoadError => 'Failed to load accounts.';

  @override
  String get txnCommonDescriptionLabel => 'Description (optional)';

  @override
  String get txnCommonAmountRpLabel => 'Amount (Rp)';

  @override
  String get txnCommonSelectCategoryTitle => 'Select category';

  @override
  String get txnCommonNoCategoryForType => 'No categories yet for this type';

  @override
  String get txnCommonSelectAccountTitle => 'Select account';

  @override
  String get txnCommonNoneOption => 'None';

  @override
  String get txnCommonDateSectionLabel => 'Date';

  @override
  String get txnCommonTypeSectionLabel => 'Type';

  @override
  String get txnCommonCategorySectionLabel => 'Category';

  @override
  String get txnCommonNoAccountAvailable => 'No accounts yet';

  @override
  String txnCategoryFallbackName(int id) {
    return 'Category #$id';
  }

  @override
  String txnAccountFallbackName(int id) {
    return 'Account #$id';
  }

  @override
  String get txnRecurringMenuTileTitle => 'Recurring Transactions';

  @override
  String get txnFeatureRequiresUpgrade =>
      'This feature requires a membership upgrade';

  @override
  String get txnListTitle => 'Transactions';

  @override
  String get txnListLoadError => 'Failed to load transactions.';

  @override
  String get txnListEmptyTitle => 'No transactions yet';

  @override
  String get txnListEmptySubtitle =>
      'Tap the + button to record income or expenses.';

  @override
  String get txnListNoResultsTitle => 'No results';

  @override
  String get txnListNoResultsSubtitle => 'No transactions match this search.';

  @override
  String get txnSearchHint => 'Search category, note, or account';

  @override
  String get txnNetBalanceLabel => 'Net Balance';

  @override
  String get txnDeleteDialogTitle => 'Delete transaction?';

  @override
  String get txnDeleteDialogContent =>
      'This transaction will be permanently deleted.';

  @override
  String get txnRecurringMenuTileSubtitle => 'Manage recurring bills/income';

  @override
  String get txnPickDateLabel => 'Select Date';

  @override
  String get txnFilterThisMonth => 'This Month';

  @override
  String get txnFilterLastMonth => 'Last Month';

  @override
  String get txnFilterLast7Days => 'Last 7 Days';

  @override
  String get txnFilterLast30Days => 'Last 30 Days';

  @override
  String get txnScanReceiptFailedMessage =>
      'Couldn\'t read this receipt, please fill in manually.';

  @override
  String get txnScanReceiptAutofilledMessage =>
      'Auto-filled from the receipt — please double-check before saving.';

  @override
  String get txnFormTitleEdit => 'Edit Transaction';

  @override
  String get txnFormTitleAdd => 'Add Transaction';

  @override
  String get txnFormAccountOptionalLabel => 'Account (optional)';

  @override
  String get txnScanReceiptScanning => 'Reading receipt...';

  @override
  String get txnScanReceiptButtonLabel => 'Scan Receipt';

  @override
  String get txnScanSourceCamera => 'Take Photo';

  @override
  String get txnScanSourceGallery => 'Choose from Gallery';

  @override
  String get txnRecurringListLoadError =>
      'Failed to load recurring transactions.';

  @override
  String get txnRecurringListEmptyTitle => 'No recurring transactions yet';

  @override
  String get txnRecurringListEmptySubtitle =>
      'Tap the + button to create a template, e.g. a monthly bill.';

  @override
  String get txnRecurringDeleteDialogTitle => 'Delete recurring transaction?';

  @override
  String txnRecurringDeleteDialogContent(String name) {
    return 'The \"$name\" template will be permanently deleted. Transactions already generated from it won\'t be removed.';
  }

  @override
  String txnRecurringNextDateLabel(String date) {
    return 'Next $date';
  }

  @override
  String get txnRecurringSelectAccountFirst =>
      'Please select an account first.';

  @override
  String get txnRecurringFormTitleEdit => 'Edit Recurring Transaction';

  @override
  String get txnRecurringFormTitleAdd => 'Add Recurring Transaction';

  @override
  String get txnRecurringNameLabel => 'Name';

  @override
  String get txnRecurringNameRequired => 'Name is required';

  @override
  String get txnRecurringAccountSectionLabel => 'Account';

  @override
  String get txnRecurringFrequencyLabel => 'Frequency';

  @override
  String get txnRecurringStartDateLabel => 'Start Date';

  @override
  String get txnRecurringStartDateHistoricalNote =>
      'This template has already been processed, so changing this date won\'t shift the next schedule — it just records when it was first created.';

  @override
  String get txnRecurringSubmitAdd => 'Add';

  @override
  String get txnRecurringPickFrequencyTitle => 'Select frequency';

  @override
  String get txnTransferListTitle => 'Account Transfer';

  @override
  String get txnTransferListLoadError => 'Failed to load transfers.';

  @override
  String get txnTransferListEmptyTitle => 'No transfers yet';

  @override
  String get txnTransferListEmptySubtitle =>
      'Tap the + button to move funds between your accounts.';

  @override
  String get txnTransferDeleteDialogTitle => 'Delete transfer?';

  @override
  String get txnTransferDeleteDialogContent =>
      'This transfer will be permanently deleted, and both account balances will be adjusted back.';

  @override
  String get txnTransferSelectAccountsError =>
      'Select the source and destination accounts.';

  @override
  String get txnTransferSameAccountError =>
      'Source and destination accounts can\'t be the same.';

  @override
  String get txnTransferAssetRequiredError =>
      'Enter the asset symbol (e.g. BTC) — one of the accounts is a crypto account.';

  @override
  String get txnTransferFormTitleEdit => 'Edit Transfer';

  @override
  String get txnTransferFromAccountLabel => 'From Account';

  @override
  String get txnTransferFromAccountPlaceholder => 'Select source account';

  @override
  String get txnTransferToAccountLabel => 'To Account';

  @override
  String get txnTransferToAccountPlaceholder => 'Select destination account';

  @override
  String get txnTransferAssetSectionLabel => 'Asset';

  @override
  String get txnTransferAssetHint =>
      'One of the accounts is a crypto account — enter its asset symbol so it\'s included in the per-asset breakdown in Investment (both top-ups and withdrawals/profit taking).';

  @override
  String get txnTransferAssetFieldLabel => 'Asset symbol (e.g. BTC)';

  @override
  String get txnTransferSubmitLabel => 'Transfer';

  @override
  String get txnBudgetListTitle => 'Budget';

  @override
  String get txnBudgetListLoadError => 'Failed to load budget.';

  @override
  String get txnBudgetListEmptyMessage =>
      'No budget yet for this month.\nTap the + button to add one.';

  @override
  String get txnBudgetPerCategoryLabel => 'By Category';

  @override
  String get txnBudgetTapToEditHint => 'Tap one to change its budget amount.';

  @override
  String get txnBudgetTotalLabel => 'Total Budget';

  @override
  String txnBudgetUsedAmount(String amount) {
    return 'Used $amount';
  }

  @override
  String txnBudgetCategoryOverBudget(String spent) {
    return 'Used $spent — over budget';
  }

  @override
  String txnBudgetCategoryUsedOfTotal(String spent, String total) {
    return 'Used $spent of $total';
  }

  @override
  String get txnBudgetFormTitleEdit => 'Edit Budget';

  @override
  String get txnBudgetFormTitleAdd => 'Add Budget';

  @override
  String txnBudgetFormPeriodLabel(String month, int year) {
    return 'For the $month $year period';
  }

  @override
  String get txnBudgetExpenseCategoryLabel => 'Expense Category';

  @override
  String get txnBudgetAllCategoriesBudgeted =>
      'All categories already have a budget';

  @override
  String get txnBudgetAmountLabel => 'Budget Amount (Rp)';

  @override
  String get investDashboardTitle => 'Investment';

  @override
  String get investActivityHistoryLabel => 'Activity History';

  @override
  String get investRecordProfitLossTooltip => 'Record Profit/Loss';

  @override
  String get investLoadErrorMessage => 'Failed to load investment data.';

  @override
  String get investYourAssetsLabel => 'Your Assets';

  @override
  String get investTotalCryptoValueLabel => 'Total Crypto Value';

  @override
  String get investAssetCountEmpty => 'No assets yet';

  @override
  String investAssetCountTracked(int count) {
    return '$count assets tracked';
  }

  @override
  String investPnl24hFull(String amount) {
    return 'PnL $amount (24h)';
  }

  @override
  String investPnl24hShort(String amount) {
    return 'PnL $amount (24h)';
  }

  @override
  String get investPriceUnavailable => 'Price unavailable';

  @override
  String get investEmptyCryptoAccountsTitle => 'No crypto accounts yet';

  @override
  String get investEmptyCryptoAccountsSubtitle =>
      'Add an account with a Crypto-type provider via Portfolio, then top up its balance via Account Transfer.';

  @override
  String get investHeldInAccountsTitle => 'Held in Accounts';

  @override
  String get investHeldInAccountsSubtitle =>
      'Calculated from activity history — check the code comments if the numbers look off.';

  @override
  String get investCurrentPriceLabel => 'Current Price';

  @override
  String investChangePercent24h(String percent) {
    return '$percent% (24h)';
  }

  @override
  String get investTotalHeldLabel => 'Total You Hold';

  @override
  String investApproxQuantityBtc(String quantity) {
    return '≈ $quantity BTC';
  }

  @override
  String get investPerformanceTitle => 'Performance (Floating PnL)';

  @override
  String get investPeriod24h => '24 Hours';

  @override
  String get investPeriod1w => '1 Week';

  @override
  String get investPeriod1m => '1 Month';

  @override
  String get investPeriod3m => '3 Months';

  @override
  String get investPeriod6m => '6 Months';

  @override
  String get investPeriod5y => '5 Years';

  @override
  String get investDataUnavailable => 'Data unavailable';

  @override
  String get investMarketPriceUnavailable =>
      'Market price for this asset isn\'t available yet.';

  @override
  String get investNoBalanceRecorded =>
      'No balance recorded for this asset yet.';

  @override
  String investAccountFallbackName(int accountId) {
    return 'Account #$accountId';
  }

  @override
  String get investActivityLoadError => 'Failed to load history.';

  @override
  String get investActivityEmptyTitle => 'No activity yet';

  @override
  String get investActivityEmptySubtitle =>
      'Top up via Account Transfer, or record Profit/Loss with the + button.';

  @override
  String get investLabelDeposit => 'Deposit';

  @override
  String get investLabelWithdrawal => 'Withdrawal';

  @override
  String get investLabelProfit => 'Profit';

  @override
  String get investLabelLoss => 'Loss';

  @override
  String get investLabelTransfer => 'Transfer';

  @override
  String get investFromTransferSuffix => 'from Transfer';

  @override
  String get investDeleteEntryDialogTitle => 'Delete entry?';

  @override
  String get investDeleteEntryDialogContent =>
      'This entry will be permanently deleted from tracking.';

  @override
  String get investCancelButton => 'Cancel';

  @override
  String get investDeleteButton => 'Delete';

  @override
  String get investManageFromTransferTooltip => 'Manage from Account Transfer';

  @override
  String get investFromTransferSnackbar =>
      'This entry is from Transfer — manage it from the Account Transfer menu.';

  @override
  String get investSelectCryptoAccountFirstError =>
      'Please select a crypto account first.';

  @override
  String get investEditProfitLossTitle => 'Edit Profit/Loss';

  @override
  String get investRecordProfitLossTitle => 'Record Profit/Loss';

  @override
  String get investCryptoAccountLabel => 'Crypto Account';

  @override
  String get investSelectAccountPlaceholder => 'Select account';

  @override
  String get investAssetSymbolLabel => 'Asset symbol (e.g. BTC)';

  @override
  String get investAssetSymbolRequiredError => 'Asset symbol is required';

  @override
  String get investTypeLabel => 'Type';

  @override
  String get investDateLabel => 'Date';

  @override
  String get investAmountLabel => 'Amount (Rp)';

  @override
  String get investAmountRequiredError => 'Amount is required';

  @override
  String get investAmountInvalidError => 'Invalid amount';

  @override
  String get investDescriptionLabel => 'Description (optional)';

  @override
  String get investSaveChangesButton => 'Save Changes';

  @override
  String get investSaveButton => 'Save';

  @override
  String get investSelectCryptoAccountSheetTitle => 'Select crypto account';

  @override
  String get investUpgradeMembershipTitle => 'Upgrade Membership';

  @override
  String get investMembershipStatusLoadError =>
      'Failed to load membership status.';

  @override
  String get investChoosePlanTitle => 'Choose a Plan';

  @override
  String get investPlanListLoadError => 'Failed to load plan list.';

  @override
  String get investMemberFallbackName => 'Member';

  @override
  String investActiveUntil(String date) {
    return 'Active until $date';
  }

  @override
  String get investActiveLabel => 'Active';

  @override
  String get investPendingVerificationSubtitle =>
      'Waiting for payment verification from admin';

  @override
  String get investFreeLabel => 'Free';

  @override
  String get investNoMembershipSubtitle => 'Haven\'t upgraded membership yet';

  @override
  String get investManualTransferTitle => 'Manual Transfer';

  @override
  String get investBankLabel => 'Bank';

  @override
  String get investAccountNumberLabel => 'Account Number';

  @override
  String get investAccountHolderLabel => 'Account Holder';

  @override
  String get investNominalLabel => 'Amount';

  @override
  String get investTransferInstructionsNote =>
      'After transferring, admin will verify the payment and activate your membership manually.';

  @override
  String get investCheckStatusButton => 'I\'ve transferred, check status';

  @override
  String investConfirmPlanDialogTitle(String planName) {
    return 'Confirm $planName';
  }

  @override
  String investConfirmPlanDialogContent(
    String planName,
    String price,
    int days,
  ) {
    return 'You will upgrade to the $planName plan for $price for $days days.';
  }

  @override
  String get investSwitchPlanWarning =>
      'Your current plan is still active. Switching to another plan will reset your access to Free until the new payment is verified by admin.';

  @override
  String get investConfirmButton => 'Confirm';

  @override
  String get investPlanSelectedSnackbar =>
      'Plan selected. Please transfer according to the instructions above.';

  @override
  String get investSelectPlanError => 'Failed to select plan.';

  @override
  String get investActivePlanLabel => 'Active Plan';

  @override
  String get investSelectPlanButton => 'Select Plan';

  @override
  String investPricePerDuration(String price, int days) {
    return '$price / $days days';
  }

  @override
  String get investPlanFeaturesTitle => 'Features included';

  @override
  String get investPlanFeaturesUnavailable =>
      'Feature details for this plan aren\'t available yet.';

  @override
  String get investCategoryListTitle => 'Categories';

  @override
  String get investCategoryLoadError => 'Failed to load categories.';

  @override
  String get investCategoryEmptyTitle => 'No categories yet';

  @override
  String get investCategoryEmptySubtitle =>
      'Categories are managed by admin via the web app.';

  @override
  String get investRetryButton => 'Retry';

  @override
  String get investProviderListTitle => 'Investment Providers';

  @override
  String get investProviderLoadError => 'Failed to load investment providers.';

  @override
  String get investProviderEmptyTitle => 'No investment providers yet';

  @override
  String get investProviderEmptySubtitle =>
      'Investment providers are managed by admin via the web app.';

  @override
  String get investPayrollCycleTitle => 'Payroll Cycle';

  @override
  String get investPayrollSettingsLoadError => 'Failed to load settings.';

  @override
  String get investPayrollSavedSnackbar => 'Payroll cycle saved successfully.';

  @override
  String get investPayrollDescription =>
      'The payroll cycle start date determines the period used by Dashboard, Budget, and Summary — not the regular calendar 1-31 date.';

  @override
  String get investUseEndOfMonthLabel => 'Use end of month';

  @override
  String get investUseEndOfMonthSubtitle =>
      'Cycle starts from the last date of each month';

  @override
  String get investStartDateLabel => 'Start date';

  @override
  String investDayLabel(int day) {
    return 'Day $day';
  }

  @override
  String get investSelectStartDateTitle => 'Select start date';

  @override
  String get fireTitle => 'Retirement/FIRE Calculator';

  @override
  String get fireLoadError => 'Failed to load financial data.';

  @override
  String get fireRetry => 'Retry';

  @override
  String get fireReturnRateLabel => 'Assumed Annual Investment Return';

  @override
  String get fireCreateGoalButton => 'Create Retirement/FIRE Goal';

  @override
  String get fireGoalName => 'Retirement/FIRE Fund';

  @override
  String get fireAverageIncomeLabel => 'Average Monthly Income';

  @override
  String get fireAverageExpenseLabel => 'Average Monthly Expense';

  @override
  String get fireSavingsRateLabel => 'Savings Rate';

  @override
  String fireAverageBasis(int months) {
    return 'Based on the last $months recorded months';
  }

  @override
  String get fireManualHint =>
      'Your transaction data isn\'t enough yet to calculate an automatic average. Enter it manually below:';

  @override
  String get fireManualIncomeLabel => 'Average monthly income (Rp)';

  @override
  String get fireManualExpenseLabel => 'Average monthly expense (Rp)';

  @override
  String get fireReturnRateConservative => 'Conservative';

  @override
  String get fireReturnRateModerate => 'Moderate';

  @override
  String get fireReturnRateAggressive => 'Aggressive';

  @override
  String get fireProjectionLabel => 'Estimated Time to Financial Independence';

  @override
  String fireYearsToGo(int years) {
    return '$years years to go';
  }

  @override
  String fireNotReachableWithinCap(int years) {
    return 'Not reached within $years years';
  }

  @override
  String fireTargetYear(int year, String amount) {
    return 'Target reached by ±$year · Amount needed $amount';
  }

  @override
  String fireTargetAmountOnly(String amount) {
    return 'Amount needed $amount — increase your savings rate to speed this up';
  }

  @override
  String fireExistingGoalProgress(String name) {
    return 'Progress on \"$name\"';
  }

  @override
  String fireExistingGoalAmounts(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get summaryFireCardSubtitle => 'Project when you can retire';
}
