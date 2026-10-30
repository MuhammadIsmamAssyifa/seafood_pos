# Flutter POS Sprint 12

# Polish & Release

## Status

Completed

# Tujuan Sprint

Melakukan tahap **finalisasi aplikasi Flutter POS** sebelum digunakan di operasional restoran.

Sprint ini berfokus pada:

- Penyempurnaan UI/UX
- Stabilitas aplikasi
- Optimasi performa
- Penanganan error
- Integrasi perangkat
- Pengujian end-to-end
- Persiapan Release Candidate (RC)

Sprint ini **tidak menambahkan fitur bisnis baru**. Seluruh fitur inti telah selesai pada Sprint 01–11.

---

# 1. Business Flow

```text
Development Finished

↓

UI Polish

↓

Bug Fix

↓

Performance Optimization

↓

Printer Integration

↓

Testing

↓

Release Candidate

↓

Production
```

---

# 2. Scope Sprint

Sprint ini mencakup:

- UI Polish
- Loading State
- Empty State
- Error State
- Offline Awareness
- Session Handling
- Thermal Printer
- Responsive Layout
- Bug Fix
- Final Testing
- Release Candidate

Tidak termasuk:

- Fitur baru
- Purchasing
- Inventory Management
- Kitchen Display System
- Admin Dashboard

---

# 3. Project Structure

```text
features/

├── release/
│
│   ├── bindings/
│   │   └── release_binding.dart
│   │
│   ├── controllers/
│   │   └── release_controller.dart
│   │
│   ├── services/
│   │   ├── printer_service.dart
│   │   ├── connectivity_service.dart
│   │   └── session_service.dart
│   │
│   └── widgets/
│       ├── empty_state.dart
│       ├── error_state.dart
│       ├── skeleton_loading.dart
│       └── retry_button.dart
```

---

# 4. Loading State

Seluruh halaman wajib memiliki Loading State.

Contoh:

```text
Loading...

██████████

██████████

██████████
```

Menggunakan Skeleton Loading.

Tidak menggunakan loading kosong.

---

# 5. Empty State

Semua halaman yang tidak memiliki data wajib memiliki Empty State.

Contoh:

```text
Belum ada transaksi.

[ Refresh ]
```

Contoh lainnya:

```text
Belum ada menu.

Silakan hubungi administrator.
```

---

# 6. Error State

Jika API gagal:

```text
Terjadi kesalahan.

[ Coba Lagi ]
```

Retry memanggil ulang endpoint.

---

# 7. Pull To Refresh

Semua halaman data wajib mendukung:

```text
Tarik ke bawah

↓

Refresh

↓

Request API

↓

Update Data
```

Minimal diterapkan pada:

- Dashboard
- Menu
- Order History
- Reporting

---

# 8. Form Validation

Seluruh form wajib memiliki validasi.

Contoh:

```text
Customer Name

Tidak boleh kosong.
```

```text
Quantity

Harus lebih dari 0.
```

```text
Payment

Nominal kurang.
```

Tidak boleh terjadi crash karena input user.

---

# 9. Session Handling

Jika token tidak valid:

```text
401 Unauthorized

↓

Clear Token

↓

Login Screen
```

Kasir harus login kembali.

---

# 10. Offline Awareness

POS tetap memberi informasi ketika koneksi terputus.

Contoh:

```text
Tidak ada koneksi internet.

Sebagian fitur mungkin tidak tersedia.
```

Jika backend sudah mendukung mode offline di masa depan, modul ini dapat dikembangkan tanpa mengubah UI utama.

---

# 11. Connectivity Monitoring

Pantau perubahan koneksi:

```text
Online

↓

Offline

↓

Online
```

Ketika koneksi kembali:

- Refresh data yang diperlukan.
- Sinkronisasi sesuai kemampuan backend.

---

# 12. Thermal Printer Integration

Integrasi printer thermal Bluetooth/LAN sesuai perangkat yang dipilih restoran.

Fitur:

- Scan Printer
- Pilih Printer
- Simpan Printer
- Test Print
- Print Receipt

Flow:

```text
Payment Success

↓

Generate Receipt

↓

Print

↓

Success
```

Printer dipilih satu kali dan disimpan pada local storage.

---

# 13. Responsive Layout

Pastikan aplikasi berjalan baik pada:

```text
Tablet 8"

Tablet 10"

Tablet 11"

Desktop Window (opsional)
```

Tidak boleh ada overflow.

---

# 14. Performance Optimization

Lakukan optimasi:

- Lazy Loading
- Pagination
- Const Widget
- Image Optimization
- Minimize Rebuild
- Dispose Controller yang tidak digunakan

Target:

- Navigasi terasa responsif.
- Scroll tetap lancar meskipun data banyak.

---

# 15. Security Review

Pastikan:

- Token tersimpan di Secure Storage.
- Logout menghapus seluruh session.
- Tidak ada endpoint tanpa autentikasi.
- Error internal tidak ditampilkan ke pengguna.

---

# 16. Final Bug Fix

Lakukan pengujian seluruh alur:

- Login
- Dashboard
- Pilih Meja
- Tambah Item
- Submit Kitchen
- Kitchen Status
- Adjustment
- Payment
- Order History
- Reporting

Seluruh bug yang ditemukan diperbaiki sebelum Release Candidate.

---

# 17. User Acceptance Testing (UAT)

Lakukan simulasi operasional restoran.

Contoh skenario:

- Customer datang.
- Kasir membuat order.
- Kitchen menerima.
- Kitchen memasak.
- Kitchen Ready.
- Customer membayar Cash.
- Customer membayar Transfer.
- Split Payment.
- Order Adjustment.
- Reprint Receipt.
- Order History.
- Reporting.

Semua skenario harus berhasil tanpa error.

---

# 18. Controller

File:

```dart
release_controller.dart
```

Method:

```dart
checkSession()

retryRequest()

refreshAll()

connectPrinter()

printReceipt()

logout()
```

State:

```dart
isConnected

isPrinting

printer

sessionExpired

isRefreshing
```

---

# 19. Task Checklist

## UI Polish

- [x] Skeleton Loading
- [x] Empty State
- [x] Error State
- [x] Retry Button

## Validation

- [x] Form Validation
- [x] API Error Handling
- [x] Session Expired

## Connectivity

- [x] Connectivity Monitoring
- [x] Offline Banner
- [x] Pull To Refresh

## Printer

- [x] Scan Printer
- [x] Connect Printer
- [x] Save Printer
- [x] Test Print
- [x] Print Receipt

## Optimization

- [x] Remove Unused Widget
- [x] Reduce Rebuild
- [x] Pagination Review
- [x] Memory Leak Review

## Testing

- [x] Login Test
- [x] Order Test
- [x] Kitchen Test
- [x] Adjustment Test
- [x] Payment Test
- [x] History Test
- [x] Reporting Test
- [x] Printer Test

## Release

- [x] Version Number
- [x] App Icon
- [x] Splash Screen
- [x] Release Notes
- [x] Generate Release APK / AAB

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Seluruh fitur Sprint 01–11 berjalan tanpa bug kritis

✅ Seluruh halaman memiliki Loading, Empty, dan Error State

✅ Session Expired ditangani dengan benar

✅ Printer thermal berhasil mencetak struk

✅ Aplikasi responsif pada perangkat target

✅ Pengujian end-to-end berhasil

✅ Release Candidate berhasil dibuat

---

# Output Sprint

Hasil akhir Sprint 12:

```text
Flutter POS

├── Stabil
├── Cepat
├── Aman
├── Siap Digunakan
├── Terintegrasi Printer
└── Release Candidate
```

---
