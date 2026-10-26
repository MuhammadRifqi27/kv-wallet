# Plan Rilis Flowr ke Google Play Store

Dibuat: 2026-10-04. Menggantikan `docs/flutter-playstore-deployment-guide.txt`
(nama app lama "KVWallet", belum memuat aturan akun baru & kebijakan billing).

> Aturan & tarif Google berubah dari waktu ke waktu. Poin bertanda **(cek ulang)**
> harus diverifikasi di Play Console / halaman Help resmi sebelum dieksekusi.

---

## 0. Ringkasan & keputusan yang harus diambil dulu

| Hal | Status |
|---|---|
| Akun developer | Biaya **US$25 sekali bayar, berlaku selamanya** (bukan langganan). Benar seperti yang Anda tahu. |
| Banyak app per akun | **Bisa.** Satu akun boleh mempublikasikan banyak aplikasi tanpa biaya tambahan per app. |
| Application ID | Masih `com.example.kv_wallet` → **wajib diganti**, permanen setelah publish. |
| Signing | Release masih memakai debug key → **wajib** buat keystore rilis. |
| **Membership via transfer manual** | **Risiko penolakan terbesar** (lihat bagian 2). Putuskan sebelum submit. |

---

## 1. Akun Google Play Console

1. Daftar di <https://play.google.com/console>, bayar US$25.
2. Pilih tipe akun — ini menentukan beban rilis:

| | Personal | Organization |
|---|---|---|
| Syarat | KTP/paspor + verifikasi identitas | Badan usaha + D-U-N-S number |
| **Closed testing sebelum Production** | **Wajib: minimal 12 tester opt-in, berjalan 14 hari berturut-turut** (cek ulang angkanya) | Tidak diwajibkan |
| Cocok untuk | Developer perorangan | Perusahaan (mis. atas nama Kodevisual) |

   Jika akun personal: **mulai rekrut 12 tester sekarang**, karena 14 hari itu
   jadi jalur kritis jadwal rilis. Tester harus tetap ter-opt-in selama
   periode itu.
3. Siapkan **Payments profile** (wajib bila ada produk berbayar, lihat bagian 2)
   dan data pajak (NPWP, dsb. — **cek ulang** formulir yang diminta).
4. Aktifkan 2-Step Verification di akun Google yang dipakai.

---

## 2. Monetisasi — baca ini sebelum menentukan model harga

### 2.1 Masalah kebijakan: transfer manual

Saat ini Membership (Member / Member Premium) dibayar **transfer bank manual**
lalu diverifikasi admin, dan membuka fitur di dalam app. Kebijakan **Payments**
Google Play mengharuskan produk digital yang dikonsumsi di dalam app (fitur
premium, langganan) dibeli lewat **Google Play Billing**. Menjual unlock fitur
lewat transfer manual berisiko **ditolak saat review atau di-suspend** (cek ulang
pengecualian & program *user choice billing* yang berlaku untuk Indonesia).

Opsi (pilih satu):

| Opsi | Cara | Konsekuensi |
|---|---|---|
| **A. Gratis di Play Store, upgrade di web** | App tidak menampilkan harga/ajakan bayar/instruksi transfer; membership dibeli di website. | Cepat rilis. Tapi jangan ada tombol/teks di app yang mengarahkan pembayaran di luar Play (itu juga pelanggaran). Layar "Upgrade Membership" harus diubah. |
| **B. Google Play Billing (subscription)** | Integrasi paket `in_app_purchase` + verifikasi purchase token di backend. | Sesuai kebijakan; ada potongan Google; butuh kerja di app + backend (2–3 minggu). |
| **C. Hybrid** | Play Billing di app, web tetap boleh bayar manual. | Dua jalur harus disinkronkan di backend. |

**Keputusan (2026-10-04): Opsi A dipilih** — membership dibeli di web. Layar
Membership di app sudah diubah jadi informasi saja (tanpa harga, rekening,
atau tombol pilih plan).

**Rekomendasi:** rilis v1.0 dengan **Opsi A** (bawa ke review tanpa jalur bayar
di app), lalu kerjakan **Opsi B** untuk v1.1. Dengan begitu rilis tidak
tertahan oleh integrasi billing.

Konsekuensi Opsi A yang perlu dikerjakan di app: ubah/sembunyikan
`MembershipPlansPage` (instruksi transfer & harga) menjadi layar informasi
"fitur ini tersedia untuk akun Member" tanpa CTA pembayaran.

### 2.2 Potongan Google (service fee) — cek ulang

| Jenis | Potongan |
|---|---|
| Langganan (subscription) | **15%** sejak transaksi pertama |
| In-app product / one-time | 15% untuk pendapatan pertama US$1 juta per tahun, 30% di atasnya |
| App berbayar di muka | sama seperti di atas |
| Akun developer | US$25 sekali, tanpa biaya tahunan |

