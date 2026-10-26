# Referensi API Mobile (Auth, PIN, Membership, Recurring Transactions, BTC Tracking, Savings Goals, Tabungan Bersama, Teman, Wallet)

Referensi lengkap untuk tim Flutter — semua endpoint yang dibangun untuk
mobile app di sesi ini. Untuk endpoint Money Management lainnya (dashboard,
transaksi, budget, dll), lihat Postman collection
(`postman/money-management-api.postman_collection.json`) dan
`routes/api.php`.

---

## Dasar

- **Base URL**: `{{base_url}}/api/v1` (contoh: `https://kodevisual.com/api/v1`)
- **Auth**: Bearer token (Laravel Sanctum). Login/register mengembalikan
  `token` sekali di awal — simpan di device, kirim di header ini pada
  **semua** request lain:
  ```
  Authorization: Bearer {token}
  ```
- **Content-Type**: `application/json` untuk semua request POST.
- **Error validasi (422)**: format standar Laravel —
  ```json
  {
    "message": "The login field is required.",
    "errors": { "login": ["The login field is required."] }
  }
  ```

---

## Auth

### `POST /auth/register`
Registrasi mandiri — langsung dapat token (auto-login, **tidak** ada
approval wall). Akun baru otomatis masuk role `free-user` untuk app
money-management.

**Request:**
```json
{
  "name": "Budi Santoso",
  "username": "budisantoso",
  "email": "budi@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "device_name": "iPhone 15 Budi",
  "pin": "123456",
  "pin_confirmation": "123456"
}
```
`pin`/`pin_confirmation` opsional — bisa dilewati dan diatur belakangan lewat
`POST /auth/pin`.

**Response `201`:**
```json
{
  "token": "1|abcdef123456...",
  "user": {
    "id": 10,
    "name": "Budi Santoso",
    "username": "budisantoso",
    "email": "budi@example.com",
    "avatar_url": null,
    "has_pin": true,
    "is_approved": false,
    "is_paid_member": false,
    "membership_plan": null,
    "money_management_permissions": ["dashboard", "transactions", "settings", "settings.payroll"]
  }
}
```
Field `is_approved` cuma flag admin ("sudah direview"), **bukan** gate akses
— cek `money_management_permissions` (kosong = belum ada akses sama sekali)
atau `is_paid_member` untuk tahu status akses sebenarnya.

---

### `POST /auth/login`
```json
{
  "login": "budisantoso",
  "password": "password123",
  "device_name": "iPhone 15 Budi"
}
```
`login` bisa diisi **username atau email** — dideteksi otomatis (kalau
formatnya valid email, dicari sebagai email; kalau tidak, sebagai username).

**Response `200`:** sama persis shape-nya dengan `register()` di atas (tanpa
status code `201`).

**Error `422`** kalau salah kredensial:
```json
{
  "message": "Email/Username atau password salah.",
  "errors": { "login": ["Email/Username atau password salah."] }
}
```

---

### `POST /auth/logout` 🔒
Revoke token yang sedang dipakai (device ini saja, device lain tetap login).

**Response `200`:**
```json
{ "success": "Berhasil logout" }
```

---

### `GET /auth/me` 🔒
Ambil data user + status membership terkini — panggil ini tiap kali app
dibuka untuk sinkronisasi state.

**Response `200`:** shape sama seperti `user` object di `register`/`login`.

---

