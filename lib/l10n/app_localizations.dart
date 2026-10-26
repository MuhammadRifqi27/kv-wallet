import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('id'),
  ];

  /// No description provided for @profileAppBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Profile'**
  String get profileAppBarTitle;

  /// No description provided for @profileSectionPortfolio.
  ///
  /// In id, this message translates to:
  /// **'Portfolio'**
  String get profileSectionPortfolio;

  /// No description provided for @profilePortfolioTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Portfolio Saya'**
  String get profilePortfolioTileTitle;

  /// No description provided for @profilePortfolioTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Akun, dompet, dan investasi Anda'**
  String get profilePortfolioTileSubtitle;

  /// No description provided for @profileSavingsGoalTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Tabungan'**
  String get profileSavingsGoalTileTitle;

  /// No description provided for @profileSavingsGoalTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Buat target dan catat nabung/tarik dana'**
  String get profileSavingsGoalTileSubtitle;

  /// No description provided for @profileInvestmentTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Investment / BTC Tracking'**
  String get profileInvestmentTileTitle;

  /// No description provided for @profileInvestmentTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pantau aset crypto dan catat profit/loss'**
  String get profileInvestmentTileSubtitle;

  /// No description provided for @profileSectionDisplay.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get profileSectionDisplay;

  /// No description provided for @profileThemeTitle.
  ///
  /// In id, this message translates to:
  /// **'Tema Aplikasi'**
  String get profileThemeTitle;

  /// No description provided for @profileThemeSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get profileThemeDark;

  /// No description provided for @profileLanguageTitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Aplikasi'**
  String get profileLanguageTitle;

  /// No description provided for @profileLanguageSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get profileLanguageSystem;

  /// No description provided for @profileLanguageIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get profileLanguageIndonesian;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In id, this message translates to:
  /// **'Inggris'**
  String get profileLanguageEnglish;

  /// No description provided for @profileSectionMasterData.
  ///
  /// In id, this message translates to:
  /// **'Master Data'**
  String get profileSectionMasterData;

  /// No description provided for @profileCategoryTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get profileCategoryTileTitle;

  /// No description provided for @profileCategoryTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori pemasukan & pengeluaran'**
  String get profileCategoryTileSubtitle;

  /// No description provided for @profileInvestmentProviderTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Provider Investasi'**
  String get profileInvestmentProviderTileTitle;

  /// No description provided for @profileInvestmentProviderTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bank, exchange, dan broker'**
  String get profileInvestmentProviderTileSubtitle;

  /// No description provided for @profileSectionOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get profileSectionOther;

  /// No description provided for @profilePayrollTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gajian'**
  String get profilePayrollTileTitle;

  /// No description provided for @profilePayrollTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Atur tanggal mulai periode gajian'**
  String get profilePayrollTileSubtitle;

  /// No description provided for @profileCustomerServiceTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Hubungi Customer Service'**
  String get profileCustomerServiceTileTitle;

  /// No description provided for @profileCustomerServiceTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Isi form bantuan'**
  String get profileCustomerServiceTileSubtitle;

  /// No description provided for @profileCustomerServiceLaunchFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat membuka form.'**
  String get profileCustomerServiceLaunchFailed;

  /// No description provided for @profileSectionSecurity.
  ///
  /// In id, this message translates to:
  /// **'Keamanan'**
  String get profileSectionSecurity;

  /// No description provided for @profileChangePasswordTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get profileChangePasswordTileTitle;

  /// No description provided for @profileChangePasswordTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti password akun Anda'**
  String get profileChangePasswordTileSubtitle;

  /// No description provided for @profileChangePinTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah PIN'**
  String get profileChangePinTileTitle;

  /// No description provided for @profileChangePinTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti PIN 6 digit untuk membuka aplikasi'**
  String get profileChangePinTileSubtitle;

  /// No description provided for @profileBiometricTitle.
  ///
  /// In id, this message translates to:
  /// **'Login Biometrik'**
  String get profileBiometricTitle;

  /// No description provided for @profileBiometricSubtitleEnabled.
  ///
  /// In id, this message translates to:
  /// **'Aktif — tap \"Gunakan Biometrik\" di layar kunci untuk masuk tanpa mengetik PIN'**
  String get profileBiometricSubtitleEnabled;

  /// No description provided for @profileBiometricSubtitleDisabled.
  ///
  /// In id, this message translates to:
  /// **'Buka aplikasi dengan sidik jari/Face ID, sebagai pengganti mengetik PIN'**
  String get profileBiometricSubtitleDisabled;

  /// No description provided for @profileBiometricUnsupported.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini tidak mendukung atau belum mendaftarkan biometrik.'**
  String get profileBiometricUnsupported;

  /// No description provided for @profileBiometricEnrollReason.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan login biometrik untuk Flowr'**
  String get profileBiometricEnrollReason;

  /// No description provided for @profileBiometricEnrolledSuccess.
  ///
  /// In id, this message translates to:
  /// **'Biometrik aktif. Mulai sekarang cukup tap \"Gunakan Biometrik\" di layar kunci untuk masuk tanpa PIN.'**
  String get profileBiometricEnrolledSuccess;

  /// No description provided for @profileBiometricEnrollFailed.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi biometrik gagal atau dibatalkan.'**
  String get profileBiometricEnrollFailed;

  /// No description provided for @profileSectionAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get profileSectionAccount;

  /// No description provided for @profileLogoutTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get profileLogoutTileTitle;

  /// No description provided for @profileLogoutTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Logout dari akun ini'**
  String get profileLogoutTileSubtitle;

  /// No description provided for @profileLogoutDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar akun?'**
  String get profileLogoutDialogTitle;

  /// No description provided for @profileLogoutDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Anda perlu login kembali untuk mengakses aplikasi.'**
  String get profileLogoutDialogContent;

  /// No description provided for @profileCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get profileCancel;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get profileLogoutConfirm;

  /// No description provided for @profileEditTooltip.
  ///
  /// In id, this message translates to:
  /// **'Edit Profil'**
  String get profileEditTooltip;

  /// No description provided for @profileMembershipFallback.
  ///
  /// In id, this message translates to:
  /// **'Member'**
  String get profileMembershipFallback;

  /// No description provided for @profileMembershipFree.
  ///
  /// In id, this message translates to:
  /// **'Free'**
  String get profileMembershipFree;

  /// No description provided for @profileAppVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi {version}'**
  String profileAppVersion(String version);

  /// No description provided for @emergencyFundTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalkulator Dana Darurat'**
  String get emergencyFundTitle;

  /// No description provided for @emergencyFundLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data pengeluaran.'**
  String get emergencyFundLoadError;

  /// No description provided for @emergencyFundRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get emergencyFundRetry;

  /// No description provided for @emergencyFundTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target (bulan pengeluaran)'**
  String get emergencyFundTargetLabel;

  /// No description provided for @emergencyFundCreateGoalButton.
  ///
  /// In id, this message translates to:
  /// **'Buat Goal Dana Darurat'**
  String get emergencyFundCreateGoalButton;

  /// No description provided for @emergencyFundGoalName.
  ///
  /// In id, this message translates to:
  /// **'Dana Darurat'**
  String get emergencyFundGoalName;

  /// No description provided for @emergencyFundAverageLabel.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata Pengeluaran Bulanan'**
  String get emergencyFundAverageLabel;

  /// No description provided for @emergencyFundAverageBasis.
  ///
  /// In id, this message translates to:
  /// **'Berdasarkan {months} bulan terakhir tercatat'**
  String emergencyFundAverageBasis(int months);

  /// No description provided for @emergencyFundManualHint.
  ///
  /// In id, this message translates to:
  /// **'Data transaksi kamu belum cukup untuk menghitung rata-rata otomatis. Isi manual di bawah:'**
  String get emergencyFundManualHint;

  /// No description provided for @emergencyFundManualLabel.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata pengeluaran bulanan (Rp)'**
  String get emergencyFundManualLabel;

  /// No description provided for @emergencyFundManualInvalid.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nominal yang valid'**
  String get emergencyFundManualInvalid;

  /// No description provided for @emergencyFundRecommendationLabel.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi Dana Darurat ({multiplier}x pengeluaran bulanan)'**
  String emergencyFundRecommendationLabel(int multiplier);

  /// No description provided for @emergencyFundExistingGoalProgress.
  ///
  /// In id, this message translates to:
  /// **'Progress \"{name}\"'**
  String emergencyFundExistingGoalProgress(String name);

  /// No description provided for @emergencyFundExistingGoalAmounts.
  ///
  /// In id, this message translates to:
  /// **'{saved} dari {target}'**
  String emergencyFundExistingGoalAmounts(String saved, String target);

  /// No description provided for @summaryAppBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get summaryAppBarTitle;

  /// No description provided for @summaryLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat ringkasan.'**
  String get summaryLoadError;

  /// No description provided for @summaryIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get summaryIncomeLabel;

  /// No description provided for @summaryExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get summaryExpenseLabel;

  /// No description provided for @summaryNetProfitLabel.
  ///
  /// In id, this message translates to:
  /// **'Untung Bersih'**
  String get summaryNetProfitLabel;

  /// No description provided for @summarySectionAssetAllocation.
  ///
  /// In id, this message translates to:
  /// **'Alokasi Aset'**
  String get summarySectionAssetAllocation;

  /// No description provided for @summarySectionExpenseBreakdown.
  ///
  /// In id, this message translates to:
  /// **'Breakdown Pengeluaran'**
  String get summarySectionExpenseBreakdown;

  /// No description provided for @summarySectionMonthlyTrend.
  ///
  /// In id, this message translates to:
  /// **'Tren Pemasukan vs Pengeluaran'**
  String get summarySectionMonthlyTrend;

  /// No description provided for @summarySectionSmartAdvisor.
  ///
  /// In id, this message translates to:
  /// **'Smart Advisor'**
  String get summarySectionSmartAdvisor;

  /// No description provided for @summaryNetWorthTitle.
  ///
  /// In id, this message translates to:
  /// **'Total Kekayaan Bersih'**
  String get summaryNetWorthTitle;

  /// No description provided for @summaryNetWorthDelta.
  ///
  /// In id, this message translates to:
  /// **'{sign} {amount} dari bulan lalu'**
  String summaryNetWorthDelta(String sign, String amount);

  /// No description provided for @summaryChangeBadge.
  ///
  /// In id, this message translates to:
  /// **'{percent}% vs lalu'**
  String summaryChangeBadge(String percent);

  /// No description provided for @summarySavingsRateTitle.
  ///
  /// In id, this message translates to:
  /// **'Rasio Menabung'**
  String get summarySavingsRateTitle;

  /// No description provided for @summaryBudgetAllOk.
  ///
  /// In id, this message translates to:
  /// **'Semua kategori masih dalam budget'**
  String get summaryBudgetAllOk;

  /// No description provided for @summaryBudgetOverCount.
  ///
  /// In id, this message translates to:
  /// **'{over} dari {total} kategori melebihi budget'**
  String summaryBudgetOverCount(int over, int total);

  /// No description provided for @summaryEmergencyFundCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hitung rekomendasi nominal ideal'**
  String get summaryEmergencyFundCardSubtitle;

  /// No description provided for @notificationBudgetExceededTitle.
  ///
  /// In id, this message translates to:
  /// **'Budget {category} Terlampaui'**
  String notificationBudgetExceededTitle(String category);

  /// No description provided for @notificationBudgetNearLimitTitle.
  ///
  /// In id, this message translates to:
  /// **'Budget {category} Hampir Habis'**
  String notificationBudgetNearLimitTitle(String category);

  /// No description provided for @notificationBudgetNearLimitBody.
  ///
  /// In id, this message translates to:
  /// **'Sudah terpakai {spent} dari budget {budget} bulan {month} {year}.'**
  String notificationBudgetNearLimitBody(
    String spent,
    String budget,
    String month,
    int year,
  );

  /// No description provided for @notificationBudgetExceededBody.
  ///
  /// In id, this message translates to:
  /// **'Terpakai {spent} dari budget {budget} bulan {month} {year}.'**
  String notificationBudgetExceededBody(
    String spent,
    String budget,
    String month,
    int year,
  );

  /// No description provided for @notificationHistoryAppBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Notifikasi'**
  String get notificationHistoryAppBarTitle;

  /// No description provided for @notificationHistoryEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Notifikasi'**
  String get notificationHistoryEmptyTitle;

  /// No description provided for @notificationHistoryEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi budget yang pernah muncul akan tersimpan di sini.'**
  String get notificationHistoryEmptySubtitle;

  /// No description provided for @profileNotificationHistoryTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Notifikasi'**
  String get profileNotificationHistoryTileTitle;

  /// No description provided for @profileNotificationHistoryTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Lihat notifikasi budget yang pernah muncul'**
  String get profileNotificationHistoryTileSubtitle;

  /// No description provided for @profileNotificationToggleTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Budget'**
  String get profileNotificationToggleTitle;

  /// No description provided for @profileNotificationToggleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Peringatan saat budget hampir habis atau terlampaui'**
  String get profileNotificationToggleSubtitle;

  /// No description provided for @appChangePasswordSuccessMessage.
  ///
  /// In id, this message translates to:
  /// **'Password berhasil diperbarui.'**
  String get appChangePasswordSuccessMessage;

  /// No description provided for @appChangePasswordAppBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get appChangePasswordAppBarTitle;

  /// No description provided for @appChangePasswordCurrentLabel.
  ///
  /// In id, this message translates to:
  /// **'Password saat ini'**
  String get appChangePasswordCurrentLabel;

  /// No description provided for @appChangePasswordCurrentRequired.
  ///
  /// In id, this message translates to:
  /// **'Password saat ini wajib diisi'**
  String get appChangePasswordCurrentRequired;

  /// No description provided for @appChangePasswordNewLabel.
  ///
  /// In id, this message translates to:
  /// **'Password baru'**
  String get appChangePasswordNewLabel;

  /// No description provided for @appChangePasswordNewRequired.
  ///
  /// In id, this message translates to:
  /// **'Password baru wajib diisi'**
  String get appChangePasswordNewRequired;

  /// No description provided for @appChangePasswordMinLength.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get appChangePasswordMinLength;

  /// No description provided for @appChangePasswordConfirmLabel.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password baru'**
  String get appChangePasswordConfirmLabel;

  /// No description provided for @appChangePasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Password tidak cocok'**
  String get appChangePasswordMismatch;

  /// No description provided for @appChangePasswordSaveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get appChangePasswordSaveButton;

  /// No description provided for @appEditProfileSuccessMessage.
  ///
  /// In id, this message translates to:
  /// **'Profil berhasil diperbarui.'**
  String get appEditProfileSuccessMessage;

  /// No description provided for @appEditProfileAppBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Profil'**
  String get appEditProfileAppBarTitle;

  /// No description provided for @appEditProfileNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get appEditProfileNameLabel;

  /// No description provided for @appEditProfileNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get appEditProfileNameRequired;

  /// No description provided for @appEditProfileUsernameLabel.
  ///
  /// In id, this message translates to:
  /// **'Username'**
  String get appEditProfileUsernameLabel;

  /// No description provided for @appEditProfileUsernameRequired.
  ///
  /// In id, this message translates to:
  /// **'Username wajib diisi'**
  String get appEditProfileUsernameRequired;

  /// No description provided for @appEditProfileUsernameNoSpaces.
  ///
  /// In id, this message translates to:
  /// **'Username tidak boleh mengandung spasi'**
  String get appEditProfileUsernameNoSpaces;

  /// No description provided for @appEditProfileEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get appEditProfileEmailLabel;

  /// No description provided for @appEditProfileEmailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email wajib diisi'**
  String get appEditProfileEmailRequired;

  /// No description provided for @appEditProfileEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get appEditProfileEmailInvalid;

  /// No description provided for @appEditProfileSaveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get appEditProfileSaveButton;

  /// No description provided for @appEditProfileSecuritySectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Keamanan'**
  String get appEditProfileSecuritySectionLabel;

  /// No description provided for @appEditProfileChangePasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get appEditProfileChangePasswordTitle;

  /// No description provided for @appEditProfileChangePasswordSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti password akun Anda'**
  String get appEditProfileChangePasswordSubtitle;

  /// No description provided for @appEditProfileChangePinTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah PIN'**
  String get appEditProfileChangePinTitle;

  /// No description provided for @appEditProfileChangePinSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti PIN 6 digit untuk membuka aplikasi'**
  String get appEditProfileChangePinSubtitle;

  /// No description provided for @appCyclePeriodThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan Ini'**
  String get appCyclePeriodThisMonth;

  /// No description provided for @appCyclePeriodLastMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan Lalu'**
  String get appCyclePeriodLastMonth;

  /// No description provided for @appCyclePeriodSelectMonth.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bulan'**
  String get appCyclePeriodSelectMonth;

  /// No description provided for @appNavDashboard.
  ///
  /// In id, this message translates to:
  /// **'Dashboard'**
  String get appNavDashboard;

  /// No description provided for @appNavTransactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get appNavTransactions;

  /// No description provided for @appNavSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get appNavSummary;

  /// No description provided for @appNavBudgets.
  ///
  /// In id, this message translates to:
  /// **'Budget'**
  String get appNavBudgets;

  /// No description provided for @appNavInvestment.
  ///
  /// In id, this message translates to:
  /// **'Investment'**
  String get appNavInvestment;

  /// No description provided for @appNavProfile.
  ///
  /// In id, this message translates to:
  /// **'Profile'**
  String get appNavProfile;

  /// No description provided for @appNavUpgradeRequired.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini khusus akun Member'**
  String get appNavUpgradeRequired;

  /// No description provided for @authLoginWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang kembali'**
  String get authLoginWelcomeTitle;

  /// No description provided for @authLoginWelcomeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan kelola keuangan Anda'**
  String get authLoginWelcomeSubtitle;

  /// No description provided for @authLoginEmailOrUsernameLabel.
  ///
  /// In id, this message translates to:
  /// **'Email atau Username'**
  String get authLoginEmailOrUsernameLabel;

  /// No description provided for @authLoginEmailOrUsernameRequired.
  ///
  /// In id, this message translates to:
  /// **'Email atau username wajib diisi'**
  String get authLoginEmailOrUsernameRequired;

  /// No description provided for @authLoginPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get authLoginPasswordLabel;

  /// No description provided for @authLoginPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi wajib diisi'**
  String get authLoginPasswordRequired;

  /// No description provided for @authLoginForgotPasswordLink.
  ///
  /// In id, this message translates to:
  /// **'Lupa kata sandi?'**
  String get authLoginForgotPasswordLink;

  /// No description provided for @authLoginSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authLoginSubmitButton;

  /// No description provided for @authLoginNoAccountPrompt.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun?'**
  String get authLoginNoAccountPrompt;

  /// No description provided for @authLoginRegisterLink.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get authLoginRegisterLink;

  /// No description provided for @authRegisterTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat akun baru'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Mulai kelola pemasukan & pengeluaran Anda'**
  String get authRegisterSubtitle;

  /// No description provided for @authRegisterInfoBanner.
  ///
  /// In id, this message translates to:
  /// **'Akun langsung aktif setelah daftar — Anda akan diminta membuat PIN 6 digit berikutnya.'**
  String get authRegisterInfoBanner;

  /// No description provided for @authRegisterNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get authRegisterNameLabel;

  /// No description provided for @authRegisterNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get authRegisterNameRequired;

  /// No description provided for @authRegisterUsernameLabel.
  ///
  /// In id, this message translates to:
  /// **'Username'**
  String get authRegisterUsernameLabel;

  /// No description provided for @authRegisterUsernameRequired.
  ///
  /// In id, this message translates to:
  /// **'Username wajib diisi'**
  String get authRegisterUsernameRequired;

  /// No description provided for @authRegisterUsernameNoSpaces.
  ///
  /// In id, this message translates to:
  /// **'Username tidak boleh mengandung spasi'**
  String get authRegisterUsernameNoSpaces;

  /// No description provided for @authRegisterEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get authRegisterEmailLabel;

  /// No description provided for @authRegisterEmailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email wajib diisi'**
  String get authRegisterEmailRequired;

  /// No description provided for @authRegisterEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get authRegisterEmailInvalid;

  /// No description provided for @authRegisterPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get authRegisterPasswordLabel;

  /// No description provided for @authRegisterPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi wajib diisi'**
  String get authRegisterPasswordRequired;

  /// No description provided for @authRegisterPasswordMinLength.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get authRegisterPasswordMinLength;

  /// No description provided for @authRegisterConfirmPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi kata sandi'**
  String get authRegisterConfirmPasswordLabel;

  /// No description provided for @authRegisterPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak cocok'**
  String get authRegisterPasswordMismatch;

  /// No description provided for @authRegisterSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get authRegisterSubmitButton;

  /// No description provided for @authRegisterHaveAccountPrompt.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get authRegisterHaveAccountPrompt;

  /// No description provided for @authRegisterLoginLink.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authRegisterLoginLink;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Lupa Kata Sandi'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Isi form di bawah, admin akan memproses pengajuanmu'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authForgotPasswordInfoBanner.
  ///
  /// In id, this message translates to:
  /// **'Belum ada reset otomatis lewat email. Admin akan menghubungimu lewat WhatsApp/telepon untuk mengirim link reset kata sandi.'**
  String get authForgotPasswordInfoBanner;

  /// No description provided for @authForgotPasswordIdentifierLabel.
  ///
  /// In id, this message translates to:
  /// **'Email atau Username'**
  String get authForgotPasswordIdentifierLabel;

  /// No description provided for @authForgotPasswordIdentifierRequired.
  ///
  /// In id, this message translates to:
  /// **'Email atau username wajib diisi'**
  String get authForgotPasswordIdentifierRequired;

  /// No description provided for @authForgotPasswordPhoneLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp/telepon'**
  String get authForgotPasswordPhoneLabel;

  /// No description provided for @authForgotPasswordPhoneRequired.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp/telepon wajib diisi'**
  String get authForgotPasswordPhoneRequired;

  /// No description provided for @authForgotPasswordPhoneInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format nomor tidak valid'**
  String get authForgotPasswordPhoneInvalid;

  /// No description provided for @authForgotPasswordNoteLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get authForgotPasswordNoteLabel;

  /// No description provided for @authForgotPasswordSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Kirim Pengajuan'**
  String get authForgotPasswordSubmitButton;

  /// No description provided for @authForgotPasswordCheckStatusLink.
  ///
  /// In id, this message translates to:
  /// **'Sudah pernah mengajukan? Cek status'**
  String get authForgotPasswordCheckStatusLink;

  /// No description provided for @authResetStatusAppBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Cek Status Pengajuan'**
  String get authResetStatusAppBarTitle;

  /// No description provided for @authResetStatusDescription.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email atau username yang dipakai saat mengajukan reset kata sandi.'**
  String get authResetStatusDescription;

  /// No description provided for @authResetStatusIdentifierLabel.
  ///
  /// In id, this message translates to:
  /// **'Email atau Username'**
  String get authResetStatusIdentifierLabel;

  /// No description provided for @authResetStatusIdentifierRequired.
  ///
  /// In id, this message translates to:
  /// **'Email atau username wajib diisi'**
  String get authResetStatusIdentifierRequired;

  /// No description provided for @authResetStatusCheckButton.
  ///
  /// In id, this message translates to:
  /// **'Cek Status'**
  String get authResetStatusCheckButton;

  /// No description provided for @authResetStatusPendingTitle.
  ///
  /// In id, this message translates to:
  /// **'Menunggu Diproses Admin'**
  String get authResetStatusPendingTitle;

  /// No description provided for @authResetStatusPendingDescription.
  ///
  /// In id, this message translates to:
  /// **'Admin akan menghubungimu lewat WhatsApp/telepon di nomor yang kamu daftarkan untuk mengirim link reset kata sandi.'**
  String get authResetStatusPendingDescription;

  /// No description provided for @authResetStatusProcessedTitle.
  ///
  /// In id, this message translates to:
  /// **'Sudah Diproses'**
  String get authResetStatusProcessedTitle;

  /// No description provided for @authResetStatusProcessedDescription.
  ///
  /// In id, this message translates to:
  /// **'Admin sudah membuat link reset kata sandi dan seharusnya sudah mengirimkannya lewat WhatsApp/telepon. Buka link tersebut untuk mengatur kata sandi baru.'**
  String get authResetStatusProcessedDescription;

  /// No description provided for @authResetStatusRejectedTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengajuan Ditolak'**
  String get authResetStatusRejectedTitle;

  /// No description provided for @authResetStatusRejectedDescription.
  ///
  /// In id, this message translates to:
  /// **'Admin menolak pengajuan reset kata sandi ini. Silakan ajukan ulang lewat form.'**
  String get authResetStatusRejectedDescription;

  /// No description provided for @authOnboardingSlide1Title.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang di Flowr'**
  String get authOnboardingSlide1Title;

  /// No description provided for @authOnboardingSlide1Description.
  ///
  /// In id, this message translates to:
  /// **'Kelola pemasukan, pengeluaran, dan investasi Anda dalam satu aplikasi.'**
  String get authOnboardingSlide1Description;

  /// No description provided for @authOnboardingSlide2Title.
  ///
  /// In id, this message translates to:
  /// **'Pantau Semua Transaksi'**
  String get authOnboardingSlide2Title;

  /// No description provided for @authOnboardingSlide2Description.
  ///
  /// In id, this message translates to:
  /// **'Catat transaksi harian, lihat ringkasan keuangan, dan pantau portofolio investasi kapan saja.'**
  String get authOnboardingSlide2Description;

  /// No description provided for @authOnboardingSlide3Title.
  ///
  /// In id, this message translates to:
  /// **'Atur Budget & Dapat Peringatan'**
  String get authOnboardingSlide3Title;

  /// No description provided for @authOnboardingSlide3Description.
  ///
  /// In id, this message translates to:
  /// **'Buat batas anggaran per kategori pengeluaran dan dapat notifikasi begitu mulai berlebih.'**
  String get authOnboardingSlide3Description;

  /// No description provided for @authOnboardingSlide4Title.
  ///
  /// In id, this message translates to:
  /// **'Aman dengan PIN'**
  String get authOnboardingSlide4Title;

  /// No description provided for @authOnboardingSlide4Description.
  ///
  /// In id, this message translates to:
  /// **'Akun Anda dilindungi PIN 6 digit setiap kali membuka aplikasi, seperti aplikasi m-banking.'**
  String get authOnboardingSlide4Description;

  /// No description provided for @authOnboardingSkipButton.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get authOnboardingSkipButton;

  /// No description provided for @authOnboardingStartButton.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get authOnboardingStartButton;

  /// No description provided for @authOnboardingNextButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get authOnboardingNextButton;

  /// No description provided for @authSplashTagline.
  ///
  /// In id, this message translates to:
  /// **'Kelola keuangan Anda dengan mudah'**
  String get authSplashTagline;

  /// No description provided for @authConfirmPinTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi PIN Anda'**
  String get authConfirmPinTitle;

  /// No description provided for @authConfirmPinSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN 6 digit saat ini untuk mengaktifkan login biometrik'**
  String get authConfirmPinSubtitle;

  /// No description provided for @authChangePinMismatch.
  ///
  /// In id, this message translates to:
  /// **'PIN tidak cocok, coba lagi'**
  String get authChangePinMismatch;

  /// No description provided for @authChangePinSuccessSnackbar.
  ///
  /// In id, this message translates to:
  /// **'PIN berhasil diperbarui.'**
  String get authChangePinSuccessSnackbar;

  /// No description provided for @authChangePinAppBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah PIN'**
  String get authChangePinAppBarTitle;

  /// No description provided for @authChangePinStepCurrentTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN Saat Ini'**
  String get authChangePinStepCurrentTitle;

  /// No description provided for @authChangePinStepNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat PIN Baru'**
  String get authChangePinStepNewTitle;

  /// No description provided for @authChangePinStepConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi PIN Baru'**
  String get authChangePinStepConfirmTitle;

  /// No description provided for @authChangePinStepCurrentSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN 6 digit yang sedang Anda pakai'**
  String get authChangePinStepCurrentSubtitle;

  /// No description provided for @authChangePinStepNewSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN 6 digit yang baru'**
  String get authChangePinStepNewSubtitle;

  /// No description provided for @authChangePinStepConfirmSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ulang PIN baru untuk konfirmasi'**
  String get authChangePinStepConfirmSubtitle;

  /// No description provided for @authVerifyPinBiometricReason.
  ///
  /// In id, this message translates to:
  /// **'Buka Flowr dengan biometrik'**
  String get authVerifyPinBiometricReason;

  /// No description provided for @authVerifyPinGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {userName}'**
  String authVerifyPinGreeting(String userName);

  /// No description provided for @authVerifyPinEnterPinTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN'**
  String get authVerifyPinEnterPinTitle;

  /// No description provided for @authVerifyPinSubtitleBiometric.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN atau gunakan sidik jari/Face ID untuk membuka aplikasi'**
  String get authVerifyPinSubtitleBiometric;

  /// No description provided for @authVerifyPinSubtitleDefault.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN 6 digit untuk membuka aplikasi'**
  String get authVerifyPinSubtitleDefault;

  /// No description provided for @authVerifyPinUseBiometricButton.
  ///
  /// In id, this message translates to:
  /// **'Gunakan Biometrik'**
  String get authVerifyPinUseBiometricButton;

  /// No description provided for @authVerifyPinNotYouLogout.
  ///
  /// In id, this message translates to:
  /// **'Bukan Anda? Keluar'**
  String get authVerifyPinNotYouLogout;

  /// No description provided for @authVerifyPinLogoutDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Bukan Anda?'**
  String get authVerifyPinLogoutDialogTitle;

  /// No description provided for @authVerifyPinLogoutDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Anda akan logout dan perlu login kembali dengan email/username & password.'**
  String get authVerifyPinLogoutDialogContent;

  /// No description provided for @authVerifyPinLogoutDialogCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get authVerifyPinLogoutDialogCancel;

  /// No description provided for @authVerifyPinLogoutDialogConfirm.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get authVerifyPinLogoutDialogConfirm;

  /// No description provided for @authSetPinMismatch.
  ///
  /// In id, this message translates to:
  /// **'PIN tidak cocok, coba lagi'**
  String get authSetPinMismatch;

  /// No description provided for @authSetPinConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi PIN'**
  String get authSetPinConfirmTitle;

  /// No description provided for @authSetPinCreateTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat PIN 6 Digit'**
  String get authSetPinCreateTitle;

  /// No description provided for @authSetPinConfirmSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ulang PIN yang sama untuk konfirmasi'**
  String get authSetPinConfirmSubtitle;

  /// No description provided for @authSetPinCreateSubtitle.
  ///
  /// In id, this message translates to:
  /// **'PIN ini dipakai untuk membuka aplikasi setiap kali dibuka, mirip aplikasi m-banking'**
  String get authSetPinCreateSubtitle;

  /// No description provided for @authSetPinRestartButton.
  ///
  /// In id, this message translates to:
  /// **'Ulangi dari awal'**
  String get authSetPinRestartButton;

  /// No description provided for @authBiometricPromptTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk lebih cepat dengan biometrik?'**
  String get authBiometricPromptTitle;

  /// No description provided for @authBiometricPromptContent.
  ///
  /// In id, this message translates to:
  /// **'Buka Flowr pakai sidik jari atau Face ID, tanpa perlu mengetik PIN tiap kali. Bisa diaktifkan/dimatikan kapan saja lewat Profile.'**
  String get authBiometricPromptContent;

  /// No description provided for @authBiometricPromptLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get authBiometricPromptLater;

  /// No description provided for @authBiometricPromptEnable.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan'**
  String get authBiometricPromptEnable;

  /// No description provided for @authBiometricPromptEnrollReason.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan login biometrik untuk Flowr'**
  String get authBiometricPromptEnrollReason;

  /// No description provided for @authBiometricPromptSuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Biometrik aktif!'**
  String get authBiometricPromptSuccessTitle;

  /// No description provided for @authBiometricPromptFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengaktifkan'**
  String get authBiometricPromptFailedTitle;

  /// No description provided for @authBiometricPromptSuccessContent.
  ///
  /// In id, this message translates to:
  /// **'Lain kali Anda bisa masuk ke Flowr tanpa mengetik PIN.'**
  String get authBiometricPromptSuccessContent;

  /// No description provided for @authBiometricPromptFailedContent.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi biometrik gagal atau dibatalkan. Anda bisa coba lagi kapan saja lewat Profile.'**
  String get authBiometricPromptFailedContent;

  /// No description provided for @authBiometricPromptOkButton.
  ///
  /// In id, this message translates to:
  /// **'Oke'**
  String get authBiometricPromptOkButton;

  /// No description provided for @walletPortfolioListUpgradeRequired.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini khusus akun Member'**
  String get walletPortfolioListUpgradeRequired;

  /// No description provided for @walletPortfolioListTitle.
  ///
  /// In id, this message translates to:
  /// **'Portfolio'**
  String get walletPortfolioListTitle;

  /// No description provided for @walletPortfolioListLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat portfolio.'**
  String get walletPortfolioListLoadError;

  /// No description provided for @walletPortfolioListEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada akun'**
  String get walletPortfolioListEmptyTitle;

  /// No description provided for @walletPortfolioListEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tekan tombol + untuk menambah akun/dompet pertama Anda.'**
  String get walletPortfolioListEmptySubtitle;

  /// No description provided for @walletPortfolioListTransferTitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer Antar Akun'**
  String get walletPortfolioListTransferTitle;

  /// No description provided for @walletPortfolioListTransferSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan dana antar akun/dompet Anda'**
  String get walletPortfolioListTransferSubtitle;

  /// No description provided for @walletPortfolioListDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus akun?'**
  String get walletPortfolioListDeleteDialogTitle;

  /// No description provided for @walletPortfolioListDeleteDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Akun \"{accountName}\" akan dihapus permanen.'**
  String walletPortfolioListDeleteDialogContent(String accountName);

  /// No description provided for @walletPortfolioListCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get walletPortfolioListCancel;

  /// No description provided for @walletPortfolioListDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get walletPortfolioListDeleteConfirm;

  /// No description provided for @walletPortfolioListProviderFallback.
  ///
  /// In id, this message translates to:
  /// **'Provider #{id}'**
  String walletPortfolioListProviderFallback(int id);

  /// No description provided for @walletPortfolioListEditAction.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get walletPortfolioListEditAction;

  /// No description provided for @walletPortfolioFormProviderRequired.
  ///
  /// In id, this message translates to:
  /// **'Pilih provider investasi terlebih dahulu.'**
  String get walletPortfolioFormProviderRequired;

  /// No description provided for @walletPortfolioFormEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Akun'**
  String get walletPortfolioFormEditTitle;

  /// No description provided for @walletPortfolioFormCreateTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Akun'**
  String get walletPortfolioFormCreateTitle;

  /// No description provided for @walletPortfolioFormProviderLabel.
  ///
  /// In id, this message translates to:
  /// **'Provider'**
  String get walletPortfolioFormProviderLabel;

  /// No description provided for @walletPortfolioFormLoadProvidersError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar provider.'**
  String get walletPortfolioFormLoadProvidersError;

  /// No description provided for @walletPortfolioFormAccountNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama akun'**
  String get walletPortfolioFormAccountNameLabel;

  /// No description provided for @walletPortfolioFormAccountNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama akun wajib diisi'**
  String get walletPortfolioFormAccountNameRequired;

  /// No description provided for @walletPortfolioFormAccountNumberLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor akun (opsional)'**
  String get walletPortfolioFormAccountNumberLabel;

  /// No description provided for @walletPortfolioFormDescriptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi (opsional)'**
  String get walletPortfolioFormDescriptionLabel;

  /// No description provided for @walletPortfolioFormInvestmentAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Akun investasi'**
  String get walletPortfolioFormInvestmentAccountTitle;

  /// No description provided for @walletPortfolioFormInvestmentAccountSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Dana masuk/keluar dicatat sebagai deposit/profit/withdrawal/loss, terpisah dari transaksi biasa'**
  String get walletPortfolioFormInvestmentAccountSubtitle;

  /// No description provided for @walletPortfolioFormSaveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get walletPortfolioFormSaveChanges;

  /// No description provided for @walletPortfolioFormNoProviders.
  ///
  /// In id, this message translates to:
  /// **'Belum ada provider investasi'**
  String get walletPortfolioFormNoProviders;

  /// No description provided for @walletPortfolioFormSelectProvider.
  ///
  /// In id, this message translates to:
  /// **'Pilih provider'**
  String get walletPortfolioFormSelectProvider;

  /// No description provided for @walletPortfolioFormSelectProviderSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih provider investasi'**
  String get walletPortfolioFormSelectProviderSheetTitle;

  /// No description provided for @walletSavingsGoalListTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Tabungan'**
  String get walletSavingsGoalListTitle;

  /// No description provided for @walletSavingsGoalListLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat target tabungan.'**
  String get walletSavingsGoalListLoadError;

  /// No description provided for @walletSavingsGoalListEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada target tabungan'**
  String get walletSavingsGoalListEmptyTitle;

  /// No description provided for @walletSavingsGoalListEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tekan tombol + untuk membuat target pertama Anda.'**
  String get walletSavingsGoalListEmptySubtitle;

  /// No description provided for @walletSavingsGoalListActiveLabel.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get walletSavingsGoalListActiveLabel;

  /// No description provided for @walletSavingsGoalListAchievedLabel.
  ///
  /// In id, this message translates to:
  /// **'Tercapai'**
  String get walletSavingsGoalListAchievedLabel;

  /// No description provided for @walletSavingsGoalListSummarySuffix.
  ///
  /// In id, this message translates to:
  /// **'{label} Goal'**
  String walletSavingsGoalListSummarySuffix(String label);

  /// No description provided for @walletSavingsGoalListDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus target?'**
  String get walletSavingsGoalListDeleteDialogTitle;

  /// No description provided for @walletSavingsGoalListDeleteDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Target \"{name}\" beserta seluruh riwayat nabung/tariknya akan dihapus permanen.'**
  String walletSavingsGoalListDeleteDialogContent(String name);

  /// No description provided for @walletSavingsGoalListCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get walletSavingsGoalListCancel;

  /// No description provided for @walletSavingsGoalListDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get walletSavingsGoalListDeleteConfirm;

  /// No description provided for @walletSavingsGoalListArchiveDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan target?'**
  String get walletSavingsGoalListArchiveDialogTitle;

  /// No description provided for @walletSavingsGoalListArchiveDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Target berhenti dihitung aktif/tercapai, tapi riwayatnya tetap tersimpan. Tidak bisa dibatalkan dari aplikasi.'**
  String get walletSavingsGoalListArchiveDialogContent;

  /// No description provided for @walletSavingsGoalListArchiveConfirm.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan'**
  String get walletSavingsGoalListArchiveConfirm;

  /// No description provided for @walletSavingsGoalListEditAction.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get walletSavingsGoalListEditAction;

  /// No description provided for @walletSavingsGoalListProgressAmounts.
  ///
  /// In id, this message translates to:
  /// **'{saved} dari {target}'**
  String walletSavingsGoalListProgressAmounts(String saved, String target);

  /// No description provided for @walletSavingsGoalListOverAllocatedWarning.
  ///
  /// In id, this message translates to:
  /// **'Total alokasi ke akun ini melebihi saldo aslinya.'**
  String get walletSavingsGoalListOverAllocatedWarning;

  /// No description provided for @walletSavingsGoalFormEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Target Tabungan'**
  String get walletSavingsGoalFormEditTitle;

  /// No description provided for @walletSavingsGoalFormCreateTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Tabungan Baru'**
  String get walletSavingsGoalFormCreateTitle;

  /// No description provided for @walletSavingsGoalFormNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama target'**
  String get walletSavingsGoalFormNameLabel;

  /// No description provided for @walletSavingsGoalFormNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama target wajib diisi'**
  String get walletSavingsGoalFormNameRequired;

  /// No description provided for @walletSavingsGoalFormPurposeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tujuan (opsional)'**
  String get walletSavingsGoalFormPurposeLabel;

  /// No description provided for @walletSavingsGoalFormTargetAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah Target (Rp)'**
  String get walletSavingsGoalFormTargetAmountLabel;

  /// No description provided for @walletSavingsGoalFormTargetAmountRequired.
  ///
  /// In id, this message translates to:
  /// **'Jumlah target wajib diisi'**
  String get walletSavingsGoalFormTargetAmountRequired;

  /// No description provided for @walletSavingsGoalFormAmountInvalid.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak valid'**
  String get walletSavingsGoalFormAmountInvalid;

  /// No description provided for @walletSavingsGoalFormDeadlineLabel.
  ///
  /// In id, this message translates to:
  /// **'Tenggat (opsional)'**
  String get walletSavingsGoalFormDeadlineLabel;

  /// No description provided for @walletSavingsGoalFormNoDeadline.
  ///
  /// In id, this message translates to:
  /// **'Tanpa tenggat'**
  String get walletSavingsGoalFormNoDeadline;

  /// No description provided for @walletSavingsGoalFormSourceAccountLabel.
  ///
  /// In id, this message translates to:
  /// **'Akun sumber dana (opsional)'**
  String get walletSavingsGoalFormSourceAccountLabel;

  /// No description provided for @walletSavingsGoalFormLoadAccountsError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar akun.'**
  String get walletSavingsGoalFormLoadAccountsError;

  /// No description provided for @walletSavingsGoalFormNoAccounts.
  ///
  /// In id, this message translates to:
  /// **'Belum ada akun'**
  String get walletSavingsGoalFormNoAccounts;

  /// No description provided for @walletSavingsGoalFormNoAccountBound.
  ///
  /// In id, this message translates to:
  /// **'Tidak diikat ke akun manapun'**
  String get walletSavingsGoalFormNoAccountBound;

  /// No description provided for @walletSavingsGoalFormColorLabel.
  ///
  /// In id, this message translates to:
  /// **'Warna'**
  String get walletSavingsGoalFormColorLabel;

  /// No description provided for @walletSavingsGoalFormIconLabel.
  ///
  /// In id, this message translates to:
  /// **'Ikon'**
  String get walletSavingsGoalFormIconLabel;

  /// No description provided for @walletSavingsGoalFormSaveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get walletSavingsGoalFormSaveChanges;

  /// No description provided for @walletSavingsGoalFormCreateAction.
  ///
  /// In id, this message translates to:
  /// **'Buat Target'**
  String get walletSavingsGoalFormCreateAction;

  /// No description provided for @walletSavingsGoalFormPickAccountSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun sumber dana'**
  String get walletSavingsGoalFormPickAccountSheetTitle;

  /// No description provided for @walletSavingsGoalDetailAddEntryTooltip.
  ///
  /// In id, this message translates to:
  /// **'Catat Nabung/Tarik'**
  String get walletSavingsGoalDetailAddEntryTooltip;

  /// No description provided for @walletSavingsGoalDetailHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Nabung/Tarik'**
  String get walletSavingsGoalDetailHistoryTitle;

  /// No description provided for @walletSavingsGoalDetailLoadHistoryError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat riwayat.'**
  String get walletSavingsGoalDetailLoadHistoryError;

  /// No description provided for @walletSavingsGoalDetailEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat'**
  String get walletSavingsGoalDetailEmptyTitle;

  /// No description provided for @walletSavingsGoalDetailEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tekan tombol + untuk mencatat nabung/tarik pertama.'**
  String get walletSavingsGoalDetailEmptySubtitle;

  /// No description provided for @walletSavingsGoalDetailCollectedLabel.
  ///
  /// In id, this message translates to:
  /// **'Terkumpul'**
  String get walletSavingsGoalDetailCollectedLabel;

  /// No description provided for @walletSavingsGoalDetailTargetAmount.
  ///
  /// In id, this message translates to:
  /// **'Target {amount}'**
  String walletSavingsGoalDetailTargetAmount(String amount);

  /// No description provided for @walletSavingsGoalDetailRemainingAmount.
  ///
  /// In id, this message translates to:
  /// **'Kurang {amount} lagi'**
  String walletSavingsGoalDetailRemainingAmount(String amount);

  /// No description provided for @walletSavingsGoalDetailDeadline.
  ///
  /// In id, this message translates to:
  /// **'Tenggat {date}'**
  String walletSavingsGoalDetailDeadline(String date);

  /// No description provided for @walletSavingsGoalDetailDefaultAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun default: {name}'**
  String walletSavingsGoalDetailDefaultAccount(String name);

  /// No description provided for @walletSavingsGoalDetailOverAllocatedWarning.
  ///
  /// In id, this message translates to:
  /// **'Total alokasi ke akun ini dari semua goal sudah melebihi saldo aslinya.'**
  String get walletSavingsGoalDetailOverAllocatedWarning;

  /// No description provided for @walletSavingsGoalDetailDeleteEntryTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus baris ini?'**
  String get walletSavingsGoalDetailDeleteEntryTitle;

  /// No description provided for @walletSavingsGoalDetailDeleteEntryContent.
  ///
  /// In id, this message translates to:
  /// **'Baris riwayat ini akan dihapus permanen dan progress target dihitung ulang.'**
  String get walletSavingsGoalDetailDeleteEntryContent;

  /// No description provided for @walletSavingsGoalDetailCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get walletSavingsGoalDetailCancel;

  /// No description provided for @walletSavingsGoalDetailDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get walletSavingsGoalDetailDeleteConfirm;

  /// No description provided for @walletSavingsGoalDetailWithdrawLabel.
  ///
  /// In id, this message translates to:
  /// **'Tarik'**
  String get walletSavingsGoalDetailWithdrawLabel;

  /// No description provided for @walletSavingsGoalDetailContributeLabel.
  ///
  /// In id, this message translates to:
  /// **'Nabung'**
  String get walletSavingsGoalDetailContributeLabel;

  /// No description provided for @walletSavingsGoalDetailDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get walletSavingsGoalDetailDateLabel;

  /// No description provided for @walletSavingsGoalDetailAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah (Rp)'**
  String get walletSavingsGoalDetailAmountLabel;

  /// No description provided for @walletSavingsGoalDetailAmountRequired.
  ///
  /// In id, this message translates to:
  /// **'Jumlah wajib diisi'**
  String get walletSavingsGoalDetailAmountRequired;

  /// No description provided for @walletSavingsGoalDetailAmountInvalid.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak valid'**
  String get walletSavingsGoalDetailAmountInvalid;

  /// No description provided for @walletSavingsGoalDetailAccountLabel.
  ///
  /// In id, this message translates to:
  /// **'Akun (opsional)'**
  String get walletSavingsGoalDetailAccountLabel;

  /// No description provided for @walletSavingsGoalDetailLoadAccountsError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar akun.'**
  String get walletSavingsGoalDetailLoadAccountsError;

  /// No description provided for @walletSavingsGoalDetailNoAccounts.
  ///
  /// In id, this message translates to:
  /// **'Belum ada akun'**
  String get walletSavingsGoalDetailNoAccounts;

  /// No description provided for @walletSavingsGoalDetailNoAccountRecorded.
  ///
  /// In id, this message translates to:
  /// **'Tidak dicatat ke akun manapun'**
  String get walletSavingsGoalDetailNoAccountRecorded;

  /// No description provided for @walletSavingsGoalDetailNoteLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get walletSavingsGoalDetailNoteLabel;

  /// No description provided for @walletSavingsGoalDetailSaveAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get walletSavingsGoalDetailSaveAction;

  /// No description provided for @walletSavingsGoalDetailPickAccountSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun'**
  String get walletSavingsGoalDetailPickAccountSheetTitle;

  /// No description provided for @walletGoalStatusAchieved.
  ///
  /// In id, this message translates to:
  /// **'Tercapai'**
  String get walletGoalStatusAchieved;

  /// No description provided for @walletGoalStatusArchived.
  ///
  /// In id, this message translates to:
  /// **'Diarsipkan'**
  String get walletGoalStatusArchived;

  /// No description provided for @walletGoalStatusActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get walletGoalStatusActive;

  /// No description provided for @walletDashboardLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat dashboard.'**
  String get walletDashboardLoadError;

  /// No description provided for @walletDashboardCashBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo Kas'**
  String get walletDashboardCashBalanceLabel;

  /// No description provided for @walletDashboardInvestmentBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo Investasi'**
  String get walletDashboardInvestmentBalanceLabel;

  /// No description provided for @walletDashboardIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get walletDashboardIncomeLabel;

  /// No description provided for @walletDashboardExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get walletDashboardExpenseLabel;

  /// No description provided for @walletDashboardDailyAccountsTitle.
  ///
  /// In id, this message translates to:
  /// **'Akun Harian'**
  String get walletDashboardDailyAccountsTitle;

  /// No description provided for @walletDashboardInvestmentAccountsTitle.
  ///
  /// In id, this message translates to:
  /// **'Akun Investasi'**
  String get walletDashboardInvestmentAccountsTitle;

  /// No description provided for @walletDashboardIncomeSourcesTitle.
  ///
  /// In id, this message translates to:
  /// **'Sumber Pemasukan'**
  String get walletDashboardIncomeSourcesTitle;

  /// No description provided for @walletDashboardTopCategoriesTitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori Terbesar'**
  String get walletDashboardTopCategoriesTitle;

  /// No description provided for @walletDashboardRecentTransactionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Terbaru'**
  String get walletDashboardRecentTransactionsTitle;

  /// No description provided for @walletDashboardEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Aktivitas'**
  String get walletDashboardEmptyTitle;

  /// No description provided for @walletDashboardEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Catat transaksi pertamamu untuk mulai lihat ringkasan keuangan di sini.'**
  String get walletDashboardEmptySubtitle;

  /// No description provided for @walletDashboardEmptyCta.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get walletDashboardEmptyCta;

  /// No description provided for @walletDashboardGreetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat Pagi, {name}'**
  String walletDashboardGreetingMorning(String name);

  /// No description provided for @walletDashboardGreetingMidday.
  ///
  /// In id, this message translates to:
  /// **'Selamat Siang, {name}'**
  String walletDashboardGreetingMidday(String name);

  /// No description provided for @walletDashboardGreetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat Sore, {name}'**
  String walletDashboardGreetingAfternoon(String name);

  /// No description provided for @walletDashboardGreetingNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat Malam, {name}'**
  String walletDashboardGreetingNight(String name);

  /// No description provided for @walletDashboardGreetingPayday.
  ///
  /// In id, this message translates to:
  /// **'Selamat Gajian, {name}'**
  String walletDashboardGreetingPayday(String name);

  /// No description provided for @walletDashboardGreetingEndingSoon.
  ///
  /// In id, this message translates to:
  /// **'Gajian Sebentar Lagi, {name}'**
  String walletDashboardGreetingEndingSoon(String name);

  /// No description provided for @walletDashboardCycleRange.
  ///
  /// In id, this message translates to:
  /// **'Siklus {start} — {end}'**
  String walletDashboardCycleRange(String start, String end);

  /// No description provided for @walletDashboardNetWorthLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Kekayaan Bersih'**
  String get walletDashboardNetWorthLabel;

  /// No description provided for @walletDashboardToggleNominalShow.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan nominal'**
  String get walletDashboardToggleNominalShow;

  /// No description provided for @walletDashboardToggleNominalHide.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan nominal'**
  String get walletDashboardToggleNominalHide;

  /// No description provided for @pinCodeFieldSemanticLabel.
  ///
  /// In id, this message translates to:
  /// **'Input kode PIN, {filled} dari {total} digit terisi'**
  String pinCodeFieldSemanticLabel(int filled, int total);

  /// No description provided for @walletDashboardSavingsGoalsCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Tabungan'**
  String get walletDashboardSavingsGoalsCardTitle;

  /// No description provided for @walletDashboardSavingsGoalsSummary.
  ///
  /// In id, this message translates to:
  /// **'{active} aktif · {achieved} tercapai'**
  String walletDashboardSavingsGoalsSummary(int active, int achieved);

  /// No description provided for @walletDashboardSavingsGoalProgress.
  ///
  /// In id, this message translates to:
  /// **'{saved} dari {target}'**
  String walletDashboardSavingsGoalProgress(String saved, String target);

  /// No description provided for @txnCommonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get txnCommonCancel;

  /// No description provided for @txnCommonDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get txnCommonDelete;

  /// No description provided for @txnCommonEdit.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get txnCommonEdit;

  /// No description provided for @txnIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get txnIncomeLabel;

  /// No description provided for @txnExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get txnExpenseLabel;

  /// No description provided for @txnFilterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get txnFilterAll;

  /// No description provided for @txnCommonSaveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get txnCommonSaveChanges;

  /// No description provided for @txnCommonAmountRequired.
  ///
  /// In id, this message translates to:
  /// **'Jumlah wajib diisi'**
  String get txnCommonAmountRequired;

  /// No description provided for @txnCommonAmountInvalid.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak valid'**
  String get txnCommonAmountInvalid;

  /// No description provided for @txnCommonSelectCategoryFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori terlebih dahulu.'**
  String get txnCommonSelectCategoryFirst;

  /// No description provided for @txnCommonCategoryLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kategori.'**
  String get txnCommonCategoryLoadError;

  /// No description provided for @txnCommonAccountLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat akun.'**
  String get txnCommonAccountLoadError;

  /// No description provided for @txnCommonDescriptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi (opsional)'**
  String get txnCommonDescriptionLabel;

  /// No description provided for @txnCommonAmountRpLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah (Rp)'**
  String get txnCommonAmountRpLabel;

  /// No description provided for @txnCommonSelectCategoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori'**
  String get txnCommonSelectCategoryTitle;

  /// No description provided for @txnCategoryTypeIncome.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get txnCategoryTypeIncome;

  /// No description provided for @txnCategoryTypeExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get txnCategoryTypeExpense;

  /// No description provided for @txnCommonNoCategoryForType.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori untuk tipe ini'**
  String get txnCommonNoCategoryForType;

  /// No description provided for @txnCommonSelectAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun'**
  String get txnCommonSelectAccountTitle;

  /// No description provided for @txnCommonNoneOption.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada'**
  String get txnCommonNoneOption;

  /// No description provided for @txnCommonDateSectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get txnCommonDateSectionLabel;

  /// No description provided for @txnCommonTypeSectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Tipe'**
  String get txnCommonTypeSectionLabel;

  /// No description provided for @txnCommonCategorySectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get txnCommonCategorySectionLabel;

  /// No description provided for @txnCommonNoAccountAvailable.
  ///
  /// In id, this message translates to:
  /// **'Belum ada akun'**
  String get txnCommonNoAccountAvailable;

  /// No description provided for @txnCategoryFallbackName.
  ///
  /// In id, this message translates to:
  /// **'Kategori #{id}'**
  String txnCategoryFallbackName(int id);

  /// No description provided for @txnAccountFallbackName.
  ///
  /// In id, this message translates to:
  /// **'Akun #{id}'**
  String txnAccountFallbackName(int id);

  /// No description provided for @txnRecurringMenuTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Berulang'**
  String get txnRecurringMenuTileTitle;

  /// No description provided for @txnFeatureRequiresUpgrade.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini khusus akun Member'**
  String get txnFeatureRequiresUpgrade;

  /// No description provided for @txnListTitle.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get txnListTitle;

  /// No description provided for @txnListLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat transaksi.'**
  String get txnListLoadError;

  /// No description provided for @txnListEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get txnListEmptyTitle;

  /// No description provided for @txnListEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tekan tombol + untuk mencatat pemasukan atau pengeluaran.'**
  String get txnListEmptySubtitle;

  /// No description provided for @txnListNoResultsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil'**
  String get txnListNoResultsTitle;

  /// No description provided for @txnListNoResultsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi yang cocok dengan pencarian ini.'**
  String get txnListNoResultsSubtitle;

  /// No description provided for @txnListLoadMore.
  ///
  /// In id, this message translates to:
  /// **'Muat transaksi lebih lama'**
  String get txnListLoadMore;

  /// No description provided for @txnSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari kategori, catatan, atau akun'**
  String get txnSearchHint;

  /// No description provided for @txnNetBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo Bersih'**
  String get txnNetBalanceLabel;

  /// No description provided for @txnDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus transaksi?'**
  String get txnDeleteDialogTitle;

  /// No description provided for @txnDeleteDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Transaksi ini akan dihapus permanen.'**
  String get txnDeleteDialogContent;

  /// No description provided for @txnRecurringMenuTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola tagihan/pemasukan otomatis berkala'**
  String get txnRecurringMenuTileSubtitle;

  /// No description provided for @txnPickDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih Tanggal'**
  String get txnPickDateLabel;

  /// No description provided for @txnFilterThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan Ini'**
  String get txnFilterThisMonth;

  /// No description provided for @txnFilterLastMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan Lalu'**
  String get txnFilterLastMonth;

  /// No description provided for @txnFilterLast7Days.
  ///
  /// In id, this message translates to:
  /// **'7 Hari Terakhir'**
  String get txnFilterLast7Days;

  /// No description provided for @txnFilterLast30Days.
  ///
  /// In id, this message translates to:
  /// **'30 Hari Terakhir'**
  String get txnFilterLast30Days;

  /// No description provided for @txnScanReceiptFailedMessage.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa membaca struk ini, silakan isi manual.'**
  String get txnScanReceiptFailedMessage;

  /// No description provided for @txnScanReceiptAutofilledMessage.
  ///
  /// In id, this message translates to:
  /// **'Terisi otomatis dari struk — mohon periksa kembali sebelum simpan.'**
  String get txnScanReceiptAutofilledMessage;

  /// No description provided for @txnScanReceiptNoDataMessage.
  ///
  /// In id, this message translates to:
  /// **'Teks struk terbaca, tapi tidak ada info yang bisa dikenali — silakan isi manual.'**
  String get txnScanReceiptNoDataMessage;

  /// No description provided for @txnScanReceiptFieldAutofilledBadge.
  ///
  /// In id, this message translates to:
  /// **'Terisi otomatis dari scan struk'**
  String get txnScanReceiptFieldAutofilledBadge;

  /// No description provided for @txnScanReceiptFieldGuessBadge.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan dari scan struk — mohon cek kembali'**
  String get txnScanReceiptFieldGuessBadge;

  /// No description provided for @txnFormTitleEdit.
  ///
  /// In id, this message translates to:
  /// **'Edit Transaksi'**
  String get txnFormTitleEdit;

  /// No description provided for @txnFormTitleAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah Transaksi'**
  String get txnFormTitleAdd;

  /// No description provided for @txnFormAccountOptionalLabel.
  ///
  /// In id, this message translates to:
  /// **'Akun (opsional)'**
  String get txnFormAccountOptionalLabel;

  /// No description provided for @txnScanReceiptScanning.
  ///
  /// In id, this message translates to:
  /// **'Membaca struk...'**
  String get txnScanReceiptScanning;

  /// No description provided for @txnScanReceiptButtonLabel.
  ///
  /// In id, this message translates to:
  /// **'Scan Struk'**
  String get txnScanReceiptButtonLabel;

  /// No description provided for @txnScanSourceCamera.
  ///
  /// In id, this message translates to:
  /// **'Ambil Foto'**
  String get txnScanSourceCamera;

  /// No description provided for @txnScanSourceGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari Galeri'**
  String get txnScanSourceGallery;

  /// No description provided for @txnRecurringListLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat transaksi berulang.'**
  String get txnRecurringListLoadError;

  /// No description provided for @txnRecurringListEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi berulang'**
  String get txnRecurringListEmptyTitle;

  /// No description provided for @txnRecurringListEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tekan tombol + untuk membuat template, misal tagihan bulanan.'**
  String get txnRecurringListEmptySubtitle;

  /// No description provided for @txnRecurringDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus transaksi berulang?'**
  String get txnRecurringDeleteDialogTitle;

  /// No description provided for @txnRecurringDeleteDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Template \"{name}\" akan dihapus permanen. Transaksi yang sudah pernah dibuat tidak terhapus.'**
  String txnRecurringDeleteDialogContent(String name);

  /// No description provided for @txnRecurringNextDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Berikutnya {date}'**
  String txnRecurringNextDateLabel(String date);

  /// No description provided for @txnRecurringSelectAccountFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun terlebih dahulu.'**
  String get txnRecurringSelectAccountFirst;

  /// No description provided for @txnRecurringFormTitleEdit.
  ///
  /// In id, this message translates to:
  /// **'Edit Transaksi Berulang'**
  String get txnRecurringFormTitleEdit;

  /// No description provided for @txnRecurringFormTitleAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah Transaksi Berulang'**
  String get txnRecurringFormTitleAdd;

  /// No description provided for @txnRecurringNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get txnRecurringNameLabel;

  /// No description provided for @txnRecurringNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get txnRecurringNameRequired;

  /// No description provided for @txnRecurringAccountSectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get txnRecurringAccountSectionLabel;

  /// No description provided for @txnRecurringFrequencyLabel.
  ///
  /// In id, this message translates to:
  /// **'Frekuensi'**
  String get txnRecurringFrequencyLabel;

  /// No description provided for @txnRecurringFrequencyDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get txnRecurringFrequencyDaily;

  /// No description provided for @txnRecurringFrequencyWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get txnRecurringFrequencyWeekly;

  /// No description provided for @txnRecurringFrequencyMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get txnRecurringFrequencyMonthly;

  /// No description provided for @txnRecurringFrequencyYearly.
  ///
  /// In id, this message translates to:
  /// **'Tahunan'**
  String get txnRecurringFrequencyYearly;

  /// No description provided for @txnRecurringStartDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Mulai Tanggal'**
  String get txnRecurringStartDateLabel;

  /// No description provided for @txnRecurringStartDateHistoricalNote.
  ///
  /// In id, this message translates to:
  /// **'Template ini sudah pernah diproses, jadi mengubah tanggal ini tidak menggeser jadwal berikutnya — cuma jadi catatan kapan pertama dibuat.'**
  String get txnRecurringStartDateHistoricalNote;

  /// No description provided for @txnRecurringSubmitAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get txnRecurringSubmitAdd;

  /// No description provided for @txnRecurringPickFrequencyTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih frekuensi'**
  String get txnRecurringPickFrequencyTitle;

  /// No description provided for @txnTransferListTitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer Antar Akun'**
  String get txnTransferListTitle;

  /// No description provided for @txnTransferListLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat transfer.'**
  String get txnTransferListLoadError;

  /// No description provided for @txnTransferListEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transfer'**
  String get txnTransferListEmptyTitle;

  /// No description provided for @txnTransferListEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tekan tombol + untuk memindahkan dana antar akun Anda.'**
  String get txnTransferListEmptySubtitle;

  /// No description provided for @txnTransferDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus transfer?'**
  String get txnTransferDeleteDialogTitle;

  /// No description provided for @txnTransferDeleteDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Transfer ini akan dihapus permanen, saldo kedua akun akan disesuaikan kembali.'**
  String get txnTransferDeleteDialogContent;

  /// No description provided for @txnTransferSelectAccountsError.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun asal dan akun tujuan.'**
  String get txnTransferSelectAccountsError;

  /// No description provided for @txnTransferSameAccountError.
  ///
  /// In id, this message translates to:
  /// **'Akun asal dan tujuan tidak boleh sama.'**
  String get txnTransferSameAccountError;

  /// No description provided for @txnTransferInsufficientBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo tidak cukup (tersedia {balance})'**
  String txnTransferInsufficientBalance(String balance);

  /// No description provided for @txnTransferAssetRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Isi simbol aset (mis. BTC) — salah satu akun tipe crypto.'**
  String get txnTransferAssetRequiredError;

  /// No description provided for @txnTransferFormTitleEdit.
  ///
  /// In id, this message translates to:
  /// **'Edit Transfer'**
  String get txnTransferFormTitleEdit;

  /// No description provided for @txnTransferFromAccountLabel.
  ///
  /// In id, this message translates to:
  /// **'Dari Akun'**
  String get txnTransferFromAccountLabel;

  /// No description provided for @txnTransferFromAccountPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun asal'**
  String get txnTransferFromAccountPlaceholder;

  /// No description provided for @txnTransferToAccountLabel.
  ///
  /// In id, this message translates to:
  /// **'Ke Akun'**
  String get txnTransferToAccountLabel;

  /// No description provided for @txnTransferToAccountPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun tujuan'**
  String get txnTransferToAccountPlaceholder;

  /// No description provided for @txnTransferAssetSectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Aset'**
  String get txnTransferAssetSectionLabel;

  /// No description provided for @txnTransferAssetHint.
  ///
  /// In id, this message translates to:
  /// **'Salah satu akun tipe crypto — isi simbol asetnya supaya masuk breakdown per-aset di Investment (topup maupun withdrawal/profit taking).'**
  String get txnTransferAssetHint;

  /// No description provided for @txnTransferAssetFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Simbol aset (mis. BTC)'**
  String get txnTransferAssetFieldLabel;

  /// No description provided for @txnTransferSubmitLabel.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get txnTransferSubmitLabel;

  /// No description provided for @txnBudgetListTitle.
  ///
  /// In id, this message translates to:
  /// **'Budget'**
  String get txnBudgetListTitle;

  /// No description provided for @txnBudgetListLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat budget.'**
  String get txnBudgetListLoadError;

  /// No description provided for @txnBudgetListEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Budget'**
  String get txnBudgetListEmptyTitle;

  /// No description provided for @txnBudgetListEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Tap tombol + untuk menambah budget bulan ini.'**
  String get txnBudgetListEmptyMessage;

  /// No description provided for @txnBudgetPerCategoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Per Kategori'**
  String get txnBudgetPerCategoryLabel;

  /// No description provided for @txnBudgetTapToEditHint.
  ///
  /// In id, this message translates to:
  /// **'Tap salah satu untuk mengubah jumlah budget-nya.'**
  String get txnBudgetTapToEditHint;

  /// No description provided for @txnBudgetTotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Budget'**
  String get txnBudgetTotalLabel;

  /// No description provided for @txnBudgetUsedAmount.
  ///
  /// In id, this message translates to:
  /// **'Terpakai {amount}'**
  String txnBudgetUsedAmount(String amount);

  /// No description provided for @txnBudgetCategoryOverBudget.
  ///
  /// In id, this message translates to:
  /// **'Terpakai {spent} — melebihi budget'**
  String txnBudgetCategoryOverBudget(String spent);

  /// No description provided for @txnBudgetCategoryUsedOfTotal.
  ///
  /// In id, this message translates to:
  /// **'Terpakai {spent} dari {total}'**
  String txnBudgetCategoryUsedOfTotal(String spent, String total);

  /// No description provided for @txnBudgetFormTitleEdit.
  ///
  /// In id, this message translates to:
  /// **'Edit Budget'**
  String get txnBudgetFormTitleEdit;

  /// No description provided for @txnBudgetFormTitleAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah Budget'**
  String get txnBudgetFormTitleAdd;

  /// No description provided for @txnBudgetFormPeriodLabel.
  ///
  /// In id, this message translates to:
  /// **'Untuk periode {month} {year}'**
  String txnBudgetFormPeriodLabel(String month, int year);

  /// No description provided for @txnBudgetExpenseCategoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori Pengeluaran'**
  String get txnBudgetExpenseCategoryLabel;

  /// No description provided for @txnBudgetAllCategoriesBudgeted.
  ///
  /// In id, this message translates to:
  /// **'Semua kategori sudah punya budget'**
  String get txnBudgetAllCategoriesBudgeted;

  /// No description provided for @txnBudgetAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah Budget (Rp)'**
  String get txnBudgetAmountLabel;

  /// No description provided for @investDashboardTitle.
  ///
  /// In id, this message translates to:
  /// **'Investment'**
  String get investDashboardTitle;

  /// No description provided for @investActivityHistoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Aktivitas'**
  String get investActivityHistoryLabel;

  /// No description provided for @investRecordProfitLossTooltip.
  ///
  /// In id, this message translates to:
  /// **'Catat Profit/Loss'**
  String get investRecordProfitLossTooltip;

  /// No description provided for @investLoadErrorMessage.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data investasi.'**
  String get investLoadErrorMessage;

  /// No description provided for @investYourAssetsLabel.
  ///
  /// In id, this message translates to:
  /// **'Aset Anda'**
  String get investYourAssetsLabel;

  /// No description provided for @investTotalCryptoValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Nilai Crypto'**
  String get investTotalCryptoValueLabel;

  /// No description provided for @investAssetCountEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada aset'**
  String get investAssetCountEmpty;

  /// No description provided for @investAssetCountTracked.
  ///
  /// In id, this message translates to:
  /// **'{count} aset dilacak'**
  String investAssetCountTracked(int count);

  /// No description provided for @investPnl24hFull.
  ///
  /// In id, this message translates to:
  /// **'PnL {amount} (24 jam)'**
  String investPnl24hFull(String amount);

  /// No description provided for @investPnl24hShort.
  ///
  /// In id, this message translates to:
  /// **'PnL {amount} (24j)'**
  String investPnl24hShort(String amount);

  /// No description provided for @investPriceUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Harga tidak tersedia'**
  String get investPriceUnavailable;

  /// No description provided for @investEmptyCryptoAccountsTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada akun crypto'**
  String get investEmptyCryptoAccountsTitle;

  /// No description provided for @investEmptyCryptoAccountsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah akun dengan provider bertipe Crypto lewat Portfolio, lalu top up saldonya lewat Transfer Antar Akun.'**
  String get investEmptyCryptoAccountsSubtitle;

  /// No description provided for @investHeldInAccountsTitle.
  ///
  /// In id, this message translates to:
  /// **'Dipegang di Akun'**
  String get investHeldInAccountsTitle;

  /// No description provided for @investHeldInAccountsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Dihitung dari riwayat aktivitas — lihat catatan di kode kalau angkanya tampak meleset.'**
  String get investHeldInAccountsSubtitle;

  /// No description provided for @investCurrentPriceLabel.
  ///
  /// In id, this message translates to:
  /// **'Harga Saat Ini'**
  String get investCurrentPriceLabel;

  /// No description provided for @investChangePercent24h.
  ///
  /// In id, this message translates to:
  /// **'{percent}% (24 jam)'**
  String investChangePercent24h(String percent);

  /// No description provided for @investTotalHeldLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Anda Miliki'**
  String get investTotalHeldLabel;

  /// No description provided for @investApproxQuantityBtc.
  ///
  /// In id, this message translates to:
  /// **'≈ {quantity} BTC'**
  String investApproxQuantityBtc(String quantity);

  /// No description provided for @investPerformanceTitle.
  ///
  /// In id, this message translates to:
  /// **'Performa (Floating PnL)'**
  String get investPerformanceTitle;

  /// No description provided for @investPeriod24h.
  ///
  /// In id, this message translates to:
  /// **'24 Jam'**
  String get investPeriod24h;

  /// No description provided for @investPeriod1w.
  ///
  /// In id, this message translates to:
  /// **'1 Minggu'**
  String get investPeriod1w;

  /// No description provided for @investPeriod1m.
  ///
  /// In id, this message translates to:
  /// **'1 Bulan'**
  String get investPeriod1m;

  /// No description provided for @investPeriod3m.
  ///
  /// In id, this message translates to:
  /// **'3 Bulan'**
  String get investPeriod3m;

  /// No description provided for @investPeriod6m.
  ///
  /// In id, this message translates to:
  /// **'6 Bulan'**
  String get investPeriod6m;

  /// No description provided for @investPeriod5y.
  ///
  /// In id, this message translates to:
  /// **'5 Tahun'**
  String get investPeriod5y;

  /// No description provided for @investDataUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Data tidak tersedia'**
  String get investDataUnavailable;

  /// No description provided for @investMarketPriceUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Harga pasar untuk aset ini belum tersedia.'**
  String get investMarketPriceUnavailable;

  /// No description provided for @investMarketPriceLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat harga pasar. Cek koneksi lalu coba lagi.'**
  String get investMarketPriceLoadError;

  /// No description provided for @investNoBalanceRecorded.
  ///
  /// In id, this message translates to:
  /// **'Belum ada saldo tercatat untuk aset ini.'**
  String get investNoBalanceRecorded;

  /// No description provided for @investAccountFallbackName.
  ///
  /// In id, this message translates to:
  /// **'Akun #{accountId}'**
  String investAccountFallbackName(int accountId);

  /// No description provided for @investActivityLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat riwayat.'**
  String get investActivityLoadError;

  /// No description provided for @investActivityEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas'**
  String get investActivityEmptyTitle;

  /// No description provided for @investActivityEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Top up lewat Transfer Antar Akun, atau catat Profit/Loss dengan tombol +.'**
  String get investActivityEmptySubtitle;

  /// No description provided for @investLabelDeposit.
  ///
  /// In id, this message translates to:
  /// **'Deposit'**
  String get investLabelDeposit;

  /// No description provided for @investLabelWithdrawal.
  ///
  /// In id, this message translates to:
  /// **'Withdrawal'**
  String get investLabelWithdrawal;

  /// No description provided for @investLabelProfit.
  ///
  /// In id, this message translates to:
  /// **'Profit'**
  String get investLabelProfit;

  /// No description provided for @investLabelLoss.
  ///
  /// In id, this message translates to:
  /// **'Loss'**
  String get investLabelLoss;

  /// No description provided for @investLabelTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get investLabelTransfer;

  /// No description provided for @investFromTransferSuffix.
  ///
  /// In id, this message translates to:
  /// **'dari Transfer'**
  String get investFromTransferSuffix;

  /// No description provided for @investDeleteEntryDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus entry?'**
  String get investDeleteEntryDialogTitle;

  /// No description provided for @investDeleteEntryDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Entry ini akan dihapus permanen dari tracking.'**
  String get investDeleteEntryDialogContent;

  /// No description provided for @investCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get investCancelButton;

  /// No description provided for @investDeleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get investDeleteButton;

  /// No description provided for @investManageFromTransferTooltip.
  ///
  /// In id, this message translates to:
  /// **'Kelola dari Transfer Antar Akun'**
  String get investManageFromTransferTooltip;

  /// No description provided for @investFromTransferSnackbar.
  ///
  /// In id, this message translates to:
  /// **'Entry ini dari Transfer — kelola dari menu Transfer Antar Akun.'**
  String get investFromTransferSnackbar;

  /// No description provided for @investSelectCryptoAccountFirstError.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun crypto terlebih dahulu.'**
  String get investSelectCryptoAccountFirstError;

  /// No description provided for @investEditProfitLossTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Profit/Loss'**
  String get investEditProfitLossTitle;

  /// No description provided for @investRecordProfitLossTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat Profit/Loss'**
  String get investRecordProfitLossTitle;

  /// No description provided for @investCryptoAccountLabel.
  ///
  /// In id, this message translates to:
  /// **'Akun Crypto'**
  String get investCryptoAccountLabel;

  /// No description provided for @investSelectAccountPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun'**
  String get investSelectAccountPlaceholder;

  /// No description provided for @investAssetSymbolLabel.
  ///
  /// In id, this message translates to:
  /// **'Simbol aset (mis. BTC)'**
  String get investAssetSymbolLabel;

  /// No description provided for @investAssetSymbolRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Simbol aset wajib diisi'**
  String get investAssetSymbolRequiredError;

  /// No description provided for @investTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tipe'**
  String get investTypeLabel;

  /// No description provided for @investDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get investDateLabel;

  /// No description provided for @investAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah (Rp)'**
  String get investAmountLabel;

  /// No description provided for @investAmountRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah wajib diisi'**
  String get investAmountRequiredError;

  /// No description provided for @investAmountInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak valid'**
  String get investAmountInvalidError;

  /// No description provided for @investDescriptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi (opsional)'**
  String get investDescriptionLabel;

  /// No description provided for @investSaveChangesButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get investSaveChangesButton;

  /// No description provided for @investSaveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get investSaveButton;

  /// No description provided for @investSelectCryptoAccountSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun crypto'**
  String get investSelectCryptoAccountSheetTitle;

  /// No description provided for @investMembershipTitle.
  ///
  /// In id, this message translates to:
  /// **'Membership'**
  String get investMembershipTitle;

  /// No description provided for @investMembershipInfoNote.
  ///
  /// In id, this message translates to:
  /// **'Akses fitur mengikuti status membership akun Anda. Tarik ke bawah untuk memperbarui status.'**
  String get investMembershipInfoNote;

  /// No description provided for @investMembershipStatusLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat status membership.'**
  String get investMembershipStatusLoadError;

  /// No description provided for @investChoosePlanTitle.
  ///
  /// In id, this message translates to:
  /// **'Paket Membership'**
  String get investChoosePlanTitle;

  /// No description provided for @investPlanListLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar plan.'**
  String get investPlanListLoadError;

  /// No description provided for @investPlanListEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Plan Tersedia'**
  String get investPlanListEmptyTitle;

  /// No description provided for @investPlanListEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Paket membership belum tersedia saat ini. Coba lagi nanti.'**
  String get investPlanListEmptySubtitle;

  /// No description provided for @investMemberFallbackName.
  ///
  /// In id, this message translates to:
  /// **'Member'**
  String get investMemberFallbackName;

  /// No description provided for @investActiveUntil.
  ///
  /// In id, this message translates to:
  /// **'Berlaku sampai {date}'**
  String investActiveUntil(String date);

  /// No description provided for @investActiveLabel.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get investActiveLabel;

  /// No description provided for @investPendingVerificationSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Membership sedang diproses'**
  String get investPendingVerificationSubtitle;

  /// No description provided for @investFreeLabel.
  ///
  /// In id, this message translates to:
  /// **'Free'**
  String get investFreeLabel;

  /// No description provided for @investNoMembershipSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Menggunakan paket Free'**
  String get investNoMembershipSubtitle;

  /// No description provided for @investActivePlanLabel.
  ///
  /// In id, this message translates to:
  /// **'Plan Aktif'**
  String get investActivePlanLabel;

  /// No description provided for @investPlanFeaturesTitle.
  ///
  /// In id, this message translates to:
  /// **'Fitur yang didapat'**
  String get investPlanFeaturesTitle;

  /// No description provided for @investPlanFeaturesUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Detail fitur untuk plan ini belum tersedia.'**
  String get investPlanFeaturesUnavailable;

  /// No description provided for @investCategoryListTitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get investCategoryListTitle;

  /// No description provided for @investCategoryLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kategori.'**
  String get investCategoryLoadError;

  /// No description provided for @investCategoryEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori'**
  String get investCategoryEmptyTitle;

  /// No description provided for @investCategoryEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori dikelola oleh admin lewat aplikasi web.'**
  String get investCategoryEmptySubtitle;

  /// No description provided for @investRetryButton.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get investRetryButton;

  /// No description provided for @investProviderListTitle.
  ///
  /// In id, this message translates to:
  /// **'Provider Investasi'**
  String get investProviderListTitle;

  /// No description provided for @investProviderLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat provider investasi.'**
  String get investProviderLoadError;

  /// No description provided for @investProviderEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada provider investasi'**
  String get investProviderEmptyTitle;

  /// No description provided for @investProviderEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Provider investasi dikelola oleh admin lewat aplikasi web.'**
  String get investProviderEmptySubtitle;

  /// No description provided for @investPayrollCycleTitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gajian'**
  String get investPayrollCycleTitle;

  /// No description provided for @investPayrollSettingsLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat pengaturan.'**
  String get investPayrollSettingsLoadError;

  /// No description provided for @investPayrollSavedSnackbar.
  ///
  /// In id, this message translates to:
  /// **'Siklus gajian berhasil disimpan.'**
  String get investPayrollSavedSnackbar;

  /// No description provided for @investPayrollDescription.
  ///
  /// In id, this message translates to:
  /// **'Tanggal mulai siklus gajian menentukan periode yang dipakai Dashboard, Budget, dan Ringkasan — bukan tanggal 1-31 kalender biasa.'**
  String get investPayrollDescription;

  /// No description provided for @investUseEndOfMonthLabel.
  ///
  /// In id, this message translates to:
  /// **'Pakai akhir bulan'**
  String get investUseEndOfMonthLabel;

  /// No description provided for @investUseEndOfMonthSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus mulai dari tanggal terakhir tiap bulan'**
  String get investUseEndOfMonthSubtitle;

  /// No description provided for @investStartDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal mulai'**
  String get investStartDateLabel;

  /// No description provided for @investDayLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal {day}'**
  String investDayLabel(int day);

  /// No description provided for @investSelectStartDateTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal mulai'**
  String get investSelectStartDateTitle;

  /// No description provided for @fireTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalkulator Pensiun/FIRE'**
  String get fireTitle;

  /// No description provided for @fireLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data keuangan.'**
  String get fireLoadError;

  /// No description provided for @fireRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get fireRetry;

  /// No description provided for @fireReturnRateLabel.
  ///
  /// In id, this message translates to:
  /// **'Asumsi Return Investasi Tahunan'**
  String get fireReturnRateLabel;

  /// No description provided for @fireCreateGoalButton.
  ///
  /// In id, this message translates to:
  /// **'Buat Goal Dana Pensiun/FIRE'**
  String get fireCreateGoalButton;

  /// No description provided for @fireGoalName.
  ///
  /// In id, this message translates to:
  /// **'Dana Pensiun/FIRE'**
  String get fireGoalName;

  /// No description provided for @fireAverageIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata Pemasukan Bulanan'**
  String get fireAverageIncomeLabel;

  /// No description provided for @fireAverageExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata Pengeluaran Bulanan'**
  String get fireAverageExpenseLabel;

  /// No description provided for @fireSavingsRateLabel.
  ///
  /// In id, this message translates to:
  /// **'Rasio Menabung'**
  String get fireSavingsRateLabel;

  /// No description provided for @fireAverageBasis.
  ///
  /// In id, this message translates to:
  /// **'Berdasarkan {months} bulan terakhir tercatat'**
  String fireAverageBasis(int months);

  /// No description provided for @fireManualHint.
  ///
  /// In id, this message translates to:
  /// **'Data transaksi kamu belum cukup untuk menghitung rata-rata otomatis. Isi manual di bawah:'**
  String get fireManualHint;

  /// No description provided for @fireManualIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata pemasukan bulanan (Rp)'**
  String get fireManualIncomeLabel;

  /// No description provided for @fireManualExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata pengeluaran bulanan (Rp)'**
  String get fireManualExpenseLabel;

  /// No description provided for @fireManualIncomeInvalid.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nominal yang valid'**
  String get fireManualIncomeInvalid;

  /// No description provided for @fireManualExpenseInvalid.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nominal yang valid'**
  String get fireManualExpenseInvalid;

  /// No description provided for @fireNegativeSavingsWarning.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran sama atau lebih besar dari pemasukan, jadi belum ada yang bisa disisihkan untuk pensiun. Proyeksi baru bisa dihitung kalau pemasukan lebih besar dari pengeluaran.'**
  String get fireNegativeSavingsWarning;

  /// No description provided for @fireReturnRateConservative.
  ///
  /// In id, this message translates to:
  /// **'Konservatif'**
  String get fireReturnRateConservative;

  /// No description provided for @fireReturnRateModerate.
  ///
  /// In id, this message translates to:
  /// **'Moderat'**
  String get fireReturnRateModerate;

  /// No description provided for @fireReturnRateAggressive.
  ///
  /// In id, this message translates to:
  /// **'Agresif'**
  String get fireReturnRateAggressive;

  /// No description provided for @fireProjectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Menuju Financial Independence'**
  String get fireProjectionLabel;

  /// No description provided for @fireYearsToGo.
  ///
  /// In id, this message translates to:
  /// **'{years} tahun lagi'**
  String fireYearsToGo(int years);

  /// No description provided for @fireNotReachableWithinCap.
  ///
  /// In id, this message translates to:
  /// **'Belum tercapai dalam {years} tahun'**
  String fireNotReachableWithinCap(int years);

  /// No description provided for @fireTargetYear.
  ///
  /// In id, this message translates to:
  /// **'Target tercapai ±{year} · Kebutuhan dana {amount}'**
  String fireTargetYear(int year, String amount);

  /// No description provided for @fireTargetAmountOnly.
  ///
  /// In id, this message translates to:
  /// **'Kebutuhan dana {amount} — naikkan rasio menabung untuk mempercepat'**
  String fireTargetAmountOnly(String amount);

  /// No description provided for @fireExistingGoalProgress.
  ///
  /// In id, this message translates to:
  /// **'Progress \"{name}\"'**
  String fireExistingGoalProgress(String name);

  /// No description provided for @fireExistingGoalAmounts.
  ///
  /// In id, this message translates to:
  /// **'{saved} dari {target}'**
  String fireExistingGoalAmounts(String saved, String target);

  /// No description provided for @summaryFireCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Proyeksi kapan bisa pensiun'**
  String get summaryFireCardSubtitle;

  /// No description provided for @profileFeatureTourTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Lihat Tour Fitur'**
  String get profileFeatureTourTileTitle;

  /// No description provided for @profileFeatureTourTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ulangi panduan singkat fitur-fitur utama app'**
  String get profileFeatureTourTileSubtitle;

  /// No description provided for @tourNetWorthTitle.
  ///
  /// In id, this message translates to:
  /// **'Saldo & Kekayaan Bersih'**
  String get tourNetWorthTitle;

  /// No description provided for @tourNetWorthDescription.
  ///
  /// In id, this message translates to:
  /// **'Lihat total saldo dan net worth kamu di sini, update otomatis dari semua akun & transaksi.'**
  String get tourNetWorthDescription;

  /// No description provided for @tourStatsTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Keuangan'**
  String get tourStatsTitle;

  /// No description provided for @tourStatsDescription.
  ///
  /// In id, this message translates to:
  /// **'Cash balance, investasi, pemasukan, dan pengeluaran periode berjalan — semua dalam satu tampilan.'**
  String get tourStatsDescription;

  /// No description provided for @tourSavingsGoalsTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Tabungan'**
  String get tourSavingsGoalsTitle;

  /// No description provided for @tourSavingsGoalsDescription.
  ///
  /// In id, this message translates to:
  /// **'Pantau progres target tabunganmu, tap untuk lihat detail atau buat target baru.'**
  String get tourSavingsGoalsDescription;

  /// No description provided for @tourNavDashboardTitle.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get tourNavDashboardTitle;

  /// No description provided for @tourNavDashboardDescription.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan keuangan lengkap kamu ada di sini.'**
  String get tourNavDashboardDescription;

  /// No description provided for @tourNavTransactionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get tourNavTransactionsTitle;

  /// No description provided for @tourNavTransactionsDescription.
  ///
  /// In id, this message translates to:
  /// **'Catat & lihat semua transaksi harianmu di sini.'**
  String get tourNavTransactionsDescription;

  /// No description provided for @tourNavSummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get tourNavSummaryTitle;

  /// No description provided for @tourNavSummaryDescription.
  ///
  /// In id, this message translates to:
  /// **'Analisis pengeluaran & pemasukan dalam bentuk grafik.'**
  String get tourNavSummaryDescription;

  /// No description provided for @tourNavBudgetsTitle.
  ///
  /// In id, this message translates to:
  /// **'Anggaran'**
  String get tourNavBudgetsTitle;

  /// No description provided for @tourNavBudgetsDescription.
  ///
  /// In id, this message translates to:
  /// **'Atur & pantau anggaran bulananmu per kategori.'**
  String get tourNavBudgetsDescription;

  /// No description provided for @tourNavProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get tourNavProfileTitle;

  /// No description provided for @tourNavProfileDescription.
  ///
  /// In id, this message translates to:
  /// **'Kelola akun, tema, bahasa, dan pengaturan lainnya.'**
  String get tourNavProfileDescription;

  /// No description provided for @tourPayrollTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur Siklus Gajian Dulu'**
  String get tourPayrollTitle;

  /// No description provided for @tourPayrollDescription.
  ///
  /// In id, this message translates to:
  /// **'Setting tanggal gajian kamu di sini dulu, supaya data periode di seluruh app — termasuk portfolio — lebih akurat.'**
  String get tourPayrollDescription;

  /// No description provided for @tourPortfolioTitle.
  ///
  /// In id, this message translates to:
  /// **'Terakhir, Portfolio Investasi'**
  String get tourPortfolioTitle;

  /// No description provided for @tourPortfolioDescription.
  ///
  /// In id, this message translates to:
  /// **'Atur portfolio investasimu di sini supaya datanya ikut muncul di Dashboard.'**
  String get tourPortfolioDescription;

  /// No description provided for @profileUserGuideTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Panduan Pengguna'**
  String get profileUserGuideTileTitle;

  /// No description provided for @profileUserGuideTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Buku panduan lengkap cara pakai aplikasi (PDF)'**
  String get profileUserGuideTileSubtitle;

  /// No description provided for @profileUserGuideOpenFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat membuka panduan. Pastikan ada aplikasi pembaca PDF di perangkatmu.'**
  String get profileUserGuideOpenFailed;

  /// No description provided for @wltSectionWallet.
  ///
  /// In id, this message translates to:
  /// **'Dompet'**
  String get wltSectionWallet;

  /// No description provided for @wltCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Saldo Dompet'**
  String get wltCardTitle;

  /// No description provided for @wltCardCopyAccountNumber.
  ///
  /// In id, this message translates to:
  /// **'Salin nomor rekening'**
  String get wltCardCopyAccountNumber;

  /// No description provided for @wltCopiedAccountNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor rekening disalin'**
  String get wltCopiedAccountNumber;

  /// No description provided for @wltCardLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat saldo dompet'**
  String get wltCardLoadError;

  /// No description provided for @wltCardRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get wltCardRetry;

  /// No description provided for @wltCardFrozen.
  ///
  /// In id, this message translates to:
  /// **'Dompet dibekukan'**
  String get wltCardFrozen;

  /// No description provided for @wltTransferTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get wltTransferTileTitle;

  /// No description provided for @wltTransferTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kirim saldo dompet ke pengguna lain lewat nomor rekening'**
  String get wltTransferTileSubtitle;

  /// No description provided for @wltPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Dompet Saya'**
  String get wltPageTitle;

  /// No description provided for @wltAccountNumberLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor Rekening'**
  String get wltAccountNumberLabel;

  /// No description provided for @wltActionTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get wltActionTransfer;

  /// No description provided for @wltActionTopup.
  ///
  /// In id, this message translates to:
  /// **'Isi Saldo'**
  String get wltActionTopup;

  /// No description provided for @wltActionWithdraw.
  ///
  /// In id, this message translates to:
  /// **'Tarik'**
  String get wltActionWithdraw;

  /// No description provided for @wltFrozenBanner.
  ///
  /// In id, this message translates to:
  /// **'Dompet Anda dibekukan. Transaksi tidak dapat dilakukan, hubungi customer service.'**
  String get wltFrozenBanner;

  /// No description provided for @wltLimitsTitle.
  ///
  /// In id, this message translates to:
  /// **'Limit Transfer'**
  String get wltLimitsTitle;

  /// No description provided for @wltLimitPerTransaction.
  ///
  /// In id, this message translates to:
  /// **'Per transaksi: {min} – {max}'**
  String wltLimitPerTransaction(String min, String max);

  /// No description provided for @wltLimitRemainingToday.
  ///
  /// In id, this message translates to:
  /// **'Sisa limit hari ini: {remaining} dari {daily}'**
  String wltLimitRemainingToday(String remaining, String daily);

  /// No description provided for @wltHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Mutasi'**
  String get wltHistoryTitle;

  /// No description provided for @wltFilterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get wltFilterAll;

  /// No description provided for @wltFilterTransferOut.
  ///
  /// In id, this message translates to:
  /// **'Transfer Keluar'**
  String get wltFilterTransferOut;

  /// No description provided for @wltFilterTransferIn.
  ///
  /// In id, this message translates to:
  /// **'Transfer Masuk'**
  String get wltFilterTransferIn;

  /// No description provided for @wltFilterTopup.
  ///
  /// In id, this message translates to:
  /// **'Isi Saldo'**
  String get wltFilterTopup;

  /// No description provided for @wltFilterWithdraw.
  ///
  /// In id, this message translates to:
  /// **'Tarik Saldo'**
  String get wltFilterWithdraw;

  /// No description provided for @wltHistoryEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada mutasi'**
  String get wltHistoryEmptyTitle;

  /// No description provided for @wltHistoryEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer, isi saldo, dan penarikan akan muncul di sini.'**
  String get wltHistoryEmptySubtitle;

  /// No description provided for @wltHistoryLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat mutasi dompet.'**
  String get wltHistoryLoadError;

  /// No description provided for @wltTxnTransferOut.
  ///
  /// In id, this message translates to:
  /// **'Transfer ke {name}'**
  String wltTxnTransferOut(String name);

  /// No description provided for @wltTxnTransferIn.
  ///
  /// In id, this message translates to:
  /// **'Transfer dari {name}'**
  String wltTxnTransferIn(String name);

  /// No description provided for @wltTxnTopup.
  ///
  /// In id, this message translates to:
  /// **'Isi saldo dari portofolio'**
  String get wltTxnTopup;

  /// No description provided for @wltTxnWithdraw.
  ///
  /// In id, this message translates to:
  /// **'Tarik ke portofolio'**
  String get wltTxnWithdraw;

  /// No description provided for @wltTxnReversal.
  ///
  /// In id, this message translates to:
  /// **'Pembatalan transaksi'**
  String get wltTxnReversal;

  /// No description provided for @wltTxnAdjustment.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian saldo'**
  String get wltTxnAdjustment;

  /// No description provided for @wltTxnBalanceAfter.
  ///
  /// In id, this message translates to:
  /// **'Saldo: {amount}'**
  String wltTxnBalanceAfter(String amount);

  /// No description provided for @wltTransferTitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get wltTransferTitle;

  /// No description provided for @wltTransferAccountField.
  ///
  /// In id, this message translates to:
  /// **'Nomor rekening tujuan'**
  String get wltTransferAccountField;

  /// No description provided for @wltTransferAccountHelper.
  ///
  /// In id, this message translates to:
  /// **'12 digit, diawali 88'**
  String get wltTransferAccountHelper;

  /// No description provided for @wltTransferAccountInvalid.
  ///
  /// In id, this message translates to:
  /// **'Nomor rekening harus 12 digit angka'**
  String get wltTransferAccountInvalid;

  /// No description provided for @wltTransferCheck.
  ///
  /// In id, this message translates to:
  /// **'Cek Rekening'**
  String get wltTransferCheck;

  /// No description provided for @wltTransferRecipientLabel.
  ///
  /// In id, this message translates to:
  /// **'Penerima'**
  String get wltTransferRecipientLabel;

  /// No description provided for @wltTransferChange.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get wltTransferChange;

  /// No description provided for @wltTransferAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal (Rp)'**
  String get wltTransferAmountLabel;

  /// No description provided for @wltTransferNoteLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get wltTransferNoteLabel;

  /// No description provided for @wltTransferAvailableBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo dompet: {balance}'**
  String wltTransferAvailableBalance(String balance);

  /// No description provided for @wltTransferContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get wltTransferContinue;

  /// No description provided for @wltTransferAmountRequired.
  ///
  /// In id, this message translates to:
  /// **'Nominal wajib diisi'**
  String get wltTransferAmountRequired;

  /// No description provided for @wltTransferAmountTooSmall.
  ///
  /// In id, this message translates to:
  /// **'Minimal transfer {min}'**
  String wltTransferAmountTooSmall(String min);

  /// No description provided for @wltTransferAmountTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} per transaksi'**
  String wltTransferAmountTooLarge(String max);

  /// No description provided for @wltTransferExceedsDaily.
  ///
  /// In id, this message translates to:
  /// **'Melebihi sisa limit harian ({remaining})'**
  String wltTransferExceedsDaily(String remaining);

  /// No description provided for @wltTransferInsufficient.
  ///
  /// In id, this message translates to:
  /// **'Saldo dompet tidak cukup'**
  String get wltTransferInsufficient;

  /// No description provided for @wltTransferConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Transfer'**
  String get wltTransferConfirmTitle;

  /// No description provided for @wltTransferConfirmCheckName.
  ///
  /// In id, this message translates to:
  /// **'Pastikan nama penerima sudah benar sebelum mengirim.'**
  String get wltTransferConfirmCheckName;

  /// No description provided for @wltTransferConfirmSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get wltTransferConfirmSend;

  /// No description provided for @wltCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get wltCancel;

  /// No description provided for @wltPinTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN'**
  String get wltPinTitle;

  /// No description provided for @wltPinSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi transaksi dengan PIN 6 digit Anda.'**
  String get wltPinSubtitle;

  /// No description provided for @wltPinLocked.
  ///
  /// In id, this message translates to:
  /// **'PIN terkunci. Coba lagi dalam {minutes} menit.'**
  String wltPinLocked(int minutes);

  /// No description provided for @wltPinNotSet.
  ///
  /// In id, this message translates to:
  /// **'Anda belum memiliki PIN. Atur PIN terlebih dulu di menu Profil.'**
  String get wltPinNotSet;

  /// No description provided for @wltPinRetryNetwork.
  ///
  /// In id, this message translates to:
  /// **'Koneksi bermasalah. Masukkan PIN lagi untuk mencoba ulang — transfer tidak akan terkirim dua kali.'**
  String get wltPinRetryNetwork;

  /// No description provided for @wltErrAccountNotFound.
  ///
  /// In id, this message translates to:
  /// **'Nomor rekening tidak ditemukan.'**
  String get wltErrAccountNotFound;

  /// No description provided for @wltErrSelfTransfer.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa transfer ke rekening sendiri.'**
  String get wltErrSelfTransfer;

  /// No description provided for @wltErrFrozen.
  ///
  /// In id, this message translates to:
  /// **'Dompet Anda dibekukan.'**
  String get wltErrFrozen;

  /// No description provided for @wltErrInsufficientBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo dompet tidak cukup.'**
  String get wltErrInsufficientBalance;

  /// No description provided for @wltErrInsufficientPortfolio.
  ///
  /// In id, this message translates to:
  /// **'Saldo portofolio tidak cukup.'**
  String get wltErrInsufficientPortfolio;

  /// No description provided for @wltErrDailyLimit.
  ///
  /// In id, this message translates to:
  /// **'Limit transfer harian terlampaui.'**
  String get wltErrDailyLimit;

  /// No description provided for @wltErrAmountOutOfRange.
  ///
  /// In id, this message translates to:
  /// **'Nominal di luar batas minimum/maksimum per transaksi.'**
  String get wltErrAmountOutOfRange;

  /// No description provided for @wltErrRateLimit.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak percobaan. Coba lagi sebentar lagi.'**
  String get wltErrRateLimit;

  /// No description provided for @wltErrPinInvalid.
  ///
  /// In id, this message translates to:
  /// **'PIN salah.'**
  String get wltErrPinInvalid;

  /// No description provided for @wltReceiptTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Transfer'**
  String get wltReceiptTitle;

  /// No description provided for @wltReceiptSuccess.
  ///
  /// In id, this message translates to:
  /// **'Transfer Berhasil'**
  String get wltReceiptSuccess;

  /// No description provided for @wltReceiptReceivedHeader.
  ///
  /// In id, this message translates to:
  /// **'Transfer Diterima'**
  String get wltReceiptReceivedHeader;

  /// No description provided for @wltReceiptReference.
  ///
  /// In id, this message translates to:
  /// **'No. Referensi'**
  String get wltReceiptReference;

  /// No description provided for @wltReceiptDate.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get wltReceiptDate;

  /// No description provided for @wltReceiptStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get wltReceiptStatus;

  /// No description provided for @wltReceiptStatusCompleted.
  ///
  /// In id, this message translates to:
  /// **'Berhasil'**
  String get wltReceiptStatusCompleted;

  /// No description provided for @wltReceiptRecipient.
  ///
  /// In id, this message translates to:
  /// **'Penerima'**
  String get wltReceiptRecipient;

  /// No description provided for @wltReceiptSender.
  ///
  /// In id, this message translates to:
  /// **'Pengirim'**
  String get wltReceiptSender;

  /// No description provided for @wltReceiptAccount.
  ///
  /// In id, this message translates to:
  /// **'Rekening'**
  String get wltReceiptAccount;

  /// No description provided for @wltReceiptAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal'**
  String get wltReceiptAmount;

  /// No description provided for @wltReceiptNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get wltReceiptNote;

  /// No description provided for @wltReceiptBalanceAfter.
  ///
  /// In id, this message translates to:
  /// **'Saldo setelah transfer'**
  String get wltReceiptBalanceAfter;

  /// No description provided for @wltReceiptDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get wltReceiptDone;

  /// No description provided for @wltReceiptLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat detail transfer.'**
  String get wltReceiptLoadError;

  /// No description provided for @wltTopupTitle.
  ///
  /// In id, this message translates to:
  /// **'Isi Saldo Dompet'**
  String get wltTopupTitle;

  /// No description provided for @wltWithdrawTitle.
  ///
  /// In id, this message translates to:
  /// **'Tarik ke Portofolio'**
  String get wltWithdrawTitle;

  /// No description provided for @wltMoveTopupInfo.
  ///
  /// In id, this message translates to:
  /// **'Saldo diambil dari portofolio yang dipilih dan masuk ke dompet.'**
  String get wltMoveTopupInfo;

  /// No description provided for @wltMoveWithdrawInfo.
  ///
  /// In id, this message translates to:
  /// **'Saldo dompet dipindahkan ke portofolio yang dipilih.'**
  String get wltMoveWithdrawInfo;

  /// No description provided for @wltMovePortfolioLabel.
  ///
  /// In id, this message translates to:
  /// **'Portofolio'**
  String get wltMovePortfolioLabel;

  /// No description provided for @wltMovePortfolioPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Pilih portofolio'**
  String get wltMovePortfolioPlaceholder;

  /// No description provided for @wltMoveSelectPortfolioError.
  ///
  /// In id, this message translates to:
  /// **'Pilih portofolio terlebih dulu'**
  String get wltMoveSelectPortfolioError;

  /// No description provided for @wltMoveDescriptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Keterangan (opsional)'**
  String get wltMoveDescriptionLabel;

  /// No description provided for @wltMoveSubmitTopup.
  ///
  /// In id, this message translates to:
  /// **'Isi Saldo'**
  String get wltMoveSubmitTopup;

  /// No description provided for @wltMoveSubmitWithdraw.
  ///
  /// In id, this message translates to:
  /// **'Tarik Saldo'**
  String get wltMoveSubmitWithdraw;

  /// No description provided for @wltMoveSuccessTopup.
  ///
  /// In id, this message translates to:
  /// **'Saldo dompet berhasil diisi.'**
  String get wltMoveSuccessTopup;

  /// No description provided for @wltMoveSuccessWithdraw.
  ///
  /// In id, this message translates to:
  /// **'Saldo berhasil ditarik ke portofolio.'**
  String get wltMoveSuccessWithdraw;

  /// No description provided for @wltMovePortfolioBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo portofolio: {balance}'**
  String wltMovePortfolioBalance(String balance);

  /// No description provided for @rptPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get rptPageTitle;

  /// No description provided for @rptTabCashFlow.
  ///
  /// In id, this message translates to:
  /// **'Arus Kas'**
  String get rptTabCashFlow;

  /// No description provided for @rptTabSavings.
  ///
  /// In id, this message translates to:
  /// **'Tabungan'**
  String get rptTabSavings;

  /// No description provided for @rptTabCompare.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan'**
  String get rptTabCompare;

  /// No description provided for @rptTabCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get rptTabCategory;

  /// No description provided for @rptTabUnexpected.
  ///
  /// In id, this message translates to:
  /// **'Tak Terduga'**
  String get rptTabUnexpected;

  /// No description provided for @rptTabYear.
  ///
  /// In id, this message translates to:
  /// **'Tahunan'**
  String get rptTabYear;

  /// No description provided for @rptTabTax.
  ///
  /// In id, this message translates to:
  /// **'Pajak'**
  String get rptTabTax;

  /// No description provided for @rptCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get rptCardTitle;

  /// No description provided for @rptCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Arus kas, rasio menabung, perbandingan, pajak, dan lainnya'**
  String get rptCardSubtitle;

  /// No description provided for @rptLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat laporan.'**
  String get rptLoadError;

  /// No description provided for @rptCyclesOption.
  ///
  /// In id, this message translates to:
  /// **'{n} cycle'**
  String rptCyclesOption(int n);

  /// No description provided for @rptCfOpening.
  ///
  /// In id, this message translates to:
  /// **'Saldo Awal'**
  String get rptCfOpening;

  /// No description provided for @rptCfClosing.
  ///
  /// In id, this message translates to:
  /// **'Saldo Akhir'**
  String get rptCfClosing;

  /// No description provided for @rptCfNet.
  ///
  /// In id, this message translates to:
  /// **'Selisih Bersih'**
  String get rptCfNet;

  /// No description provided for @rptCfOther.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian lain'**
  String get rptCfOther;

  /// No description provided for @rptCfOtherHint.
  ///
  /// In id, this message translates to:
  /// **'Perubahan saldo di luar pemasukan/pengeluaran, mis. perubahan nilai investasi.'**
  String get rptCfOtherHint;

  /// No description provided for @rptCfBalanceChart.
  ///
  /// In id, this message translates to:
  /// **'Saldo Berjalan'**
  String get rptCfBalanceChart;

  /// No description provided for @rptCfDailyTitle.
  ///
  /// In id, this message translates to:
  /// **'Pergerakan Harian'**
  String get rptCfDailyTitle;

  /// No description provided for @rptCfEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get rptCfEmptyTitle;

  /// No description provided for @rptCfEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi pada cycle ini.'**
  String get rptCfEmptySubtitle;

  /// No description provided for @rptSrCurrent.
  ///
  /// In id, this message translates to:
  /// **'Rasio Saat Ini'**
  String get rptSrCurrent;

  /// No description provided for @rptSrPrevious.
  ///
  /// In id, this message translates to:
  /// **'Cycle Lalu'**
  String get rptSrPrevious;

  /// No description provided for @rptSrAverage.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata'**
  String get rptSrAverage;

  /// No description provided for @rptSrTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target'**
  String get rptSrTargetLabel;

  /// No description provided for @rptSrChangePoints.
  ///
  /// In id, this message translates to:
  /// **'{value} poin'**
  String rptSrChangePoints(String value);

  /// No description provided for @rptSrFormula.
  ///
  /// In id, this message translates to:
  /// **'(Pemasukan − Pengeluaran) ÷ Pemasukan'**
  String get rptSrFormula;

  /// No description provided for @rptSrOnTarget.
  ///
  /// In id, this message translates to:
  /// **'{count} dari {total} cycle mencapai target'**
  String rptSrOnTarget(int count, int total);

  /// No description provided for @rptSrSeriesTitle.
  ///
  /// In id, this message translates to:
  /// **'Tren Rasio Menabung'**
  String get rptSrSeriesTitle;

  /// No description provided for @rptSrBest.
  ///
  /// In id, this message translates to:
  /// **'Terbaik'**
  String get rptSrBest;

  /// No description provided for @rptSrWorst.
  ///
  /// In id, this message translates to:
  /// **'Terendah'**
  String get rptSrWorst;

  /// No description provided for @rptCmpCompareWith.
  ///
  /// In id, this message translates to:
  /// **'Dibanding dengan'**
  String get rptCmpCompareWith;

  /// No description provided for @rptCmpDefaultPrev.
  ///
  /// In id, this message translates to:
  /// **'Cycle sebelumnya'**
  String get rptCmpDefaultPrev;

  /// No description provided for @rptCmpMetrics.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get rptCmpMetrics;

  /// No description provided for @rptCmpSavingsRate.
  ///
  /// In id, this message translates to:
  /// **'Rasio Menabung'**
  String get rptCmpSavingsRate;

  /// No description provided for @rptCmpCategories.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran per Kategori'**
  String get rptCmpCategories;

  /// No description provided for @rptCmpNewLabel.
  ///
  /// In id, this message translates to:
  /// **'Baru'**
  String get rptCmpNewLabel;

  /// No description provided for @rptCatSelect.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get rptCatSelect;

  /// No description provided for @rptCatNoCategoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori'**
  String get rptCatNoCategoryTitle;

  /// No description provided for @rptCatNoCategorySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan kategori dan transaksi untuk melihat laporan ini.'**
  String get rptCatNoCategorySubtitle;

  /// No description provided for @rptCatTotal.
  ///
  /// In id, this message translates to:
  /// **'Total Cycle Ini'**
  String get rptCatTotal;

  /// No description provided for @rptCatCount.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String rptCatCount(int count);

  /// No description provided for @rptCatPrevious.
  ///
  /// In id, this message translates to:
  /// **'Cycle Lalu'**
  String get rptCatPrevious;

  /// No description provided for @rptCatAverage.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata/cycle'**
  String get rptCatAverage;

  /// No description provided for @rptCatShare.
  ///
  /// In id, this message translates to:
  /// **'Porsi'**
  String get rptCatShare;

  /// No description provided for @rptCatSeries.
  ///
  /// In id, this message translates to:
  /// **'Tren per Cycle'**
  String get rptCatSeries;

  /// No description provided for @rptCatTop.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Terbesar'**
  String get rptCatTop;

  /// No description provided for @rptCatFrequent.
  ///
  /// In id, this message translates to:
  /// **'Paling Sering'**
  String get rptCatFrequent;

  /// No description provided for @rptCatFrequentLine.
  ///
  /// In id, this message translates to:
  /// **'{count}× · {total}'**
  String rptCatFrequentLine(int count, String total);

  /// No description provided for @rptCatAll.
  ///
  /// In id, this message translates to:
  /// **'Semua Transaksi'**
  String get rptCatAll;

  /// No description provided for @rptCatNoTx.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi di kategori ini.'**
  String get rptCatNoTx;

  /// No description provided for @rptUxHow.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran lebih dari {factor}× rata-rata transaksi kategori itu dalam {cycles} cycle sebelumnya. Kategori dengan kurang dari {samples} transaksi pembanding tidak dianalisis.'**
  String rptUxHow(String factor, int cycles, int samples);

  /// No description provided for @rptUxTotalFlagged.
  ///
  /// In id, this message translates to:
  /// **'Total Ditandai'**
  String get rptUxTotalFlagged;

  /// No description provided for @rptUxAnalyzedLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori Dianalisis'**
  String get rptUxAnalyzedLabel;

  /// No description provided for @rptUxEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pengeluaran mencurigakan'**
  String get rptUxEmptyTitle;

  /// No description provided for @rptUxEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaranmu di cycle ini masih wajar. Bagus!'**
  String get rptUxEmptySubtitle;

  /// No description provided for @rptUxRatio.
  ///
  /// In id, this message translates to:
  /// **'{ratio}× rata-rata'**
  String rptUxRatio(String ratio);

  /// No description provided for @rptUxAverage.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata kategori: {amount}'**
  String rptUxAverage(String amount);

  /// No description provided for @rptYrAvgExpense.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata Pengeluaran/Bulan'**
  String get rptYrAvgExpense;

  /// No description provided for @rptYrMonthly.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan vs Pengeluaran Bulanan'**
  String get rptYrMonthly;

  /// No description provided for @rptYrBest.
  ///
  /// In id, this message translates to:
  /// **'Bulan Terbaik'**
  String get rptYrBest;

  /// No description provided for @rptYrWorst.
  ///
  /// In id, this message translates to:
  /// **'Bulan Terburuk'**
  String get rptYrWorst;

  /// No description provided for @rptYrBiggest.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Terbesar'**
  String get rptYrBiggest;

  /// No description provided for @rptYrTopExpenses.
  ///
  /// In id, this message translates to:
  /// **'Kategori Pengeluaran Teratas'**
  String get rptYrTopExpenses;

  /// No description provided for @rptYrTopIncome.
  ///
  /// In id, this message translates to:
  /// **'Sumber Pemasukan Teratas'**
  String get rptYrTopIncome;

  /// No description provided for @rptYrBudgetTitle.
  ///
  /// In id, this message translates to:
  /// **'Anggaran Setahun'**
  String get rptYrBudgetTitle;

  /// No description provided for @rptYrBudgetTotals.
  ///
  /// In id, this message translates to:
  /// **'Terpakai {spent} dari {budget}'**
  String rptYrBudgetTotals(String spent, String budget);

  /// No description provided for @rptYrBudgetMonthsOver.
  ///
  /// In id, this message translates to:
  /// **'{over} dari {total} bulan melebihi anggaran'**
  String rptYrBudgetMonthsOver(int over, int total);

  /// No description provided for @rptYrBudgetUsed.
  ///
  /// In id, this message translates to:
  /// **'{pct}% terpakai'**
  String rptYrBudgetUsed(String pct);

  /// No description provided for @rptYrOverItems.
  ///
  /// In id, this message translates to:
  /// **'Kelebihan Anggaran Terbesar'**
  String get rptYrOverItems;

  /// No description provided for @rptYrOverBy.
  ///
  /// In id, this message translates to:
  /// **'+{amount} ({pct}%)'**
  String rptYrOverBy(String amount, String pct);

  /// No description provided for @rptYrOverCategories.
  ///
  /// In id, this message translates to:
  /// **'Kategori Paling Sering Melebihi'**
  String get rptYrOverCategories;

  /// No description provided for @rptYrOverTimes.
  ///
  /// In id, this message translates to:
  /// **'{times}× melebihi · {amount}'**
  String rptYrOverTimes(int times, String amount);

  /// No description provided for @rptTaxDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Ini hanya rekap, bukan perhitungan pajak: total pemasukan setahun dan pengeluaran yang kamu tandai sebagai pengurang pajak. Konsultasikan ke konsultan pajak untuk hitungan resmi.'**
  String get rptTaxDisclaimer;

  /// No description provided for @rptTaxTotalIncome.
  ///
  /// In id, this message translates to:
  /// **'Total Pemasukan'**
  String get rptTaxTotalIncome;

  /// No description provided for @rptTaxTotalDeductible.
  ///
  /// In id, this message translates to:
  /// **'Total Pengurang'**
  String get rptTaxTotalDeductible;

  /// No description provided for @rptTaxAfter.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan Setelah Pengurang'**
  String get rptTaxAfter;

  /// No description provided for @rptTaxDeductibleList.
  ///
  /// In id, this message translates to:
  /// **'Pengurang Terhitung'**
  String get rptTaxDeductibleList;

  /// No description provided for @rptTaxNoDeductible.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori yang ditandai dan memiliki pengeluaran.'**
  String get rptTaxNoDeductible;

  /// No description provided for @rptTaxCategoriesTitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori Pengurang Pajak'**
  String get rptTaxCategoriesTitle;

  /// No description provided for @rptTaxCategoriesHint.
  ///
  /// In id, this message translates to:
  /// **'Centang kategori pengeluaran yang dapat mengurangi pajak. Pilihan berlaku untuk semua tahun.'**
  String get rptTaxCategoriesHint;

  /// No description provided for @rptTaxNoCategories.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori pengeluaran.'**
  String get rptTaxNoCategories;

  /// No description provided for @rptTaxSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan Pilihan'**
  String get rptTaxSave;

  /// No description provided for @rptTaxSaved.
  ///
  /// In id, this message translates to:
  /// **'Pilihan disimpan.'**
  String get rptTaxSaved;

  /// No description provided for @brcTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi Budget'**
  String get brcTitle;

  /// No description provided for @brcLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat rekomendasi budget.'**
  String get brcLoadError;

  /// No description provided for @brcEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rekomendasi'**
  String get brcEmptyTitle;

  /// No description provided for @brcEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi muncul setelah ada riwayat pengeluaran dalam {cycles} cycle terakhir.'**
  String brcEmptySubtitle(int cycles);

  /// No description provided for @brcBasisPercentage.
  ///
  /// In id, this message translates to:
  /// **'Saran dihitung dari rata-rata porsi pengeluaran tiap kategori terhadap pemasukan selama {cycles} cycle terakhir, dikalikan pemasukan cycle ini ({income}).'**
  String brcBasisPercentage(String income, int cycles);

  /// No description provided for @brcBasisNominal.
  ///
  /// In id, this message translates to:
  /// **'Gaji cycle ini belum masuk, saran memakai rata-rata nominal pengeluaran selama {cycles} cycle terakhir.'**
  String brcBasisNominal(int cycles);

  /// No description provided for @brcSelectedCount.
  ///
  /// In id, this message translates to:
  /// **'{selected} dari {total} dipilih'**
  String brcSelectedCount(int selected, int total);

  /// No description provided for @brcSelectAll.
  ///
  /// In id, this message translates to:
  /// **'Pilih semua'**
  String get brcSelectAll;

  /// No description provided for @brcDeselectAll.
  ///
  /// In id, this message translates to:
  /// **'Batal pilih semua'**
  String get brcDeselectAll;

  /// No description provided for @brcNoBudgetYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada budget'**
  String get brcNoBudgetYet;

  /// No description provided for @brcAverageSpent.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata belanja {amount} per cycle · {percent} dari pemasukan'**
  String brcAverageSpent(String amount, String percent);

  /// No description provided for @brcLimitedNote.
  ///
  /// In id, this message translates to:
  /// **'Melebihi budget di {count} cycle, tidak dinaikkan'**
  String brcLimitedNote(int count);

  /// No description provided for @brcApplyButton.
  ///
  /// In id, this message translates to:
  /// **'Terapkan ({count})'**
  String brcApplyButton(int count);

  /// No description provided for @brcApplied.
  ///
  /// In id, this message translates to:
  /// **'{count} budget berhasil disimpan.'**
  String brcApplied(int count);

  /// No description provided for @brcAppliedPartial.
  ///
  /// In id, this message translates to:
  /// **'{saved} dari {total} budget disimpan. Sisanya tidak punya saran.'**
  String brcAppliedPartial(int saved, int total);

  /// No description provided for @brcAppliedNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada budget yang disimpan. Kategori yang dipilih tidak punya saran.'**
  String get brcAppliedNone;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
