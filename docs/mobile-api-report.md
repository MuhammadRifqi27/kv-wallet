# API Laporan (Reports) — Panduan untuk Mobile Dev

Dokumen ini khusus endpoint **Laporan** di menu Summary. Untuk hal umum
(login, token, error validasi) lihat
[mobile-api-reference.md](mobile-api-reference.md). Koleksi Postman ada di
folder **Reports** pada `postman/money-management-api.postman_collection.json`.

Semua laporan dihitung **di server**, jadi layar laporan cukup memanggil API
lalu menggambar chart/daftar. Tidak ada yang perlu dihitung ulang di Flutter.

---

## 1. Dasar

- **Base URL**: `{{base_url}}/api/v1/money-management/reports`
- **Auth**: `Authorization: Bearer {token}` + `Accept: application/json`
- **Permission**: `money-management.summary` (sama dengan menu Summary).
  Tanpa itu respons `403`. Cek `money_management_permissions` dari
  `/auth/me`: kalau tidak ada `summary`, sembunyikan menu Laporan.
- **Online-only**: laporan tidak masuk antrean sync offline. Boleh cache
  respons terakhir untuk tampilan read-only dengan label "terakhir
  diperbarui".
- Semua endpoint **GET** kecuali `POST /tax-categories`.
- Semua respons dibungkus `{ "data": { ... } }`.

### Format data

| Hal | Aturan |
|---|---|
| Nominal | angka rupiah (number, bukan string). Boleh bernilai negatif (mis. selisih) |
| Persentase | angka biasa, **bukan** pecahan: `91.52` berarti 91,52%. Dibulatkan 2 desimal |
| Tanggal | string `YYYY-MM-DD` |
| Nilai kosong | `null` (lihat catatan per endpoint) |

### Periode = cycle gaji, bukan bulan kalender

Laporan per **cycle gaji** user (hari gajian diatur user di pengaturan,
sama seperti dashboard dan budget). `month` + `year` menyebut cycle-nya,
tanggal pastinya ada di `start` dan `end` pada respons. Contoh: jika gajian
tanggal 30, cycle `month=10&year=2026` berjalan **2026-09-30 s/d 2026-10-30**.

Jadi **tampilkan rentang tanggal dari `start`–`end`**, jangan menebak dari
nama bulan.

### Parameter umum

| Param | Tipe | Default | Keterangan |
|---|---|---|---|
| `month` | 1–12 | bulan sekarang | cycle yang dilihat |
| `year` | 2000–2100 | tahun sekarang | |
| `cycles` | `3`, `6`, atau `12` | beda per endpoint | jumlah cycle ke belakang |
| `compare_month`, `compare_year` | | cycle sebelum `month/year` | hanya endpoint `compare` |
| `category_id` | id kategori | kategori pengeluaran terbesar | hanya endpoint `category` |

Parameter salah memberi `422` format validasi Laravel biasa
(`{ "message": ..., "errors": { "cycles": [...] } }`).

---

## 2. Ringkasan endpoint

| Endpoint | Untuk layar | Param yang dipakai |
|---|---|---|
| `GET /cash-flow` | Arus kas harian + saldo | `month`, `year` |
| `GET /savings-rate` | Rasio menabung & tren | `month`, `year`, `cycles` (default **12**) |
| `GET /compare` | Bandingkan dua cycle | `month`, `year`, `compare_month`, `compare_year` |
| `GET /category` | Detail satu kategori | `month`, `year`, `category_id`, `cycles` (default **6**) |
| `GET /unexpected-expenses` | Pengeluaran tak terduga | `month`, `year` |
| `GET /year-in-review` | Laporan tahunan | `year` |
| `GET /tax` | Rekap pajak | `year` |
| `POST /tax-categories` | Simpan kategori pengurang pajak | body `year`, `category_ids` |

Export Excel/PDF **belum tersedia di API** (hanya web).

---

## 3. Detail endpoint

### `GET /cash-flow`

Saldo awal, pergerakan per hari dengan saldo berjalan, saldo akhir.

```
GET /cash-flow?month=10&year=2026
```
```json
{
  "data": {
    "month": 10,
    "year": 2026,
    "start": "2026-09-30",
    "end": "2026-10-30",
    "opening_balance": 17830161,
    "closing_balance": 21379952,
    "total_income": 4189363,
    "total_expense": 355386,
    "net": 3833977,
    "other_movements": -284186,
    "rows": [
      { "date": "2026-09-30", "income": 4189363, "expense": 26000, "net": 4163363, "balance": 21993524 },
      { "date": "2026-10-01", "income": 0, "expense": 13000, "net": -13000, "balance": 21980524 }
    ]
  }
}
```

