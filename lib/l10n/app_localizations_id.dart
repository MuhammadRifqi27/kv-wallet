// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get profileAppBarTitle => 'Profile';

  @override
  String get profileSectionPortfolio => 'Portfolio';

  @override
  String get profilePortfolioTileTitle => 'Portfolio Saya';

  @override
  String get profilePortfolioTileSubtitle => 'Akun, dompet, dan investasi Anda';

  @override
  String get profileSavingsGoalTileTitle => 'Target Tabungan';

  @override
  String get profileSavingsGoalTileSubtitle =>
      'Buat target dan catat nabung/tarik dana';

  @override
  String get profileInvestmentTileTitle => 'Investment / BTC Tracking';

  @override
  String get profileInvestmentTileSubtitle =>
      'Pantau aset crypto dan catat profit/loss';

  @override
  String get profileSectionDisplay => 'Tampilan';

  @override
  String get profileThemeTitle => 'Tema Aplikasi';

  @override
  String get profileThemeSystem => 'Sistem';

  @override
  String get profileThemeLight => 'Terang';

  @override
  String get profileThemeDark => 'Gelap';

  @override
  String get profileLanguageTitle => 'Bahasa Aplikasi';

  @override
  String get profileLanguageSystem => 'Sistem';

  @override
  String get profileLanguageIndonesian => 'Indonesia';

  @override
  String get profileLanguageEnglish => 'Inggris';

  @override
  String get profileSectionMasterData => 'Master Data';

  @override
  String get profileCategoryTileTitle => 'Kategori';

  @override
  String get profileCategoryTileSubtitle => 'Kategori pemasukan & pengeluaran';

  @override
  String get profileInvestmentProviderTileTitle => 'Provider Investasi';

  @override
  String get profileInvestmentProviderTileSubtitle =>
      'Bank, exchange, dan broker';

  @override
  String get profileSectionOther => 'Lainnya';

  @override
  String get profilePayrollTileTitle => 'Siklus Gajian';

  @override
  String get profilePayrollTileSubtitle => 'Atur tanggal mulai periode gajian';

  @override
  String get profileCustomerServiceTileTitle => 'Hubungi Customer Service';

  @override
  String get profileCustomerServiceTileSubtitle => 'Isi form bantuan';

  @override
  String get profileCustomerServiceLaunchFailed => 'Tidak dapat membuka form.';

  @override
  String get profileSectionSecurity => 'Keamanan';

  @override
  String get profileChangePasswordTileTitle => 'Ubah Password';

  @override
  String get profileChangePasswordTileSubtitle => 'Ganti password akun Anda';

  @override
  String get profileChangePinTileTitle => 'Ubah PIN';

  @override
  String get profileChangePinTileSubtitle =>
      'Ganti PIN 6 digit untuk membuka aplikasi';

  @override
  String get profileBiometricTitle => 'Login Biometrik';

  @override
  String get profileBiometricSubtitleEnabled =>
      'Aktif — tap \"Gunakan Biometrik\" di layar kunci untuk masuk tanpa mengetik PIN';

  @override
  String get profileBiometricSubtitleDisabled =>
      'Buka aplikasi dengan sidik jari/Face ID, sebagai pengganti mengetik PIN';

  @override
  String get profileBiometricUnsupported =>
      'Perangkat ini tidak mendukung atau belum mendaftarkan biometrik.';

  @override
  String get profileBiometricEnrollReason =>
      'Aktifkan login biometrik untuk Flowr';

  @override
  String get profileBiometricEnrolledSuccess =>
      'Biometrik aktif. Mulai sekarang cukup tap \"Gunakan Biometrik\" di layar kunci untuk masuk tanpa PIN.';

  @override
  String get profileBiometricEnrollFailed =>
      'Verifikasi biometrik gagal atau dibatalkan.';

  @override
  String get profileSectionAccount => 'Akun';

  @override
  String get profileLogoutTileTitle => 'Keluar';

  @override
  String get profileLogoutTileSubtitle => 'Logout dari akun ini';

  @override
  String get profileLogoutDialogTitle => 'Keluar akun?';

  @override
  String get profileLogoutDialogContent =>
      'Anda perlu login kembali untuk mengakses aplikasi.';

  @override
  String get profileCancel => 'Batal';

  @override
  String get profileLogoutConfirm => 'Keluar';

  @override
  String get profileEditTooltip => 'Edit Profil';

  @override
  String get profileMembershipFallback => 'Member';

  @override
  String get profileMembershipFree => 'Free — belum upgrade membership';

  @override
  String profileAppVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get emergencyFundTitle => 'Kalkulator Dana Darurat';

  @override
  String get emergencyFundLoadError => 'Gagal memuat data pengeluaran.';

  @override
  String get emergencyFundRetry => 'Coba lagi';

  @override
  String get emergencyFundTargetLabel => 'Target (bulan pengeluaran)';

  @override
  String get emergencyFundCreateGoalButton => 'Buat Goal Dana Darurat';

  @override
  String get emergencyFundGoalName => 'Dana Darurat';

  @override
  String get emergencyFundAverageLabel => 'Rata-rata Pengeluaran Bulanan';

  @override
  String emergencyFundAverageBasis(int months) {
    return 'Berdasarkan $months bulan terakhir tercatat';
  }

  @override
  String get emergencyFundManualHint =>
      'Data transaksi kamu belum cukup untuk menghitung rata-rata otomatis. Isi manual di bawah:';

  @override
  String get emergencyFundManualLabel => 'Rata-rata pengeluaran bulanan (Rp)';

  @override
  String emergencyFundRecommendationLabel(int multiplier) {
    return 'Rekomendasi Dana Darurat (${multiplier}x pengeluaran bulanan)';
  }

  @override
  String emergencyFundExistingGoalProgress(String name) {
    return 'Progress \"$name\"';
  }

  @override
  String emergencyFundExistingGoalAmounts(String saved, String target) {
    return '$saved dari $target';
  }

  @override
  String get summaryAppBarTitle => 'Ringkasan';

  @override
  String get summaryLoadError => 'Gagal memuat ringkasan.';

  @override
  String get summaryIncomeLabel => 'Pemasukan';

  @override
  String get summaryExpenseLabel => 'Pengeluaran';

  @override
  String get summaryNetProfitLabel => 'Untung Bersih';

  @override
  String get summarySectionAssetAllocation => 'Alokasi Aset';

  @override
  String get summarySectionExpenseBreakdown => 'Breakdown Pengeluaran';

  @override
  String get summarySectionMonthlyTrend => 'Tren Pemasukan vs Pengeluaran';

  @override
  String get summarySectionSmartAdvisor => 'Smart Advisor';

  @override
  String get summaryNetWorthTitle => 'Total Kekayaan Bersih';

  @override
  String summaryNetWorthDelta(String sign, String amount) {
    return '$sign $amount dari bulan lalu';
  }

  @override
  String summaryChangeBadge(String percent) {
    return '$percent% vs lalu';
  }

  @override
  String get summarySavingsRateTitle => 'Rasio Menabung';

  @override
  String get summaryBudgetAllOk => 'Semua kategori masih dalam budget';

  @override
  String summaryBudgetOverCount(int over, int total) {
    return '$over dari $total kategori melebihi budget';
  }

  @override
  String get summaryEmergencyFundCardSubtitle =>
      'Hitung rekomendasi nominal ideal';

  @override
  String notificationBudgetExceededTitle(String category) {
    return 'Budget $category Terlampaui';
  }

  @override
  String notificationBudgetExceededBody(
    String spent,
    String budget,
    String month,
    int year,
  ) {
    return 'Terpakai $spent dari budget $budget bulan $month $year.';
  }

  @override
  String get appChangePasswordSuccessMessage => 'Password berhasil diperbarui.';

  @override
  String get appChangePasswordAppBarTitle => 'Ubah Password';

  @override
  String get appChangePasswordCurrentLabel => 'Password saat ini';

  @override
  String get appChangePasswordCurrentRequired =>
      'Password saat ini wajib diisi';

  @override
  String get appChangePasswordNewLabel => 'Password baru';

  @override
  String get appChangePasswordNewRequired => 'Password baru wajib diisi';

  @override
  String get appChangePasswordMinLength => 'Minimal 8 karakter';

  @override
  String get appChangePasswordConfirmLabel => 'Konfirmasi password baru';

  @override
  String get appChangePasswordMismatch => 'Password tidak cocok';

  @override
  String get appChangePasswordSaveButton => 'Simpan';

  @override
  String get appEditProfileSuccessMessage => 'Profil berhasil diperbarui.';

  @override
  String get appEditProfileAppBarTitle => 'Edit Profil';

  @override
  String get appEditProfileNameLabel => 'Nama lengkap';

  @override
  String get appEditProfileNameRequired => 'Nama wajib diisi';

  @override
  String get appEditProfileUsernameLabel => 'Username';

  @override
  String get appEditProfileUsernameRequired => 'Username wajib diisi';

  @override
  String get appEditProfileUsernameNoSpaces =>
      'Username tidak boleh mengandung spasi';

  @override
  String get appEditProfileEmailLabel => 'Email';

  @override
  String get appEditProfileEmailRequired => 'Email wajib diisi';

  @override
  String get appEditProfileEmailInvalid => 'Format email tidak valid';

  @override
  String get appEditProfileSaveButton => 'Simpan';

  @override
  String get appEditProfileSecuritySectionLabel => 'Keamanan';

  @override
  String get appEditProfileChangePasswordTitle => 'Ubah Password';

  @override
  String get appEditProfileChangePasswordSubtitle => 'Ganti password akun Anda';

  @override
  String get appEditProfileChangePinTitle => 'Ubah PIN';

  @override
  String get appEditProfileChangePinSubtitle =>
      'Ganti PIN 6 digit untuk membuka aplikasi';

  @override
  String get appCyclePeriodThisMonth => 'Bulan Ini';

  @override
  String get appCyclePeriodLastMonth => 'Bulan Lalu';

  @override
  String get appCyclePeriodSelectMonth => 'Pilih Bulan';

  @override
  String get appNavDashboard => 'Dashboard';

  @override
  String get appNavTransactions => 'Transaksi';

  @override
  String get appNavSummary => 'Ringkasan';

  @override
  String get appNavBudgets => 'Budget';

  @override
  String get appNavInvestment => 'Investment';

  @override
  String get appNavProfile => 'Profile';

  @override
  String get appNavUpgradeRequired => 'Fitur ini butuh upgrade membership';

  @override
  String get authLoginWelcomeTitle => 'Selamat datang kembali';

  @override
  String get authLoginWelcomeSubtitle =>
      'Masuk untuk melanjutkan kelola keuangan Anda';

  @override
  String get authLoginEmailOrUsernameLabel => 'Email atau Username';

  @override
  String get authLoginEmailOrUsernameRequired =>
      'Email atau username wajib diisi';

  @override
  String get authLoginPasswordLabel => 'Kata sandi';

  @override
  String get authLoginPasswordRequired => 'Kata sandi wajib diisi';

  @override
  String get authLoginForgotPasswordLink => 'Lupa kata sandi?';

  @override
  String get authLoginSubmitButton => 'Masuk';

  @override
  String get authLoginNoAccountPrompt => 'Belum punya akun?';

  @override
  String get authLoginRegisterLink => 'Daftar';

  @override
  String get authRegisterTitle => 'Buat akun baru';

  @override
  String get authRegisterSubtitle =>
      'Mulai kelola pemasukan & pengeluaran Anda';

  @override
  String get authRegisterInfoBanner =>
      'Akun langsung aktif setelah daftar — Anda akan diminta membuat PIN 6 digit berikutnya.';

  @override
  String get authRegisterNameLabel => 'Nama lengkap';

  @override
  String get authRegisterNameRequired => 'Nama wajib diisi';

  @override
  String get authRegisterUsernameLabel => 'Username';

  @override
  String get authRegisterUsernameRequired => 'Username wajib diisi';

  @override
  String get authRegisterUsernameNoSpaces =>
      'Username tidak boleh mengandung spasi';

  @override
  String get authRegisterEmailLabel => 'Email';

  @override
  String get authRegisterEmailRequired => 'Email wajib diisi';

  @override
  String get authRegisterEmailInvalid => 'Format email tidak valid';

  @override
  String get authRegisterPasswordLabel => 'Kata sandi';

  @override
  String get authRegisterPasswordRequired => 'Kata sandi wajib diisi';

  @override
  String get authRegisterPasswordMinLength => 'Minimal 8 karakter';

  @override
  String get authRegisterConfirmPasswordLabel => 'Konfirmasi kata sandi';

  @override
  String get authRegisterPasswordMismatch => 'Kata sandi tidak cocok';

  @override
  String get authRegisterSubmitButton => 'Daftar';

  @override
  String get authRegisterHaveAccountPrompt => 'Sudah punya akun?';

  @override
  String get authRegisterLoginLink => 'Masuk';

  @override
  String get authForgotPasswordTitle => 'Lupa Kata Sandi';

  @override
  String get authForgotPasswordSubtitle =>
      'Isi form di bawah, admin akan memproses pengajuanmu';

  @override
  String get authForgotPasswordInfoBanner =>
      'Belum ada reset otomatis lewat email. Admin akan menghubungimu lewat WhatsApp/telepon untuk mengirim link reset kata sandi.';

  @override
  String get authForgotPasswordIdentifierLabel => 'Email atau Username';

  @override
  String get authForgotPasswordIdentifierRequired =>
      'Email atau username wajib diisi';

  @override
  String get authForgotPasswordPhoneLabel => 'Nomor WhatsApp/telepon';

  @override
  String get authForgotPasswordPhoneRequired =>
      'Nomor WhatsApp/telepon wajib diisi';

  @override
  String get authForgotPasswordNoteLabel => 'Catatan (opsional)';

  @override
  String get authForgotPasswordSubmitButton => 'Kirim Pengajuan';

  @override
  String get authForgotPasswordCheckStatusLink =>
      'Sudah pernah mengajukan? Cek status';

  @override
  String get authResetStatusAppBarTitle => 'Cek Status Pengajuan';

  @override
  String get authResetStatusDescription =>
      'Masukkan email atau username yang dipakai saat mengajukan reset kata sandi.';

  @override
  String get authResetStatusIdentifierLabel => 'Email atau Username';

  @override
  String get authResetStatusIdentifierRequired =>
      'Email atau username wajib diisi';

  @override
  String get authResetStatusCheckButton => 'Cek Status';

  @override
  String get authResetStatusPendingTitle => 'Menunggu Diproses Admin';

  @override
  String get authResetStatusPendingDescription =>
      'Admin akan menghubungimu lewat WhatsApp/telepon di nomor yang kamu daftarkan untuk mengirim link reset kata sandi.';

  @override
  String get authResetStatusProcessedTitle => 'Sudah Diproses';

  @override
  String get authResetStatusProcessedDescription =>
      'Admin sudah membuat link reset kata sandi dan seharusnya sudah mengirimkannya lewat WhatsApp/telepon. Buka link tersebut untuk mengatur kata sandi baru.';

  @override
  String get authResetStatusRejectedTitle => 'Pengajuan Ditolak';

  @override
  String get authResetStatusRejectedDescription =>
      'Admin menolak pengajuan reset kata sandi ini. Silakan ajukan ulang lewat form.';

  @override
  String get authOnboardingSlide1Title => 'Selamat Datang di Flowr';

  @override
  String get authOnboardingSlide1Description =>
      'Kelola pemasukan, pengeluaran, dan investasi Anda dalam satu aplikasi.';

  @override
  String get authOnboardingSlide2Title => 'Pantau Semua Transaksi';

  @override
  String get authOnboardingSlide2Description =>
      'Catat transaksi harian, lihat ringkasan keuangan, dan pantau portofolio investasi kapan saja.';

  @override
  String get authOnboardingSlide3Title => 'Atur Budget & Dapat Peringatan';

  @override
  String get authOnboardingSlide3Description =>
      'Buat batas anggaran per kategori pengeluaran dan dapat notifikasi begitu mulai berlebih.';

  @override
  String get authOnboardingSlide4Title => 'Aman dengan PIN';

  @override
  String get authOnboardingSlide4Description =>
      'Akun Anda dilindungi PIN 6 digit setiap kali membuka aplikasi, seperti aplikasi m-banking.';

  @override
  String get authOnboardingSkipButton => 'Lewati';

  @override
  String get authOnboardingStartButton => 'Mulai';

  @override
  String get authOnboardingNextButton => 'Lanjut';

  @override
  String get authSplashTagline => 'Kelola keuangan Anda dengan mudah';

  @override
  String get authConfirmPinTitle => 'Konfirmasi PIN Anda';

  @override
  String get authConfirmPinSubtitle =>
      'Masukkan PIN 6 digit saat ini untuk mengaktifkan login biometrik';

  @override
  String get authChangePinMismatch => 'PIN tidak cocok, coba lagi';

  @override
  String get authChangePinSuccessSnackbar => 'PIN berhasil diperbarui.';

  @override
  String get authChangePinAppBarTitle => 'Ubah PIN';

  @override
  String get authChangePinStepCurrentTitle => 'Masukkan PIN Saat Ini';

  @override
  String get authChangePinStepNewTitle => 'Buat PIN Baru';

  @override
  String get authChangePinStepConfirmTitle => 'Konfirmasi PIN Baru';

  @override
  String get authChangePinStepCurrentSubtitle =>
      'Masukkan PIN 6 digit yang sedang Anda pakai';

  @override
  String get authChangePinStepNewSubtitle => 'Masukkan PIN 6 digit yang baru';

  @override
  String get authChangePinStepConfirmSubtitle =>
      'Masukkan ulang PIN baru untuk konfirmasi';

  @override
  String get authVerifyPinBiometricReason => 'Buka Flowr dengan biometrik';

  @override
  String authVerifyPinGreeting(String userName) {
    return 'Halo, $userName';
  }

  @override
  String get authVerifyPinEnterPinTitle => 'Masukkan PIN';

  @override
  String get authVerifyPinSubtitleBiometric =>
      'Masukkan PIN atau gunakan sidik jari/Face ID untuk membuka aplikasi';

  @override
  String get authVerifyPinSubtitleDefault =>
      'Masukkan PIN 6 digit untuk membuka aplikasi';

  @override
  String get authVerifyPinUseBiometricButton => 'Gunakan Biometrik';

  @override
  String get authVerifyPinNotYouLogout => 'Bukan Anda? Keluar';

  @override
  String get authVerifyPinLogoutDialogTitle => 'Bukan Anda?';

  @override
  String get authVerifyPinLogoutDialogContent =>
      'Anda akan logout dan perlu login kembali dengan email/username & password.';

  @override
  String get authVerifyPinLogoutDialogCancel => 'Batal';

  @override
  String get authVerifyPinLogoutDialogConfirm => 'Keluar';

  @override
  String get authSetPinMismatch => 'PIN tidak cocok, coba lagi';

  @override
  String get authSetPinConfirmTitle => 'Konfirmasi PIN';

  @override
  String get authSetPinCreateTitle => 'Buat PIN 6 Digit';

  @override
  String get authSetPinConfirmSubtitle =>
      'Masukkan ulang PIN yang sama untuk konfirmasi';

  @override
  String get authSetPinCreateSubtitle =>
      'PIN ini dipakai untuk membuka aplikasi setiap kali dibuka, mirip aplikasi m-banking';

  @override
  String get authSetPinRestartButton => 'Ulangi dari awal';

  @override
  String get authBiometricPromptTitle => 'Masuk lebih cepat dengan biometrik?';

  @override
  String get authBiometricPromptContent =>
      'Buka Flowr pakai sidik jari atau Face ID, tanpa perlu mengetik PIN tiap kali. Bisa diaktifkan/dimatikan kapan saja lewat Profile.';

  @override
  String get authBiometricPromptLater => 'Nanti saja';

  @override
  String get authBiometricPromptEnable => 'Aktifkan';

  @override
  String get authBiometricPromptEnrollReason =>
      'Aktifkan login biometrik untuk Flowr';

  @override
  String get authBiometricPromptSuccessTitle => 'Biometrik aktif!';

  @override
  String get authBiometricPromptFailedTitle => 'Gagal mengaktifkan';

  @override
  String get authBiometricPromptSuccessContent =>
      'Lain kali Anda bisa masuk ke Flowr tanpa mengetik PIN.';

  @override
  String get authBiometricPromptFailedContent =>
      'Verifikasi biometrik gagal atau dibatalkan. Anda bisa coba lagi kapan saja lewat Profile.';

  @override
  String get authBiometricPromptOkButton => 'Oke';

  @override
  String get walletPortfolioListUpgradeRequired =>
      'Fitur ini butuh upgrade membership';

  @override
  String get walletPortfolioListTitle => 'Portfolio';

  @override
  String get walletPortfolioListLoadError => 'Gagal memuat portfolio.';

  @override
  String get walletPortfolioListEmptyTitle => 'Belum ada akun';

  @override
  String get walletPortfolioListEmptySubtitle =>
      'Tekan tombol + untuk menambah akun/dompet pertama Anda.';

  @override
  String get walletPortfolioListTransferTitle => 'Transfer Antar Akun';

  @override
  String get walletPortfolioListTransferSubtitle =>
      'Pindahkan dana antar akun/dompet Anda';

  @override
  String get walletPortfolioListDeleteDialogTitle => 'Hapus akun?';

  @override
  String walletPortfolioListDeleteDialogContent(String accountName) {
    return 'Akun \"$accountName\" akan dihapus permanen.';
  }

  @override
  String get walletPortfolioListCancel => 'Batal';

  @override
  String get walletPortfolioListDeleteConfirm => 'Hapus';

  @override
  String walletPortfolioListProviderFallback(int id) {
    return 'Provider #$id';
  }

  @override
  String get walletPortfolioListEditAction => 'Edit';

  @override
  String get walletPortfolioFormProviderRequired =>
      'Pilih provider investasi terlebih dahulu.';

  @override
  String get walletPortfolioFormEditTitle => 'Edit Akun';

  @override
  String get walletPortfolioFormCreateTitle => 'Tambah Akun';

  @override
  String get walletPortfolioFormProviderLabel => 'Provider';

  @override
  String get walletPortfolioFormLoadProvidersError =>
      'Gagal memuat daftar provider.';

  @override
  String get walletPortfolioFormAccountNameLabel => 'Nama akun';

  @override
  String get walletPortfolioFormAccountNameRequired => 'Nama akun wajib diisi';

  @override
  String get walletPortfolioFormAccountNumberLabel => 'Nomor akun (opsional)';

  @override
  String get walletPortfolioFormDescriptionLabel => 'Deskripsi (opsional)';

  @override
  String get walletPortfolioFormInvestmentAccountTitle => 'Akun investasi';

  @override
  String get walletPortfolioFormInvestmentAccountSubtitle =>
      'Dana masuk/keluar dicatat sebagai deposit/profit/withdrawal/loss, terpisah dari transaksi biasa';

  @override
  String get walletPortfolioFormSaveChanges => 'Simpan Perubahan';

  @override
  String get walletPortfolioFormNoProviders => 'Belum ada provider investasi';

  @override
  String get walletPortfolioFormSelectProvider => 'Pilih provider';

  @override
  String get walletPortfolioFormSelectProviderSheetTitle =>
      'Pilih provider investasi';

  @override
  String get walletSavingsGoalListTitle => 'Target Tabungan';

  @override
  String get walletSavingsGoalListLoadError => 'Gagal memuat target tabungan.';

  @override
  String get walletSavingsGoalListEmptyTitle => 'Belum ada target tabungan';

  @override
  String get walletSavingsGoalListEmptySubtitle =>
      'Tekan tombol + untuk membuat target pertama Anda.';

  @override
  String get walletSavingsGoalListActiveLabel => 'Aktif';

  @override
  String get walletSavingsGoalListAchievedLabel => 'Tercapai';

  @override
  String walletSavingsGoalListSummarySuffix(String label) {
    return '$label Goal';
  }

  @override
  String get walletSavingsGoalListDeleteDialogTitle => 'Hapus target?';

  @override
  String walletSavingsGoalListDeleteDialogContent(String name) {
    return 'Target \"$name\" beserta seluruh riwayat nabung/tariknya akan dihapus permanen.';
  }

  @override
  String get walletSavingsGoalListCancel => 'Batal';

  @override
  String get walletSavingsGoalListDeleteConfirm => 'Hapus';

  @override
  String get walletSavingsGoalListArchiveDialogTitle => 'Arsipkan target?';

  @override
  String get walletSavingsGoalListArchiveDialogContent =>
      'Target berhenti dihitung aktif/tercapai, tapi riwayatnya tetap tersimpan. Tidak bisa dibatalkan dari aplikasi.';

  @override
  String get walletSavingsGoalListArchiveConfirm => 'Arsipkan';

  @override
  String get walletSavingsGoalListEditAction => 'Edit';

  @override
  String walletSavingsGoalListProgressAmounts(String saved, String target) {
    return '$saved dari $target';
  }

  @override
  String get walletSavingsGoalListOverAllocatedWarning =>
      'Total alokasi ke akun ini melebihi saldo aslinya.';

  @override
  String get walletSavingsGoalFormEditTitle => 'Edit Target Tabungan';

  @override
  String get walletSavingsGoalFormCreateTitle => 'Target Tabungan Baru';

  @override
  String get walletSavingsGoalFormNameLabel => 'Nama target';

  @override
  String get walletSavingsGoalFormNameRequired => 'Nama target wajib diisi';

  @override
  String get walletSavingsGoalFormPurposeLabel => 'Tujuan (opsional)';

  @override
  String get walletSavingsGoalFormTargetAmountLabel => 'Jumlah Target (Rp)';

  @override
  String get walletSavingsGoalFormTargetAmountRequired =>
      'Jumlah target wajib diisi';

  @override
  String get walletSavingsGoalFormAmountInvalid => 'Jumlah tidak valid';

  @override
  String get walletSavingsGoalFormDeadlineLabel => 'Tenggat (opsional)';

  @override
  String get walletSavingsGoalFormNoDeadline => 'Tanpa tenggat';

  @override
  String get walletSavingsGoalFormSourceAccountLabel =>
      'Akun sumber dana (opsional)';

  @override
  String get walletSavingsGoalFormLoadAccountsError =>
      'Gagal memuat daftar akun.';

  @override
  String get walletSavingsGoalFormNoAccounts => 'Belum ada akun';

  @override
  String get walletSavingsGoalFormNoAccountBound =>
      'Tidak diikat ke akun manapun';

  @override
  String get walletSavingsGoalFormColorLabel => 'Warna';

  @override
  String get walletSavingsGoalFormIconLabel => 'Ikon';

  @override
  String get walletSavingsGoalFormSaveChanges => 'Simpan Perubahan';

  @override
  String get walletSavingsGoalFormCreateAction => 'Buat Target';

  @override
  String get walletSavingsGoalFormPickAccountSheetTitle =>
      'Pilih akun sumber dana';

  @override
  String get walletSavingsGoalDetailAddEntryTooltip => 'Catat Nabung/Tarik';

  @override
  String get walletSavingsGoalDetailHistoryTitle => 'Riwayat Nabung/Tarik';

  @override
  String get walletSavingsGoalDetailLoadHistoryError => 'Gagal memuat riwayat.';

  @override
  String get walletSavingsGoalDetailEmptyTitle => 'Belum ada riwayat';

  @override
  String get walletSavingsGoalDetailEmptySubtitle =>
      'Tekan tombol + untuk mencatat nabung/tarik pertama.';

  @override
  String get walletSavingsGoalDetailCollectedLabel => 'Terkumpul';

  @override
  String walletSavingsGoalDetailTargetAmount(String amount) {
    return 'Target $amount';
  }

  @override
  String walletSavingsGoalDetailRemainingAmount(String amount) {
    return 'Kurang $amount lagi';
  }

  @override
  String walletSavingsGoalDetailDeadline(String date) {
    return 'Tenggat $date';
  }

  @override
  String walletSavingsGoalDetailDefaultAccount(String name) {
    return 'Akun default: $name';
  }

  @override
  String get walletSavingsGoalDetailOverAllocatedWarning =>
      'Total alokasi ke akun ini dari semua goal sudah melebihi saldo aslinya.';

  @override
  String get walletSavingsGoalDetailDeleteEntryTitle => 'Hapus baris ini?';

  @override
  String get walletSavingsGoalDetailDeleteEntryContent =>
      'Baris riwayat ini akan dihapus permanen dan progress target dihitung ulang.';

  @override
  String get walletSavingsGoalDetailCancel => 'Batal';

  @override
  String get walletSavingsGoalDetailDeleteConfirm => 'Hapus';

  @override
  String get walletSavingsGoalDetailWithdrawLabel => 'Tarik';

  @override
  String get walletSavingsGoalDetailContributeLabel => 'Nabung';

  @override
  String get walletSavingsGoalDetailDateLabel => 'Tanggal';

  @override
  String get walletSavingsGoalDetailAmountLabel => 'Jumlah (Rp)';

  @override
  String get walletSavingsGoalDetailAmountRequired => 'Jumlah wajib diisi';

  @override
  String get walletSavingsGoalDetailAmountInvalid => 'Jumlah tidak valid';

  @override
  String get walletSavingsGoalDetailAccountLabel => 'Akun (opsional)';

  @override
  String get walletSavingsGoalDetailLoadAccountsError =>
      'Gagal memuat daftar akun.';

  @override
  String get walletSavingsGoalDetailNoAccounts => 'Belum ada akun';

  @override
  String get walletSavingsGoalDetailNoAccountRecorded =>
      'Tidak dicatat ke akun manapun';

  @override
  String get walletSavingsGoalDetailNoteLabel => 'Catatan (opsional)';

  @override
  String get walletSavingsGoalDetailSaveAction => 'Simpan';

  @override
  String get walletSavingsGoalDetailPickAccountSheetTitle => 'Pilih akun';

  @override
  String get walletGoalStatusAchieved => 'Tercapai';

  @override
  String get walletGoalStatusArchived => 'Diarsipkan';

  @override
  String get walletGoalStatusActive => 'Aktif';

  @override
  String get walletDashboardLoadError => 'Gagal memuat dashboard.';

  @override
  String get walletDashboardCashBalanceLabel => 'Saldo Kas';

  @override
  String get walletDashboardInvestmentBalanceLabel => 'Saldo Investasi';

  @override
  String get walletDashboardIncomeLabel => 'Pemasukan';

  @override
  String get walletDashboardExpenseLabel => 'Pengeluaran';

  @override
  String get walletDashboardDailyAccountsTitle => 'Akun Harian';

  @override
  String get walletDashboardInvestmentAccountsTitle => 'Akun Investasi';

  @override
  String get walletDashboardIncomeSourcesTitle => 'Sumber Pemasukan';

  @override
  String get walletDashboardTopCategoriesTitle => 'Kategori Terbesar';

  @override
  String get walletDashboardRecentTransactionsTitle => 'Transaksi Terbaru';

  @override
  String walletDashboardGreeting(String name) {
    return 'Halo, $name';
  }

  @override
  String walletDashboardCycleRange(String start, String end) {
    return 'Siklus $start — $end';
  }

  @override
  String get walletDashboardNetWorthLabel => 'Total Kekayaan Bersih';

  @override
  String get walletDashboardSavingsGoalsCardTitle => 'Target Tabungan';

  @override
  String walletDashboardSavingsGoalsSummary(int active, int achieved) {
    return '$active aktif · $achieved tercapai';
  }

  @override
  String walletDashboardSavingsGoalProgress(String saved, String target) {
    return '$saved dari $target';
  }

  @override
  String get txnCommonCancel => 'Batal';

  @override
  String get txnCommonDelete => 'Hapus';

  @override
  String get txnCommonEdit => 'Edit';

  @override
  String get txnIncomeLabel => 'Pemasukan';

  @override
  String get txnExpenseLabel => 'Pengeluaran';

  @override
  String get txnFilterAll => 'Semua';

  @override
  String get txnCommonSaveChanges => 'Simpan Perubahan';

  @override
  String get txnCommonAmountRequired => 'Jumlah wajib diisi';

  @override
  String get txnCommonAmountInvalid => 'Jumlah tidak valid';

  @override
  String get txnCommonSelectCategoryFirst => 'Pilih kategori terlebih dahulu.';

  @override
  String get txnCommonCategoryLoadError => 'Gagal memuat kategori.';

  @override
  String get txnCommonAccountLoadError => 'Gagal memuat akun.';

  @override
  String get txnCommonDescriptionLabel => 'Deskripsi (opsional)';

  @override
  String get txnCommonAmountRpLabel => 'Jumlah (Rp)';

  @override
  String get txnCommonSelectCategoryTitle => 'Pilih kategori';

  @override
  String get txnCommonNoCategoryForType => 'Belum ada kategori untuk tipe ini';

  @override
  String get txnCommonSelectAccountTitle => 'Pilih akun';

  @override
  String get txnCommonNoneOption => 'Tidak ada';

  @override
  String get txnCommonDateSectionLabel => 'Tanggal';

  @override
  String get txnCommonTypeSectionLabel => 'Tipe';

  @override
  String get txnCommonCategorySectionLabel => 'Kategori';

  @override
  String get txnCommonNoAccountAvailable => 'Belum ada akun';

  @override
  String txnCategoryFallbackName(int id) {
    return 'Kategori #$id';
  }

  @override
  String txnAccountFallbackName(int id) {
    return 'Akun #$id';
  }

  @override
  String get txnRecurringMenuTileTitle => 'Transaksi Berulang';

  @override
  String get txnFeatureRequiresUpgrade => 'Fitur ini butuh upgrade membership';

  @override
  String get txnListTitle => 'Transaksi';

  @override
  String get txnListLoadError => 'Gagal memuat transaksi.';

  @override
  String get txnListEmptyTitle => 'Belum ada transaksi';

  @override
  String get txnListEmptySubtitle =>
      'Tekan tombol + untuk mencatat pemasukan atau pengeluaran.';

  @override
  String get txnListNoResultsTitle => 'Tidak ada hasil';

  @override
  String get txnListNoResultsSubtitle =>
      'Tidak ada transaksi yang cocok dengan pencarian ini.';

  @override
  String get txnSearchHint => 'Cari kategori, catatan, atau akun';

  @override
  String get txnNetBalanceLabel => 'Saldo Bersih';

  @override
  String get txnDeleteDialogTitle => 'Hapus transaksi?';

  @override
  String get txnDeleteDialogContent => 'Transaksi ini akan dihapus permanen.';

  @override
  String get txnRecurringMenuTileSubtitle =>
      'Kelola tagihan/pemasukan otomatis berkala';

  @override
  String get txnPickDateLabel => 'Pilih Tanggal';

  @override
  String get txnFilterThisMonth => 'Bulan Ini';

  @override
  String get txnFilterLastMonth => 'Bulan Lalu';

  @override
  String get txnFilterLast7Days => '7 Hari Terakhir';

  @override
  String get txnFilterLast30Days => '30 Hari Terakhir';

  @override
  String get txnScanReceiptFailedMessage =>
      'Tidak bisa membaca struk ini, silakan isi manual.';

  @override
  String get txnScanReceiptAutofilledMessage =>
      'Terisi otomatis dari struk — mohon periksa kembali sebelum simpan.';

  @override
  String get txnFormTitleEdit => 'Edit Transaksi';

  @override
  String get txnFormTitleAdd => 'Tambah Transaksi';

  @override
  String get txnFormAccountOptionalLabel => 'Akun (opsional)';

  @override
  String get txnScanReceiptScanning => 'Membaca struk...';

  @override
  String get txnScanReceiptButtonLabel => 'Scan Struk';

  @override
  String get txnScanSourceCamera => 'Ambil Foto';

  @override
  String get txnScanSourceGallery => 'Pilih dari Galeri';

  @override
  String get txnRecurringListLoadError => 'Gagal memuat transaksi berulang.';

  @override
  String get txnRecurringListEmptyTitle => 'Belum ada transaksi berulang';

  @override
  String get txnRecurringListEmptySubtitle =>
      'Tekan tombol + untuk membuat template, misal tagihan bulanan.';

  @override
  String get txnRecurringDeleteDialogTitle => 'Hapus transaksi berulang?';

  @override
  String txnRecurringDeleteDialogContent(String name) {
    return 'Template \"$name\" akan dihapus permanen. Transaksi yang sudah pernah dibuat tidak terhapus.';
  }

  @override
  String txnRecurringNextDateLabel(String date) {
    return 'Berikutnya $date';
  }

  @override
  String get txnRecurringSelectAccountFirst => 'Pilih akun terlebih dahulu.';

  @override
  String get txnRecurringFormTitleEdit => 'Edit Transaksi Berulang';

  @override
  String get txnRecurringFormTitleAdd => 'Tambah Transaksi Berulang';

  @override
  String get txnRecurringNameLabel => 'Nama';

  @override
  String get txnRecurringNameRequired => 'Nama wajib diisi';

  @override
  String get txnRecurringAccountSectionLabel => 'Akun';

  @override
  String get txnRecurringFrequencyLabel => 'Frekuensi';

  @override
  String get txnRecurringStartDateLabel => 'Mulai Tanggal';

  @override
  String get txnRecurringStartDateHistoricalNote =>
      'Template ini sudah pernah diproses, jadi mengubah tanggal ini tidak menggeser jadwal berikutnya — cuma jadi catatan kapan pertama dibuat.';

  @override
  String get txnRecurringSubmitAdd => 'Tambah';

  @override
  String get txnRecurringPickFrequencyTitle => 'Pilih frekuensi';

  @override
  String get txnTransferListTitle => 'Transfer Antar Akun';

  @override
  String get txnTransferListLoadError => 'Gagal memuat transfer.';

  @override
  String get txnTransferListEmptyTitle => 'Belum ada transfer';

  @override
  String get txnTransferListEmptySubtitle =>
      'Tekan tombol + untuk memindahkan dana antar akun Anda.';

  @override
  String get txnTransferDeleteDialogTitle => 'Hapus transfer?';

  @override
  String get txnTransferDeleteDialogContent =>
      'Transfer ini akan dihapus permanen, saldo kedua akun akan disesuaikan kembali.';

  @override
  String get txnTransferSelectAccountsError =>
      'Pilih akun asal dan akun tujuan.';

  @override
  String get txnTransferSameAccountError =>
      'Akun asal dan tujuan tidak boleh sama.';

  @override
  String get txnTransferAssetRequiredError =>
      'Isi simbol aset (mis. BTC) — salah satu akun tipe crypto.';

  @override
  String get txnTransferFormTitleEdit => 'Edit Transfer';

  @override
  String get txnTransferFromAccountLabel => 'Dari Akun';

  @override
  String get txnTransferFromAccountPlaceholder => 'Pilih akun asal';

  @override
  String get txnTransferToAccountLabel => 'Ke Akun';

  @override
  String get txnTransferToAccountPlaceholder => 'Pilih akun tujuan';

  @override
  String get txnTransferAssetSectionLabel => 'Aset';

  @override
  String get txnTransferAssetHint =>
      'Salah satu akun tipe crypto — isi simbol asetnya supaya masuk breakdown per-aset di Investment (topup maupun withdrawal/profit taking).';

  @override
  String get txnTransferAssetFieldLabel => 'Simbol aset (mis. BTC)';

  @override
  String get txnTransferSubmitLabel => 'Transfer';

  @override
  String get txnBudgetListTitle => 'Budget';

  @override
  String get txnBudgetListLoadError => 'Gagal memuat budget.';

  @override
  String get txnBudgetListEmptyMessage =>
      'Belum ada budget untuk bulan ini.\nTap tombol + untuk menambah.';

  @override
  String get txnBudgetPerCategoryLabel => 'Per Kategori';

  @override
  String get txnBudgetTapToEditHint =>
      'Tap salah satu untuk mengubah jumlah budget-nya.';

  @override
  String get txnBudgetTotalLabel => 'Total Budget';

  @override
  String txnBudgetUsedAmount(String amount) {
    return 'Terpakai $amount';
  }

  @override
  String txnBudgetCategoryOverBudget(String spent) {
    return 'Terpakai $spent — melebihi budget';
  }

  @override
  String txnBudgetCategoryUsedOfTotal(String spent, String total) {
    return 'Terpakai $spent dari $total';
  }

  @override
  String get txnBudgetFormTitleEdit => 'Edit Budget';

  @override
  String get txnBudgetFormTitleAdd => 'Tambah Budget';

  @override
  String txnBudgetFormPeriodLabel(String month, int year) {
    return 'Untuk periode $month $year';
  }

  @override
  String get txnBudgetExpenseCategoryLabel => 'Kategori Pengeluaran';

  @override
  String get txnBudgetAllCategoriesBudgeted =>
      'Semua kategori sudah punya budget';

  @override
  String get txnBudgetAmountLabel => 'Jumlah Budget (Rp)';

  @override
  String get investDashboardTitle => 'Investment';

  @override
  String get investActivityHistoryLabel => 'Riwayat Aktivitas';

  @override
  String get investRecordProfitLossTooltip => 'Catat Profit/Loss';

  @override
  String get investLoadErrorMessage => 'Gagal memuat data investasi.';

  @override
  String get investYourAssetsLabel => 'Aset Anda';

  @override
  String get investTotalCryptoValueLabel => 'Total Nilai Crypto';

  @override
  String get investAssetCountEmpty => 'Belum ada aset';

  @override
  String investAssetCountTracked(int count) {
    return '$count aset dilacak';
  }

  @override
  String investPnl24hFull(String amount) {
    return 'PnL $amount (24 jam)';
  }

  @override
  String investPnl24hShort(String amount) {
    return 'PnL $amount (24j)';
  }

  @override
  String get investPriceUnavailable => 'Harga tidak tersedia';

  @override
  String get investEmptyCryptoAccountsTitle => 'Belum ada akun crypto';

  @override
  String get investEmptyCryptoAccountsSubtitle =>
      'Tambah akun dengan provider bertipe Crypto lewat Portfolio, lalu top up saldonya lewat Transfer Antar Akun.';

  @override
  String get investHeldInAccountsTitle => 'Dipegang di Akun';

  @override
  String get investHeldInAccountsSubtitle =>
      'Dihitung dari riwayat aktivitas — lihat catatan di kode kalau angkanya tampak meleset.';

  @override
  String get investCurrentPriceLabel => 'Harga Saat Ini';

  @override
  String investChangePercent24h(String percent) {
    return '$percent% (24 jam)';
  }

  @override
  String get investTotalHeldLabel => 'Total Anda Miliki';

  @override
  String investApproxQuantityBtc(String quantity) {
    return '≈ $quantity BTC';
  }

  @override
  String get investPerformanceTitle => 'Performa (Floating PnL)';

  @override
  String get investPeriod24h => '24 Jam';

  @override
  String get investPeriod1w => '1 Minggu';

  @override
  String get investPeriod1m => '1 Bulan';

  @override
  String get investPeriod3m => '3 Bulan';

  @override
  String get investPeriod6m => '6 Bulan';

  @override
  String get investPeriod5y => '5 Tahun';

  @override
  String get investDataUnavailable => 'Data tidak tersedia';

  @override
  String get investMarketPriceUnavailable =>
      'Harga pasar untuk aset ini belum tersedia.';

  @override
  String get investNoBalanceRecorded =>
      'Belum ada saldo tercatat untuk aset ini.';

  @override
  String investAccountFallbackName(int accountId) {
    return 'Akun #$accountId';
  }

  @override
  String get investActivityLoadError => 'Gagal memuat riwayat.';

  @override
  String get investActivityEmptyTitle => 'Belum ada aktivitas';

  @override
  String get investActivityEmptySubtitle =>
      'Top up lewat Transfer Antar Akun, atau catat Profit/Loss dengan tombol +.';

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
  String get investFromTransferSuffix => 'dari Transfer';

  @override
  String get investDeleteEntryDialogTitle => 'Hapus entry?';

  @override
  String get investDeleteEntryDialogContent =>
      'Entry ini akan dihapus permanen dari tracking.';

  @override
  String get investCancelButton => 'Batal';

  @override
  String get investDeleteButton => 'Hapus';

  @override
  String get investManageFromTransferTooltip =>
      'Kelola dari Transfer Antar Akun';

  @override
  String get investFromTransferSnackbar =>
      'Entry ini dari Transfer — kelola dari menu Transfer Antar Akun.';

  @override
  String get investSelectCryptoAccountFirstError =>
      'Pilih akun crypto terlebih dahulu.';

  @override
  String get investEditProfitLossTitle => 'Edit Profit/Loss';

  @override
  String get investRecordProfitLossTitle => 'Catat Profit/Loss';

  @override
  String get investCryptoAccountLabel => 'Akun Crypto';

  @override
  String get investSelectAccountPlaceholder => 'Pilih akun';

  @override
  String get investAssetSymbolLabel => 'Simbol aset (mis. BTC)';

  @override
  String get investAssetSymbolRequiredError => 'Simbol aset wajib diisi';

  @override
  String get investTypeLabel => 'Tipe';

  @override
  String get investDateLabel => 'Tanggal';

  @override
  String get investAmountLabel => 'Jumlah (Rp)';

  @override
  String get investAmountRequiredError => 'Jumlah wajib diisi';

  @override
  String get investAmountInvalidError => 'Jumlah tidak valid';

  @override
  String get investDescriptionLabel => 'Deskripsi (opsional)';

  @override
  String get investSaveChangesButton => 'Simpan Perubahan';

  @override
  String get investSaveButton => 'Simpan';

  @override
  String get investSelectCryptoAccountSheetTitle => 'Pilih akun crypto';

  @override
  String get investUpgradeMembershipTitle => 'Upgrade Membership';

  @override
  String get investMembershipStatusLoadError =>
      'Gagal memuat status membership.';

  @override
  String get investChoosePlanTitle => 'Pilih Plan';

  @override
  String get investPlanListLoadError => 'Gagal memuat daftar plan.';

  @override
  String get investMemberFallbackName => 'Member';

  @override
  String investActiveUntil(String date) {
    return 'Berlaku sampai $date';
  }

  @override
  String get investActiveLabel => 'Aktif';

  @override
  String get investPendingVerificationSubtitle =>
      'Menunggu verifikasi pembayaran dari admin';

  @override
  String get investFreeLabel => 'Free';

  @override
  String get investNoMembershipSubtitle => 'Belum upgrade membership';

  @override
  String get investManualTransferTitle => 'Transfer Manual';

  @override
  String get investBankLabel => 'Bank';

  @override
  String get investAccountNumberLabel => 'No. Rekening';

  @override
  String get investAccountHolderLabel => 'Atas Nama';

  @override
  String get investNominalLabel => 'Nominal';

  @override
  String get investTransferInstructionsNote =>
      'Setelah transfer, admin akan memverifikasi pembayaran dan mengaktifkan membership Anda secara manual.';

  @override
  String get investCheckStatusButton => 'Saya sudah transfer, cek status';

  @override
  String investConfirmPlanDialogTitle(String planName) {
    return 'Konfirmasi $planName';
  }

  @override
  String investConfirmPlanDialogContent(
    String planName,
    String price,
    int days,
  ) {
    return 'Anda akan upgrade ke plan $planName seharga $price untuk $days hari.';
  }

  @override
  String get investSwitchPlanWarning =>
      'Plan Anda saat ini masih aktif. Mengganti ke plan lain akan mereset akses Anda ke Free sampai pembayaran baru diverifikasi admin.';

  @override
  String get investConfirmButton => 'Konfirmasi';

  @override
  String get investPlanSelectedSnackbar =>
      'Plan dipilih. Silakan transfer sesuai instruksi di atas.';

  @override
  String get investSelectPlanError => 'Gagal memilih plan.';

  @override
  String get investActivePlanLabel => 'Plan Aktif';

  @override
  String get investSelectPlanButton => 'Pilih Plan';

  @override
  String investPricePerDuration(String price, int days) {
    return '$price / $days hari';
  }

  @override
  String get investPlanFeaturesTitle => 'Fitur yang didapat';

  @override
  String get investPlanFeaturesUnavailable =>
      'Detail fitur untuk plan ini belum tersedia.';

  @override
  String get investCategoryListTitle => 'Kategori';

  @override
  String get investCategoryLoadError => 'Gagal memuat kategori.';

  @override
  String get investCategoryEmptyTitle => 'Belum ada kategori';

  @override
  String get investCategoryEmptySubtitle =>
      'Kategori dikelola oleh admin lewat aplikasi web.';

  @override
  String get investRetryButton => 'Coba lagi';

  @override
  String get investProviderListTitle => 'Provider Investasi';

  @override
  String get investProviderLoadError => 'Gagal memuat provider investasi.';

  @override
  String get investProviderEmptyTitle => 'Belum ada provider investasi';

  @override
  String get investProviderEmptySubtitle =>
      'Provider investasi dikelola oleh admin lewat aplikasi web.';

  @override
  String get investPayrollCycleTitle => 'Siklus Gajian';

  @override
  String get investPayrollSettingsLoadError => 'Gagal memuat pengaturan.';

  @override
  String get investPayrollSavedSnackbar => 'Siklus gajian berhasil disimpan.';

  @override
  String get investPayrollDescription =>
      'Tanggal mulai siklus gajian menentukan periode yang dipakai Dashboard, Budget, dan Ringkasan — bukan tanggal 1-31 kalender biasa.';

  @override
  String get investUseEndOfMonthLabel => 'Pakai akhir bulan';

  @override
  String get investUseEndOfMonthSubtitle =>
      'Siklus mulai dari tanggal terakhir tiap bulan';

  @override
  String get investStartDateLabel => 'Tanggal mulai';

  @override
  String investDayLabel(int day) {
    return 'Tanggal $day';
  }

  @override
  String get investSelectStartDateTitle => 'Pilih tanggal mulai';

  @override
  String get fireTitle => 'Kalkulator Pensiun/FIRE';

  @override
  String get fireLoadError => 'Gagal memuat data keuangan.';

  @override
  String get fireRetry => 'Coba lagi';

  @override
  String get fireReturnRateLabel => 'Asumsi Return Investasi Tahunan';

  @override
  String get fireCreateGoalButton => 'Buat Goal Dana Pensiun/FIRE';

  @override
  String get fireGoalName => 'Dana Pensiun/FIRE';

  @override
  String get fireAverageIncomeLabel => 'Rata-rata Pemasukan Bulanan';

  @override
  String get fireAverageExpenseLabel => 'Rata-rata Pengeluaran Bulanan';

  @override
  String get fireSavingsRateLabel => 'Rasio Menabung';

  @override
  String fireAverageBasis(int months) {
    return 'Berdasarkan $months bulan terakhir tercatat';
  }

  @override
  String get fireManualHint =>
      'Data transaksi kamu belum cukup untuk menghitung rata-rata otomatis. Isi manual di bawah:';

  @override
  String get fireManualIncomeLabel => 'Rata-rata pemasukan bulanan (Rp)';

  @override
  String get fireManualExpenseLabel => 'Rata-rata pengeluaran bulanan (Rp)';

  @override
  String get fireReturnRateConservative => 'Konservatif';

  @override
  String get fireReturnRateModerate => 'Moderat';

  @override
  String get fireReturnRateAggressive => 'Agresif';

  @override
  String get fireProjectionLabel => 'Estimasi Menuju Financial Independence';

  @override
  String fireYearsToGo(int years) {
    return '$years tahun lagi';
  }

  @override
  String fireNotReachableWithinCap(int years) {
    return 'Belum tercapai dalam $years tahun';
  }

  @override
  String fireTargetYear(int year, String amount) {
    return 'Target tercapai ±$year · Kebutuhan dana $amount';
  }

  @override
  String fireTargetAmountOnly(String amount) {
    return 'Kebutuhan dana $amount — naikkan rasio menabung untuk mempercepat';
  }

  @override
  String fireExistingGoalProgress(String name) {
    return 'Progress \"$name\"';
  }

  @override
  String fireExistingGoalAmounts(String saved, String target) {
    return '$saved dari $target';
  }

  @override
  String get summaryFireCardSubtitle => 'Proyeksi kapan bisa pensiun';
}
