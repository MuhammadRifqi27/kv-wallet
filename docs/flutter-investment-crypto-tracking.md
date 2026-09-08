# Fitur Investment — Crypto Tracking (Mobile)

Dokumentasi teknis untuk tab navbar **Investment**, dibangun di atas API
"BTC Tracking" (lihat `docs/mobile-api-reference.md` bagian "BTC Tracking"
untuk kontrak API lengkap — dokumen ini fokus ke keputusan desain,
integrasi pihak ketiga, dan asumsi yang perlu diwaspadai di sisi mobile).

---

## Ringkasan

Tab **Investment** menampilkan portofolio crypto user secara **per-aset**
(BTC, ETH, dst — bukan per-akun), dengan:

- Total nilai crypto + floating P&L 24 jam gabungan.
- Harga pasar live (IDR & USD) + indikator naik/turun 24 jam per aset,
  dari CoinGecko.
- Estimasi jumlah koin yang dimiliki (dikonversi dari nilai Rupiah ÷ harga
  sekarang — bukan angka tersimpan).
- Chart candlestick (widget TradingView via WebView) saat tap ke satu aset.
- Halaman detail aset: floating P&L 6 periode (24 jam/1 minggu/1 bulan/3
  bulan/6 bulan/5 tahun), dari data historis CoinGecko.
- Breakdown akun mana saja yang pegang aset itu, dihitung client-side dari
  riwayat aktivitas.
- Catat Profit/Loss manual (tombol +).

Topup/withdrawal saldo crypto **tidak** punya form sendiri di fitur ini —
itu dilakukan lewat **Transfer Antar Akun** (uang beneran pindah), yang
form-nya sudah ditambah field "Aset" khusus untuk kasus ini.

---

## Struktur File

```
lib/data/models/
  btc_tracking_model.dart       BtcOverview, AssetBalance, BtcActivityItem,
                                 computePortfolioBalancesForAsset()
  crypto_price_model.dart       CryptoPrice (+ floatingPnl24h/7d/30d/5y()),
                                 cryptoSymbolToCoinGeckoId (fast-path map)

lib/data/repositories/
  btc_tracking_repository.dart  CRUD ke /money-management/btc-tracking
  crypto_price_repository.dart  CoinGecko (harga + resolusi nama aset)

lib/features/investment/
  application/
    btc_tracking_controller.dart   btcOverviewControllerProvider,
                                    btcActivityControllerProvider (+ CRUD)
    crypto_price_controller.dart   assetPricesProvider, singleAssetPriceProvider,
                                    assetTickerProvider
  presentation/
    investment_dashboard_page.dart  Tab utama (asset-first list)
    btc_activity_page.dart          Riwayat aktivitas gabungan
    btc_entry_form_page.dart        Form catat Profit/Loss (create+edit)
    asset_detail_page.dart          Detail 1 aset: harga, chart, breakdown akun

lib/shared/widgets/
  tradingview_chart.dart        Embed widget TradingView via WebView
```

Routing: `/investment` (branch navbar), `/investment/entry-form`,
`/investment/activity`, `/investment/asset/:symbol` — lihat
`lib/routing/app_router.dart` & `lib/routing/main_shell.dart` (permission
gate: `btc-tracking`).

---

## Kenapa desainnya begini

### Asset-first, bukan portfolio-first
Awalnya dashboard menampilkan daftar akun crypto. Setelah didiskusikan,
diubah supaya baris utama adalah **aset** (BTC, ETH, ...), dan tap ke satu
aset baru menampilkan akun mana saja yang pegang aset itu + berapa banyak.
Alasannya: pertanyaan user biasanya "BTC saya berapa & di mana", bukan
"akun ini isinya apa saja".

### Topup/withdrawal lewat Transfer, bukan form sendiri
API BTC Tracking (`POST/PUT/DELETE /btc-tracking`) memang didesain cuma
untuk entry `deposit/withdrawal/profit/loss` **manual** — tapi perpindahan
uang beneran (topup dari bank, withdrawal profit ke bank) sebaiknya lewat
Transfer Antar Akun supaya tercatat juga sebagai transaksi transfer yang
benar (bukan cuma "penyesuaian saldo"). Makanya tombol "+" di Investment
sengaja **dibatasi cuma untuk Profit/Loss** — dua tipe yang memang tidak
punya padanan pergerakan uang nyata.

