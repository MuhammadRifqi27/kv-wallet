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
- Halaman Profile: info akun (nama, username, email) dan status membership
  jadi satu tempat, dengan akses cepat ke Portfolio, Master Data (Kategori,
  Provider Investasi), dan menu lain (Siklus Gajian, Hubungi CS) —
  menggantikan halaman Settings yang sebelumnya cuma daftar menu.
- Edit Profil: ubah nama, username, dan email langsung dari halaman Profile,
  tersimpan ke server (avatar belum bisa diedit dari sini — belum ada UI
  upload-nya meski API sudah menyediakan endpoint-nya).
- Ubah Password: ganti password akun tanpa perlu proses "lupa password",
  diakses dari halaman Profile maupun Edit Profil.
- Ubah PIN: ganti PIN 6 digit yang sudah ada (alur 3 langkah: PIN lama →
  PIN baru → konfirmasi), diakses dari halaman Profile maupun Edit Profil.
- Filter periode di Dashboard: shortcut "Bulan Ini"/"Bulan Lalu"/pilih bulan
  lain (sebelumnya Dashboard tidak punya filter periode sama sekali).
- Filter tanggal di halaman Transaksi: shortcut Semua/Bulan Ini/Bulan
  Lalu/7 Hari Terakhir/30 Hari Terakhir, plus pilih rentang tanggal sendiri.
- Kartu perbandingan "vs bulan lalu" di Ringkasan (Pemasukan, Pengeluaran,
  Untung Bersih, Total Kekayaan Bersih), kartu Rasio Menabung, dan kartu
  Budget Health (ringkasan berapa kategori yang melebihi budget bulan ini,
  tap untuk buka halaman Budget).
- Dashboard: daftar "Semua Akun" dipisah jadi "Akun Harian" dan "Akun
  Investasi".
- Budget: kategori yang sudah punya anggaran bisa diedit langsung dengan
  tap kartunya (jumlah ter-isi otomatis, kategori terkunci) — sebelumnya
  edit cuma bisa lewat form "Tambah Budget" tanpa indikasi jelas kalau itu
  bakal menimpa anggaran kategori yang sama.
- Fitur Transaksi Berulang: buat, edit, dan hapus template pemasukan/
  pengeluaran yang otomatis dibuatkan transaksi asli secara berkala
  (harian/mingguan/bulanan/tahunan), misal tagihan bulanan — diakses dari
  menu di halaman Transaksi. Fitur premium (plan Member ke atas).
- Tab navbar baru **Investment**: dashboard Crypto Tracking berbasis aset
  (BTC, ETH, dst — bukan per akun) dengan harga pasar live (IDR & USD) +
  indikator naik/turun 24 jam (dari CoinGecko), riwayat aktivitas, dan
  catat Profit/Loss. Tap salah satu aset untuk lihat chart (widget
  TradingView) dan breakdown akun mana saja yang pegang aset itu beserta
  jumlahnya. Topup/withdrawal saldo crypto dilakukan lewat Transfer Antar
  Akun (bukan form terpisah) — form Transfer sekarang punya field "Aset"
  yang muncul otomatis kalau salah satu akun (asal atau tujuan) bertipe
  crypto. Fitur premium (permission `btc-tracking`). Detail teknis &
  batasan fitur ini di `docs/flutter-investment-crypto-tracking.md`.
- Investment: estimasi jumlah koin yang dimiliki (nilai Rupiah dikonversi
  ke satuan koin pakai harga sekarang, mis. "≈ 0.00601917 BTC"), tampil di
  dashboard maupun halaman detail aset.
- Investment: floating P&L 24 jam (reaksi harga pasar 24 jam terakhir
  terhadap posisi yang dipegang sekarang, dalam Rupiah) — di kartu Total
  Nilai Crypto (gabungan semua aset), tiap baris aset, dan halaman detail
  aset. Bukan P&L dari modal/harga beli asli (data itu tidak tersimpan di
  ledger-nya sama sekali).
- Investment: halaman detail aset sekarang juga punya floating P&L untuk
  periode 1 minggu, 1 bulan, 3 bulan, 6 bulan, dan 5 tahun (selain 24 jam),
  di kartu "Performa" baru — dihitung dari data historis harga CoinGecko.
  Hanya di halaman detail (bukan di list dashboard) supaya tidak menambah beban
  request ke CoinGecko untuk tiap baris aset sekaligus.
- Fitur Target Tabungan (Savings Goals): buat target menabung dengan nama
  & tujuan tertentu, opsional diikat ke satu akun sebagai sumber dana
  default, catat riwayat nabung/tarik per target — jumlah terkumpul,
  persentase progress, dan status (aktif/tercapai/diarsipkan) dihitung
  otomatis oleh server dari riwayat kontribusi, bukan diinput manual.
  Diakses dari menu di halaman Profile, dengan kartu ringkasan progress
  juga tampil di Dashboard.
- Pencarian teks di halaman Transaksi: cari transaksi berdasarkan nama
  kategori, catatan, atau nama akun — menyaring dari transaksi yang sudah
  termuat sesuai filter tanggal/tipe yang aktif.
