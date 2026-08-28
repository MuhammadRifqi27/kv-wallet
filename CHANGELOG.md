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
- Menu "Upgrade Membership" dan "Hubungi Customer Service" (buka form
  bantuan) di halaman Settings.
- Welcome/onboarding slides (4 slide perkenalan fitur), tampil sekali per
  device sebelum halaman Login/Register.
- Dokumentasi PDF: Developer Documentation (`docs/`) dan User Work
  Instruction (`docs/WI/`).
- Fitur Budget: atur batas anggaran per kategori pengeluaran per bulan,
  lihat progress pemakaian vs limit per kategori dan secara keseluruhan.
- Notifikasi (lokal) saat pengeluaran suatu kategori melebihi budget yang
  ditentukan.
- Toggle sembunyikan/tampilkan nominal di halaman Dashboard.
- Tab navbar otomatis terkunci (blur + ikon gembok) untuk fitur yang belum
  termasuk permission/plan user, mengarahkan ke halaman Upgrade Membership
  saat disentuh.
- Panduan deploy ke Google Play Store (dokumentasi).
- Fitur "Lupa Kata Sandi": user ajukan reset password lewat form (email/
  username + nomor WhatsApp), admin proses pengajuannya lewat panel web,
  link reset dikirim manual lewat WhatsApp/telepon — belum ada email/SMS
  otomatis. Tersedia juga halaman cek status pengajuan (menunggu diproses/
  sudah diproses/ditolak).
- Fitur Transfer Antar Akun: pindahkan dana antar portfolio/akun milik
  sendiri, diakses dari halaman Portfolio. Fitur premium, butuh plan
  Member Premium.

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
- Icon tab Budget diganti jadi kalkulator (sebelumnya celengan), diseragamkan
  juga di slide onboarding & form tambah budget.
- Menu "Hubungi Customer Service" diganti dari buka WhatsApp menjadi buka
  form Google Forms.
- Skema warna aplikasi diganti dari ungu/indigo menjadi palet dusty-rose
  (blush) + charcoal — tombol, spinner, kartu Total Kekayaan Bersih, dan
  progress bar ikut menyesuaikan.
- Loading spinner bawaan diganti jadi animasi tiga titik bertema warna
  aplikasi di halaman-halaman utama (Dashboard, Transaksi, Portfolio,
  Budget, Ringkasan, Membership, dll).

### Diperbaiki
- Login gagal karena nama field request salah (`email` seharusnya `login`).
- Build APK release tidak bisa konek ke API sama sekali karena izin
  `INTERNET` belum ada di `AndroidManifest.xml` utama (cuma ada di
  manifest debug/profile).
- Logout tidak konsisten mengarahkan kembali ke halaman login.
- Parsing response API Membership & Budget disesuaikan setelah dites
  dengan response asli dari server (bentuknya beda dari dugaan awal).
- Transfer Antar Akun menampilkan "Akun #0" alih-alih nama akun asal/tujuan
  — nama field response API (`finance_investment_id`/`to_finance_investment_id`
  dkk) ternyata beda dari dugaan awal, sudah disesuaikan setelah dites
  dengan response asli.
