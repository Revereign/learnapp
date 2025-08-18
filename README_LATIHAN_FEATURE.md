# Fitur Latihan - LearnApp

## Deskripsi
Fitur Latihan adalah halaman baru yang menggantikan tombol "Buat Kalimat" di `sub_level_page.dart`. Halaman ini menyediakan 3 jenis latihan yang berbeda untuk membantu pengguna memahami materi lebih dalam.

## Perubahan yang Dibuat

### 1. **Sub Level Page**
- **Sebelum**: Tombol "Buat Kalimat" dengan subtitle "Latihan membuat kalimat"
- **Sesudah**: Tombol "Latihan" dengan subtitle "Memahami lebih dalam"
- **Icon**: Berubah dari `Icons.edit_note` menjadi `Icons.school`
- **Route**: Berubah dari `/sentence` menjadi `/latihan`

### 2. **Halaman Baru: LatihanPage**
- **Lokasi**: `lib/presentation/pages/child/latihan_page.dart`
- **Background**: Gradient biru (blue.shade300, blue.shade500, blue.shade700)
- **Fitur**: 3 tombol latihan dengan warna yang berbeda

## Struktur Halaman Latihan

### **Header**
- Tombol back dengan icon `Icons.arrow_back_ios`
- Judul "Latihan Level X" (X = level yang dipilih)
- Background gradient biru

### **Description Box**
- Container transparan dengan border putih
- Teks: "Pilih jenis latihan yang ingin kamu lakukan untuk memahami materi lebih dalam"
- Styling dengan shadow dan opacity

### **3 Tombol Latihan**

#### **1. Latihan Membaca**
- **Icon**: `Icons.menu_book`
- **Warna**: Orange (Colors.orange)
- **Subtitle**: "Latihan membaca karakter"
- **Route**: `/latihan-membaca`

#### **2. Latihan Goresan**
- **Icon**: `Icons.edit`
- **Warna**: Teal (Colors.teal)
- **Subtitle**: "Latihan menulis karakter"
- **Route**: `/latihan-goresan`

#### **3. Buat Kalimat**
- **Icon**: `Icons.edit_note`
- **Warna**: Indigo (Colors.indigo)
- **Subtitle**: "Latihan membuat kalimat"
- **Route**: `/buat-kalimat`

## Fitur UI/UX

### **Animasi**
- **Fade In**: Transisi smooth saat halaman dibuka (1000ms)
- **Bounce**: Feedback saat tombol ditekan (200ms)
- **Staggered Animation**: Tombol muncul dengan delay bertahap (200ms, 400ms, 600ms)

### **Styling**
- **Gradient Background**: Linear gradient dari kiri atas ke kanan bawah
- **Button Design**: Mengikuti style yang sama dengan `sub_level_page.dart`
- **Shadow Effects**: Box shadow dengan opacity yang sesuai dengan warna tombol
- **Icon Container**: Background putih transparan dengan border radius

### **Responsive Design**
- `SingleChildScrollView` untuk konten yang panjang
- `SafeArea` untuk kompatibilitas device
- `MediaQuery` untuk ukuran layar yang responsif

## Integrasi dengan Sistem

### **Audio Management**
- **BGM**: **Tidak dihentikan** saat masuk ke halaman latihan (sesuai permintaan)
- **BGM**: Tetap menyala selama di halaman latihan
- **Pattern**: Berbeda dengan halaman lain untuk memberikan pengalaman yang lebih smooth

### **Navigation**
- **Back Button**: Kembali ke `sub_level_page.dart`
- **Route Handling**: Setiap tombol memiliki route yang unik
- **Level Passing**: Level yang dipilih diteruskan ke halaman latihan

## Warna yang Digunakan

### **Background**
- `Colors.blue.shade300` (Light Blue)
- `Colors.blue.shade500` (Medium Blue)
- `Colors.blue.shade700` (Dark Blue)

### **Tombol Latihan**
- **Latihan Membaca**: `Colors.orange` (Orange)
- **Latihan Goresan**: `Colors.teal` (Teal)
- **Buat Kalimat**: `Colors.indigo` (Indigo)

### **Kontras dengan sub_level_page.dart**
- **Sub Level Page**: Green, Purple, Red
- **Latihan Page**: Orange, Teal, Indigo
- **Tidak ada warna yang sama** untuk menghindari kebingungan

## File yang Dimodifikasi

### **1. sub_level_page.dart**
- Import `LatihanPage`
- Ubah tombol "Buat Kalimat" menjadi "Latihan"
- Tambah case `/latihan` di `_onButtonTap`
- Routing ke `LatihanPage`

### **2. latihan_page.dart** (Baru)
- Halaman lengkap dengan 3 tombol latihan
- Animasi dan styling yang konsisten
- Audio management yang proper

## Status Implementasi

### **✅ Sudah Selesai:**
- Halaman LatihanPage lengkap
- Routing dan navigation
- UI/UX dengan animasi
- Audio management (BGM)
- Styling yang konsisten
- **Halaman Latihan Membaca lengkap dengan fitur:**
  - ✅ Text-to-Speech (TTS) untuk pengucapan Hanzi
  - ✅ Speech-to-Text (STT) untuk pengenalan suara
  - ✅ Pengecekan pengucapan dengan feedback visual
  - ✅ Tampilan kosakata dari Firebase Firestore
  - ✅ Navigasi antar kosakata
  - ✅ UI yang menarik untuk anak-anak

### **🔧 TODO (Implementasi Selanjutnya):**
- ✅ **Halaman "Latihan Membaca"** (`/latihan-membaca`) - **SUDAH SELESAI**
- Halaman "Latihan Goresan" (`/latihan-goresan`)
- Halaman "Buat Kalimat" (`/buat-kalimat`)
- Logic untuk setiap jenis latihan

## Cara Penggunaan

1. **Akses**: Dari `sub_level_page.dart`, tekan tombol "Latihan"
2. **Pilih Latihan**: Pilih salah satu dari 3 jenis latihan
3. **Kembali**: Gunakan tombol back untuk kembali ke sub level page
4. **BGM**: **Tetap menyala** saat masuk ke halaman latihan (sesuai permintaan)

## Catatan Penting

- **BGM tetap menyala** di halaman latihan (sesuai permintaan)
- **Audio Management**: Berbeda dengan halaman lain - BGM tidak dihentikan saat masuk ke latihan
- **Warna berbeda** dengan sub_level_page.dart untuk menghindari kebingungan
- **Style konsisten** dengan halaman lain untuk user experience yang baik
- **Animasi smooth** untuk feedback visual yang menarik
- **Responsive design** untuk berbagai ukuran layar

## Dependencies

- `flutter/material.dart`: UI components
- `flutter_bloc/flutter_bloc.dart`: State management (untuk future use)
- `learnapp/core/services/audio_manager.dart`: Audio management

## Troubleshooting

### **Jika tombol tidak berfungsi:**
1. Periksa console log untuk debug info
2. Pastikan routing di `_onButtonTap` sudah benar
3. Verifikasi import `LatihanPage` sudah ditambahkan

### **Jika BGM tidak berfungsi:**
1. Periksa `AudioManager` initialization
2. Pastikan file audio tersedia di assets
3. Verifikasi pattern audio management sudah benar
