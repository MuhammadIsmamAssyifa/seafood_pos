# Flutter POS Sprint 03

# Dashboard POS

## Status

Completed

# Tujuan Sprint

Membangun halaman utama (Dashboard POS) sebagai pusat navigasi kasir setelah berhasil login.

Sprint ini hanya membuat Dashboard beserta navigasi utama. Belum membuat fitur transaksi.

Sprint ini membuat:

- Dashboard POS
- Informasi kasir
- Informasi outlet
- Shortcut menu
- Logout
- Navigation

Tidak termasuk:

- Create Order
- Table
- Menu
- Payment
- Kitchen

---

# 1. Business Flow

Flow setelah login berhasil:

```
Login

↓

Dashboard POS

↓

Kasir memilih menu

↓

Masuk ke fitur yang dipilih
```

Dashboard menjadi pusat seluruh aktivitas kasir.

---

# 2. Backend Endpoint

Menggunakan endpoint:

```
GET /api/user
```

atau endpoint profile yang sudah tersedia pada backend.

Digunakan untuk mengambil informasi:

- Nama Kasir
- Role
- Outlet
- Restaurant

---

# 3. Scope Sprint

Membuat feature:

```
features/dashboard/

├── bindings/
│   └── dashboard_binding.dart
│
├── controllers/
│   └── dashboard_controller.dart
│
├── repositories/
│   └── dashboard_repository.dart
│
├── views/
│   └── dashboard_page.dart
│
└── widgets/
    ├── dashboard_header.dart
    ├── menu_card.dart
    ├── user_card.dart
    └── logout_dialog.dart
```

---

# 4. Dashboard Layout

Komponen utama:

```
AppBar

↓

User Information

↓

Outlet Information

↓

Shortcut Menu

↓

Logout
```

---

# 5. Shortcut Menu

Dashboard menampilkan menu utama POS.

Contoh:

```
Order Baru

Daftar Meja

Riwayat Order

Profile
```

Fitur yang belum selesai tetap dapat ditampilkan dalam keadaan nonaktif atau diarahkan ke halaman placeholder.

---

# 6. Dashboard Controller

File:

```
dashboard_controller.dart
```

Tanggung jawab:

- Mengambil informasi user
- Mengambil informasi outlet
- Menyiapkan shortcut menu
- Logout

State:

```dart
isLoading

user

outlet

menuList
```

---

# 7. Repository Layer

File:

```
dashboard_repository.dart
```

Tanggung jawab:

- Mengambil profile user
- Mengambil informasi outlet

Repository tidak mengatur UI.

---

# 8. UI Screen

## Dashboard Page

Komponen:

```
AppBar

Header User

Header Outlet

Shortcut Menu

Logout Button
```

---

## Dashboard Header

Menampilkan:

```
Nama Kasir

Role

Nama Outlet
```

---

## Menu Card

Digunakan untuk seluruh shortcut.

Contoh:

```
📋 Order Baru

🍽 Meja

📄 Riwayat

👤 Profile
```

Widget ini reusable.

---

# 9. Navigation

Menggunakan GetX Navigation.

Flow:

```
Dashboard

↓

Order

↓

Table

↓

History

↓

Profile
```

Halaman tujuan boleh masih berupa placeholder.

---

# 10. Logout Flow

Flow:

```
Dashboard

↓

Logout

↓

Confirmation Dialog

↓

Hapus Token

↓

Login Screen
```

---

# 11. Error Handling

Handle:

## API Error

```
Gagal mengambil data user.
```

## Session Expired

```
Session telah berakhir.

Silakan login kembali.
```

## Network Error

```
Tidak dapat terhubung ke server.
```

---

# 12. Task Checklist

## Repository

- [x] Create DashboardRepository
- [x] Get User Profile
- [x] Get Outlet Information

## Controller

- [x] Create DashboardController
- [x] Load Dashboard Data
- [x] Logout Function

## UI

- [x] Create Dashboard Page
- [x] Create Dashboard Header
- [x] Create User Card
- [x] Create Shortcut Menu
- [x] Create Logout Dialog

## Navigation

- [x] Setup Dashboard Route
- [x] Navigate to Placeholder Pages

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Dashboard tampil setelah login

✅ Informasi kasir tampil

✅ Informasi outlet tampil

✅ Shortcut menu tampil

✅ Logout berfungsi

✅ Navigasi menuju halaman placeholder berjalan

✅ Tidak ada business logic di Widget

---

# Output Sprint

Hasil akhir Sprint 03:

```
Splash

↓

Login

↓

Dashboard POS

├── Order Baru
├── Daftar Meja
├── Riwayat Order
└── Profile
```

Dashboard telah menjadi pusat navigasi aplikasi dan siap digunakan untuk Sprint berikutnya.

Sprint selanjutnya:

# Sprint 04 — Table Management

Membuat fitur:

- Daftar Meja
- Status Meja
- Pilih Meja
- Membuat Order dari Meja
