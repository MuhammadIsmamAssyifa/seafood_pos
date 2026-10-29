# Flutter POS Sprint 11

# Reporting

## Status

Completed

# Tujuan Sprint

Membangun dashboard laporan operasional pada aplikasi Flutter POS agar owner atau kasir dapat melihat performa penjualan secara cepat tanpa harus membuka dashboard web.

Sprint ini hanya **menampilkan data**.

Seluruh proses perhitungan laporan dilakukan di backend Laravel.

Sprint ini membuat:

- Dashboard Summary
- Sales Summary
- Payment Summary
- Order Summary
- Best Selling Menu
- Today's Statistics

Tidak termasuk:

- Export Excel
- Export PDF
- Grafik tahunan
- Profit Analysis
- Inventory Report

---

# 1. Business Flow

```text
Dashboard

↓

Reporting

↓

Pilih Periode

↓

Backend Menghitung

↓

Summary

↓

Charts

↓

Detail
```

---

# 2. Backend Endpoint

Menggunakan endpoint reporting yang sudah tersedia atau akan dibuat.

## Dashboard Summary

```http
GET /api/v1/reports/dashboard
```

---

## Sales Report

```http
GET /api/v1/reports/sales
```

Parameter:

```text
date

start_date

end_date
```

---

## Best Selling Menu

```http
GET /api/v1/reports/top-menu
```

---

## Payment Report

```http
GET /api/v1/reports/payments
```

---

# 3. Scope Sprint

```text
features/report/

├── bindings/
│   └── report_binding.dart
│
├── controllers/
│   └── report_controller.dart
│
├── repositories/
│   └── report_repository.dart
│
├── models/
│   ├── dashboard_summary_model.dart
│   ├── sales_report_model.dart
│   ├── payment_summary_model.dart
│   ├── top_menu_model.dart
│   └── report_filter.dart
│
├── views/
│   ├── report_page.dart
│   └── sales_detail_page.dart
│
└── widgets/
    ├── summary_card.dart
    ├── sales_chart.dart
    ├── payment_chart.dart
    ├── top_menu_card.dart
    ├── report_filter_sheet.dart
    └── statistic_card.dart
```

---

# 4. Dashboard Summary

Menampilkan KPI utama.

Informasi:

```text
Total Sales

Total Orders

Average Transaction

Completed Orders
```

Contoh:

```text
Sales Today

Rp18.250.000

Orders

56

Average

Rp325.000
```

---

# 5. Sales Summary

Ringkasan penjualan.

Menampilkan:

```text
Subtotal

Discount

Grand Total
```

Periode:

```text
Hari Ini

7 Hari

30 Hari

Custom Range
```

---

# 6. Payment Summary

Menampilkan komposisi pembayaran.

Contoh:

```text
Cash

Rp8.200.000

Transfer

Rp10.050.000
```

Visualisasi menggunakan Pie Chart sederhana.

---

# 7. Order Summary

Menampilkan jumlah order berdasarkan status.

Contoh:

```text
Draft

Submitted

Preparing

Ready

Completed

Cancelled
```

Visualisasi menggunakan Bar Chart.

---

# 8. Best Selling Menu

Menampilkan menu dengan penjualan terbanyak.

Contoh:

```text
1.

Ikan Etong Bakar

120 Porsi

------------------

2.

Cumi Crispy

95 Porsi

------------------

3.

Es Teh Manis

80 Gelas
```

---

# 9. Filter

Filter laporan:

```text
Hari Ini

Kemarin

7 Hari

30 Hari

Custom Range
```

Setiap perubahan filter akan meminta data baru ke backend.

---

# 10. Controller

File:

```text
report_controller.dart
```

Method:

```dart
loadDashboard()

loadSales()

loadPayments()

loadTopMenu()

changeFilter()

refreshReport()
```

State:

```dart
isLoading

dashboard

sales

payments

topMenus

selectedFilter
```

---

# 11. Repository

Method:

```dart
getDashboard()

getSales()

getPayments()

getTopMenu()
```

Repository hanya mengambil data dari backend.

---

# 12. UI

## Report Dashboard

Komponen:

```text
Summary Cards

↓

Sales Chart

↓

Payment Chart

↓

Top Menu

↓

Order Statistics
```

---

## Summary Card

Menampilkan:

```text
Title

Value

Icon
```

Contoh:

```text
Today's Sales

Rp18.250.000
```

---

## Sales Chart

Grafik:

```text
Penjualan per Hari
```

Menggunakan Line Chart sederhana.

---

## Payment Chart

Grafik:

```text
Cash

vs

Transfer
```

Menggunakan Pie Chart.

---

## Top Menu Card

Menampilkan:

```text
Nama Menu

Jumlah Terjual
```

---

# 13. Refresh Report

Refresh dilakukan ketika:

```text
Pull to Refresh

↓

Request API

↓

Update Dashboard
```

Tidak menggunakan auto refresh pada MVP.

---

# 14. Error Handling

## API

```text
Laporan tidak tersedia.
```

---

## Empty Data

```text
Belum ada transaksi pada periode ini.
```

---

## Network

```text
Tidak dapat mengambil laporan.
```

---

# 15. Task Checklist

## Model

- [x] Create DashboardSummaryModel
- [x] Create SalesReportModel
- [x] Create PaymentSummaryModel
- [x] Create TopMenuModel

## Repository

- [x] Get Dashboard
- [x] Get Sales Report
- [x] Get Payment Summary
- [x] Get Top Menu

## Controller

- [x] Load Dashboard
- [x] Change Filter
- [x] Refresh Report

## UI

- [x] Report Dashboard
- [x] Summary Cards
- [x] Sales Chart
- [x] Payment Chart
- [x] Order Statistics
- [x] Top Menu List

## Integration

- [x] Dashboard API
- [x] Sales API
- [x] Payment API
- [x] Top Menu API

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Dashboard berhasil dimuat

✅ Ringkasan penjualan tampil

✅ Ringkasan metode pembayaran tampil

✅ Statistik order tampil

✅ Menu terlaris tampil

✅ Filter periode berfungsi

✅ Pull to Refresh berfungsi

✅ Seluruh angka berasal dari backend

---

# Output Sprint

Hasil akhir Sprint 11:

```text
Dashboard

↓

Reporting

├── Sales Summary
├── Payment Summary
├── Order Statistics
├── Top Selling Menu
└── Filter Periode
```

Owner atau kasir dapat melihat kondisi operasional restoran secara cepat tanpa membuka dashboard web. Semua perhitungan tetap berada di backend sehingga frontend hanya bertanggung jawab menampilkan data secara konsisten.

---

# Sprint Berikutnya

## Flutter POS Sprint 12 — Polish & Release

Fitur yang akan diselesaikan:

- Loading & Skeleton UI
- Empty State
- Error State
- Pull to Refresh
- Form Validation
- Offline Handling
- Session Expired Handling
- Performance Optimization
- Responsive Layout
- Dark Mode (opsional)
- Printer Thermal Integration
- Final Bug Fix
- Release Candidate (RC)

Sprint 12 merupakan tahap finalisasi sebelum aplikasi POS siap digunakan pada operasional restoran.
:::writing