# Referensi API Mobile (Auth, PIN, Membership)

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

## Legend
🔒 = butuh header `Authorization: Bearer {token}` (route di belakang `auth:sanctum`).