- `rows` hanya berisi hari yang ada transaksinya. Untuk chart garis, hubungkan
  titik `balance` per `date`.
- `other_movements` = selisih saldo yang **bukan** pemasukan/pengeluaran
  (mis. perubahan nilai investasi). Matematikanya:
  `opening_balance + net + other_movements = closing_balance`. Tampilkan
  sebagai baris "Penyesuaian lain" bila `≠ 0`, jangan disembunyikan, supaya
  angka tetap nyambung.

---

### `GET /savings-rate`

Rasio menabung = `(pemasukan − pengeluaran) / pemasukan × 100`.

```
GET /savings-rate?month=10&year=2026&cycles=12
```
```json
{
  "data": {
    "month": 10,
    "year": 2026,
    "target": 20,
    "series": [
      { "label": "Nov 2025", "income": 0, "expense": 0, "saved": 0, "rate": 0 },
      { "label": "Oct 2026", "income": 4189363, "expense": 355386, "saved": 3833977, "rate": 91.52 }
    ],
    "current_rate": 91.52,
    "previous_rate": 8.21,
    "rate_change": 83.31,
    "average_rate": 24.45,
    "best":  { "label": "Oct 2026", "income": 4189363, "expense": 355386, "saved": 3833977, "rate": 91.52 },
    "worst": { "label": "Feb 2026", "income": 5162832, "expense": 7805965, "saved": -2643133, "rate": -51.2 },
    "months_on_target": 5,
    "months_counted": 9
  }
}
```

- `series` berurutan dari yang terlama; panjangnya = `cycles`. Gambar
  sebagai chart garis/batang dengan **garis target di `target`** (20).
- `rate` cycle tanpa pemasukan bernilai `0`; cycle seperti itu **tidak
  dihitung** di `months_counted`, `average_rate`, `best`, `worst`.
- `previous_rate`, `rate_change`, `best`, `worst` bisa `null` (data belum
  cukup) — tangani sebelum menampilkan.
- `rate_change` adalah selisih poin persentase (`83.31` = naik 83,31 poin),
  bukan persen kenaikan.
- `months_on_target` = jumlah cycle dengan `rate ≥ target`.

---

### `GET /compare`

Dua cycle berdampingan. `a` = cycle pembanding, `b` = cycle utama
(`month/year`). Default `a` = cycle sebelumnya.

```
GET /compare?month=10&year=2026
GET /compare?month=10&year=2026&compare_month=3&compare_year=2026
```
```json
{
  "data": {
    "a": { "month": 9, "year": 2026, "start": "2026-08-31", "end": "2026-09-29" },
    "b": { "month": 10, "year": 2026, "start": "2026-09-30", "end": "2026-10-30" },
    "metrics": {
      "income":       { "a": 4764363, "b": 4189363, "diff": -575000,  "diff_pct": -12.07 },
      "expense":      { "a": 4373395, "b": 355386,  "diff": -4018009, "diff_pct": -91.87 },
      "net":          { "a": 390968,  "b": 3833977, "diff": 3443009,  "diff_pct": 880.64 },
      "savings_rate": { "a": 8.21,    "b": 91.52,   "diff": 83.31,    "diff_pct": 1015.23 }
    },
    "categories": [
      { "name": "Shop", "a": 1886345, "b": 0,      "diff": -1886345, "diff_pct": -100 },
      { "name": "Food", "a": 895750,  "b": 189600, "diff": -706150,  "diff_pct": -78.83 }
    ]
  }
}
```

- `diff = b − a`; `diff_pct` = perubahan relatif terhadap `a`. **`diff_pct`
  bisa `null`** (di `metrics` maupun `categories`) bila nilai `a` = 0 (tidak
  ada pembanding), tampilkan "-" atau "baru", jangan dianggap 0%.
- `categories` adalah **kategori pengeluaran** dari kedua cycle, diurutkan
  dari yang nilainya paling besar (yang terbesar antara `a` dan `b`).
- Warna: untuk `income` dan `net`, naik = baik (hijau). Untuk `expense`,
  naik = buruk (merah). Server tidak mengirim warna.

---

### `GET /category`

Satu kategori selama beberapa cycle. Tanpa `category_id`, server memilih
kategori **pengeluaran terbesar** pada cycle itu.

