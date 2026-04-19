<div align="center">

<br/>

# 🌿 SayurKu

### *Segar Langsung ke Rumah*

Aplikasi mobile belanja sayuran segar yang menghubungkan pelanggan langsung dengan pengepul — tanpa perantara, tanpa ribet, tetap segar.

<br/>

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

<br/>

---

</div>

## 📖 Tentang SayurKu

Selama ini, sayuran yang dipanen petani harus melewati banyak lapisan perantara sebelum sampai ke tangan konsumen — membuat harga membengkak hingga dua kali lipat. Di sisi lain, pengepul masih mengandalkan WhatsApp dan catatan manual untuk menerima pesanan.

**SayurKu** hadir sebagai solusi digital yang memangkas rantai distribusi tersebut. Pelanggan dapat memesan sayuran segar langsung dari pengepul melalui satu aplikasi yang mudah, cepat, dan transparan.

> Dikembangkan sebagai proyek mata kuliah **Workshop** — Jurusan Teknologi Informasi, Politeknik Negeri Malang (2026).

<br/>

---

## ✨ Fitur Unggulan

<table>
  <tr>
    <td width="50%">

### 👤 Customer
- 🏠 Beranda dengan produk unggulan & promo
- 📦 Katalog produk dengan filter kategori
- 🔍 Detail produk & stok harian real-time
- 🛒 Keranjang belanja interaktif
- 💳 Checkout dengan COD & Transfer Bank
- 📋 Riwayat & pelacakan status pesanan
- 👛 Dompet digital & isi saldo
- 📍 Manajemen alamat pengiriman

    </td>
    <td width="50%">

### 🛠️ Admin (Pengepul)
- 📊 Dashboard rekap penjualan harian
- 🥦 Kelola produk (tambah, ubah, hapus)
- 📥 Notifikasi pesanan masuk real-time
- ✅ Verifikasi pembayaran transfer
- 🚚 Update status pengiriman pesanan
- 💰 Validasi permintaan top-up saldo
- 👤 Manajemen profil admin

    </td>
  </tr>
</table>

<br/>

---

## 🛠️ Teknologi

| Teknologi | Versi | Fungsi |
|:---:|:---:|:---|
| **Flutter** | 3.x | Framework utama pengembangan UI |
| **Dart** | 3.x | Bahasa pemrograman |
| **Firebase Auth** | ^5.0.0 | Autentikasi & manajemen pengguna |
| **Cloud Firestore** | ^5.0.0 | Database NoSQL real-time |
| **Firebase Storage** | latest | Penyimpanan foto produk |

<br/>

---

## 📁 Struktur Proyek

```
sayurku_kelompok6/
│
├── lib/
│   ├── core/                   # Konstanta global
│   │   ├── colors.dart         # Palet warna aplikasi
│   │   ├── text_styles.dart    # Tipografi global
│   │   └── constants.dart      # Konstanta umum
│   │
│   ├── models/                 # Struktur data
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   └── order_model.dart
│   │
│   ├── services/               # Logika Firebase
│   │   ├── auth_service.dart
│   │   ├── product_service.dart
│   │   ├── order_service.dart
│   │   └── wallet_service.dart
│   │
│   ├── widgets/                # Komponen UI reusable
│   │   ├── custom_button.dart
│   │   ├── custom_textfield.dart
│   │   └── product_card.dart
│   │
│   └── features/
│       ├── auth/               # Splash, Login, Register
│       ├── customer/
│       │   ├── shop/           # Beranda, Katalog, Detail, Keranjang, Checkout
│       │   └── profile/        # Profil, Dompet, Riwayat, Alamat
│       └── admin/              # Dashboard, Produk, Verifikasi
│
├── assets/
│   └── images/                 # Aset gambar lokal
│
└── pubspec.yaml
```

<br/>

---

## 🚀 Menjalankan Proyek

### Prasyarat

Pastikan perangkat kamu sudah memiliki:

- ✅ [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.x ke atas)
- ✅ [Android Studio](https://developer.android.com/studio) + emulator Android
- ✅ [Git](https://git-scm.com)
- ✅ Akun [Firebase](https://firebase.google.com) (untuk konfigurasi backend)

### Instalasi

**1. Clone repositori**
```bash
git clone https://github.com/Salim-amir/sayurku_kelompok6.git
cd sayurku_kelompok6
```

**2. Install semua dependensi**
```bash
flutter pub get
```

**3. Konfigurasi Firebase**
```
Letakkan file google-services.json ke dalam folder android/app/
```

**4. Jalankan aplikasi**
```bash
# Jalankan di emulator / HP
flutter run

# Jalankan di browser Chrome
flutter run -d chrome
```

<br/>

---

## 👥 Tim Pengembang

<div align="center">

| No | Nama | NIM | Peran |
|:---:|:---|:---:|:---|
| 1 | **Salim Amir** | 244107060085 | Lead & Authentication |
| 2 | **Liliyan Pramudita** | 244107060096 | Customer Alur Belanja |
| 3 | **Mohammad Febriansyah** | 244107060117 | Customer Transaksi & Profil |
| 4 | **Almafarel Akbar Remizard** | 244107060019 | Admin Dashboard |

</div>

<br/>

---

## 📸 Tampilan Aplikasi

<div align="center">

| Splash Screen | Home | Katalog |
|:---:|:---:|:---:|
| *soon* | *soon* | *soon* |

| Detail Produk | Keranjang | Checkout |
|:---:|:---:|:---:|
| *soon* | *soon* | *soon* |

</div>

<br/>

---

<div align="center">

**© 2026 — Kelompok 6**<br/>
Jurusan Teknologi Informasi · Politeknik Negeri Malang

</div>