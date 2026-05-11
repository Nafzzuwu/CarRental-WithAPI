# 🚗 CarRental App — Flutter with REST API

Aplikasi mobile **Sewa Mobil** berbasis Flutter yang terintegrasi dengan REST API. Mendukung dua peran pengguna: **USER** dan **ADMIN**, dengan alur lengkap dari pemesanan hingga verifikasi pembayaran.

---

## 📱 Fitur Aplikasi

### 👤 Role USER
- Melihat daftar mobil yang tersedia
- Membuat pemesanan mobil (pilih tanggal, lokasi pengambilan & pengembalian)
- Melihat estimasi total biaya sewa secara otomatis
- Melakukan pembayaran dengan berbagai metode (Transfer Bank, Kartu Kredit, Kartu Debit, E-Wallet, Tunai)
- Melihat riwayat dan status pemesanan

### 🛠️ Role ADMIN
- Melihat seluruh data pemesanan dari semua pengguna
- Mengkonfirmasi atau menolak pemesanan yang masuk
- Memverifikasi (approve/reject) pembayaran dari user
- Mengelola data mobil (tambah, edit, hapus)

---

## 🗂️ Struktur Project

```
lib/
├── main.dart
├── config/
│   ├── api_config.dart          # Base URL & prefix endpoint API
│   └── app_colors.dart          # Konstanta warna aplikasi
├── models/
│   ├── booking_model.dart       # Model data pemesanan
│   ├── car_model.dart           # Model data mobil
│   ├── payment_model.dart       # Model data pembayaran
│   └── user_model.dart          # Model data pengguna
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── booking/
│   │   ├── booking_form_screen.dart     # Form buat pesanan baru
│   │   └── booking_list_screen.dart     # Daftar pesanan (user & admin)
│   ├── car/
│   │   ├── car_list_screen.dart         # Daftar mobil tersedia
│   │   └── car_form_screen.dart         # Form tambah/edit mobil (admin)
│   ├── payment/
│   │   ├── payment_form_screen.dart           # Form pembayaran user
│   │   └── payment_verification_screen.dart   # Verifikasi pembayaran admin
│   └── main_navigation_screen.dart      # Bottom navigation utama
├── services/
│   ├── auth_service.dart        # Login, register, token management
│   ├── booking_service.dart     # CRUD booking & konfirmasi
│   ├── car_service.dart         # CRUD data mobil
│   └── payment_service.dart     # Pembayaran & verifikasi
└── widgets/
    ├── car_card.dart            # Komponen kartu mobil
    ├── custom_text_field.dart   # Input field kustom
    └── loading_indicator.dart   # Widget loading
```

---

## 🔌 API Reference

**Base URL:** `https://car-rental-api-silk.vercel.app`

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `POST` | `/api/auth/login` | Login pengguna |
| `POST` | `/api/auth/register` | Register pengguna baru |
| `GET` | `/api/cars` | Ambil daftar mobil |
| `GET` | `/api/bookings` | Ambil data booking |
| `POST` | `/api/bookings` | Buat booking baru |
| `PUT` | `/api/bookings/:id/confirm` | Konfirmasi booking (admin) |
| `PUT` | `/api/bookings/:id/cancel` | Batalkan booking |
| `GET` | `/api/payments` | Ambil semua data pembayaran |
| `POST` | `/api/payments` | Buat pembayaran baru |
| `PUT` | `/api/payments/:id/verify` | Verifikasi pembayaran (admin) |

> Semua endpoint (kecuali auth) membutuhkan **Bearer Token** di header Authorization.

---

## 🔄 Alur Penggunaan

```
USER                              ADMIN
 │                                  │
 ├─ Register / Login                ├─ Login sebagai Admin
 ├─ Lihat Daftar Mobil              │
 ├─ Isi Form Pemesanan              │
 ├─ Submit Booking ──────────────► Konfirmasi / Tolak Booking
 ├─ Lakukan Pembayaran              │
 └─ Kirim Pembayaran ────────────► Verifikasi (Approve / Reject)
```

---

## ⚙️ Cara Menjalankan

**1. Clone repository**
```bash
git clone https://github.com/Nafzzuwu/CarRental-WithAPI.git
cd CarRental-WithAPI
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Jalankan aplikasi**
```bash
flutter run
```

> Pastikan sudah terhubung ke emulator atau perangkat fisik.

---

## 🛠️ Tech Stack

| Teknologi | Keterangan |
|-----------|------------|
| Flutter | Framework UI mobile |
| Dart | Bahasa pemrograman |
| REST API | Backend Car Rental |
| `http` | HTTP client untuk komunikasi API |
| `intl` | Format tanggal & angka |
| `shared_preferences` | Penyimpanan token lokal |
