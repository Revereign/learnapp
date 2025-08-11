# Implementasi Halaman Choose Level

## Overview
Halaman Choose Level telah berhasil dibuat untuk aplikasi pembelajaran bahasa Mandarin anak-anak. Halaman ini memungkinkan anak-anak untuk memilih level pembelajaran yang sesuai dengan kemampuan mereka.

## Fitur yang Diimplementasikan

### 1. Level Bloc (State Management)
- **File**: `lib/presentation/blocs/child/level/`
  - `level_bloc.dart` - Bloc utama untuk mengelola state level
  - `level_event.dart` - Event untuk load dan select level
  - `level_state.dart` - State untuk loading, loaded, error, dan selected

### 2. Halaman Choose Level
- **File**: `lib/presentation/pages/child/choose_level.dart`
- **Fitur**:
  - UI yang menarik dan sesuai untuk anak-anak
  - Animasi fade-in saat halaman dimuat
  - Background image dari Firebase Storage
  - Background music (BGM) dari Firebase Storage
  - Grid layout untuk menampilkan level
  - Setiap level card memiliki:
    - Nomor level dengan lingkaran
    - Judul level
    - Deskripsi level
    - Jumlah materi dalam level
    - Warna yang berbeda untuk setiap level
    - Efek gradient dan shadow
  - Tombol back yang animatif
  - Dialog untuk level yang terkunci
  - Sound effect saat tombol ditekan

### 3. Data Sample
- **File**: `lib/core/utils/sample_data.dart`
- **Konten**: 23 materi sample dalam 5 level:
  - **Level 1**: Kosakata Dasar - Angka dan Warna (6 materi)
  - **Level 2**: Keluarga dan Binatang (5 materi)
  - **Level 3**: Makanan dan Minuman (4 materi)
  - **Level 4**: Bagian Tubuh dan Pakaian (4 materi)
  - **Level 5**: Transportasi dan Tempat (4 materi)

### 4. Halaman Admin untuk Data Management
- **File**: `lib/presentation/pages/admin/add_sample_data_page.dart`
- **Fitur**:
  - Menambahkan data sample ke Firebase
  - Menghapus semua data dari Firebase
  - Progress indicator saat proses berlangsung
  - Status feedback untuk user
  - Konfirmasi dialog untuk operasi berbahaya

### 5. Routing System
- **File**: `lib/core/routes/app_routes.dart`
- **Routes yang ditambahkan**:
  - `/choose-level` - Halaman pilih level
  - `/add-sample-data` - Halaman admin untuk tambah data sample

## Integrasi dengan Firebase

### 1. Firestore
- Collection: `materi`
- Fields: `id`, `kosakata`, `arti`, `level`, `gambarBase64`, `createdAt`
- Struktur data sesuai dengan entity `Materi`

### 2. Firebase Storage
- Folder: `choose_level/`
  - `background.jpg` - Background image untuk halaman
  - `level_bgm.mp3` - Background music

### 3. Bloc Integration
- `LevelBloc` menggunakan `GetAllMateri` usecase
- Terintegrasi dengan `MateriRepositoryImpl` dan `MateriRemoteDataSourceImpl`
- Data diambil dari Firestore dan dikelompokkan berdasarkan level

## Cara Penggunaan

### 1. Menjalankan Aplikasi
```bash
flutter pub get
flutter run
```

### 2. Menambahkan Data Sample (Admin)
1. Login sebagai admin
2. Navigate ke halaman "Tambah Data Sample"
3. Klik tombol "Tambah Data Sample"
4. Tunggu hingga proses selesai

### 3. Testing Halaman Choose Level
1. Login sebagai child user
2. Dari main menu, tekan tombol "Play"
3. Halaman Choose Level akan terbuka
4. Pilih level yang diinginkan

## Struktur File yang Dibuat

```
lib/
├── core/
│   ├── routes/
│   │   └── app_routes.dart
│   └── utils/
│       └── sample_data.dart
├── presentation/
│   ├── blocs/
│   │   └── child/
│   │       └── level/
│   │           ├── level_bloc.dart
│   │           ├── level_event.dart
│   │           └── level_state.dart
│   └── pages/
│       ├── child/
│       │   └── choose_level.dart
│       └── admin/
│           └── add_sample_data_page.dart
```

## Fitur Gamifikasi

### 1. Visual Design
- Warna-warna cerah dan menarik untuk anak-anak
- Animasi smooth dan responsif
- Icon dan elemen visual yang friendly

### 2. Audio Experience
- Background music yang menyenangkan
- Sound effect saat interaksi
- Volume yang sesuai untuk anak-anak

### 3. Progress System
- Level unlocking system (siap untuk diimplementasikan)
- Visual feedback untuk level yang terkunci
- Progress indicator untuk setiap level

## Next Steps

### 1. Implementasi Level Unlocking
- Integrasi dengan user progress
- Sistem achievement
- Reward system

### 2. Halaman Level Detail
- Implementasi halaman pembelajaran per level
- Quiz dan games
- Progress tracking

### 3. Audio Content
- Upload audio files ke Firebase Storage
- Implementasi pronunciation guide
- Interactive audio lessons

### 4. Parent Dashboard Integration
- Progress monitoring untuk orang tua
- Report dan analytics
- Customization options

## Dependencies yang Digunakan

- `flutter_bloc` - State management
- `equatable` - Value equality
- `audioplayers` - Audio playback
- `firebase_storage` - File storage
- `cloud_firestore` - Database
- `lottie` - Animations
- `flutter_animate` - UI animations

## Testing

### Manual Testing Checklist
- [ ] Halaman Choose Level dapat diakses dari Main Menu
- [ ] Data level ditampilkan dengan benar
- [ ] Animasi berjalan smooth
- [ ] Audio berfungsi dengan baik
- [ ] Tombol back berfungsi
- [ ] Dialog level terkunci muncul
- [ ] Data sample dapat ditambahkan via admin page
- [ ] Error handling berfungsi

### Unit Testing (Future)
- LevelBloc testing
- Repository testing
- Usecase testing

## Troubleshooting

### Common Issues
1. **Audio tidak berfungsi**: Pastikan file audio ada di Firebase Storage
2. **Data tidak muncul**: Pastikan data sample sudah ditambahkan
3. **Routing error**: Pastikan semua route sudah didefinisikan di app_routes.dart

### Debug Tips
- Gunakan `debugPrint` untuk tracking state changes
- Monitor Firebase console untuk data changes
- Check network connectivity untuk Firebase operations 