### `POST /auth/profile` 🔒
Update profil user: `name`, `username`, `email`, dan/atau `avatar`. Ini
**partial update** — kirim cuma field yang mau diubah, field lain tidak
disentuh. Password dan PIN **tidak** ditangani di sini — lihat
`POST /auth/change-password` untuk ganti password (user tahu password
lama) dan `POST /auth/pin` untuk PIN. Untuk user yang lupa password
(tidak bisa login sama sekali), pakai alur [Password Reset](#password-reset-tanpa-email)
admin-mediated di bawah.

**Request** (`multipart/form-data` — dipakai kalau upload file avatar):
| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `name` | string | tidak | max 255 |
| `username` | string | tidak | max 255, alpha-dash (`a-z`, `0-9`, `-`, `_`), harus unik |
| `email` | string | tidak | format email, harus unik |
| `avatar` | file | tidak | image, max 2MB. Pakai field ini kalau kirim `multipart/form-data` |
| `avatar_base64` | string | tidak | alternatif `avatar` tanpa multipart — data URI, contoh: `data:image/png;base64,iVBORw0KG...`. Dipakai kalau app mau kirim JSON biasa (mis. hasil crop di app) |
| `remove_avatar` | boolean | tidak | `true` untuk hapus avatar yang ada tanpa ganti yang baru |

Kalau `avatar` (file) dan `avatar_base64` sama-sama dikirim, `avatar` (file)
yang dipakai. `remove_avatar` diabaikan kalau salah satu dari keduanya
dikirim.

Contoh request JSON biasa (tanpa ganti avatar, cuma update nama & email):
```json
{ "name": "Budi Santoso Baru", "email": "budi.baru@example.com" }
```

**Response `200`:** shape sama seperti `user` object di `register`/`login`
(sudah termasuk `avatar_url` terbaru).

**Error `422`** kalau `username`/`email` sudah dipakai user lain, atau
`avatar_base64` formatnya tidak valid:
```json
{
  "message": "The email has already been taken.",
  "errors": { "email": ["The email has already been taken."] }
}
```

---

### `POST /auth/change-password` 🔒
Ganti password — dipakai user yang **masih bisa login** dan tahu password
lamanya (mis. dari layar "Edit Profile" / "Keamanan"). Kalau user lupa
password (tidak bisa login sama sekali), ini bukan endpoint yang tepat —
arahkan ke alur [Password Reset](#password-reset-tanpa-email) di bawah.

**Request:**
```json
{
  "current_password": "password123",
  "password": "passwordBaru123",
  "password_confirmation": "passwordBaru123"
}
```

**Response `200`:**
```json
{ "message": "Password berhasil diperbarui." }
```

**Error `422`** kalau `current_password` salah:
```json
{
  "message": "Password saat ini salah.",
  "errors": { "current_password": ["Password saat ini salah."] }
}
```

Token Sanctum yang sedang dipakai **tidak** ikut di-revoke setelah ganti
password — device ini (dan device lain yang masih login) tetap login.

---

## Password Reset (Tanpa Email)

App ini **tidak** mengirim email/SMS/WhatsApp otomatis untuk reset password
— belum ada provider transactional email yang siap dipakai. Sebagai
gantinya, alurnya **admin-mediated**: user submit tiket, admin proses manual
lewat panel web, lalu admin sendiri yang mengirim link ke user via
WhatsApp/telepon. Detail rasional & alur lengkapnya di
[docs/password-reset-request-flow.md](password-reset-request-flow.md).

Alur untuk mobile:

1. User isi form "lupa password" di app → `POST /auth/password-reset-request`.
2. (Opsional) App polling `GET /auth/password-reset-request/status` untuk
   nampilin status "menunggu admin" / "sudah diproses".
3. Admin proses tiket dari panel web, dapat link, kirim manual ke user lewat
   WhatsApp/telepon — **di luar app**, tidak ada API untuk langkah ini.
4. User buka link itu. Kalau linknya format web (`https://.../reset-password/{token}?email=...`),
   deep-link/intercept URL itu di app lalu ambil `token` & `email` dari
   query-nya, lanjut ke langkah 5 — atau biarkan saja terbuka di browser
   (halaman web-nya sudah lengkap, tidak butuh app sama sekali).
5. Kalau mau diselesaikan di dalam app (bukan browser): `POST /auth/password-reset`
   dengan token+email dari link tadi + password baru.

Ketiga endpoint di bawah **tidak butuh** `Authorization` header — user
belum bisa login di titik ini.

### `POST /auth/password-reset-request`
Submit tiket pengajuan reset password.

**Request:**
```json
{
  "identifier": "budi@example.com",
  "phone": "081234567890",
  "note": "Sudah tidak bisa akses email lama"
}
```
`identifier` bisa email atau username. `note` opsional. `phone` dipakai
admin untuk menghubungi balik — wajib diisi.

**Response `201`:**
```json
{
  "success": "Pengajuan reset password sudah dikirim. Admin akan menghubungimu lewat WhatsApp/telepon untuk proses selanjutnya.",
  "ticket_id": 4,
  "status": "pending"
}
```

**Error `422`** kalau `identifier` tidak ketemu:
```json
{
  "message": "Email atau username tidak ditemukan.",
  "errors": { "identifier": ["Email atau username tidak ditemukan."] }
}
```

---

### `GET /auth/password-reset-request/status`
Cek status tiket **terbaru** untuk sebuah identifier — dipakai untuk
polling di layar "menunggu admin".

```
GET /auth/password-reset-request/status?identifier=budi@example.com
```

**Response `200`:**
```json
{
  "ticket_id": 4,
  "status": "pending",
  "submitted_at": "2026-08-28T01:47:58.000000Z",
  "processed_at": null
}
```
`status` salah satu dari `pending` / `processed` / `rejected`. Begitu jadi
`processed`, itu artinya admin **sudah generate link** dan (harusnya) sudah
mengirimkannya manual — bukan berarti user sudah selesai ganti password.

**Response `404`** kalau belum pernah ada tiket untuk identifier itu:
```json
{ "message": "Belum ada pengajuan reset password untuk identifier ini." }
```

---

### `POST /auth/password-reset`
Selesaikan reset password pakai token dari link yang dikirim admin —
alternatif buat app yang mau handle ini in-app (deep link) alih-alih
membuka browser ke halaman web `reset-password`.

**Request:**
```json
{
  "token": "19e04d8212568ce01f3cc447e00662583384f5d87bb7c5019cd7a54545ccac74",
  "email": "budi@example.com",
  "password": "passwordBaru123",
  "password_confirmation": "passwordBaru123"
}
```
`token` & `email` diambil dari query string link yang dikirim admin
(`.../reset-password/{token}?email=...`). Token **sekali pakai** dan
kedaluwarsa 60 menit sejak dibuat admin.

**Response `200`:**
```json
{ "success": "Password berhasil direset. Silakan masuk dengan password barumu." }
```

**Error `422`** kalau token sudah dipakai/kedaluwarsa/salah:
```json
{
  "message": "Link reset password tidak valid atau sudah kedaluwarsa.",
  "errors": { "email": ["Link reset password tidak valid atau sudah kedaluwarsa."] }
}
```

---

## PIN

PIN 6-digit untuk lock screen mobile app — dicek **setelah** login (login
cuma sekali; PIN yang dipakai berulang tiap kali app dibuka lagi).

### `POST /auth/pin` 🔒
Set PIN pertama kali:
```json
{ "pin": "123456", "pin_confirmation": "123456" }
```
Ganti PIN yang sudah ada (wajib sertakan `current_pin`):
```json
{ "current_pin": "123456", "pin": "654321", "pin_confirmation": "654321" }
```

**Response `200`:**
```json
{ "message": "PIN berhasil diperbarui." }
```

### `POST /auth/verify-pin` 🔒
```json
{ "pin": "123456" }
```
**Response `200`:** `{ "message": "PIN valid." }`
**Error `422`** kalau salah: `{ "message": "PIN salah.", "errors": { "pin": ["PIN salah."] } }`

---

## Membership

Tingkatan akses: **Free** (default) → **Member** → **Member Premium**. Alur
lengkapnya di [docs/user-guide-membership.md](user-guide-membership.md) —
ringkasnya:

1. User pilih plan lewat `select-plan` di bawah.
2. User transfer manual ke rekening pemilik app (di luar app), kirim
   konfirmasi nama+email.
3. Admin verifikasi lalu klik "Mark Paid" di panel admin.
4. Mobile app poll `GET /membership/status` sampai `is_paid_member` jadi `true`.

Pembayaran online (Xendit) sudah dibangun tapi **dijeda** — lihat
[docs/xendit/README.md](xendit/README.md). Endpoint `POST /membership/checkout`
karena itu belum aktif dipakai, jangan diintegrasikan dulu di sisi mobile.

### `GET /membership/plans` 🔒
Daftar plan yang bisa dipilih.

**Response `200`:**
```json
[
  {
    "id": 1,
    "code": "member-monthly",
    "name": "Member",
    "description": "View Dashboard, Manage Transactions, View Financial Summary, Manage Portfolio, Manage Settings, Transaction Recurring, Master Payroll",
    "app_role_code": "member-user",
    "price": 15000,
    "duration_days": 30,
    "is_active": true,
    "created_at": "2026-08-25T07:51:17.000000Z",
    "updated_at": "2026-08-25T07:51:17.000000Z"
  },
  {
    "id": 2,
    "code": "member-premium-monthly",
    "name": "Member Premium",
    "description": "View Dashboard, Manage Transactions, Manage Budgets, View Financial Summary, Manage Portfolio, Manage Settings, Internal Transfers, Transaction Recurring, Bitcoin Tracking, Master Category Expenses, Master Category Income, Master Investment, Master Payroll",
    "app_role_code": "member-premium-user",
    "price": 35000,
    "duration_days": 30,
    "is_active": true,
    "created_at": "2026-08-25T07:51:17.000000Z",
    "updated_at": "2026-08-25T07:51:17.000000Z"
  }
]
```
`price` dalam Rupiah (integer, tanpa desimal). `description` **otomatis
dibuat dari daftar permission** yang didapat plan itu (diatur admin lewat
menu Applications → App Roles) — bukan teks bebas, jadi selalu sinkron
dengan fitur yang benar-benar didapat user. Tampilkan sebagai daftar benefit
di layar pilih plan. Instruksi transfer manual (rekening tujuan, dll)
**tidak** disediakan API ini — kelola sebagai konten statis di app.

### `POST /membership/select-plan` 🔒
Catat pilihan plan user. **Tidak** langsung membuka akses — cuma menandai
"user ini mau plan apa", menunggu admin verifikasi pembayaran.

⚠️ **Penting**: kalau user sedang `is_paid_member: true` lalu pilih plan yang
**berbeda** dari plan aktifnya, akses otomatis di-reset ke Free
(`is_paid_member` jadi `false`) — plan berbeda = harga berbeda = butuh
verifikasi baru. Tampilkan warning di UI sebelum submit kalau ini terjadi.

```json
{ "membership_plan_id": 2 }
```

**Response `200`:**
```json
{
  "app_role_code": "free-user",
  "is_paid_member": false,
  "membership_expires_at": null,
  "membership_plan": { "id": 2, "code": "member-premium-monthly", "name": "Member Premium", "description": "..." }
}
```

### `GET /membership/status` 🔒
Status membership terkini — dipakai untuk polling setelah user transfer,
menunggu admin klik "Mark Paid".

**Response `200`:**
```json
{
  "app_role_code": "member-premium-user",
  "is_paid_member": true,
  "membership_expires_at": "2026-09-24T09:04:32.000000Z",
  "membership_plan": { "id": 2, "code": "member-premium-monthly", "name": "Member Premium", "description": "..." },
  "latest_payment": null
}
```
`latest_payment` cuma terisi kalau ada riwayat lewat Xendit (saat ini selalu
`null` karena Xendit masih dijeda — abaikan field ini untuk sekarang).

`app_role_code` nilai yang mungkin: `free-user`, `member-user`,
`member-premium-user` — gunakan `is_paid_member` + `membership_expires_at`
untuk logic UI (badge, warning "akan habis"), bukan `app_role_code` mentah.

---

## Recurring Transactions

Base path: `/money-management/recurring` (gate permission
`money-management.recurring`). Dipakai untuk automasi transaksi berulang
(mis. langganan bulanan) — sistem generate `FinanceTransaction` beneran
setiap kali template jatuh tempo.

### `GET /money-management/recurring` 🔒
List semua template recurring milik user. Sebelum list diambil, endpoint
ini otomatis menjalankan proses "generate transaksi untuk yang jatuh
tempo" dulu (sama seperti `POST /recurring/process` di bawah) — jadi list
yang dikembalikan (termasuk `next_date`) selalu sudah up-to-date, tidak
perlu dipanggil terpisah tiap kali buka layar ini.

**Response `200`:**
```json
[
  {
    "id": 3,
    "user_id": 10,
    "name": "Langganan Netflix",
    "type": "expense",
    "finance_category_id": 1,
    "finance_investment_id": 1,
    "amount": "65000.00",
    "frequency": "monthly",
    "start_date": "2026-08-05",
    "next_date": "2026-09-05",
    "description": "Testing dari Postman",
    "is_active": true,
    "created_at": "2026-08-05T02:10:00.000000Z",
    "updated_at": "2026-08-05T02:10:00.000000Z",
    "category": { "id": 1, "name": "Subscription", "type": "expense" },
    "portfolio": { "id": 1, "account_name": "BCA Utama" }
  }
]
```

---

### `POST /money-management/recurring` 🔒
Buat template recurring baru. `next_date` otomatis di-set sama dengan
`start_date`, dan `is_active` otomatis `true` — tidak ada field ini di
request.

**Request:**
```json
{
  "name": "Langganan Netflix",
  "type": "expense",
  "finance_category_id": 1,
  "finance_investment_id": 1,
  "amount": 65000,
  "frequency": "monthly",
  "start_date": "2026-08-05",
  "description": "Opsional"
}
```
| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `name` | string | ya | max 255 |
| `type` | string | ya | `income` atau `expense` |
| `finance_category_id` | integer | ya | harus milik user (`finance_categories`) |
| `finance_investment_id` | integer | ya | akun/portofolio tujuan, harus milik user |
| `amount` | numeric | ya | min `0.01` |
| `frequency` | string | ya | `daily`, `weekly`, `monthly`, atau `yearly` |
| `start_date` | date | ya | tanggal mulai/generate pertama |
| `description` | string | tidak | — |

**Response `201`:** object recurring yang baru dibuat (shape sama seperti item di `GET /recurring`, tanpa relasi `category`/`portfolio` di-load).

---

### `PUT /money-management/recurring/{id}` 🔒
Edit template recurring yang sudah ada. Body **sama persis** dengan
`POST` di atas — semua field tetap wajib dikirim (bukan partial update).
Cuma bisa edit milik sendiri (404 kalau `id` bukan milik user).

⚠️ **Soal `next_date`**: kalau template ini **belum pernah diproses sama
sekali** (`next_date` di database masih sama dengan `start_date` lama),
mengubah `start_date` di request ini otomatis ikut menggeser `next_date`
supaya tetap sinkron. Tapi kalau template **sudah pernah** jalan
(`next_date` sudah maju melewati `start_date` awal), maka `next_date`
**tidak disentuh** — `start_date` di titik itu jadi murni catatan
historis kapan automasi ini pertama kali dibuat.

**Response `200`:** object recurring yang sudah diperbarui.

**Error `404`** kalau `id` tidak ditemukan / bukan milik user.
**Error `422`** kalau validasi gagal (format sama seperti `POST`).

---

### `DELETE /money-management/recurring/{id}` 🔒
Hapus template recurring. Transaksi yang **sudah** ter-generate sebelumnya
tetap ada — cuma template automasinya yang hilang, tidak ada penambahan
transaksi baru lagi ke depannya.

**Response `200`:**
```json
{ "success": "Recurring transaction berhasil dihapus" }
```

---

### `POST /money-management/recurring/process` 🔒
Trigger manual proses "generate transaksi untuk semua template yang jatuh
tempo" (`next_date <= hari ini` dan `is_active`), lalu majukan `next_date`
tiap template sesuai `frequency`-nya. Biasanya **tidak perlu dipanggil
manual** dari mobile karena `GET /recurring` sudah melakukan ini
otomatis setiap kali dipanggil — endpoint ini disediakan untuk kasus
kalau app butuh trigger proses tanpa sekalian minta list-nya.

**Response `200`:**
```json
{ "processed": 2 }
```
`processed` = jumlah template yang baru saja digenerate jadi transaksi
beneran pada request ini (bisa `0` kalau tidak ada yang jatuh tempo).

⚠️ Tidak ada endpoint untuk pause/resume (`is_active`) tanpa hapus —
"pause" saat ini cuma bisa dilakukan dengan `DELETE` template-nya.

---

## BTC Tracking

Base path: `/money-management/btc-tracking` (gate permission
`money-management.btc-tracking`). Ini **versi sederhana** untuk tracking
aset crypto — cuma deposit/withdrawal/profit/loss (seperti ledger akun
biasa di Portfolio), **tidak ada** fitur buy/sell/trade dengan harga
per-unit seperti Stock Tracking.

Setiap entry di sini sebenarnya adalah baris `FinanceInvestmentTransaction`
yang tersimpan terhadap sebuah akun Portofolio ber-tipe **crypto** — semua
endpoint `store`/`update` di bawah otomatis memvalidasi bahwa
`finance_investment_id` yang dikirim itu benar milik user **dan** tipe
investasinya `crypto` (404 kalau tidak, mis. kalau id itu akun bank biasa
atau akun broker saham).

### `GET /money-management/btc-tracking` 🔒
Ringkasan/overview — dipakai buat kartu total value + breakdown saldo per
aset di layar utama BTC Tracking. **Bukan** daftar transaksi baris-per-baris
— untuk itu pakai `GET /btc-tracking/activity` di bawah.

**Response `200`:**
```json
{
  "btc_portfolios": [
    { "id": 1, "user_id": 10, "finance_investment_id": 2, "account_name": "Indodax", "account_number": null, "description": null, "account_investment": true, "..." : "field lain sama seperti item di GET /portfolios" }
  ],
  "total_btc_value": 15000000,
  "asset_balances": [
    { "asset": "BTC", "balance": 12000000 },
    { "asset": "ETH", "balance": 3000000 }
  ]
}
```
`total_btc_value` = jumlah `balance` semua akun crypto (dalam Rupiah).
`asset_balances` = breakdown per simbol aset (`BTC`, `ETH`, dst — string
bebas yang diisi user sendiri lewat field `asset`, bukan daftar tetap).

---

### `GET /money-management/btc-tracking/activity` 🔒
Feed gabungan semua aktivitas crypto milik user, digabung dari dua sumber
dan diurutkan terbaru dulu — dipakai untuk layar "History" BTC Tracking
(setara datatable di web):
- `source_type: "investment"` — entry deposit/withdrawal/profit/loss yang
  dibuat lewat `POST /btc-tracking` di bawah (atau lewat halaman Portfolio).
- `source_type: "transfer"` — sisi transfer antar akun yang di-tag aset
  crypto (dibuat lewat endpoint Transfers, **bukan** dari sini). Baris jenis
  ini **tidak bisa** di-`PUT`/`DELETE` lewat BTC Tracking — kelola dari
  endpoint `/transfers`.

**Response `200`:**
```json
[
  {
    "id": 5,
    "finance_investment_id": 2,
    "asset": "BTC",
    "lot": null,
    "date": "2026-09-01",
    "type": "deposit",
    "amount": "1500000.00",
    "description": "Beli BTC",
    "source_type": "investment",
    "portfolio": { "id": 2, "account_name": "Indodax" }
  },
  {
    "id": 41,
    "finance_investment_id": 2,
    "asset": "BTC",
    "date": "2026-08-20",
    "type": "transfer",
    "amount": "500000.00",
    "description": "Transfer dari BCA Utama",
    "source_type": "transfer"
  }
]
```

---

### `POST /money-management/btc-tracking` 🔒
Catat entry deposit/withdrawal/profit/loss baru terhadap salah satu akun
crypto milik user.

**Request:**
```json
{
  "finance_investment_id": 2,
  "asset": "BTC",
  "date": "2026-09-08",
  "type": "deposit",
  "amount": 1500000,
  "description": "Opsional"
}
```
| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `finance_investment_id` | integer | ya | id akun Portfolio, harus milik user & tipe investasinya `crypto` |
| `asset` | string | ya | simbol aset, mis. `BTC`, `ETH` — **wajib** di sini (beda dari ledger Portfolio biasa yang boleh kosong), supaya selalu muncul di breakdown `asset_balances` |
| `date` | date | ya | — |
| `type` | string | ya | `deposit`, `withdrawal`, `profit`, atau `loss` |
| `amount` | numeric | ya | min `0`, dalam Rupiah |
| `description` | string | tidak | — |

**Response `201`:** object transaksi yang baru dibuat.

**Error `404`** kalau `finance_investment_id` bukan milik user atau bukan
akun bertipe crypto.

---

### `PUT /money-management/btc-tracking/{id}` 🔒
Edit entry deposit/withdrawal/profit/loss yang sudah ada. Body sama
seperti `POST` **tanpa** `finance_investment_id` (akun tujuan tidak bisa
diganti lewat sini — hapus lalu buat ulang kalau perlu pindah akun).

```json
{
  "asset": "BTC",
  "date": "2026-09-08",
  "type": "deposit",
  "amount": 1750000,
  "description": "Opsional"
}
```

**Response `200`:** object transaksi yang sudah diperbarui.

**Error `404`** kalau `id` bukan milik user, atau bukan entry di akun
bertipe crypto (mis. `id` itu sebenarnya baris `source_type: "transfer"` —
baris itu tidak dikelola dari sini sama sekali, lihat catatan di
`GET /activity` di atas).

---

### `DELETE /money-management/btc-tracking/{id}` 🔒
Hapus satu baris entry dari tracking.

**Response `200`:**
```json
{ "success": "Transaction removed from tracking" }
```

---

## Savings Goals

Base path: `/money-management/savings-goals` (gate permission
`money-management.savings-goals`). Fitur "Target Tabungan" — user bikin
target dengan tujuan/alasan tertentu (dana darurat, DP rumah, liburan, dst),
lalu mencatat nabung/tarik terhadap target itu. Desain lengkapnya ada di
[docs/money-management-savings-goals-blueprint.txt](money-management-savings-goals-blueprint.txt).

Dua hal penting yang beda dari modul lain:

1. **`saved_amount` selalu dihitung, tidak pernah diinput manual** — dari
   riwayat kontribusi (`POST .../contributions`), sama seperti saldo akun di
   Portfolio yang juga selalu dihitung ulang dari transaksi, bukan kolom
   tersimpan.
2. **`status` (`active`/`achieved`) juga otomatis** — begitu `saved_amount`
   mencapai `target_amount`, status berubah sendiri jadi `achieved` (dan
   balik lagi ke `active` kalau ada penarikan yang membuatnya turun di bawah
   target lagi). Tidak ada cara set status ini langsung lewat API — cuma ada
   status ketiga, `archived`, yang murni manual (lihat catatan di bawah,
   status ini belum ada endpoint khusus dari mobile, sementara kelola dari
   web).
3. **Satu akun (`finance_portfolio_id`) boleh dipakai untuk beberapa goal
   sekaligus** — kontribusi adalah ledger terpisah, bukan cerminan langsung
   saldo akun. Konsekuensinya: `is_over_allocated` di response bisa `true`
   kalau total yang "dialokasikan" ke satu akun (dari semua goal) sudah
   melebihi saldo asli akun itu — ini cuma penanda/warning, bukan yang
   memblokir request.

Goal juga bisa **dibagi dengan teman** — lihat
[Tabungan Bersama](#tabungan-bersama-shared-savings-goals). Di goal bersama
`saved_amount` / `progress_percent` / `status` dihitung dari kontribusi
**semua** member.

### `GET /money-management/savings-goals` 🔒
List semua goal milik user **plus goal bersama yang sudah user terima**,
sudah termasuk perhitungan progress-nya. Tiap item punya field tambahan
`is_shared`, `role`, `owner`, `my_contribution`, `members` (lihat
[Tabungan Bersama](#field-tambahan-di-response-goal-additive)).

**Response `200`:**
```json
{
  "active_count": 2,
  "achieved_count": 1,
  "goals": [
    {
      "id": 4,
      "name": "Dana Darurat",
      "purpose": "Cadangan 6 bulan pengeluaran",
      "portfolio": { "id": 1, "name": "BCA - Rekening Utama" },
      "target_amount": 50000000,
      "target_date": "2027-01-01",
      "saved_amount": 15000000,
      "progress_percent": 30,
      "remaining_amount": 35000000,
      "is_over_allocated": false,
      "status": "active",
      "icon": "shield-tick",
      "color": "success"
    }
  ]
}
```
`portfolio` bisa `null` kalau goal tidak diikat ke akun manapun (target yang
masih murni aspirasional). `progress_percent` sudah dibatasi maksimal `100`.

---

### `POST /money-management/savings-goals` 🔒
Buat goal baru.

**Request:**
```json
{
  "name": "Dana Darurat",
  "purpose": "Cadangan 6 bulan pengeluaran",
  "finance_portfolio_id": 1,
  "target_amount": 50000000,
  "target_date": "2027-01-01",
  "icon": "shield-tick",
  "color": "success"
}
```
| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `name` | string | ya | max 255 |
| `purpose` | string | tidak | alasan/tujuan menabung — tampilkan ini di UI supaya user ingat "untuk apa" targetnya |
| `finance_portfolio_id` | integer | tidak | akun sumber dana default untuk goal ini, harus milik user. Kosongkan/`null` kalau goal belum terikat akun manapun |
| `target_amount` | numeric | ya | min `0.01` |
| `target_date` | date | tidak | deadline, boleh kosong |
| `icon` | string | tidak | nama ikon buat UI (bebas, app yang menentukan pemetaan ke aset ikon di sisi mobile) |
| `color` | string | tidak | salah satu dari `primary`, `success`, `info`, `warning`, `danger`. Default `primary` kalau tidak dikirim |

**Response `201`:** shape sama persis seperti satu item di `goals[]` pada
`GET /savings-goals` (`saved_amount: 0`, `progress_percent: 0`,
`status: "active"` untuk goal yang baru dibuat).

**Error `404`** kalau `finance_portfolio_id` dikirim tapi bukan milik user
(bukan `422` — beda dari kebanyakan field lain di app ini yang pakai
`exists:...`; ownership-nya dicek di layer Service, bukan validation rule).

---

### `PUT /money-management/savings-goals/{id}` 🔒
Edit goal yang sudah ada. Body **sama persis** dengan `POST` di atas — semua
field wajib dikirim ulang (bukan partial update). Mengubah `target_amount`
bisa langsung memicu `status` berubah (mis. diturunkan sampai di bawah
`saved_amount` yang sudah ada → otomatis jadi `achieved`).

**Response `200`:** shape sama seperti `POST`, dengan `saved_amount` /
`progress_percent` / `status` terkini (bukan di-reset).

**Error `404`** kalau `id` bukan milik user, atau `finance_portfolio_id`
yang dikirim bukan milik user.

---

### `DELETE /money-management/savings-goals/{id}` 🔒
Hapus goal secara permanen — **cascade** menghapus seluruh riwayat
kontribusi/penarikannya juga. Tidak bisa dibatalkan. Kalau cuma mau
menghentikan goal tanpa kehilangan riwayatnya, pakai `POST .../archive` di
bawah.

**Response `200`:**
```json
{ "success": true }
```

---

### `POST /money-management/savings-goals/{id}/archive` 🔒
Arsipkan goal — cara "menutup" goal tanpa menghapus riwayatnya (beda dari
`DELETE` yang permanen). Goal berstatus `archived` berhenti dihitung sebagai
`active_count`/`achieved_count`, tapi tetap muncul di `GET /savings-goals`
dan riwayat kontribusinya tetap bisa diambil. Tidak ada endpoint untuk
un-archive — status ini murni satu arah dari sisi mobile (kelola dari web
kalau perlu batalkan arsip).

**Response `200`:** shape sama seperti item di `goals[]` pada
`GET /savings-goals`, dengan `status: "archived"`.

---

### `GET /money-management/savings-goals/{id}/contributions` 🔒
Riwayat nabung/tarik satu goal, terbaru dulu.

**Response `200`:**
```json
[
  {
    "id": 12,
    "type": "contribution",
    "date": "2026-09-11",
    "amount": 500000,
    "note": "Nabung awal bulan",
    "portfolio": { "id": 1, "name": "BCA - Rekening Utama" },
    "created_at": "2026-09-11T02:00:00+00:00"
  }
]
```
`type` salah satu dari `contribution` (menambah `saved_amount`) atau
`withdrawal` (mengurangi). `portfolio` bisa `null` kalau baris ini tidak
dicatat terhadap akun manapun.

Untuk goal bersama, riwayat berisi kontribusi **semua** member. Field
tambahan (additive): `contributor` (`{id, name}` pencatat), `is_mine`
(`true` kalau dicatat oleh user yang login). `portfolio` hanya terisi untuk
baris milik sendiri — akun member lain tidak pernah terlihat. Query
opsional `?mine=1` untuk hanya menampilkan baris sendiri.

---

### `POST /money-management/savings-goals/{id}/contributions` 🔒
Catat nabung atau tarik. Satu endpoint untuk dua arah — dibedakan lewat
field `type`.

**Request (nabung):**
```json
{
  "type": "contribution",
  "date": "2026-09-11",
  "amount": 500000,
  "finance_portfolio_id": 1,
  "note": "Nabung awal bulan"
}
```
**Request (tarik):**
```json
{
  "type": "withdrawal",
  "date": "2026-09-11",
  "amount": 200000,
  "note": "Dipakai untuk keperluan darurat"
}
```
| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `type` | string | ya | `contribution` atau `withdrawal` |
| `date` | date | ya | — |
| `amount` | numeric | ya | min `0.01` |
| `finance_portfolio_id` | integer | tidak | akun untuk baris ini, harus milik user. Kalau **tidak dikirim sama sekali** (key absen dari body), otomatis pakai `finance_portfolio_id` default milik goal-nya; kalau dikirim `null`/kosong, artinya sengaja tidak dicatat ke akun manapun untuk baris ini |
| `note` | string | tidak | — |
| `idempotency_key` | string | tidak | max 64, UUID baru per percobaan user. Kalau request yang sama di-retry (timeout) dengan key yang sama, tidak dicatat dua kali (tetap `200`). **Disarankan selalu dikirim** untuk goal bersama |

**Response `200`:**
```json
{ "success": true }
```

**Error `400`** kalau `type: "withdrawal"` dengan `amount` melebihi dana
yang **dikontribusikan user itu sendiri** ke goal ini (bukan total goal —
di goal bersama tiap orang hanya bisa menarik bagiannya sendiri; di goal
pribadi sama dengan `saved_amount`). Bukan `422` — ini business rule, bukan
validasi format:
```json
{ "error": "Penarikan melebihi dana yang sudah terkumpul. Tersedia Rp 100.000" }
```

---

### `DELETE /money-management/savings-goals/{id}/contributions/{contributionId}` 🔒
Hapus satu baris riwayat nabung/tarik. `saved_amount` dan `status` goal
otomatis dihitung ulang setelah baris ini hilang.

**Response `200`:**
```json
{ "success": true }
```

**Error `400`** kalau `contributionId` ada tapi bukan milik `id` (goal) yang
dituju di URL:
```json
{ "error": "Kontribusi ini tidak ditemukan pada goal ini" }
```
Hanya **pencatat asli** yang bisa menghapus barisnya (`404` untuk baris milik
member lain). Di goal bersama, `400` juga muncul kalau menghapus kontribusi
itu akan membuat bagian user lebih kecil dari penarikan yang sudah dia
lakukan.

---

## Tabungan Bersama (Shared Savings Goals)

Goal yang sama dengan Savings Goals di atas, tapi punya **member** (teman).
Tiap member menabung dari akunnya sendiri; progress goal = jumlah kontribusi
semua orang. Gate permission tetap `money-management.savings-goals`. Rencana
lengkap: [plan-dev/tabungan-bersama-plan.txt](../plan-dev/tabungan-bersama-plan.txt).

Aturan:

1. **Hanya teman** ([Teman](#teman-friends)) yang bisa diundang. Undangan
   harus **diterima** dulu; sebelum itu orang tersebut tidak bisa melihat
   atau menabung ke goal. Undangan kedaluwarsa 14 hari.
2. **Dua role**: `owner` (pembuat: edit target, undang/keluarkan, arsip,
   hapus) dan `member` (menabung/menarik bagiannya sendiri, melihat progress,
   keluar). Endpoint edit/hapus/arsip/undang untuk non-owner menjawab `404`.
3. **Maksimal 5 orang per goal** (owner + 4 member; undangan yang belum
   kedaluwarsa ikut dihitung).
4. **Privasi**: member hanya melihat nama, avatar, dan total kontribusi tiap
   orang di goal itu. Akun/portofolio dan saldo orang lain tidak pernah
   muncul; `portfolio` pada goal milik orang lain selalu `null`, dan
   `finance_portfolio_id` default goal **tidak** diwariskan ke member.
5. **Penarikan dibatasi bagian sendiri** (lihat `POST .../contributions`).
6. **Member keluar / dikeluarkan**: kontribusinya **tetap** di goal (riwayat
   tidak dihapus), hanya kursinya dilepas. Baris `left` tetap muncul di
   `members` selama kontribusi bersihnya tidak nol.
7. **Hapus goal bersama** hanya boleh kalau `saved_amount` = 0; kalau masih
   ada saldo, jawabannya `409 SHARED_GOAL_HAS_BALANCE` — arsipkan saja
   (`POST .../archive`).
8. **Online-only**, tidak dimasukkan ke antrean offline/sync.

### Field tambahan di response goal (additive)

`GET /savings-goals`, `POST`, `PUT`, `archive`, dan `accept invitation`
mengembalikan item goal dengan field tambahan — field lama **tidak berubah**,
jadi app versi lama tidak rusak. Goal pribadi: `is_shared: false`,
`role: "owner"`, `members: []`.

```json
{
  "id": 7,
  "name": "Liburan Bareng",
  "saved_amount": 500000,
  "progress_percent": 50,
  "is_shared": true,
  "role": "member",
  "owner": { "user_id": 10, "name": "Budi Santoso" },
  "my_contribution": 200000,
  "members": [
    { "user_id": 10, "name": "Budi Santoso", "avatar_url": null, "role": "owner",  "status": "active",  "contributed_amount": 300000, "contribution_percent": 60.0 },
    { "user_id": 12, "name": "Sari Dewi",    "avatar_url": null, "role": "member", "status": "active",  "contributed_amount": 200000, "contribution_percent": 40.0 },
    { "user_id": 15, "name": "Andi",         "avatar_url": null, "role": "member", "status": "pending", "contributed_amount": 0,      "contribution_percent": 0.0 }
  ]
}
```
`role` = peran **user yang login** (`owner`/`member`). `members[].status`:
`active`, `pending` (undangan belum dijawab — hanya terlihat oleh owner dan
yang diundang), `left` (sudah keluar tapi masih ada kontribusi).
`members[0]` selalu owner.

### `POST /money-management/savings-goals` — buat goal sekaligus undang teman 🔒
Sama seperti buat goal biasa, ditambah field opsional:

| Field | Tipe | Keterangan |
|---|---|---|
| `member_ids` | integer[] | id teman (`user_id` dari `GET /friends`), maks 4. Goal langsung `is_shared: true` dan undangan terkirim. Kalau salah satu bukan teman, **seluruh request ditolak** (goal tidak dibuat) |

### `POST /money-management/savings-goals/{id}/members` 🔒
Owner mengundang teman ke goal yang sudah ada (goal pribadi otomatis menjadi
bersama). **Response `201`:** item goal. Error: lihat tabel kode di bawah.
```json
{ "user_ids": [12, 15] }
```

### `DELETE /money-management/savings-goals/{id}/members/{userId}` 🔒
Dua kegunaan: **owner mengeluarkan** member (atau membatalkan undangan yang
belum dijawab), atau **member keluar sendiri** (`userId` = id user yang
login). **Response `200`:** `{ "success": true }`.

### `GET /money-management/savings-goals/invitations` 🔒
Undangan goal yang menunggu user (yang belum kedaluwarsa), terbaru dulu.
Tidak ada push notification di v1 — tampilkan sebagai badge/inbox dan
refresh saat app dibuka / pull-to-refresh.
```json
[
  {
    "id": 3,
    "goal": { "id": 7, "name": "Liburan Bareng", "purpose": null, "target_amount": 1000000, "target_date": null, "icon": null, "color": "primary" },
    "owner": { "user_id": 10, "name": "Budi Santoso" },
    "invited_by": { "user_id": 10, "name": "Budi Santoso" },
    "expires_at": "2026-11-09T03:00:00+00:00",
    "created_at": "2026-10-26T03:00:00+00:00"
  }
]
```
`id` di sini adalah id **undangan** (bukan id goal).

### `POST /money-management/savings-goals/invitations/{id}/accept` 🔒
Terima undangan. **Response `200`:** item goal (user sekarang `role: "member"`).

### `POST /money-management/savings-goals/invitations/{id}/decline` 🔒
Tolak undangan. **Response `200`:** `{ "success": true }`.

### Kode error tabungan bersama
Selain `404`/`422` validasi biasa, error bisnis baru memakai format yang
sama dengan Wallet — `{ "message": "...", "code": "..." }`; pakai `code`,
bukan teks `message`:

| HTTP | `code` | Arti |
|---|---|---|
| 422 | `NOT_FRIENDS` | Salah satu user yang diundang bukan teman owner |
| 422 | `MEMBER_LIMIT_REACHED` | Melebihi 5 orang per goal |
| 409 | `ALREADY_MEMBER` | Sudah menjadi member aktif |
| 409 | `ALREADY_INVITED` | Undangan masih menunggu jawaban |
| 409 | `GOAL_ARCHIVED` | Goal yang diarsipkan tidak bisa menerima member baru |
| 409 | `OWNER_CANNOT_LEAVE` | Owner tidak bisa keluar dari goalnya (arsipkan/hapus saja) |
| 403 | `NOT_GOAL_OWNER` | Member biasa mencoba mengeluarkan orang lain |
| 409 | `SHARED_GOAL_HAS_BALANCE` | Hapus goal bersama yang masih ada saldo |
| 410 | `INVITATION_EXPIRED` | Undangan sudah kedaluwarsa (minta owner mengundang ulang) |

Penarikan melebihi bagian sendiri dan hapus-kontribusi yang ditolak tetap
memakai bentuk lama `400 { "error": "..." }`.

---

## Teman (Friends)

Base path: `/money-management/friends` (gate permission
`money-management.friends`, diberikan ke semua role money-management).
Pertemanan **mutual**: kirim permintaan → harus **diterima**. Dipakai untuk
memilih collaborator [Tabungan Bersama](#tabungan-bersama-shared-savings-goals).

- Teman ditemukan lewat **username** (username akun yang sama dengan
  untuk login). Tampilkan username sendiri dari `GET /friends/me` supaya bisa
  dibagikan/disalin. Input **tidak sensitif huruf besar/kecil** dan awalan
  `@` diabaikan.
- Yang terlihat dari seorang teman hanya `user_id`, `name`, `username`,
  `avatar_url` — tidak pernah e-mail, nomor rekening dompet, atau saldo.
  Username yang tidak ditemukan dan username sendiri dijawab dengan kode
  berbeda (`USER_NOT_FOUND` / `SELF_FRIEND`); pencarian dibatasi 20/menit.
- Kalau B sudah mengirim permintaan ke A lalu A mengirim ke B, keduanya
  otomatis menjadi teman (`status: "accepted"` di response).
- Menolak permintaan menghapusnya, jadi pengirim boleh mencoba lagi nanti.
- Rate limit: `lookup` dan kirim permintaan 20/menit (`429`).
- Menghapus teman **tidak** mengubah tabungan bersama yang sudah berjalan
  (data uang tidak hilang); hanya saja tidak bisa diundang lagi.

Error bisnis: `{ "message": "...", "code": "..." }`

| HTTP | `code` | Arti |
|---|---|---|
| 422 | `USER_NOT_FOUND` | Username tidak ditemukan |
| 422 | `SELF_FRIEND` | Username milik sendiri |
| 409 | `ALREADY_FRIENDS` | Sudah berteman |
| 409 | `REQUEST_EXISTS` | Permintaan ke orang ini sudah dikirim |

### `GET /money-management/friends/me` 🔒
```json
{ "data": { "username": "budisantoso" } }
```

### `GET /money-management/friends` 🔒
Daftar teman + ringkasan jumlah permintaan menunggu (untuk badge).
```json
{
  "data": [
    { "user_id": 12, "name": "Sari Dewi", "username": "saridewi", "avatar_url": null, "since": "2026-10-26T03:00:00+00:00" }
  ],
  "meta": { "friends_count": 1, "incoming_pending": 2, "outgoing_pending": 0 }
}
```

### `GET /money-management/friends/requests?direction=incoming|outgoing` 🔒
Permintaan yang menunggu; default `incoming`. `user` adalah **pihak lain**
(pengirim untuk `incoming`, tujuan untuk `outgoing`).
```json
{ "data": [ { "id": 5, "user": { "user_id": 12, "name": "Sari Dewi", "username": "saridewi", "avatar_url": null }, "created_at": "2026-10-26T03:00:00+00:00" } ] }
```

### `POST /money-management/friends/lookup` 🔒
Langkah 1 tambah teman: cek pemilik username.
```json
{ "username": "saridewi" }
```
**Response `200`:**
```json
{ "data": { "name": "Sari Dewi", "username": "saridewi", "avatar_url": null, "relationship": "none" } }
```
`relationship`: `none`, `friends`, `pending_outgoing`, `pending_incoming` —
dipakai untuk menonaktifkan tombol "Tambah" kalau sudah berelasi.

### `POST /money-management/friends/requests` 🔒
Langkah 2: kirim permintaan.
```json
{ "username": "saridewi" }
```
**Response `201`:** `{ "data": { "id": 5, "status": "pending" } }`
(`"accepted"` kalau permintaan saling bertemu).

### `POST /money-management/friends/requests/{id}/accept` 🔒
### `POST /money-management/friends/requests/{id}/decline` 🔒
Hanya penerima permintaan. **Response `200`:** `{ "success": true }`.
`404` kalau `id` bukan permintaan masuk milik user.

### `DELETE /money-management/friends/requests/{id}` 🔒
Pengirim membatalkan permintaan keluar. **Response `200`:** `{ "success": true }`.

### `DELETE /money-management/friends/{userId}` 🔒
Hapus teman (`userId` = `user_id` teman). **Response `200`:**
`{ "success": true }`. `404` kalau bukan teman.

---

## Wallet (Dompet Saldo & Transfer antar User)

Base path: `/money-management/wallet` (gate permission
`money-management.wallet`, diberikan ke semua role money-management). Tiap
user punya **satu dompet** dengan **nomor rekening 12 digit** (awalan `88`,
digit terakhir = check digit Luhn). User bisa kirim saldo dompet ke user lain
lewat nomor rekening, dan memindahkan saldo antara dompet <-> portofolio
sendiri. Desain lengkap: [money-management-wallet-p2p-transfer-blueprint.txt](money-management-wallet-p2p-transfer-blueprint.txt).

Aturan penting untuk mobile:

1. **Online-only.** Jangan masukkan endpoint ini ke antrean offline/sync.
   Boleh cache tampilan terakhir (read-only) dengan label "terakhir
   diperbarui".
2. **PIN dikirim di dalam request** transfer / topup / withdraw dan
   diverifikasi server. `POST /auth/verify-pin` hanya untuk lock screen —
   jangan dipakai sebagai pengganti. 5 PIN salah berturut-turut mengunci
   aksi dompet 15 menit (`423`, lihat `retry_after`).
3. **`idempotency_key` wajib** di `POST /transfer` (UUID baru per percobaan
   user; **pakai ulang key yang sama** saat retry karena timeout). Key yang
   sudah pernah sukses mengembalikan transfer yang sama dengan status `200`
   (bukan `201`), tanpa memindahkan uang dua kali.
4. **Semua nominal integer rupiah** di JSON. Nomor rekening & nama lawan
   transaksi: **nama ditampilkan lengkap** (supaya pengirim bisa memastikan
   tidak salah transfer), sedangkan **nomor rekening disamarkan**
   (`88******7890`); nomor lengkap hanya ada di `GET /` milik user sendiri.
5. Saldo dompet ikut dihitung di net worth (dashboard & summary) sebagai
   akun "Dompet Saldo".
6. Untuk memilih portofolio di topup/withdraw, ambil daftar dari
   `GET /money-management/portfolios`.

**Format error**: validasi Laravel `422` biasa, atau error bisnis dengan
`code` yang stabil (pakai `code`, bukan teks `message`, untuk logika UI):
```json
{ "message": "Saldo dompet tidak cukup.", "code": "INSUFFICIENT_BALANCE" }
```

| HTTP | `code` | Arti |
|---|---|---|
| 422 | `PIN_INVALID` | PIN salah (juga ada di `errors.pin`) |
| 422 | `PIN_NOT_SET` | User belum punya PIN, arahkan ke `POST /auth/pin` |
| 422 | `ACCOUNT_NOT_FOUND` | Nomor rekening salah/tidak ada/dompet dibekukan (sengaja tidak dibedakan) |
| 422 | `SELF_TRANSFER` | Rekening tujuan = rekening sendiri |
| 422 | `AMOUNT_TOO_SMALL` / `AMOUNT_TOO_LARGE` | Di luar batas min/maks per transaksi |
| 403 | `WALLET_FROZEN` | Dompet Anda dibekukan admin |
| 409 | `INSUFFICIENT_BALANCE` | Saldo dompet kurang |
| 409 | `INSUFFICIENT_PORTFOLIO_BALANCE` | Saldo portofolio kurang (topup) |
| 409 | `DAILY_LIMIT_EXCEEDED` | Limit transfer harian terlampaui |
| 423 | `PIN_LOCKED` | PIN terkunci; body ada `retry_after` (detik) |
| 429 | - | Rate limit (lookup 20/menit, transfer/topup/withdraw 10/menit) |

### `GET /money-management/wallet` 🔒
**Response `200`:**
```json
{
  "data": {
    "account_number": "881234567890",
    "balance": 850000,
    "status": "active",
    "limits": {
      "min_transfer": 10000,
      "max_transfer": 5000000,
      "daily_limit": 10000000,
      "sent_today": 150000,
      "remaining_today": 9850000
    }
  }
}
```

---

### `GET /money-management/wallet/transactions` 🔒
Mutasi dompet, terbaru dulu. Query opsional: `type`
(`all|transfer_out|transfer_in|topup_from_portfolio|withdraw_to_portfolio|reversal|adjustment`),
`from`, `to` (tanggal), `page`, `per_page` (maks 100, default 20).

**Response `200`:**
```json
{
  "data": [
    {
      "id": 12,
      "type": "transfer_out",
      "direction": "out",
      "amount": 150000,
      "balance_after": 850000,
      "description": "Transfer ke 88******7890",
      "transfer": {
        "id": 41, "reference_no": "TRF-20261004-AB12CD", "direction": "out",
        "amount": 150000, "note": "Bayar makan siang", "status": "completed",
        "counterparty": { "name": "Budi Santoso", "account_number": "88******7890" },
        "created_at": "2026-10-04T10:15:00+07:00"
      },
      "created_at": "2026-10-04T10:15:00+07:00"
    }
  ],
  "meta": { "current_page": 1, "last_page": 1, "per_page": 20, "total": 1 }
}
```
`transfer` bernilai `null` untuk entri topup/withdraw. `direction`
`in`/`out` = menambah/mengurangi saldo.

---

### `POST /money-management/wallet/lookup` 🔒
Langkah 1 transfer: cek nomor rekening tujuan.
```json
{ "account_number": "881234567890" }
```
**Response `200`:**
```json
{ "data": { "account_number": "881234567890", "masked_account_number": "88******7890", "name": "Budi Santoso" } }
```
Error: `422 ACCOUNT_NOT_FOUND`, `422 SELF_TRANSFER`.

---

### `POST /money-management/wallet/transfer` 🔒
Langkah 2: kirim.
```json
{
  "to_account_number": "881234567890",
  "amount": 150000,
  "note": "Bayar makan siang",
  "pin": "123456",
  "idempotency_key": "b3f1c9e2-7a54-4c1e-9f0d-2a6e8d1c4b77"
}
```
**Response `201`** (`200` jika `idempotency_key` sudah pernah sukses):
```json
{
  "data": {
    "id": 41,
    "reference_no": "TRF-20261004-AB12CD",
    "direction": "out",
    "amount": 150000,
    "note": "Bayar makan siang",
    "status": "completed",
    "counterparty": { "name": "Budi Santoso", "account_number": "88******7890" },
    "created_at": "2026-10-04T10:15:00+07:00",
    "balance_after": 850000
  }
}
```
Transfer bersifat final, tidak bisa diedit/dihapus user; koreksi hanya lewat
pembatalan admin (web).

---

### `GET /money-management/wallet/transfers/{id}` 🔒
Detail/struk satu transfer yang dikirim **atau diterima** user. Bentuknya
sama dengan `data` di atas (tanpa `balance_after`; `direction` relatif ke
user yang login). `404` jika bukan transfer milik user.

---

### `POST /money-management/wallet/topup` 🔒
Isi dompet dari portofolio sendiri (saldo portofolio berkurang).
```json
{ "finance_portfolio_id": 1, "amount": 500000, "description": "Isi dompet", "pin": "123456" }
```
**Response `201`:** satu entri mutasi (bentuk sama dengan item di
`/transactions`, `type: "topup_from_portfolio"`).
Error: `409 INSUFFICIENT_PORTFOLIO_BALANCE`, `404` jika portofolio bukan milik user.

### `POST /money-management/wallet/withdraw` 🔒
Tarik saldo dompet ke portofolio sendiri. Body sama dengan topup.
**Response `201`:** entri mutasi `type: "withdraw_to_portfolio"`.
Error: `409 INSUFFICIENT_BALANCE`.

---

## Reports (Laporan)

Endpoint laporan di menu Summary (`/money-management/reports/*`: cash-flow,
savings-rate, compare, category, unexpected-expenses, year-in-review, tax)
didokumentasikan terpisah di [mobile-api-reports.md](mobile-api-reports.md).

---

## Legend
🔒 = butuh header `Authorization: Bearer {token}` (route di belakang `auth:sanctum`).