```
GET /category?month=10&year=2026&cycles=6
GET /category?month=10&year=2026&category_id=2&cycles=12
```
```json
{
  "data": {
    "category": { "id": 2, "name": "Food", "type": "expense" },
    "options": [
      { "id": 21, "name": "Asuransi", "type": "expense" },
      { "id": 2,  "name": "Food",     "type": "expense" }
    ],
    "month": 10,
    "year": 2026,
    "cycles": 6,
    "start": "2026-09-30",
    "end": "2026-10-30",
    "series": [
      { "label": "May 2026", "total": 747000, "count": 26 },
      { "label": "Oct 2026", "total": 189600, "count": 5 }
    ],
    "current_total": 189600,
    "current_count": 5,
    "previous_total": 895750,
    "change_pct": -78.83,
    "average": 692075,
    "share_pct": 53.35,
    "top_transactions": [
      { "date": "2026-10-02", "description": "Pizza Gofood", "account": "GOPAY", "amount": 143600 }
    ],
    "frequent": [
      { "description": "Bigm", "count": 37, "total": 518500 }
    ],
    "transactions": [
      { "date": "2026-10-02", "description": "Makan siang", "account": "Bank Mandiri", "amount": 16000 }
    ]
  }
}
```

- `options` = isi dropdown pilihan kategori (sudah terurut nama). Pakai
  `id`-nya untuk `category_id`. **Simpan satu kali**; isinya sama di setiap
  respons.
- `cycles` hanya boleh `3`, `6`, `12`.
- `change_pct` = `current_total` dibanding `previous_total`; `average` =
  rata-rata total per cycle pada `series`; `share_pct` = porsi kategori ini
  dari total pengeluaran (atau pemasukan) cycle ini.
- `top_transactions` = 5 transaksi terbesar; `frequent` = deskripsi yang
  paling sering muncul; `transactions` = semua transaksi di cycle ini.
- Kalau tidak ada kategori sama sekali, `category` bernilai `null` dan
  respons hanya berisi `options`, `month`, `year`, `cycles` (tanpa
  `series`, `current_total`, dst.). Tangani sebagai "belum ada data".
- Kalau kategori ada tapi belum ada transaksi, angka-angkanya `0` dan
  daftarnya kosong.

---

### `GET /unexpected-expenses`

Pengeluaran yang lebih dari **2×** rata-rata transaksi kategori itu selama 6
cycle sebelumnya. Kategori dengan kurang dari 3 transaksi pembanding tidak
dianalisis.

```
GET /unexpected-expenses?month=10&year=2026
```
```json
{
  "data": {
    "month": 10,
    "year": 2026,
    "start": "2026-09-30",
    "end": "2026-10-30",
    "baseline_cycles": 6,
    "factor": 2,
    "min_samples": 3,
    "categories_analyzed": 10,
    "items": [
      {
        "date": "2026-10-02",
        "category": "Food",
        "description": "Pizza Gofood",
        "amount": 143600,
        "category_average": 32540.63,
        "ratio": 4.41
      }
    ],
    "total_flagged": 252952
  }
}
```

- `ratio` = `amount / category_average` (`4.41` = 4,41× lipat, bukan persen).
- `items` kosong = tidak ada yang mencurigakan; tampilkan pesan positif.
- Tampilkan `factor`, `baseline_cycles`, `min_samples` sebagai keterangan
  "bagaimana ini dihitung" bila perlu.

---

### `GET /year-in-review`

Satu tahun (12 cycle, satu per bulan kalender) plus sorotan.

```
GET /year-in-review?year=2026
```
```json
{
  "data": {
    "year": 2026,
    "start": "2025-12-31",
    "end": "2026-12-30",
    "months": [
      { "label": "Jan", "income": 0, "expense": 33000, "net": -33000, "rate": 0 },
      { "label": "Feb", "income": 5162832, "expense": 7805965, "net": -2643133, "rate": -51.2 }
    ],
    "total_income": 47908763,
    "total_expense": 35365658,
    "net": 12543105,
    "savings_rate": 26.18,
    "average_monthly_expense": 3536565.8,
    "budget": {
      "has_data": true,
      "months": [
        { "label": "Feb", "budget": 2100000, "spent": 5640965, "remaining": -3540965,
          "used_pct": 268.62, "categories": 5, "over_count": 3 }
      ],
      "total_budget": 5750000,
      "total_spent": 10021460,
      "months_over": 2,
      "months_with_budget": 3,
      "over_items": [
        { "month": "Feb", "month_number": 2, "category": "Shop", "budget": 500000,
          "spent": 3647865, "over": 3147865, "over_pct": 629.57 }
      ],
      "over_categories": [
        { "name": "Food", "times": 2, "total_over": 554750 }
      ]
    },
    "top_expenses": [ { "name": "Shop", "total": 12885793 } ],
    "top_income":   [ { "name": "Sallary", "total": 43706847 } ],
    "best_month":  { "label": "Mar", "income": 8499738, "expense": 3767004, "net": 4732734, "rate": 55.68 },
    "worst_month": { "label": "Feb", "income": 5162832, "expense": 7805965, "net": -2643133, "rate": -51.2 },
    "biggest_expense": { "date": "2026-02-24", "category": "Shop", "description": "Kado Ayah", "amount": 2999000 }
  }
}
```

