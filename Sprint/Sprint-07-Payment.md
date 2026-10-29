# Flutter POS Sprint 07

# Payment & Split Payment

## Status

Completed


# Tujuan Sprint

Membangun fitur pembayaran pada aplikasi Flutter POS sehingga kasir dapat menyelesaikan transaksi customer.

Sprint ini menggunakan Payment Module backend yang sudah selesai dibuat.

Kasir dapat:

- Melihat ringkasan tagihan
- Melakukan pembayaran cash
- Melakukan pembayaran transfer
- Melakukan split payment
- Melihat status pembayaran
- Menyelesaikan order setelah pembayaran lunas


Tidak termasuk:

- Laporan keuangan
- Rekap harian
- Printer thermal integration
- Discount management


---

# 1. Business Flow

Flow pembayaran normal:

```text
Order

↓

Kitchen selesai

↓

Customer meminta pembayaran

↓

Kasir membuka pembayaran

↓

Input pembayaran

↓

Payment berhasil

↓

Order Completed
```

---

# 2. Split Payment Business Flow

Sistem mendukung pembayaran bertahap.

Contoh:

Total:

```
Rp500.000
```

Customer membayar:

```
Cash
Rp300.000


Transfer
Rp200.000
```

Flow:

```text
Payment Page

↓

Input Payment 1

↓

Cash

↓

Sisa Tagihan

↓

Input Payment 2

↓

Transfer

↓

Paid
```

---

# 3. Backend Endpoint

Menggunakan endpoint Payment yang sudah dibuat.


## Payment Summary

```http
GET /api/v1/orders/{order}/payment-summary
```

Digunakan untuk mengambil:

- Total order
- Total pembayaran
- Sisa pembayaran


---

## Create Payment

```http
POST /api/v1/orders/{order}/payments
```

Request:

```json
{
    "method": "cash",
    "amount": 300000
}
```


---

## Payment History

```http
GET /api/v1/orders/{order}/payments
```

---

# 4. Scope Sprint

Feature:

```text
features/payment/

├── bindings/
│   └── payment_binding.dart
│
├── controllers/
│   └── payment_controller.dart
│
├── models/
│   ├── payment_model.dart
│   └── payment_summary_model.dart
│
├── repositories/
│   └── payment_repository.dart
│
├── views/
│   ├── payment_page.dart
│   └── payment_success_page.dart
│
└── widgets/
    ├── payment_summary_card.dart
    ├── payment_method_button.dart
    ├── payment_input.dart
    ├── payment_history.dart
    └── remaining_amount_card.dart
```

---

# 5. Payment Page Layout

Struktur:

```text
+--------------------------------+

Customer

Meja

---------------------------------

Total Order

Rp xxx.xxx


Sudah Dibayar

Rp xxx.xxx


Sisa

Rp xxx.xxx


---------------------------------

Payment Method

[ Cash ]

[ Transfer ]


Amount


[ Bayar ]

---------------------------------

Payment History

+--------------------------------+
```

---

# 6. Payment Summary

Menampilkan:

```text
Subtotal

Discount

Grand Total

Paid

Remaining
```

Nilai berasal dari backend.

Frontend tidak menghitung ulang total pembayaran.

---

# 7. Payment Method

MVP menggunakan:

```text
Cash

Transfer
```

UI:

```text
[ Cash ]

[ Transfer ]
```

---

# 8. Cash Payment

Flow:

```text
Pilih Cash

↓

Input Nominal

↓

Submit

↓

Backend Validation

↓

Payment Created
```

Contoh:

Tagihan:

```
150.000
```

Bayar:

```
200.000
```

Frontend menampilkan:

```
Kembalian

50.000
```

---

# 9. Transfer Payment

Flow:

```text
Pilih Transfer

↓

Input Nominal

↓

Submit

↓

Payment Created
```

Tidak membutuhkan input kembalian.


---

# 10. Split Payment

Controller menangani:

```text
payments[]
```

Contoh state:

```dart
[
 {
   method: cash,
   amount: 200000
 },

 {
   method: transfer,
   amount: 300000
 }
]
```

Validasi:

```text
Total pembayaran tidak boleh melebihi tagihan

Sisa harus 0 untuk menyelesaikan order
```

---

# 11. Payment Controller

File:

```text
payment_controller.dart
```


Tanggung jawab:

- Load payment summary
- Pilih metode pembayaran
- Input nominal
- Submit payment
- Refresh payment status


State:

```dart
isLoading

summary

payments

selectedMethod

amount

remainingAmount

isPaid
```

---

# 12. Payment Repository

Method:

```dart
getSummary()

createPayment()

getHistory()
```

Repository hanya menangani komunikasi API.

---

# 13. Order Completion

Jika:

```text
remaining_amount = 0
```

maka:

```text
Payment Completed

↓

Order Completed
```

Status berasal dari backend.

Frontend hanya menampilkan hasil.


---

# 14. Receipt Preview

Sprint ini hanya membuat preview sederhana.

Menampilkan:

```text
Nama Restaurant

Order Number

Customer

Item

Total

Payment

Time
```

Belum termasuk:

- Printer thermal
- Bluetooth printer


---

# 15. Error Handling


## Payment Kurang

```text
Pembayaran belum mencukupi.
```


## Payment Melebihi

```text
Nominal pembayaran melebihi tagihan.
```


## Network Error

```text
Tidak dapat terhubung ke server.
```


## Order Belum Siap Dibayar

```text
Order belum dapat diselesaikan.
```

---

# 16. Task Checklist


## Model

- [x] Create PaymentModel
- [x] Create PaymentSummaryModel


## Repository

- [x] Get Payment Summary
- [x] Create Payment
- [x] Get Payment History


## Controller

- [x] Load Summary
- [x] Select Payment Method
- [x] Submit Payment
- [x] Handle Split Payment
- [x] Check Remaining Amount


## UI

- [x] Payment Page
- [x] Summary Card
- [x] Payment Method Button
- [x] Amount Input
- [x] Payment History
- [x] Success Page


## Integration

- [x] Cash Payment
- [x] Transfer Payment
- [x] Split Payment
- [x] Complete Order


---

# Definition of Done


Sprint dianggap selesai jika:


✅ Kasir dapat melihat total tagihan


✅ Kasir dapat menerima pembayaran cash


✅ Kasir dapat menerima pembayaran transfer


✅ Kasir dapat melakukan split payment


✅ Sisa pembayaran tampil dengan benar


✅ Order berubah menjadi selesai ketika lunas


✅ History pembayaran tampil


✅ Tidak ada kalkulasi finansial utama di frontend


---

# Output Sprint


Hasil akhir Sprint 07:

```text
Dashboard

↓

Table

↓

Order

↓

Kitchen Process

↓

Payment

↓

Cash / Transfer / Split Payment

↓

Order Completed
```


Setelah Sprint 07 selesai, aplikasi Flutter POS sudah memiliki **core transaction flow lengkap**:

```text
Customer datang

↓

Kasir pilih meja

↓

Buat order

↓

Tambah menu

↓

Kirim dapur

↓

Masak

↓

Bayar

↓

Transaksi selesai
```

Sprint berikutnya:

# Sprint 08 — Order Adjustment & Inventory Awareness

Fitur:

- Item unavailable handling
- Customer approval adjustment
- Replace item
- Cancel item
- Stock warning
- Kitchen feedback ke kasir
- Sinkronisasi kondisi stok lapangan
```