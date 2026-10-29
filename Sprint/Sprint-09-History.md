# Flutter POS Sprint 09

# Order History

## Status

Planning

# Tujuan Sprint

Membangun modul **Order History** agar kasir dapat melihat kembali transaksi yang telah berlangsung.

Fitur ini digunakan untuk:

- Mencari transaksi lama
- Melihat detail transaksi
- Melihat riwayat pembayaran
- Melihat riwayat perubahan (Adjustment)
- Melakukan reprint struk

Sprint ini **bersifat read-only**. Kasir tidak dapat mengubah transaksi yang telah selesai.

Tidak termasuk:

- Edit transaksi
- Refund
- Void Order
- Laporan penjualan

---

# 1. Business Flow

Flow pencarian transaksi:

```text
Dashboard

↓

Order History

↓

Cari Order

↓

Pilih Order

↓

Detail Order

↓

Lihat History

↓

Reprint Struk (Opsional)
```

---

# 2. Backend Endpoint

Menggunakan endpoint backend yang sudah tersedia atau akan ditambahkan.

## Daftar Order

```http
GET /api/v1/orders
```

Parameter:

```text
status

date

search

page
```

---

## Detail Order

```http
GET /api/v1/orders/{id}
```

---

## Payment History

```http
GET /api/v1/orders/{id}/payments
```

---

## Order Adjustment

```http
GET /api/v1/orders/{id}/adjustments
```

---

# 3. Scope Sprint

```text
features/history/

├── bindings/
│   └── history_binding.dart
│
├── controllers/
│   └── history_controller.dart
│
├── models/
│   ├── history_order_model.dart
│   ├── history_filter.dart
│   └── history_summary.dart
│
├── repositories/
│   └── history_repository.dart
│
├── views/
│   ├── history_page.dart
│   ├── history_detail_page.dart
│   └── history_filter_sheet.dart
│
└── widgets/
    ├── order_history_card.dart
    ├── payment_history_card.dart
    ├── adjustment_history_card.dart
    ├── history_status_badge.dart
    ├── date_filter.dart
    └── search_box.dart
```

---

# 4. History List

Menampilkan daftar transaksi.

Informasi:

```text
Order Number

Customer

Table

Grand Total

Status

Tanggal
```

Contoh:

```text
ORD-20261029-001

Budi

Meja 05

Rp650.000

Completed
```

---

# 5. Search

Kasir dapat mencari berdasarkan:

```text
Order Number

Customer Name
```

Search menggunakan backend agar tetap cepat meskipun data transaksi bertambah banyak.

---

# 6. Filter

Filter yang tersedia:

## Status

```text
Semua

Draft

Preparing

Ready

Completed

Cancelled
```

---

## Tanggal

```text
Hari Ini

Kemarin

7 Hari

30 Hari

Custom Range
```

---

# 7. Order Detail

Menampilkan:

```text
Customer

Table

Guest Count

Status

Order Time

Completed Time

Order Items

Grand Total
```

---

# 8. Payment History

Menampilkan seluruh pembayaran.

Contoh:

```text
Cash

Rp300.000

-------------------

Transfer

Rp200.000
```

Jika menggunakan Split Payment:

```text
Payment 1

Cash

Rp200.000

----------------

Payment 2

Transfer

Rp300.000
```

---

# 9. Adjustment History

Jika order pernah mengalami perubahan.

Contoh:

```text
13:00

Ikan Etong

0.7 kg

↓

1 kg

Approved
```

Atau:

```text
Ikan Etong

↓

Cumi Crispy
```

History hanya ditampilkan.

Tidak dapat diedit.

---

# 10. Reprint Receipt

Kasir dapat membuka preview struk.

Flow:

```text
History

↓

Detail Order

↓

Preview Receipt

↓

Print
```

Implementasi printer dilakukan pada sprint berikutnya atau tahap integrasi perangkat.

---

# 11. Controller

File:

```text
history_controller.dart
```

Method:

```dart
loadHistory()

searchOrder()

filterOrder()

loadDetail()

loadPaymentHistory()

loadAdjustmentHistory()
```

State:

```dart
isLoading

orders

selectedOrder

payments

adjustments

filter

searchText
```

---

# 12. Repository

Method:

```dart
getHistory()

getOrder()

getPayments()

getAdjustments()
```

Repository hanya melakukan komunikasi dengan backend.

---

# 13. UI

## History Page

Komponen:

```text
Search

↓

Filter

↓

Order List
```

---

## Detail Page

Komponen:

```text
Order Information

↓

Order Items

↓

Payment History

↓

Adjustment History

↓

Receipt Preview Button
```

---

## Order Card

Menampilkan:

```text
Order Number

Customer

Status

Total

Date
```

---

# 14. Error Handling

## API Error

```text
Order tidak ditemukan.
```

---

## Empty Data

```text
Belum ada transaksi.
```

---

## Network Error

```text
Tidak dapat terhubung ke server.
```

---

# 15. Task Checklist

## Model

- [ ] Create HistoryOrderModel
- [ ] Create HistoryFilter
- [ ] Create HistorySummary

## Repository

- [ ] Get Order History
- [ ] Get Order Detail
- [ ] Get Payment History
- [ ] Get Adjustment History

## Controller

- [ ] Load History
- [ ] Search Order
- [ ] Filter History
- [ ] Load Detail

## UI

- [ ] History Page
- [ ] Detail Page
- [ ] Search Box
- [ ] Filter Bottom Sheet
- [ ] Order Card
- [ ] Payment History Widget
- [ ] Adjustment History Widget

## Integration

- [ ] History API
- [ ] Detail API
- [ ] Payment History API
- [ ] Adjustment History API

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Daftar transaksi berhasil dimuat

✅ Pencarian transaksi berfungsi

✅ Filter status berfungsi

✅ Filter tanggal berfungsi

✅ Detail transaksi dapat dibuka

✅ Riwayat pembayaran tampil

✅ Riwayat adjustment tampil

✅ Preview struk dapat dibuka

✅ Tidak ada perubahan data transaksi dari halaman history

---

# Output Sprint

Hasil akhir Sprint 09:

```text
Dashboard

↓

Order History

↓

Cari / Filter

↓

Pilih Order

↓

Detail Order

├── Informasi Order
├── Daftar Item
├── Payment History
├── Adjustment History
└── Preview Struk
```

---

# Sprint Berikutnya

## Flutter POS Sprint 10 — Inventory Awareness

Fitur yang akan dibuat:

- Informasi stok pada menu
- Indikator stok menipis
- Indikator stok habis
- Status "Perlu Cek Pasar"
- Sinkronisasi informasi stok dari backend
- Peringatan kepada kasir sebelum item dikirim ke kitchen

Sprint ini **tidak mengelola stok**. Seluruh logika inventory tetap berada di backend. Frontend hanya menampilkan informasi yang membantu kasir mengambil keputusan lebih cepat sesuai alur operasional restoran seafood.