- `months` dan `budget.months` selalu **12 item** (Jan–Des); bulan tanpa
  data bernilai `0`.
- `budget.has_data = false` berarti user tidak pernah mengisi budget tahun
  itu: sembunyikan seluruh bagian budget. Bila `true`, bulan dengan
  `categories = 0` berarti tidak ada budget di bulan itu (jangan tampilkan
  sebagai "0% terpakai").
- `over_items` diurutkan dari kelebihan terbesar, `over_categories` dari
  kategori yang paling sering melebihi budget.
- `best_month`, `worst_month`, `biggest_expense` bisa `null` bila belum ada
  data.
- `top_expenses` (maks 5 kategori) dan `top_income` (maks 3 kategori)
  sudah terurut dari terbesar. `over_categories` maks 5.

---

### `GET /tax`

**Rekap**, bukan perhitungan pajak: total pemasukan setahun dan pengeluaran
yang ditandai user sebagai pengurang pajak. Tampilkan disclaimer itu di UI.

```
GET /tax?year=2026
```
```json
{
  "data": {
    "year": 2026,
    "start": "2025-12-31",
    "end": "2026-12-30",
    "total_income": 47908763,
    "categories": [
      { "id": 21, "name": "Asuransi", "spent": 0, "deductible": false },
      { "id": 24, "name": "Biaya Administrasi Bank", "spent": 13000, "deductible": false }
    ],
    "deductible_categories": [],
    "total_deductible": 0,
    "income_after_deductions": 47908763
  }
}
```

- `categories` = semua kategori pengeluaran beserta total belanja setahun
  dan status `deductible` (untuk daftar checklist).
- `deductible_categories` = kategori yang ditandai **dan** punya belanja
  (`spent > 0`), terurut dari terbesar. Untuk status centang, pakai
  `deductible` di `categories`, bukan daftar ini.
- `income_after_deductions = total_income − total_deductible`.

### `POST /tax-categories`

Simpan kategori mana yang ditandai pengurang pajak. **Menimpa** seluruh
pilihan sebelumnya (kirim daftar lengkap, bukan perubahan saja).

```json
{ "year": 2026, "category_ids": [21, 24] }
```
Kirim `category_ids: []` untuk mengosongkan. `year` wajib dan dipakai untuk
menghitung ulang rekapnya.

**Respons `200`**: sama persis dengan `GET /tax?year=...` setelah disimpan,
jadi layar bisa langsung memakai hasilnya tanpa request kedua.

Pilihan ini berlaku per user (bukan per tahun): menandai kategori di tahun
2026 juga berlaku saat melihat tahun lain.

---

## 4. Error

| HTTP | Kapan |
|---|---|
| 401 | Token tidak ada / kedaluwarsa |
| 403 | User tidak punya permission `summary` |
| 422 | Param tidak valid (`cycles` bukan 3/6/12, `category_id` tidak ada, `year` kosong di `POST /tax-categories`, dst.) |

---

## 5. Saran implementasi di Flutter

- Satu layar Laporan dengan tab/segmen: **Arus Kas · Savings · Bandingkan ·
  Kategori · Tak Terduga · Tahunan · Pajak**. Muat data tab **saat dibuka**
  (lazy), bukan semuanya sekaligus.
- Selector periode memakai `month`/`year`; tampilkan label dari `start` dan
  `end` pada respons.
- Pakai `data` apa adanya. Jangan hitung ulang persentase di client supaya
  angka sama dengan versi web.
- Setelah `POST /tax-categories`, ganti state tab Pajak dengan respons
  POST-nya.
