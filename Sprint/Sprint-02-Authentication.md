

# Flutter POS Sprint 02

# Authentication

## Status

Completed

# Tujuan Sprint

Membuat sistem autentikasi Flutter POS agar kasir dapat masuk ke aplikasi menggunakan akun yang tersedia dari backend Laravel.

Sprint ini membuat:

- Login
- Session management
- Token storage
- User state
- Logout
- Authentication guard

Tidak termasuk:

- Dashboard POS
- Order
- Menu
- Payment

---

# 1. Business Flow

Flow login kasir:

```
Buka aplikasi

↓

Splash Screen

↓

Check token lokal

↓

Token tersedia?

        Ya
        |
        ↓
Validasi session

        |
        ↓
Masuk POS Dashboard


        Tidak

        |
        ↓

Login Screen

        |
        ↓

Input username/password

        |
        ↓

API Login

        |
        ↓

Simpan token

        |
        ↓

Masuk POS Dashboard
```

---

# 2. Backend Endpoint

Menggunakan endpoint yang sudah dibuat:

## Login User

```
POST /api/v1/login
```

Request:

```json
{
    "email": "kasir@example.com",
    "password": "password"
}
```

Response contoh:

```json
{
    "token": "xxxxx",
    "user": {
        "id": 1,
        "name": "Kasir"
    }
}
```

---

## Staff Login

Jika menggunakan PIN kasir:

```
POST /api/v1/staff-login
```

Request:

```json
{
    "username": "kasir",
    "pin": "1234"
}
```

---

# 3. Scope Sprint

## Authentication Module

Membuat feature:

```
features/auth/

├── bindings/
│   └── auth_binding.dart
│
├── controllers/
│   └── auth_controller.dart
│
├── models/
│   └── user_model.dart
│
├── repositories/
│   └── auth_repository.dart
│
├── views/
│   ├── login_page.dart
│   └── splash_page.dart
│
└── widgets/
    ├── login_form.dart
    └── password_field.dart
```

---

# 4. Model Data

## User Model

File:

```
user_model.dart
```

Data:

```dart
class UserModel {

 final int id;
 final String name;
 final String username;
 final String? email;

}
```

Menyesuaikan response Laravel.

---

# 5. Repository Layer

File:

```
auth_repository.dart
```

Tanggung jawab:

- Request login
- Request logout
- Parsing response

Contoh flow:

```
AuthController

↓

AuthRepository

↓

DioClient

↓

Laravel API
```

Repository tidak mengatur UI.

---

# 6. Auth Controller

File:

```
auth_controller.dart
```

Tanggung jawab:

- Menyimpan state login
- Menjalankan login
- Logout
- Check session

State:

```dart
isLoading

isAuthenticated

currentUser
```

---

Contoh:

```
Login Button

↓

AuthController.login()

↓

Repository.login()

↓

Save Token

↓

Update State

↓

Navigate Dashboard
```

---

# 7. Secure Storage

Gunakan:

```
flutter_secure_storage
```

Simpan:

```
access_token

user_id

user_data
```

Contoh key:

```
ACCESS_TOKEN

USER_ID

USER_DATA
```

---

# 8. Dio Interceptor Integration

Setelah login berhasil:

Semua request berikutnya otomatis:

```
Authorization:

Bearer {token}
```

Contoh:

```
GET /catalog/menus
```

otomatis menjadi:

```
Authorization: Bearer xxxx
```

---

# 9. Routing Authentication

Menggunakan GetX Middleware.

Flow:

```
/splash

↓

Check Auth


Authenticated

↓

/home


Not Authenticated

↓

/login
```

---

# 10. UI Screen

## Splash Screen

Fungsi:

- Check token
- Menentukan halaman pertama

Komponen:

```
Logo

Loading Indicator
```

---

## Login Screen

Komponen:

```
Username Field

Password Field

Login Button

Error Message
```

---

# 11. Error Handling

Handle:

## Validation Error

Contoh:

```
Username wajib diisi
Password wajib diisi
```

## API Error

Contoh:

```
Password salah
User tidak ditemukan
```

## Network Error

Contoh:

```
Tidak dapat terhubung ke server
```

---

# 12. Task Checklist

## Model

- [x] Create UserModel

## Repository

- [x] Create AuthRepository
- [x] Implement login API
- [x] Implement logout API

## Controller

- [x] Create AuthController
- [x] Login state
- [x] Logout state
- [x] Session checking

## Storage

- [x] Save token
- [x] Read token
- [x] Delete token

## API

- [x] Test login endpoint
- [x] Setup token interceptor

## UI

- [x] Create Splash Screen
- [x] Create Login Screen
- [x] Validation

## Routing

- [x] Setup auth middleware
- [x] Redirect authenticated user
- [x] Redirect guest user

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Kasir dapat login

✅ Token tersimpan aman

✅ Ketika aplikasi ditutup dan dibuka kembali user masih login

✅ Logout menghapus session

✅ API request otomatis membawa token

✅ Error login tampil dengan benar

✅ Tidak ada logic API di Widget

---

# Output Sprint

Hasil akhir Sprint 02:

```
Flutter POS

Open App

↓

Splash

↓

Login

↓

Authenticated Session

↓

Ready masuk Dashboard POS
```