- Login Biometrik (sidik jari/Face ID): alternatif membuka aplikasi tanpa
  mengetik PIN, diaktifkan dari halaman Profile (PIN dikonfirmasi sekali
  saat aktivasi). Muncul juga popup ajakan aktivasi otomatis setelah PIN
  berhasil dimasukkan (saat buat PIN baru maupun verifikasi PIN harian),
  maksimal 3 kali tampil lalu berhenti otomatis kalau terus ditolak.
- Dark Mode: toggle tema Sistem/Terang/Gelap di halaman Profile, pilihan
  tersimpan per-device.
- Fitur Scan Struk: baca teks dari foto struk (kamera atau galeri) secara
  on-device (tanpa kirim gambar ke server), lalu otomatis mengisi Jumlah,
  Tanggal, dan Deskripsi di form Tambah Transaksi. Kategori dan Akun tetap
  wajib dipilih manual, dan seluruh hasil bacaan tetap bisa diedit sebelum
  disimpan.

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
- Bottom navigation dari 6 tab jadi 5: Portfolio tidak lagi tab tersendiri
  (jadi menu di dalam Profile), tab "Settings" diganti jadi "Profile".
- Bottom navigation jadi 6 tab lagi dengan tambahan tab "Investment"
  (lihat fitur Crypto Tracking di atas).
- Menu "Transfer Antar Akun" di halaman Portfolio, dari ikon saja di AppBar
  menjadi tile menu penuh (judul + deskripsi) supaya lebih kelihatan.
- Filter tipe transaksi (Semua/Pemasukan/Pengeluaran) di halaman Transaksi,
  dari tombol segmented lebar-penuh menjadi chip kompak; gaya filter chip
  ini diseragamkan juga di Dashboard, Budget, dan Ringkasan.
- Filter "Bulan Ini"/"Bulan Lalu" di Transaksi disesuaikan ke siklus gajian
  yang sebenarnya (bukan tanggal 1-akhir bulan kalender), supaya konsisten
  dengan periode yang dipakai Dashboard/Budget/Ringkasan.
- Dashboard Investment dirombak: kartu Total Nilai Crypto lebih ringkas
  (jumlah aset dilacak + P&L 24 jam), baris tiap aset didesain ulang jadi
  gaya watchlist (avatar bulat berwarna beda per aset, harga & badge
  naik/turun satu baris), diurutkan dari nilai terbesar; akses "Riwayat
  Aktivitas" dipindah dari tile ke ikon di AppBar biar hemat ruang.
- Logo aplikasi (di halaman Splash/Login/Register/PIN, AppBar Dashboard,
  dan footer Profile) otomatis berubah warna mengikuti tema aktif — hitam
  pekat di mode terang, putih di mode gelap.

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
- Halaman Ringkasan sempat blank/kosong padahal data berhasil diambil dari
  API — penyebabnya error layout (tinggi tak terhingga) di baris kartu
  Pemasukan/Pengeluaran/Untung Bersih, sudah diperbaiki.
- Field "Aset" di form Transfer cuma dicek dari akun tujuan, jadi
  withdrawal dari akun crypto ke bank (akun *asal* yang crypto) tidak
  ke-tag — bikin nilai per-aset di Investment lebih besar dari saldo real
  akunnya. Sekarang dicek dari akun asal maupun tujuan.
- Harga & chart aset di Investment kosong untuk aset yang nama-nya bukan
  ticker standar (mis. "BITCOIN", "HYPERLIQUID" alih-alih "BTC", "HYPE") —
  resolusi nama ke CoinGecko sekarang pakai endpoint pencarian, bukan cuma
  cocokkan ke daftar ticker tetap.
- Chart TradingView di halaman detail aset tampil gepeng (CSS tinggi tidak
  diwarisi sampai ke div chart-nya) dan tidak bisa digeser/di-zoom (gesture
  kerebut scroll halaman induk) — keduanya sudah diperbaiki.
- Perbaikan gesture chart di atas sempat menimbulkan 2 masalah susulan
  sebelum ketemu solusi finalnya: (1) chart bisa di-geser/zoom tapi
  halaman jadi tidak bisa di-scroll dari atas area chart, (2) percobaan
  perbaikan #1 (taruh chart di area fixed, terpisah dari yang scroll)
  malah bikin ruang scroll di bawahnya kejepit sempit di layar HP yang
  gak terlalu tinggi. Solusi final: WebView cuma klaim gesture geser
  horizontal + pinch zoom (bukan geser vertikal) — chart tetap bisa
  di-pan/zoom, geser vertikal di atas chart tetap scroll halaman seperti
  biasa, dan halaman balik jadi satu `ListView` biasa (chart gak makan
  ruang layar permanen lagi).
- Tema (mode terang/gelap) tidak langsung ter-update di beberapa halaman
  utama (Dashboard, Transaksi, Ringkasan, Budget, Investment) maupun
  bottom navigation setelah diganti dari Profile — halaman-halaman itu
  tetap "hidup" di background (demi menjaga state saat pindah tab)
  sehingga tidak otomatis dibangun ulang saat tema berubah; sekarang
  langsung ikut berubah tanpa perlu pindah tab/reload.
- Popup ajakan aktivasi Login Biometrik tidak menampilkan hasil apapun
  setelah user menekan "Aktifkan" — notifikasi konfirmasinya keburu
  hilang karena halaman langsung berpindah ke Dashboard; diganti dengan
  dialog yang harus ditutup dulu oleh user sebelum lanjut, supaya
  hasilnya (berhasil/gagal) pasti terlihat.