### "Investment" jadi tab navbar sendiri (bukan sub-menu Portfolio)
Permintaan eksplisit user — awalnya direncanakan sebagai tile di halaman
Portfolio (pola yang sama dengan Transfer Antar Akun/Transaksi Berulang),
tapi diubah jadi tab navbar tersendiri karena dianggap cukup penting untuk
akses cepat. Bottom nav sekarang 6 tab: Dashboard, Transaksi, Ringkasan,
Budget, **Investment**, Profile.

### Kenapa cuma Crypto Tracking (belum "Investasi" generik)
Stock Tracking & IPO (lihat `docs/flutter-mobile-app-development-guide.txt`
bagian "TRADING SAHAM"/"IPO") API-nya sudah ada di backend tapi **belum
dibangun di mobile**. Halaman ini sengaja dinamai spesifik "Investment"
(bukan header "Investasi" dengan tab kosong) supaya tidak ada UI yang
menunjuk ke fitur yang belum ada. Kalau Stock Tracking/IPO dibangun nanti,
halaman ini adalah kandidat untuk dipecah jadi beberapa section/tab di
dalam tab navbar yang sama.

---

## Integrasi Pihak Ketiga

### CoinGecko (harga pasar)
- **Kenapa bukan TradingView untuk data**: TradingView tidak punya API data
  publik untuk pihak ketiga — cuma widget chart embed (lihat bagian
  TradingView di bawah). CoinGecko dipakai murni untuk angka harga & badge
  naik/turun.
- **Tier gratis, tanpa API key** (`api.coingecko.com`, bukan
  `pro-api.coingecko.com` yang berbayar) — pilihan sadar user, dengan
  catatan rate limit-nya ketat & dibagi rame-rame dengan semua aplikasi
  lain yang juga pakai endpoint publik ini (bukan jatah khusus app kita).
  Kalau nanti sering kena `429`, opsi upgrade paling murah adalah daftar
  **Demo API Key** CoinGecko (masih gratis/$0, cuma perlu akun) untuk jatah
  lebih longgar — beda dari Pro yang berbayar. Lihat
  `CryptoPriceRepository`.
- **Resolusi nama aset → CoinGecko id**: field `asset` di app ini **bebas
  diisi user** (lihat `docs/mobile-api-reference.md`), dan di data nyata
  ternyata sering berupa nama lengkap ("BITCOIN", "HYPERLIQUID"), bukan
  ticker ("BTC", "HYPE"). `CryptoPriceRepository._resolve()` karena itu:
  1. Coba jalur cepat lewat map ticker umum (`cryptoSymbolToCoinGeckoId`,
     ~20 koin populer) — tanpa request tambahan.
  2. Kalau tidak ketemu, pakai endpoint pencarian CoinGecko
     (`GET /search?query=...`), ambil hasil pertama (CoinGecko sudah
     meranking berdasar relevansi/market cap, jadi hasil pertama untuk
     nama ambigu seperti "Bitcoin" seharusnya yang benar).
  3. Hasil resolusi di-cache in-memory per sesi app (tidak di-persist).
- **Data historis (P&L 1 minggu/1 bulan/3 bulan/6 bulan/5 tahun)**:
  `getExtendedPrice()` panggil satu kali
  `GET /coins/{id}/market_chart?vs_currency=idr&days=1825` (5 tahun,
  granularitas harian otomatis dari CoinGecko untuk rentang sepanjang ini —
  sengaja tidak set param `interval` eksplisit karena itu khusus paket
  berbayar), lalu kelima periode itu semua diekstrak dari **satu** hasil
  series yang sama (tidak ada request tambahan per periode). Titik harga
  terdekat ke target tanggal (7/30/90/180/1825 hari lalu) dipakai untuk
  hitung persentase perubahan. Kalau histori koinnya lebih
  pendek dari target (koin baru listing), titik tertua yang dipakai — jadi
  "5 Tahun" diam-diam jadi "sejak listing" untuk koin semacam itu (lihat
  komentar di `CryptoPrice.changePercent5y`). Ini **request terpisah &
  lebih berat** dari `getPrices()` biasa, jadi sengaja cuma dipanggil di
  halaman detail 1 aset (`singleAssetPriceProvider`), **tidak** di list
  dashboard (`assetPricesProvider`) — supaya tidak sekali jalan minta 4x
  data historis untuk tiap aset yang dipegang.

### TradingView (chart visual)
- Widget embed resmi TradingView (`https://s3.tradingview.com/tv.js`),
  di-load via `WebViewController.loadHtmlString` (`webview_flutter`).
  Bukan sumber data — cuma visual.
