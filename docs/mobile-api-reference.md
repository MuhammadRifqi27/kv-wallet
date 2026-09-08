# Referensi API Mobile (Auth, PIN, Membership, Recurring Transactions, BTC Tracking)

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

## Legend
🔒 = butuh header `Authorization: Bearer {token}` (route di belakang `auth:sanctum`).