Contoh: langganan Rp 50.000 → Google ambil ±Rp 7.500, Anda terima ±Rp 42.500
(sebelum pajak). Pajak (PPN) ditangani/ditampilkan sesuai pengaturan Payments
profile — cek ulang perlakuan di Indonesia.

### 2.3 Usulan pricelist (draft — sesuaikan dengan harga plan yang sudah ada di backend)

Harga plan sebenarnya diatur dari backend; tabel ini hanya kerangka. Di Play
Billing, harga **ditetapkan di Play Console per produk**, bukan dari backend,
jadi harus disamakan dengan plan di backend.

| Plan | Fitur utama | Bulanan | Tahunan (diskon ±17%) |
|---|---|---|---|
| Free | Transaksi, ringkasan dasar | Rp 0 | Rp 0 |
| Member | + Budget, Savings Goals, Recurring, Laporan | Rp X | Rp X × 10 |
| Member Premium | + Transfer antar akun, Crypto tracking, Rekomendasi budget | Rp Y | Rp Y × 10 |

Catatan harga untuk Play Billing: tetapkan satu *base plan* bulanan dan satu
tahunan per tier; aktifkan *free trial*/*intro price* hanya jika backend siap
menangani status trial. Gunakan Product ID stabil (mis. `member_monthly`,
`premium_yearly`) — **tidak bisa dipakai ulang setelah dihapus**.

---

## 3. Persiapan project (satu kali)

Ikuti A.1–A.6 di panduan lama dengan penyesuaian berikut.

- [ ] **Application ID**: ganti `com.example.kv_wallet` di
      `android/app/build.gradle.kts` (`applicationId` **dan** `namespace`),
      pindahkan package di `MainActivity.kt` agar cocok, `flutter clean`.
      Usulan: `com.kodevisual.flowr`.
- [ ] `android:label` sudah `Flowr` ✔.
- [ ] **Keystore rilis** (`keytool -genkey -v -keystore flowr-release.keystore
      -alias flowr -keyalg RSA -keysize 2048 -validity 10000`), simpan di luar
      repo + backup di ≥2 tempat. **Gunakan Play App Signing** (default untuk app
      baru): keystore ini hanya jadi *upload key* yang bisa direset bila hilang.
- [ ] `android/key.properties` + blok `signingConfigs` di `build.gradle.kts`
      (lihat A.3–A.4 panduan lama); tambahkan `key.properties`, `*.keystore`,
      `*.jks` ke `.gitignore`.
- [ ] **Target API level**: Play mewajibkan target API terbaru untuk app baru
      (cek ulang angka tenggat saat ini). `targetSdk = flutter.targetSdkVersion`
      ikut versi Flutter — jalankan `flutter upgrade` bila ketinggalan.
- [ ] **Izin**: `INTERNET`, `POST_NOTIFICATIONS`, `USE_BIOMETRIC`, `CAMERA`.
      Kamera dipakai Scan Struk — sebutkan di Data safety dan store listing.
      Pastikan tidak ada izin lain yang tak terpakai di manifest hasil merge
      (`flutter build appbundle` lalu cek `AndroidManifest.xml` merged).
- [ ] **Backend**: URL API production, HTTPS valid, CORS/rate-limit siap untuk
      lonjakan user; akun demo untuk reviewer (lihat bagian 5).
- [ ] Versi: `pubspec.yaml` `1.0.0+1`; naikkan angka setelah `+` tiap upload.
- [ ] Build: `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`.
- [ ] Tes APK release di HP fisik: login, PIN, biometrik, scan struk (R8 sudah
      ada aturan ProGuard), notifikasi, wallet & laporan ke backend production.

---

## 4. Konten Play Console

| Item | Isi untuk Flowr |
|---|---|
| Nama app | Flowr (maks 30 karakter) |
| Short description (80) | mis. "Catat keuangan, budget, dan investasi dalam satu aplikasi." |
| Full description (4000) | fitur: transaksi, budget + rekomendasi, savings goals, laporan, crypto tracking, dompet |
| Icon 512×512 | dari `assets/branding/icon.png` |
| Feature graphic 1024×500 | **belum ada — perlu didesain** |
| Screenshot | min. 2 (disarankan 4–8) HP; tambah tablet 7"/10" bila ingin tampil di tablet |
| Kategori | Finance |
| Contact email + website | wajib |
| **Privacy policy URL** | **wajib** (app finansial); halaman publik, sebut data yang dikumpulkan, retensi, cara hapus akun |
| Content rating | isi kuesioner IARC (kemungkinan "Everyone") |
| Target audience | 18+ disarankan |
| Ads | No ads |
| **Data safety** | Email, nama, **financial info** (transaksi, saldo, portofolio), foto struk diproses on-device (tidak dikirim — nyatakan dengan benar), enkripsi saat transit = ya, **mekanisme hapus akun/data = wajib disediakan & dideklarasikan** |
| **Financial features declaration** | Isi form Financial features (app mengelola uang/dompet). Dompet/transfer antar-pengguna dapat memicu pertanyaan tambahan — cek ulang kategori yang benar dan apakah butuh izin/lisensi (mis. e-money/OJK/BI) |
| Account deletion | Play mewajibkan app yang punya pembuatan akun menyediakan jalur hapus akun **di dalam app dan via web**. Cek apakah backend/app sudah punya — kalau belum, itu pekerjaan sebelum submit. |

> **Fitur Dompet (transfer antar pengguna):** ini terlihat seperti layanan
> keuangan/penyimpanan nilai. Persiapkan jawaban atas pertanyaan reviewer:
> siapa penyelenggara dana, apakah ada izin regulator, bagaimana top-up/withdraw
> dari portofolio (yang dimaksud di sini saldo internal pencatatan atau uang
> nyata?). Jika ini sekadar pencatatan internal tanpa uang nyata, nyatakan
> jelas di deskripsi agar tidak dianggap layanan pembayaran.

---

## 5. Alur rilis (timeline)

| Minggu | Pekerjaan |
|---|---|
| 0 | Putuskan model harga (bagian 2); daftar akun; mulai rekrut 12 tester bila akun personal |
| 1 | Ganti application ID, keystore, signing; ubah layar membership (Opsi A); build AAB pertama; privacy policy + jalur hapus akun |
| 1–2 | Lengkapi store listing, Data safety, content rating, Financial features; siapkan feature graphic & screenshot |
| 2 | **Internal testing** (maks 100 tester, tanpa review panjang) → tes dari Play Store, bukan sideload |
| 2–4 | **Closed testing** dengan ≥12 tester selama ≥14 hari (hanya akun personal); kumpulkan feedback, naikkan versionCode per perbaikan |
| 4 | Apply for production → Production release, mulai rollout bertahap (mis. 20% → 50% → 100%) |
| 4–5 | Review Google (app finansial bisa 1–7 hari, kadang lebih) |
| 6+ | v1.1: Play Billing (Opsi B), pantau Android vitals & crash |

### Langkah di Play Console (ringkas)

1. **Create app** → nama, bahasa Indonesia, App, Free, centang deklarasi.
2. Selesaikan semua tugas di **Dashboard → Set up your app** (listing, content
   rating, Data safety, target audience, Ads, Financial features, Privacy policy).
3. **Testing → Internal testing → Create release** → upload `.aab`, isi release
   notes, tambahkan email tester → rollout.
4. **Testing → Closed testing** → buat track, daftar tester (Google Group/daftar
   email), kirim link opt-in, pastikan ≥12 orang opt-in dan tetap di sana ≥14 hari.
5. **Production → Create release** → pilih build yang sudah teruji → rollout bertahap.
6. **App access**: sediakan **akun demo** (email, password, dan PIN) di bagian
   *App access* supaya reviewer bisa melewati login + PIN, termasuk akun dengan
   plan Member agar fitur premium bisa diperiksa.

---

## 6. Rencana akun & app berikutnya

- Satu akun ($25) dipakai untuk **semua app** berikutnya; tiap app punya
  application ID, listing, dan keystore/upload key sendiri.
- Simpan keystore tiap app di folder terpisah dan catat password di password
  manager (**jangan** di repo).
- Jika kelak ingin menaungi app atas nama perusahaan, pertimbangkan membuat akun
  **Organization** sejak awal — memindahkan app antar akun masih mungkin
  (transfer app) tapi memakan proses tambahan.

---

## 7. Checklist final sebelum "Submit for review"

- [ ] Application ID baru, signing rilis, Play App Signing aktif
- [ ] Keystore ter-backup di ≥2 tempat, tidak ada di git
- [ ] Model harga diputuskan; layar Membership sesuai kebijakan Payments
- [ ] Privacy policy URL aktif; jalur hapus akun (app + web) tersedia
- [ ] Data safety & Financial features terisi akurat
- [ ] Akun demo + PIN dicantumkan di App access
- [ ] Closed testing 12 tester × 14 hari selesai (akun personal)
- [ ] Screenshot, feature graphic, icon 512 siap
- [ ] APK/AAB rilis lolos tes di HP fisik terhadap backend production
- [ ] Release notes terisi; rollout bertahap dipilih
