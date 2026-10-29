# Flutter POS Sprint 08

# Order Adjustment

## Status

Planning

# Tujuan Sprint

Membangun fitur penyesuaian pesanan (**Order Adjustment**) ketika kondisi di lapangan berbeda dengan pesanan customer.

Sprint ini mengimplementasikan business flow yang sudah dirancang pada backend, yaitu ketika stok internal habis, ukuran bahan tidak tersedia, atau customer ingin mengganti pesanan setelah order dikirim ke dapur.

Fitur ini memastikan perubahan pesanan tetap terdokumentasi dan membutuhkan persetujuan customer.

Sprint ini membuat:

- Adjustment Request
- Quantity Adjustment
- Replace Item
- Cancel Item
- Customer Approval
- Adjustment History

Tidak termasuk:

- Inventory Purchasing
- Waste Management
- Refund

---

# 1. Business Flow

## Case 1 - Ukuran Tidak Tersedia

Customer memesan:

```text
Ikan Etong 0.7 kg
```

Kitchen hanya menemukan:

```text
Ikan Etong 1 kg
```

Flow:

```text
Kitchen

↓

Request Adjustment

↓

Kasir menerima notifikasi

↓

Konfirmasi ke customer

↓

Customer Setuju

↓

Approve

↓

Order diperbarui
```

---

## Case 2 - Stok Internal Habis

Flow:

```text
Kitchen

↓

Stok Internal Habis

↓

Cek Pasar Ikan

↓

Harga Beli Naik

↓

Owner menentukan harga jual baru

↓

Kasir konfirmasi customer

↓

Customer Setuju

↓

Approve
```

---

## Case 3 - Customer Menolak

Flow:

```text
Kitchen

↓

Request Adjustment

↓

Kasir

↓

Customer Menolak

↓

Replace Item

atau

Cancel Item
```

---

# 2. Business Rules

Sesuai backend.

Perubahan hanya dapat dilakukan jika item:

```text
Waiting

Accepted
```

Tidak boleh diubah ketika:

```text
Preparing

Ready

Served

Cancelled
```

---

# 3. Backend Endpoint

## Daftar Adjustment

```http
GET /api/v1/order-item-changes
```

---

## Create Adjustment

```http
POST /api/v1/order-item-changes
```

---

## Approve

```http
PATCH /api/v1/order-item-changes/{id}/approve
```

---

## Reject

```http
PATCH /api/v1/order-item-changes/{id}/reject
```

---

# 4. Scope Sprint

```text
features/order_adjustment/

├── bindings/
│   └── order_adjustment_binding.dart
│
├── controllers/
│   └── order_adjustment_controller.dart
│
├── models/
│   ├── adjustment_model.dart
│   ├── adjustment_type.dart
│   └── adjustment_status.dart
│
├── repositories/
│   └── order_adjustment_repository.dart
│
├── views/
│   ├── adjustment_page.dart
│   ├── adjustment_detail_page.dart
│   └── approval_dialog.dart
│
└── widgets/
    ├── adjustment_card.dart
    ├── adjustment_status_badge.dart
    ├── quantity_compare.dart
    ├── replacement_item.dart
    └── adjustment_history.dart
```

---

# 5. Adjustment Type

Tipe perubahan:

```text
Quantity Change

Replace Item

Cancel Item
```

---

## Quantity Change

Contoh:

```text
0.7 kg

↓

1.0 kg
```

---

## Replace Item

Contoh:

```text
Ikan Etong

↓

Cumi Crispy
```

---

## Cancel Item

Contoh:

```text
Ikan Etong

↓

Cancelled
```

---

# 6. Adjustment Status

Status:

```text
Pending Customer

Approved

Rejected
```

Semua status berasal dari backend.

---

# 7. UI

## Adjustment List

Menampilkan:

```text
Nama Item

Jenis Adjustment

Status

Jam Request
```

---

## Adjustment Detail

Menampilkan:

```text
Item Lama

↓

Item Baru

Alasan

Status
```

