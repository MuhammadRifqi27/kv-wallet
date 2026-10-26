# API Rekomendasi Budget — Panduan untuk Mobile Dev

Fitur "Rekomendasi Budget" (tombol di halaman Monthly Budgets di web):
server menyarankan nominal budget per kategori pengeluaran berdasarkan 3
cycle gaji terakhir, user memilih kategori mana yang diterapkan. Untuk hal
umum (login, token, format error) lihat
[mobile-api-reference.md](mobile-api-reference.md). Koleksi Postman: folder
**Budgets**, request "Budget Recommendations" dan "Apply Budget Recommendations".

- **Base URL**: `{{base_url}}/api/v1/money-management/budgets/recommendations`
- **Auth**: `Authorization: Bearer {token}` + `Accept: application/json`
- **Permission**: `money-management.budgets` (sama dengan endpoint budget
  lain). Tanpa itu respons `403`.
- **Online-only**: saran dihitung server dari seluruh riwayat transaksi.
- Periode adalah **cycle gaji** (hari gajian diatur user), `month` + `year`
  menyebut cycle-nya, sama seperti `GET /budgets`.

---

## `GET /budgets/recommendations`

| Param | Wajib | Keterangan |
|---|---|---|
| `month` | ya | 1–12, cycle yang akan diisi budget-nya |
| `year` | ya | 2000–2100 |

```
GET /budgets/recommendations?month=10&year=2026
```
```json
{
  "data": {
    "items": [
      {
        "category_id": 4,
        "category_name": "Shop",
        "average_spent": 1283086.67,
        "share_percent": 13.5,
        "current_budget": 0,
        "suggested_budget": 570000,
        "suggested_percent": 13.6,
        "overspent_cycles": 1,
        "limited": false
      },
      {
        "category_id": 2,
        "category_name": "Food",
        "average_spent": 890116.67,
        "share_percent": 14.6,
        "current_budget": 500000,
        "suggested_budget": 500000,
        "suggested_percent": 11.9,
        "overspent_cycles": 1,
        "limited": true
      }
    ],
    "basis": "percentage",
    "income_pool": 4189363,
    "cycles": 3
  }
}
```

### Field `data`

| Field | Arti |
|---|---|
| `basis` | `"percentage"` atau `"nominal"` — cara saran dihitung (lihat di bawah) |
| `income_pool` | total pemasukan pada cycle `month/year` (dasar hitungan bila `basis = percentage`) |
| `cycles` | jumlah cycle ke belakang yang dipakai (saat ini selalu `3`) |
| `items` | saran per kategori, **sudah diurutkan dari `suggested_budget` terbesar**. Bisa kosong |

### Field tiap item

| Field | Arti |
|---|---|
| `category_id`, `category_name` | kategori pengeluaran |
| `average_spent` | rata-rata pengeluaran per cycle (3 cycle terakhir) |
| `share_percent` | rata-rata porsi kategori terhadap pemasukan, dalam persen (`13.5` = 13,5%) |
| `current_budget` | budget yang sudah tersimpan untuk cycle ini (`0` = belum ada) |
| `suggested_budget` | **nominal saran**, dibulatkan ke atas ke kelipatan Rp 10.000 |
| `suggested_percent` | `suggested_budget` sebagai persen dari `income_pool`; **`null`** bila cycle ini belum ada pemasukan |
| `overspent_cycles` | berapa kali (dari 3 cycle) kategori ini melebihi budget-nya |
| `limited` | `true` = saran **ditahan**, tidak dinaikkan (lihat di bawah) |

### Cara saran dihitung (untuk teks penjelasan di UI)

1. **`basis = "percentage"`** (default): rata-rata porsi pengeluaran
   kategori terhadap pemasukan, dikalikan pemasukan cycle ini. Dipakai bila
   cycle ini sudah ada pemasukan dan ada minimal satu cycle sebelumnya yang
   punya pemasukan.
