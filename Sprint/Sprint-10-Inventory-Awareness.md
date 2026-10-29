# Flutter POS Sprint 10

# Inventory Awareness

## Status

Completed

# Tujuan Sprint

Membangun fitur **Inventory Awareness** pada aplikasi POS agar kasir mengetahui kondisi stok secara real-time sebelum dan selama proses transaksi.

Sprint ini **bukan modul Inventory Management**. Seluruh logika stok tetap berada di backend.

Frontend hanya menampilkan informasi yang membantu kasir mengambil keputusan lebih cepat.

Sprint ini membuat:

- Stock Indicator
- Low Stock Warning
- Out of Stock Warning
- Market Check Status
- Stock Information pada Menu
- Inventory Alert

Tidak termasuk:

- Menambah stok
- Mengurangi stok
- Purchasing
- Inventory Adjustment
- Waste Management

---

# 1. Business Flow

Flow normal:

```text
Dashboard

↓

Table

↓

Order

↓

Pilih Menu

↓

Backend Mengirim Informasi Stok

↓

Kasir Melihat Status

↓

Tambah Item

↓

Submit Kitchen
```

---

# 2. Business Case

## Case 1 - Stock Aman

```text
Ikan Etong

Stock Available

↓

Kasir dapat menjual
```

---

## Case 2 - Low Stock

```text
Ikan Etong

Sisa sedikit

↓

Kasir tetap dapat menjual

↓

Muncul Warning
```

---

## Case 3 - Internal Stock Habis

Business flow restoran seafood:

```text
Internal Stock

↓

0 kg

↓

Kitchen Cek Pasar

↓

Masih tersedia

↓

Kasir tetap boleh menerima pesanan
```

Kasir **tidak langsung menolak pesanan**.

---

## Case 4 - Tidak Ada di Pasar

```text
Internal Stock

↓

Habis

↓

Pasar juga kosong

↓

Kitchen membuat Adjustment

↓

Kasir konfirmasi customer
```

Flow ini terhubung dengan Sprint 08.

---

# 3. Backend Endpoint

Menggunakan endpoint Catalog.

Contoh:

```http
GET /api/v1/catalog/menus
```

Response diharapkan memuat informasi:

```json
{
    "stock_status": "available",
    "stock_quantity": 12.5,
    "need_market_check": false
}
```

Apabila endpoint saat ini belum mengirim data tersebut, backend perlu menambah field tanpa mengubah alur API yang sudah ada.

---

# 4. Scope Sprint

```text
features/inventory/

├── bindings/
│   └── inventory_binding.dart
│
├── controllers/
│   └── inventory_controller.dart
│
├── repositories/
│   └── inventory_repository.dart
│
├── models/
│   ├── stock_info_model.dart
│   └── stock_status.dart
│
├── views/
│   └── stock_information_page.dart
│
└── widgets/
    ├── stock_badge.dart
    ├── stock_indicator.dart
    ├── stock_warning_card.dart
    ├── market_check_badge.dart
    └── stock_information_tile.dart
```

---

# 5. Stock Status

Frontend hanya mengenal status berikut:

```text
Available

Low Stock

Out of Stock

Need Market Check
```

Status berasal dari backend.

Frontend tidak menentukan sendiri status stok.

---

# 6. Menu Card Enhancement

Setiap Menu Card menampilkan:

```text
Nama Menu

Harga

Stock Badge
```

Contoh:

```text
Ikan Etong

Rp120.000

🟢 Available
```

atau

```text
🟡 Low Stock
```

atau

```text
🔴 Out of Stock
```

atau

```text
🔵 Need Market Check
```

---

# 7. Stock Warning

Jika memilih menu dengan status:

```text
Low Stock
```

Tampilkan informasi:

```text
Stok hampir habis.

Pastikan kitchen masih memiliki bahan yang cukup.
```

Kasir tetap dapat melanjutkan transaksi.

---

# 8. Need Market Check

Status khusus restoran seafood.

Jika backend mengirim:

```text
Need Market Check
```

Kasir melihat badge:

```text
Perlu Cek Pasar
```

Order tetap dapat dibuat.

Keputusan akhir berada di kitchen.

---

# 9. Out of Stock

Jika backend menyatakan:

```text
Out of Stock
```

Frontend:

- Menonaktifkan tombol tambah menu.
- Menampilkan informasi:

```text
Menu tidak tersedia.
```

Kasir tidak dapat menambahkan item tersebut.

---

# 10. Controller

File:

```text
inventory_controller.dart
```

Method:

```dart
loadInventoryInfo()

refreshInventory()

getStockStatus()

showStockWarning()
```

State:

```dart
isLoading

stockInfo

selectedMenu

stockStatus
```

---

# 11. Repository

Method:

```dart
getMenuInventory()

refreshInventory()
```

Repository hanya mengambil data dari backend.

---

# 12. UI

## Stock Badge

Contoh:

```text
🟢 Available

🟡 Low Stock

🔴 Out of Stock

🔵 Need Market Check
```

---

## Warning Card

Contoh:

```text
Stok hampir habis.

Silakan konfirmasi dengan kitchen jika diperlukan.
```

---

## Market Check Badge

Contoh:

```text
Perlu Cek Pasar
```

Badge ini hanya sebagai informasi.

---

# 13. Refresh Inventory

Inventory diperbarui ketika:

```text
Halaman dibuka

↓

Pull to Refresh

↓

Order selesai dibuat

↓

Aplikasi kembali ke halaman menu
```

Tidak perlu polling otomatis pada MVP.

---

# 14. Error Handling

## API

```text
Informasi stok tidak tersedia.
```

---

## Network

```text
Tidak dapat mengambil informasi stok.
```

---

## Empty Data

```text
Belum ada informasi stok.
```

---

# 15. Task Checklist

## Model

- [x] Create StockInfoModel
- [x] Create StockStatus Enum

## Repository

- [x] Get Inventory Information
- [x] Refresh Inventory

## Controller

- [x] Load Stock Information
- [x] Refresh Inventory
- [x] Handle Stock Warning

## UI

- [x] Stock Badge
- [x] Warning Card
- [x] Market Check Badge
- [x] Stock Information Tile

## Integration

- [x] Load Stock Status dari API
- [x] Tampilkan Badge pada Menu
- [x] Disable Add Item jika Out of Stock

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Informasi stok tampil pada setiap menu

✅ Badge status stok tampil sesuai data backend

✅ Warning muncul ketika stok menipis

✅ Status "Perlu Cek Pasar" dapat ditampilkan

✅ Menu yang benar-benar habis tidak dapat dipilih

✅ Inventory dapat di-refresh

✅ Frontend tidak melakukan perhitungan stok sendiri

---

# Output Sprint

Hasil akhir Sprint 10:

```text
Dashboard

↓

Table

↓

Order

↓

Menu

├── 🟢 Available
├── 🟡 Low Stock
├── 🔵 Need Market Check
└── 🔴 Out of Stock

↓

Kasir membuat keputusan berdasarkan informasi stok

↓

Submit Kitchen
```

---

# Sprint Berikutnya

## Flutter POS Sprint 11 — Reporting Dashboard

Fitur yang akan dibuat:

- Dashboard kasir
- Ringkasan penjualan hari ini
- Jumlah transaksi
- Total pendapatan
- Metode pembayaran (Cash vs Transfer)
- Menu terlaris
- Ringkasan order berdasarkan status
- Statistik operasional sederhana

Sprint ini berfokus pada **visualisasi data operasional** yang berasal dari backend. Seluruh proses perhitungan tetap dilakukan di Laravel sehingga frontend hanya bertugas menampilkan data secara informatif.
:::writing