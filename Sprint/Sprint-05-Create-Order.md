# Flutter POS Sprint 05

# Order & Menu

## Status

Planning

# Tujuan Sprint

Membangun fitur utama POS untuk membuat transaksi.

Kasir dapat memilih menu, menambahkan item ke pesanan, mengubah quantity, menghapus item, melihat total belanja, dan seluruh perubahan langsung tersimpan ke backend.

Sprint ini merupakan sprint inti pertama yang mulai menggunakan business process restoran.

Sprint ini membuat:

- Halaman Order
- Daftar Menu
- Pencarian Menu
- Filter Kategori
- Cart
- Add Item
- Update Quantity
- Delete Item
- Auto Calculate Total

Tidak termasuk:

- Submit ke Kitchen
- Kitchen Display
- Payment
- Split Payment

---

# 1. Business Flow

Flow transaksi:

```text
Dashboard

↓

Daftar Meja

↓

Create/Open Order

↓

Halaman Order

↓

Pilih Menu

↓

Tambah Item

↓

Cart

↓

Edit Quantity

↓

Delete Item

↓

Order Draft
```

Order masih berstatus:

```text
Draft
```

Belum dikirim ke dapur.

---

# 2. Backend Endpoint

Menggunakan endpoint yang telah dibuat.

## Catalog Menu

```http
GET /api/v1/catalog/menus
```

---

## Detail Order

```http
GET /api/v1/orders/{id}
```

---

## Tambah Item

```http
POST /api/v1/orders/{order}/items
```

Request:

```json
{
  "menu_variant_id": 5,
  "quantity": 2
}
```

---

## Update Quantity

```http
PATCH /api/v1/order-items/{id}
```

---

## Delete Item

```http
DELETE /api/v1/order-items/{id}
```

---

# 3. Scope Sprint

Feature:

```text
features/order/

├── bindings/
│   └── order_binding.dart
│
├── controllers/
│   └── order_controller.dart
│
├── models/
│   ├── order_model.dart
│   ├── order_item_model.dart
│   ├── menu_model.dart
│   └── menu_category.dart
│
├── repositories/
│   └── order_repository.dart
│
├── views/
│   ├── order_page.dart
│   ├── menu_page.dart
│   └── cart_page.dart
│
└── widgets/
    ├── menu_card.dart
    ├── category_chip.dart
    ├── cart_item_card.dart
    ├── quantity_selector.dart
    ├── search_bar.dart
    └── order_summary.dart
```

---

# 4. Layout Halaman Order

Layout utama:

```text
+--------------------------------------------------+
| Customer & Meja                                  |
+--------------------------------------------------+
| Search Menu                                      |
+--------------------------------------------------+
| Category                                         |
+--------------------------------------------------+
| Menu Grid                                        |
|                                                  |
|                                                  |
+--------------------------------------------------+
| Cart                                              |
|                                                  |
| Total                                            |
|                                                  |
| Continue                                         |
+--------------------------------------------------+
```

---

# 5. Menu Catalog

Menampilkan seluruh menu aktif.

Informasi:

```text
Foto

Nama Menu

Variant

Harga

Station

Status
```

Contoh:

```text
Ikan Etong Bakar

Rp120.000

Seafood
```

---

# 6. Search Menu

Kasir dapat mencari berdasarkan:

```text
Nama Menu

Variant
```

Search dilakukan secara lokal setelah data menu berhasil dimuat.

---

# 7. Filter Category

Kategori minimal:

```text
Semua

Seafood

Drink

Snack
```

Filter hanya memengaruhi tampilan daftar menu.

---

# 8. Cart

Menampilkan seluruh item yang sudah dipilih.

Informasi:

```text
Nama Menu

Variant

Harga

Quantity

Subtotal
```

Contoh:

```text
Ikan Etong

2 x 120.000

240.000
```

---

# 9. Quantity Management

Kasir dapat:

```text
Tambah

Kurang
```

Setiap perubahan akan langsung:

```text
Update API

↓

Refresh Order

↓

Update Total
```

Tidak perlu tombol simpan.

---

# 10. Delete Item

Kasir dapat menghapus item.

Flow:

```text
Tap Delete

↓

Confirmation Dialog

↓

Delete API

↓

Refresh Cart
```

---

# 11. Order Summary

Menampilkan:

```text
Subtotal

Diskon

Grand Total

Jumlah Item
```

Nilai mengikuti backend.

Frontend tidak menghitung ulang total.

---

# 12. Controller

File:

```text
order_controller.dart
```

Tanggung jawab:

- Load menu
- Search menu
- Filter category
- Add item
- Update quantity
- Delete item
- Refresh order

State:

```dart
isLoading

menus

categories

selectedCategory

searchText

order

cart

total
```

---

# 13. Repository

Method:

```dart
getMenus()

getOrder()

addItem()

updateItem()

deleteItem()
```

Repository hanya berkomunikasi dengan Laravel API.

---

# 14. Error Handling

Handle:

## API Error

```text
Menu tidak ditemukan.
```

---

## Validation

```text
Quantity tidak valid.
```

---

## Network

```text
Tidak dapat terhubung ke server.
```

---

# 15. Task Checklist

## Model

- [ ] Create MenuModel
- [ ] Create OrderModel
- [ ] Create OrderItemModel

## Repository

- [ ] Get Menu
- [ ] Get Order
- [ ] Add Item
- [ ] Update Item
- [ ] Delete Item

## Controller

- [ ] Load Menu
- [ ] Search Menu
- [ ] Filter Category
- [ ] Add Item
- [ ] Update Quantity
- [ ] Delete Item
- [ ] Refresh Order

## UI

- [ ] Order Page
- [ ] Menu Grid
- [ ] Search Bar
- [ ] Category Filter
- [ ] Cart
- [ ] Order Summary
- [ ] Quantity Selector

## Integration

- [ ] Load Menu API
- [ ] Add Item API
- [ ] Update Item API
- [ ] Delete Item API
- [ ] Refresh Order

---

# Definition of Done

Sprint dianggap selesai jika:

✅ Daftar menu berhasil dimuat dari backend

✅ Menu dapat dicari

✅ Menu dapat difilter berdasarkan kategori

✅ Item dapat ditambahkan ke order

✅ Quantity dapat diubah

✅ Item dapat dihapus

✅ Cart selalu sinkron dengan backend

✅ Total transaksi sesuai backend

✅ Tidak ada business logic perhitungan total di frontend

---

# Output Sprint

Hasil akhir Sprint 05:

```text
Dashboard

↓

Daftar Meja

↓

Order

↓

Pilih Menu

↓

Tambah Item

↓

Cart

↓

Update Quantity

↓

Delete Item

↓

Order Draft
```

Pada akhir Sprint 05, kasir sudah dapat membuat pesanan lengkap dalam status **Draft**. Seluruh item tersimpan di backend dan siap dilanjutkan ke proses berikutnya.

Sprint selanjutnya:

# Sprint 06 — Submit Order & Kitchen Integration

Membuat fitur:

- Submit Batch ke Kitchen
- Status Order (Draft → Submitted)
- Lock Order sesuai business rule
- Kitchen Queue
- Refresh Status Order
