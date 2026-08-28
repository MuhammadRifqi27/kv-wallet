# Alur Reset Password (Admin-Mediated, Tanpa Email)

## Kenapa seperti ini

App ini belum punya provider email/SMS/WhatsApp transactional yang siap
production. Dua alternatif sempat dicoba sebelum ini:

1. **Local-dev shortcut** (yang lama) — `AuthController::resetPassword()`
   mengganti password siapa pun cukup berdasarkan lookup email, **tanpa
   verifikasi token sama sekali**. Ini lubang keamanan serius (account
   takeover) yang cuma "aman" karena app belum pernah dipakai publik.
2. **Email asli via Mailtrap** — sempat dibangun penuh (notifikasi
   ter-branding, tema email teal, dst), tapi di-revert karena app masih
   tahap local development dan belum ada provider email production yang
   siap — lihat riwayat commit sekitar tanggal ini kalau butuh referensi
   implementasinya.

Solusi saat ini: **admin yang jadi kurir link reset**, bukan sistem
otomatis. User dapat link yang sama amannya (token asli, single-use, dari
`Illuminate\Auth\Passwords\PasswordBroker` bawaan Laravel), tapi
pengirimannya manual oleh admin lewat WhatsApp/telepon — nol dependency ke
provider eksternal.

## Alur lengkap

```
User (web/mobile)                Admin (panel web)              User (browser/app)
─────────────────                ─────────────────              ───────────────────
1. Isi form/API:
   identifier + phone + note
   → POST /forgot-password (web)
   → POST /api/v1/auth/
     password-reset-request
        │
        ▼
   Tersimpan sebagai tiket
   `password_reset_requests`
   status: pending
                                  2. Lihat daftar tiket di
                                     administrator/
                                     password-reset-requests
                                        │
                                        ▼
                                     3. Klik "Proses" →
                                        Password::createToken()
                                        (token asli, TIDAK
                                        memicu notifikasi apa pun)
                                        status → processed
                                        │
                                        ▼
                                     4. Link ditampilkan ke admin,
                                        admin copy & kirim manual
                                        via WhatsApp/telepon
                                                                   5. User buka link
                                                                      /reset-password/{token}
                                                                      ?email=...
                                                                      → set password baru
                                                                      → Password::reset()
                                                                        verifikasi token asli
```

## Bagian-bagian yang terlibat

**Web (form + admin panel)**
- `resources/views/pages/auth/forgot-password.blade.php` — form publik (identifier, phone, note), tema teal senada login/register.
- `app/Http/Controllers/PasswordResetRequestController.php` — `store()` (publik, bikin tiket), `index()`/`datatable()` (admin, list tiket), `process()` (admin, generate link), `reject()`.
- `resources/views/pages/admin/password_reset_requests.blade.php` — DataTable admin, tombol "Proses"/"Lihat Link Lagi"/"Tolak", modal salin-link dengan fallback `document.execCommand('copy')` untuk domain non-`https`/non-`localhost` (Clipboard API browser butuh secure context).
- `resources/views/pages/auth/reset-password.blade.php` — halaman set password baru. **Sama** dipakai baik link dari admin maupun (kalau nanti diaktifkan lagi) link dari email — halaman ini tidak peduli link-nya datang dari mana.

**Mobile API** (`app/Http/Controllers/Api/V1/AuthController.php`, lihat [docs/mobile-api-reference.md](mobile-api-reference.md) bagian "Password Reset")
- `POST /auth/password-reset-request` — versi API dari form web di atas.
- `GET /auth/password-reset-request/status` — polling status tiket.
- `POST /auth/password-reset` — versi API dari `reset-password.blade.php`, buat app yang mau handle di dalam app (deep link) alih-alih membuka browser.

**Service layer** (`app/Services/Auth/AuthService.php` + `AuthServiceImplement.php`)
- `generateResetToken(User $user): string` — wrapper tipis untuk `Password::createToken()`. Dipakai **hanya** oleh admin saat klik "Proses"/"Lihat Link Lagi". Tidak pernah memicu notifikasi/email.
- `resetUserPassword(array $data): string` — wrapper tipis untuk `Password::reset()`, verifikasi token asli + update password. Dipakai oleh `AuthController::resetPassword()` (web) dan `Api\V1\AuthController::resetPassword()` (mobile) — dua entry point, satu logic.

**Data**
- Migrasi `database/migrations/2026_08_28_090701_create_password_reset_requests_table.php` — tabel tiket (`user_id`, `identifier`, `phone`, `note`, `status`, `processed_by`, `processed_at`).
- `app/Models/PasswordResetRequest.php` — accessor `status_badge_class`/`status_label` untuk tampilan admin.

## Catatan keamanan

- **Token mentah tidak pernah disimpan** di tabel `password_reset_requests` — cuma dipakai sekali untuk membentuk link lalu langsung dilupakan sisi server. Laravel sendiri cuma menyimpan **hash** token di `password_reset_tokens` (tabel bawaan framework), bukan token mentahnya.
- Klik "Proses"/"Lihat Link Lagi" berkali-kali **aman** — tiap panggilan `Password::createToken()` otomatis menghapus token lama untuk user itu sebelum membuat yang baru, jadi cuma link **terakhir** yang pernah valid.
- Token expire 60 menit, single-use (dikonsumsi begitu `Password::reset()` berhasil) — sama persis proteksinya seperti alur email standar Laravel, cuma kanal pengirimannya yang beda.
- Endpoint mobile (`password-reset-request`, `password-reset-request/status`, `password-reset`) sengaja publik (tanpa `auth:sanctum`) — user di titik ini memang belum bisa login.

## Kalau nanti mau upgrade ke email/WhatsApp API otomatis

Tidak perlu ubah `reset-password.blade.php`, `AuthService::resetUserPassword()`,
atau endpoint mobile `POST /auth/password-reset` sama sekali — itu semua
sudah generic (cuma butuh token+email yang valid, tidak peduli asalnya).
Yang perlu diganti cuma bagian **pengiriman**: ganti admin manual-copy-paste
di `PasswordResetRequestController::process()` dengan pemanggilan
`Password::sendResetLink()` (email) atau API WhatsApp/SMS pilihan, dan
tambahkan Notification class kalau lewat email (pernah dibuat sebelumnya,
lihat riwayat commit untuk referensi `ResetPasswordNotification` +
tema mail teal-nya kalau mau dipakai lagi).
