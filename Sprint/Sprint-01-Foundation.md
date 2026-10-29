# Flutter POS Sprint 01

# Foundation Setup

## Status

Completed

## Tujuan Sprint

Membangun fondasi awal aplikasi Flutter POS agar siap dikembangkan untuk seluruh fitur kasir.

Sprint ini tidak membuat fitur bisnis, tetapi menyiapkan struktur aplikasi, komunikasi API, dan komponen dasar yang akan digunakan oleh sprint berikutnya.

---

# 1. Scope Sprint

Yang dibuat:

- Flutter project setup
- Architecture setup
- Dependency management
- API client
- Local storage
- Theme
- Routing
- Global component
- Error handling

Tidak termasuk:

- Login
- Order
- Menu
- Payment

---

# 2. Technical Stack

## Framework

Flutter

## Language

Dart

## State Management

GetX

Alasan:

- cocok untuk solo developer
- cepat implementasi
- memiliki routing + dependency injection
- cukup untuk kompleksitas POS MVP

---

## Networking

Gunakan:

```
Dio
```

Fungsi:

- HTTP Client
- Interceptor
- Token Injection
- Error Handling

---

## Local Storage

Gunakan:

```
flutter_secure_storage
```

Untuk menyimpan:

- Access Token
- User Session

---

## Routing

Gunakan:

GetX Route Management

Untuk:

- Navigation
- Authentication Guard
- Middleware
- Binding

---

# 3. Project Structure

Struktur awal:

```
lib/

├── main.dart
│
├── app/
│   ├── app.dart
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   │
│   ├── bindings/
│   │   └── initial_binding.dart
│   │
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_style.dart
│
├── core/
│   │
│   ├── api/
│   │   ├── dio_client.dart
│   │   ├── api_endpoint.dart
│   │   ├── api_exception.dart
│   │   └── api_response.dart
│   │
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   └── storage_keys.dart
│   │
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── app_assets.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatter.dart
│   │   └── helpers.dart
│   │
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   ├── app_loading.dart
│   │   └── app_error.dart
│   │
│   └── services/
│       ├── notification_service.dart
│       └── connectivity_service.dart
│
├── data/
│   ├── models/
│   └── repositories/
│
├── features/
│
│   ├── auth/
│   │   ├── bindings/
│   │   │   └── auth_binding.dart
│   │   │
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   │
│   │   ├── models/
│   │   │   └── user_model.dart
│   │   │
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   │
│   │   └── views/
│   │   │   ├── login_page.dart
│   │   │   └── splash_page.dart
│   │   └── widgets/
│   │
│   ├── dashboard/
│   │
│   ├── tables/
│   │
│   ├── menu/
│   │
│   ├── order/
│   │
│   ├── kitchen/
│   │
│   ├── payment/
│   │
│   └── profile/
│
└── shared/
    ├── enums/
    └── extensions/
```

---

# 4. Environment Configuration

Buat konfigurasi:

```
development
staging
production
```

Contoh:

```
API_BASE_URL=https://api.example.com/api/v1
```

Tujuan:

Tidak mengubah kode ketika pindah server.

---

# 5. Theme Setup

Buat:

## Color

Contoh:

```
Primary
Secondary
Background
Surface
Error
Success
```

---

## Typography

Tentukan:

```
Heading

Title

Body

Caption
```

Agar seluruh aplikasi konsisten.

---

# 6. API Client Setup

Buat Dio instance.

Fungsi:

## Request

Contoh:

```
GET /menus
POST /orders
```

---

## Interceptor

Handle:

### Request

Tambahkan:

```
Authorization: Bearer TOKEN
```

---

### Response

Handle:

```
200
201
422
401
403
500
```

---

# 7. Global Error Handling

Buat format error aplikasi.

Contoh:

```
ApiException

- message
- statusCode
- errors
```

Digunakan seluruh feature.

---

# 8. Global Component

Buat komponen reusable:

## Loading

```
AppLoading()
```

---

## Button

```
PrimaryButton()
```

---

## TextField

```
AppTextField()
```

---

## Snackbar

```
showSuccess()
showError()
```

---

# 9. Splash Screen

Screen pertama aplikasi.

Flow:

```
Open App

↓

Check Token

↓

Token Valid

↓

Check User Role

↓

Kasir Dashboard


Token Tidak Valid

↓

Login
```

---

# 10. State Management Preparation

Buat binding dasar:

```

InitialBinding

AuthBinding

NetworkBinding
```

Belum berisi logic bisnis.

---

# 11. Dependency yang wajib

Dependency:

```
get
dio
flutter_secure_storage
get_storage
intl
logger
connectivity_plus

```

---

# 11. Task Checklist

## Project

- [x] Create Flutter project
- [x] Setup package dependency
- [x] Setup folder structure

## API

- [x] Setup Dio
- [x] Setup interceptor
- [x] Setup API exception

## Storage

- [x] Setup secure storage
- [x] Token helper

## Theme

- [x] Setup color
- [x] Setup typography
- [x] Setup theme

## Navigation

- [x] Setup GetX Route Management
- [x] Setup splash route

## Component

- [x] Button component
- [x] Loading component
- [x] Snackbar component

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Flutter project dapat dijalankan

✅ Struktur folder sudah tersedia

✅ API client dapat melakukan request

✅ Token storage sudah tersedia

✅ Routing berjalan

✅ Splash screen dapat menentukan halaman awal

✅ Theme global sudah aktif

✅ GetX Binding berjalan

✅ Dependency Injection berjalan

✅ API interceptor berjalan

✅ Error handling sudah standar

✅ Environment dapat diganti

✅ Tidak ada business logic di UI

---

# Output Sprint

Hasil akhir:

Aplikasi Flutter kosong tetapi sudah memiliki fondasi production-ready.