---

## Approval Dialog

Contoh:

```text
Kitchen meminta perubahan pesanan.

Ikan Etong

0.7 kg

↓

1 kg

Customer setuju?

[Batal]

[Setujui]
```

---

# 8. Replace Item Flow

Flow:

```text
Adjustment

↓

Customer Menolak

↓

Kasir memilih menu pengganti

↓

Backend membuat item baru

↓

Order diperbarui
```

Kasir tidak mengedit item lama secara manual.

Semua perubahan dilakukan melalui endpoint backend.

---

# 9. Cancel Item Flow

Flow:

```text
Adjustment

↓

Customer Menolak

↓

Cancel Item

↓

Status Cancelled

↓

Total Order berubah
```

---

# 10. Adjustment History

Menampilkan seluruh riwayat perubahan.

Contoh:

```text
13:00

Quantity

0.7 kg

↓

1 kg

Approved
```

---

# 11. Controller

```text
order_adjustment_controller.dart
```

Method:

```dart
loadAdjustment()

approveAdjustment()

rejectAdjustment()

replaceItem()

refreshOrder()
```

State:

```dart
isLoading

adjustments

selectedAdjustment

selectedReplacement

status
```

---

# 12. Repository

Method:

```dart
getAdjustment()

approve()

reject()

replace()

refreshOrder()
```

---

# 13. Error Handling

## API

```text
Adjustment tidak ditemukan.
```

---

## Validation

```text
Item sudah diproses dan tidak dapat diubah.
```

---

## Network

```text
Tidak dapat terhubung ke server.
```

---

# 14. Task Checklist

## Model

- [ ] Create AdjustmentModel
- [ ] Create AdjustmentStatus
- [ ] Create AdjustmentType

## Repository

- [ ] Get Adjustment
- [ ] Approve Adjustment
- [ ] Reject Adjustment
- [ ] Replace Item

## Controller

- [ ] Load Adjustment
- [ ] Approve
- [ ] Reject
- [ ] Replace Item
- [ ] Refresh Order

## UI

- [ ] Adjustment List
- [ ] Detail Adjustment
- [ ] Approval Dialog
- [ ] Replacement Dialog
- [ ] History Widget

## Integration

- [ ] Adjustment API
- [ ] Approve API
- [ ] Reject API
- [ ] Replace API
- [ ] Refresh Order

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Kasir dapat melihat permintaan perubahan dari kitchen

✅ Customer dapat menyetujui perubahan quantity

✅ Customer dapat menolak perubahan

✅ Kasir dapat mengganti menu sesuai keputusan customer

✅ Kasir dapat membatalkan item jika customer tidak ingin mengganti

✅ Riwayat perubahan tampil dengan benar

✅ Total order selalu mengikuti backend setelah adjustment

✅ Tidak ada manipulasi data order secara langsung di frontend

---

# Output Sprint

Hasil akhir Sprint 08:

```text
Kitchen

↓

Request Adjustment

↓

POS menerima permintaan

↓

Kasir konfirmasi ke customer

↓

┌──────────────────────────────┐
│ Customer Setuju              │
│                              │
│ → Approve Adjustment         │
└──────────────────────────────┘

atau

┌──────────────────────────────┐
│ Customer Menolak             │
│                              │
│ → Replace Item               │
│ atau                         │
│ → Cancel Item                │
└──────────────────────────────┘

↓

Order diperbarui

↓

Kitchen melanjutkan proses
```

---

# Sprint Berikutnya

## Flutter POS Sprint 09 — Order History

Fitur yang akan dibuat:

- Daftar riwayat transaksi
- Detail order
- Filter berdasarkan tanggal
- Filter berdasarkan status
- Pencarian nomor order atau nama customer
- Reprint struk
- Ringkasan transaksi
- Melihat histori pembayaran dan adjustment pada setiap order

Sprint ini berfokus pada kebutuhan operasional kasir untuk mencari kembali transaksi yang sudah berlangsung tanpa mengubah data transaksi tersebut.