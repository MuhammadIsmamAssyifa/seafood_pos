# Flutter POS Sprint 04

# Table Management

## Status

Planning

# Tujuan Sprint

Membangun modul manajemen meja sebagai titik awal transaksi pada aplikasi POS.

Kasir dapat melihat seluruh meja, mengetahui status masing-masing meja, memilih meja kosong, atau membuka kembali transaksi yang sedang berlangsung.

Sprint ini membuat:

- Daftar meja
- Status meja
- Detail meja
- Membuat order baru
- Membuka order aktif

Tidak termasuk:

- Menu
- Cart
- Payment
- Kitchen

---

# 1. Business Flow

Flow transaksi:

```text
Dashboard

↓

Daftar Meja

↓

Pilih Meja

↓

Meja Kosong?
      │
 ┌────┴────┐
 │         │
Ya         Tidak
 │         │
 ↓         ↓
Buat      Buka
Order     Order Aktif

↓

Masuk Halaman Order
```

---

# 2. Backend Endpoint

Menggunakan endpoint yang sudah tersedia.

## Daftar Meja

```http
GET /api/v1/tables
```

---

## Detail Meja

```http
GET /api/v1/tables/{id}
```

---

## Membuat Order

```http
POST /api/v1/orders
```

Request

```json
{
    "order_table_id": 1,
    "customer_name": "Budi",
    "guest_count": 4
}
```

Response

```json
{
    "id": 1,
    "status": "draft"
}
```

---

## Detail Order

```http
GET /api/v1/orders/{id}
```

---

# 3. Scope Sprint

Feature:

```text
features/table/

├── bindings/
│   └── table_binding.dart
│
├── controllers/
│   └── table_controller.dart
│
├── models/
│   ├── table_model.dart
│   └── table_status.dart
│
├── repositories/
│   └── table_repository.dart
│
├── views/
│   ├── table_page.dart
│   ├── table_detail_page.dart
│   └── create_order_dialog.dart
│
└── widgets/
    ├── table_card.dart
    ├── table_status_badge.dart
    ├── guest_counter.dart
    └── customer_form.dart
```

---

# 4. Status Meja

Status yang digunakan pada UI:

```text
Available

Occupied

Reserved (opsional)

Cleaning (opsional)
```

Untuk MVP minimal:

```text
Available

Occupied
```

Status mengikuti kondisi order aktif pada backend.

---

# 5. Table Controller

File:

```text
table_controller.dart
```

Tanggung jawab:

- Load daftar meja
- Refresh data meja
- Membuka detail meja
- Membuat order baru

State:

```dart
isLoading

tables

selectedTable

activeOrder
```

---

# 6. Repository Layer

File:

```text
table_repository.dart
```

Method:

```dart
getTables()

getTable()

createOrder()

getOrder()
```

Repository hanya berkomunikasi dengan API Laravel.

---

# 7. UI Screen

## Table Page

Komponen:

```text
Search Bar

↓

Grid Meja

↓

Refresh Button
```

---

## Table Card

Menampilkan:

```text
Nomor Meja

Status

Jumlah Tamu (jika ada)

Customer
```

Contoh:

```text
Meja 05

Occupied

Budi

4 Orang
```

---

## Create Order Dialog

Field:

```text
Nama Customer

Jumlah Tamu
```

Button:

```text
Batal

Buat Order
```

---

# 8. Navigation

Flow:

```text
Dashboard

↓

Table Page

↓

Table Detail

↓

Create Order

↓

Order Page
```

Order Page masih berupa placeholder dan akan dibuat pada Sprint berikutnya.

---

# 9. Validation

Validasi:

```text
Nama Customer wajib diisi

Jumlah tamu minimal 1
```

Jika API gagal:

```text
Gagal membuat order.
```

---

# 10. Error Handling

Handle:

## API Error

```text
Meja tidak ditemukan.
```

---

## Network Error

```text
Tidak dapat terhubung ke server.
```

---

## Validation Error

```text
Jumlah tamu harus lebih dari 0.
```

---

# 11. Task Checklist

## Model

- [ ] Create TableModel
- [ ] Create TableStatus Enum

## Repository

- [ ] Create TableRepository
- [ ] Get Table List
- [ ] Get Table Detail
- [ ] Create Order

## Controller

- [ ] Create TableController
- [ ] Load Tables
- [ ] Refresh Tables
- [ ] Create Order

## UI

- [ ] Create Table Page
- [ ] Create Table Card
- [ ] Create CreateOrderDialog
- [ ] Create Table Status Badge

## Navigation

- [ ] Dashboard → Table
- [ ] Table → Order Placeholder

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Daftar meja tampil

✅ Status meja tampil

✅ Data customer dapat diinput

✅ Order baru berhasil dibuat

✅ Order aktif dapat dibuka kembali

✅ Navigasi menuju Order Page berjalan

✅ Tidak ada business logic di Widget

---

# Output Sprint

Hasil akhir Sprint 04:

```text
Dashboard

↓

Daftar Meja

↓

Pilih Meja

↓

Input Customer

↓

Create Order

↓

Order Page (Placeholder)
```

Sprint berikutnya:

# Sprint 05 — Order & Menu

Membuat fitur inti POS:

- Menampilkan daftar menu
- Kategori menu
- Pencarian menu
- Menambahkan item ke cart
- Mengubah quantity
- Menghapus item
- Menghitung subtotal
- Menyimpan item ke backend