2. **`basis = "nominal"`**: dipakai bila cycle ini belum ada pemasukan (mis.
   gaji belum masuk). Sarannya rata-rata nominal pengeluaran per cycle.
   Beri keterangan seperti "Gaji cycle ini belum masuk, saran memakai
   rata-rata nominal".
3. **Pengeluaran yang melebihi budget tidak menaikkan saran.** Untuk tiap
   cycle lama, belanja dihitung maksimal sebesar budget cycle itu.
4. **Budget yang pernah jebol tidak dinaikkan.** Jika kategori pernah
   melebihi budget (`overspent_cycles > 0`), sudah punya `current_budget`,
   dan saran lebih tinggi darinya, saran ditahan di `current_budget` dan
   `limited = true`. Tampilkan penanda, mis. **"Melebihi budget di
   {overspent_cycles} cycle, tidak dinaikkan"**, supaya user paham kenapa
   angkanya tidak naik.
5. Hanya kategori yang punya pengeluaran dalam 3 cycle terakhir yang muncul
   di `items`. Kategori tanpa riwayat tidak diberi saran.

Item dengan `suggested_budget == current_budget` (mis. `limited = true`)
tetap dikirim; boleh ditampilkan redup atau tidak dicentang secara default
karena menerapkannya tidak mengubah apa-apa.

---

## `POST /budgets/recommendations`

Menerapkan saran untuk kategori yang dipilih user. **Hanya kirim id
kategori, bukan nominal**: server menghitung ulang saran saat itu juga di
dalam satu transaksi database, jadi nominal dari client tidak pernah
dipakai (field `amount`, bila dikirim, diabaikan).

```json
{ "month": 10, "year": 2026, "category_ids": [4, 16] }
```

| Field | Wajib | Aturan |
|---|---|---|
| `month` | ya | 1–12 |
| `year` | ya | 2000–2100 |
| `category_ids` | ya | array, minimal 1 id, tiap id harus kategori yang ada |

**Respons `200`:**
```json
{ "data": { "saved": 2 } }
```

- `saved` = jumlah budget yang benar-benar disimpan. Budget yang sudah ada
  untuk kategori itu **ditimpa** dengan nominal saran.
- `category_ids` yang **tidak punya saran** (bukan kategori pengeluaran,
  atau tidak ada riwayat) **diabaikan tanpa error**. Maka `saved` bisa lebih
  kecil dari jumlah id yang dikirim, bahkan `0`. Bandingkan `saved` dengan
  jumlah yang dipilih dan beri tahu user bila berbeda.
- Setelah berhasil, muat ulang `GET /budgets?month=&year=` (budget biasa)
  atau perbarui state lokal dari `items` yang diterapkan.
- Saran dihitung ulang saat POST, jadi bisa sedikit beda dari yang tampil
  bila ada transaksi baru di antara GET dan POST. Itu normal.

Untuk mengubah satu budget ke angka bebas (bukan saran), pakai
`POST /budgets` yang sudah ada.

---

## Error

| HTTP | Kapan |
|---|---|
| 401 | Token tidak ada / kedaluwarsa |
| 403 | User tidak punya permission `budgets` |
| 422 | `month`/`year` kosong atau di luar rentang; `category_ids` kosong / bukan array / berisi id yang tidak ada |

Format 422 mengikuti standar Laravel:
```json
{ "message": "The category ids field is required.", "errors": { "category_ids": ["The category ids field is required."] } }
```

---

## Saran alur layar

1. Di layar Budget, tombol **"Rekomendasi"** → `GET .../recommendations`
   untuk cycle yang sedang dibuka.
2. Tampilkan daftar `items` dengan checkbox (nama kategori, `current_budget`
   → `suggested_budget`, penanda `limited`). Jelaskan `basis` di bagian atas.
3. Tombol **"Terapkan"** mengirim `category_ids` yang dicentang.
4. Tampilkan hasil dari `saved`, lalu refresh daftar budget.
