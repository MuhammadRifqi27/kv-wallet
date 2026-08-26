# Changelog

Semua perubahan penting pada aplikasi Flowr dicatat di sini.

## [1.0.0] - Belum dirilis

Mobile app belum live ke publik, jadi semua perubahan di bawah masih
tercatat di bawah versi 1.0.0 (belum ada bump versi baru).

### Ditambahkan
- Registrasi mandiri (self-service): daftar akun langsung dapat akses
  (auto-login), tidak perlu menunggu approval admin.
- Keamanan PIN 6 digit: wajib dibuat setelah register/login, dan wajib
  diverifikasi ulang setiap kali app dibuka (app-lock, mirip m-banking).
- Fitur Membership: upgrade ke plan Member/Member Premium, lihat detail
  benefit tiap plan sebelum pilih, instruksi transfer manual, dan cek
  status verifikasi pembayaran.
- Menu "Upgrade Membership" dan "Hubungi Customer Service" (langsung ke
  WhatsApp) di halaman Settings.
- Fitur Budget: atur batas anggaran per kategori pengeluaran per bulan,
  lihat progress pemakaian vs limit per kategori dan secara keseluruhan.
- Notifikasi (lokal) saat pengeluaran suatu kategori melebihi budget yang
  ditentukan.
- Toggle sembunyikan/tampilkan nominal di halaman Dashboard.
- Tab navbar otomatis terkunci (blur + ikon gembok) untuk fitur yang belum
  termasuk permission/plan user, mengarahkan ke halaman Upgrade Membership
  saat disentuh.
- Panduan deploy ke Google Play Store (dokumentasi).

### Diubah
- Nama aplikasi menjadi **Flowr**; logo, wordmark, dan icon app diganti
  memakai brand mark kodevisual.
- Halaman login menerima email atau username, tidak cuma email.
- Tampilan Dashboard: nama pengguna & info siklus gajian dipindah ke dalam
  kartu Total Kekayaan Bersih; judul di AppBar diganti jadi nama aplikasi.
- Status bar dibuat warna solid, tidak lagi transparan/menembus ke konten
  di belakangnya.
- Data permission pengguna ikut ter-refresh otomatis begitu status
  pembayaran membership terkonfirmasi, tanpa perlu logout-login ulang.

### Diperbaiki
- Login gagal karena nama field request salah (`email` seharusnya `login`).
- Build APK release tidak bisa konek ke API sama sekali karena izin
  `INTERNET` belum ada di `AndroidManifest.xml` utama (cuma ada di
  manifest debug/profile).
- Logout tidak konsisten mengarahkan kembali ke halaman login.
- Parsing response API Membership & Budget disesuaikan setelah dites
  dengan response asli dari server (bentuknya beda dari dugaan awal).
