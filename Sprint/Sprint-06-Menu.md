# Flutter POS Sprint 06

# Submit Order & Kitchen Integration

## Status

Planning

# Tujuan Sprint

Menghubungkan proses Order POS dengan Kitchen Display System (KDS).

Pada sprint ini kasir dapat mengirim pesanan ke dapur. Setelah dikirim, pesanan akan masuk ke antrian kitchen dan status order akan berubah mengikuti proses memasak secara real-time.

Sprint ini membuat:

- Submit Order Batch
- Order Status
- Kitchen Status Monitoring
- Add Item setelah Submit (Batch baru)
- Auto Refresh Status

Tidak termasuk:

- Payment
- Split Payment
- Order Adjustment
- Kitchen Web

---

# 1. Business Flow

```text
Order Draft

↓

Submit Order

↓

Kitchen Queue

↓

Accepted

↓

Preparing

↓

Ready

↓

Served
```

Kasir hanya melakukan **Submit**.

Status berikutnya berasal dari Kitchen.

---

# 2. Backend Endpoint

## Submit Batch

```http
POST /api/v1/order-batches/{batch}/submit
```

---

## Detail Order

```http
GET /api/v1/orders/{id}
```

Digunakan untuk refresh status.

---

## Add Item

```http
POST /api/v1/orders/{order}/items
```

Business Rule:

Jika order sudah pernah dikirim ke kitchen:

```text
Order

Batch 1
Submitted

↓

Tambah Item

↓

Batch 2
Waiting

↓

Submit Lagi

↓

Kitchen menerima Batch 2
```

Kasir tidak mengubah batch lama.

---

# 3. Scope Sprint

Feature:

```text
features/order/

├── bindings/
│
├── controllers/
│
├── repositories/
│
├── views/
│
└── widgets/
    ├── submit_button.dart
    ├── order_status_badge.dart
    ├── batch_card.dart
    ├── kitchen_progress.dart
    └── submit_dialog.dart
```

---

# 4. Submit Order

Flow:

```text
Draft

↓

Klik Submit

↓

Confirmation Dialog

↓

POST Submit Batch

↓

Status berubah

↓

Kitchen Queue
```

Confirmation:

```text
Kirim pesanan ke dapur?

Pesanan yang telah dikirim tidak dapat diubah secara langsung.
Penambahan menu akan dibuat sebagai batch baru.

[Batal]

[Kirim]
```

---

# 5. Order Status

Status yang ditampilkan:

```text
Draft

Submitted

Preparing

Ready

Completed

Cancelled
```

Status mengikuti backend.

Frontend tidak menentukan status.

---

# 6. Order Batch

Kasir dapat melihat batch.

Contoh:

```text
Order

Batch 1

Submitted

2 Item

------------

Batch 2

Waiting

1 Item
```

Batch memudahkan kasir mengetahui item mana yang sudah dikirim.

---

# 7. Kitchen Progress

Setiap batch memiliki progress.

Contoh:

```text
Batch 1

Waiting

Preparing

Ready

Served
```

Atau dalam bentuk badge:

```text
🟡 Waiting

🔵 Preparing

🟢 Ready

✔ Served
```

---

# 8. Add Item Setelah Submit

Business Rule yang digunakan sesuai backend.

Kasir tetap dapat menambah menu.

Flow:

```text
Order

↓

Tambah Menu

↓

Backend

↓

Batch Baru

↓

Submit Batch Baru
```

Batch lama tidak berubah.

---

# 9. Auto Refresh

Halaman Order melakukan refresh status secara berkala.

Contoh:

```text
Load Order

↓

30 detik

↓

Refresh

↓

Update Status
```

Refresh juga dilakukan ketika halaman dibuka kembali.

---

# 10. Controller

File:

```text
order_controller.dart
```

Method baru:

```dart
submitBatch()

refreshOrder()

refreshStatus()

loadBatch()

addNewBatch()
```

State:

```dart
isSubmitting

order

batches

selectedBatch

status
```

---

# 11. Repository

Method baru:

```dart
submitBatch()

getOrder()

getBatch()

refreshOrder()
```

---

# 12. UI

## Submit Button

Muncul ketika:

```text
Batch Waiting
```

Tidak muncul jika:

```text
Semua batch sudah dikirim.
```

---

## Status Badge

Contoh:

```text
Draft

Submitted

Preparing

Ready

Completed
```

---

## Batch Card

Menampilkan:

```text
Batch

Jumlah Item

Status

Jam Submit
```

---

## Kitchen Progress

Timeline sederhana.

Contoh:

```text
Waiting

↓

Preparing

↓

Ready

↓

Served
```

---

# 13. Error Handling

## Submit Gagal

```text
Pesanan gagal dikirim ke dapur.
```

---

## Validation

```text
Tidak ada item yang dapat dikirim.
```

---

## Network

```text
Tidak dapat terhubung ke server.
```

---

# 14. Task Checklist

## Repository

- [ ] Submit Batch
- [ ] Refresh Order
- [ ] Get Batch

## Controller

- [ ] Submit Batch
- [ ] Refresh Status
- [ ] Refresh Order
- [ ] Handle Batch Baru

## UI

- [ ] Submit Button
- [ ] Submit Dialog
- [ ] Order Status Badge
- [ ] Batch Card
- [ ] Kitchen Progress

## Integration

- [ ] Submit API
- [ ] Refresh Order API
- [ ] Batch API

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Batch dapat dikirim ke Kitchen

✅ Status Order mengikuti backend

✅ Batch baru dapat dibuat setelah order pernah dikirim

✅ Progress Kitchen tampil pada POS

✅ Refresh status berjalan dengan baik

✅ Tidak ada manipulasi status di frontend

---

# Output Sprint

Hasil akhir Sprint 06:

```text
Dashboard

↓

Table

↓

Order

↓

Tambah Menu

↓

Submit Batch

↓

Kitchen Queue

↓

Preparing

↓

Ready

↓

Served
```

Kasir kini dapat mengirim pesanan ke dapur dan memantau progresnya tanpa perlu berpindah ke aplikasi Kitchen.

---

# Sprint Berikutnya

## Flutter POS Sprint 07 — Payment & Split Payment

Fitur yang akan dibuat:

- Payment Summary
- Pembayaran Cash
- Pembayaran Transfer
- Split Payment
- Multi Payment
- Payment History
- Receipt Preview
- Cetak Struk
- Menyelesaikan Order (Order Completed)

Sprint 07 akan memanfaatkan seluruh backend **Payment Module** yang sudah Anda selesaikan, termasuk dukungan **split payment**, yang sebelumnya memang menjadi salah satu kebutuhan utama sistem restoran seafood ini.