- Simbol dikonversi ke pair `BINANCE:{TICKER}USDT` — pakai ticker asli
  hasil resolusi CoinGecko (`assetTickerProvider`), bukan nama mentah
  ("HYPERLIQUID" → resolve ke ticker "HYPE" → `BINANCE:HYPEUSDT"). Chart
  bisa kosong kalau pair itu memang tidak ada di Binance.
- **Gotcha #1 — chart gepeng**: `autosize: true` TradingView mengisi
  bounding box *div containernya*, jadi CSS `height: 100%` harus eksplisit
  di seluruh rantai `html → body → .tradingview-widget-container →
  #tv_chart`, bukan cuma di `body`.
- **Gotcha #2 — gesture pan/zoom chart tidak jalan**: karena WebView
  ditaruh di dalam `ListView` yang bisa di-scroll, gesture arena Flutter
  otomatis memenangkan `Scrollable` induk untuk drag/pinch, jadi WebView
  (dan chart JS di dalamnya) tidak pernah menerima gesture itu. Percobaan
  pertama: `WebViewWidget(gestureRecognizers: {...})` mengklaim SEMUA —
  `VerticalDragGestureRecognizer` + `HorizontalDragGestureRecognizer` +
  `ScaleGestureRecognizer`. Chart jadi bisa di-pan/zoom, tapi sebagai
  gantinya area chart jadi tidak bisa dipakai buat scroll halaman sama
  sekali (lihat Gotcha #3).
- **Gotcha #3 — percobaan #2 bikin halaman gak bisa di-scroll dari atas
  chart, lalu percobaan taruh chart di area fixed malah bikin ruang scroll
  di bawahnya kejepit**: dua percobaan sempat dicoba dan sama-sama punya
  masalah —
  1. Taruh chart + header harga di `Column` tetap (bukan bagian
     `Scrollable` manapun), sisanya di `Expanded(child: ListView(...))`
     sendiri. Ini menghilangkan konflik gesture-nya total, tapi chart
     jadi makan tinggi layar **permanen** terlepas dari posisi scroll —
     di layar HP yang gak terlalu tinggi, sisa ruang buat konten di
     bawahnya (Performa, daftar akun) jadi sempit banget.
  2. **Solusi final (dipakai sekarang)**: balik ke satu `ListView` biasa
     (chart cuma salah satu item di dalamnya, gak makan ruang permanen),
     tapi `gestureRecognizers` WebView cuma klaim
     `HorizontalDragGestureRecognizer` + `ScaleGestureRecognizer` — **bukan**
     `VerticalDragGestureRecognizer`. Chart candlestick memang secara
     alami di-pan pakai geser horizontal dan di-zoom pakai pinch, bukan
     geser vertikal — jadi geser vertikal yang mulai di atas chart tetap
     lolos ke `ListView` (scroll halaman jalan normal), sementara geser
     horizontal/pinch tetap diklaim WebView (chart tetap bisa di-pan/zoom).
     Ini bukan keterbatasan TradingView, murni soal composition gesture
     arena Flutter — kalau nanti ada WebView lain di app ini yang perlu
     gesture internal di dalam halaman yang scroll, pola split-per-arah
     ini (bukan klaim semua sekaligus) yang harus dipakai dari awal.

---

## Breakdown Per Akun — ⚠️ Asumsi Perlu Diverifikasi

`GET /btc-tracking` cuma kasih total **global** per aset (`asset_balances`),
bukan per akun. `computePortfolioBalancesForAsset()`
(`btc_tracking_model.dart`) menghitung sendiri dari
`GET /btc-tracking/activity`, dengan aturan tanda:

- Baris `source_type: "investment"` (`deposit`/`profit` → `+`,
  `withdrawal`/`loss` → `-`) — ini **terverifikasi**, cocok dengan validasi
  request (`amount` selalu `min: 0`, arah dari `type`).
- Baris `source_type: "transfer"` — dipakai **apa adanya** (`amount` yang
  balik dari API diasumsikan sudah bertanda: negatif kalau baris itu sisi
  keluar dari akun, positif kalau sisi masuk), mengikuti konvensi
  `finance_transactions` yang sudah dipakai di fitur Transfer lain (lihat
  catatan di `TransferModel`).

**Sudah divalidasi manual sekali** (8 September 2026): dijumlahkan seluruh
baris `BITCOIN` dari respons `activity` nyata → hasilnya persis cocok
dengan `asset_balances["BITCOIN"]` dari `GET /btc-tracking`. Tapi ini baru
satu sampel data — kalau breakdown per akun di halaman detail aset
kelihatan meleset, cek dulu fungsi ini sebelum curiga ke tempat lain.

---

## Bug yang Pernah Ditemukan (referensi biar tidak terulang)

1. **Field "Aset" di form Transfer cuma dicek dari akun tujuan.**
   Withdrawal profit dari akun crypto ke bank (akun *asal* yang crypto,
   bukan tujuan) jadi tidak pernah ke-tag `asset`, sehingga baris itu tidak
   ikut dihitung di `asset_balances` walau saldo real akun (dihitung dari
   *semua* transaksi tanpa peduli tag) sudah benar. Efeknya: nilai per-aset
   di dashboard lebih besar dari nilai real akun, selisihnya persis sebesar
   transaksi yang tidak ke-tag. Perbaikan: `_involvesCrypto()` di
   `transfer_form_page.dart` sekarang cek akun asal **atau** tujuan.
   Transaksi lama yang sudah kadung terkirim tanpa tag harus dibetulkan
   manual (edit transfer itu, isi field Aset-nya).

2. **Resolusi harga aset gagal total untuk nama bukan-ticker.** Sebelum ada
   fallback ke `/search`, mapping cuma kenal ticker (`BTC`), jadi asset
   `"BITCOIN"`/`"HYPERLIQUID"` di data nyata gagal resolve → harga & chart
   kosong tanpa error yang kelihatan (di-swallow diam-diam). Sekarang ada
   logging (`kDebugMode`) di `CryptoPriceRepository` supaya kegagalan
   serupa ke depan tidak lolos tanpa jejak.

3. **Chart TradingView gepeng, gesture tidak jalan, lalu halaman ikut
   ke-scroll** — 3 masalah berurutan, satu sama lain saling berkaitan;
   lihat Gotcha #1-#3 di bagian TradingView di atas.

---

## Floating P&L (24 Jam / 1 Minggu / 1 Bulan / 3 Bulan / 6 Bulan / 5 Tahun)

`CryptoPrice.floatingPnl24h/7d/30d/3m/6m/5y(currentValueIdr)` — **bukan** P&L
dari modal/harga beli asli user, untuk keenam periode ini. Ledger BTC
Tracking cuma pernah mencatat nominal Rupiah yang keluar/masuk, tidak
pernah "beli di harga X per koin", jadi tidak ada cost-basis tersimpan di
mana pun. Rumus yang dipakai murni reaksi harga pasar terhadap posisi yang
dipegang *sekarang*, dengan asumsi jumlah koin tidak berubah sepanjang
periode itu:

```
pnl_periode = nilai_sekarang × pct_periode / (100 + pct_periode)
```

`pct_24h` datang dari `/simple/price` (`include_24hr_change`); `pct_7d`/
`pct_30d`/`pct_3m`/`pct_6m`/`pct_5y` dihitung sendiri dari SATU respons
`/coins/{id}/market_chart` yang sama (lihat bagian CoinGecko di atas untuk
detail & batasannya, termasuk fallback "5 Tahun" jadi "sejak listing"
untuk koin yang histori-nya lebih pendek).

Kalau ke depan dibutuhkan P&L vs modal asli, opsi paling murah tanpa ubah
backend: pakai `total deposit − total withdrawal` (dari activity feed)
sebagai proxy cost-basis dibanding nilai sekarang — masih perkiraan (tidak
tahu harga beli tiap transaksi), tapi lebih dekat ke "untung/rugi dari
modal" dibanding pendekatan reaksi-harga-pasar di atas.

---

## TODO / Ide Lanjutan

- Cost-basis P&L (lihat bagian di atas) kalau user butuh, di luar 4 periode
  yang sudah ada.
- Halaman detail aset sekarang minimal 2 request CoinGecko per kunjungan
  (`/simple/price` + `/coins/{id}/market_chart`), lebih berat dari sebelum
  ada P&L multi-periode — pantau kalau rate limit publik mulai kerasa di
  sini duluan dibanding di dashboard.
- Stock Tracking & IPO — API sudah ada di backend, belum dibangun di
  mobile sama sekali. Kalau dikerjakan, pertimbangkan jadikan tab
  Investment ini hub dengan beberapa section, bukan halaman terpisah lagi.
- CoinGecko Demo API Key kalau rate limit publik mulai bermasalah di
  pemakaian nyata (lihat bagian CoinGecko di atas).
- Breakdown per-akun (`computePortfolioBalancesForAsset`) baru divalidasi
  dari satu sampel data — perlu dicek ulang di beberapa skenario lain
  (terutama transfer antar 2 akun crypto sekaligus, seperti kasus
  "swap" HYPERLIQUID→BITCOIN yang muncul di data nyata).
