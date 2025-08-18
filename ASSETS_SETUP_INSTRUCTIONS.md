# Setup Assets untuk Level 3 Game

## File yang Diperlukan

### 1. Background Image
**File**: `assets/images/level3_bg.jpg`
**Ukuran**: Disarankan 800x600 pixels atau lebih besar
**Deskripsi**: Background image untuk area permainan level 3
**Lokasi**: Tambahkan file ini ke folder `assets/images/`

### 2. Heart Image (Sudah Ada)
**File**: `assets/images/heart.png` ✅
**Status**: Sudah tersedia
**Penggunaan**: Untuk menampilkan life system

### 3. Audio Files (Sudah Ada)
- `assets/audio/correct_answer.mp3` ✅
- `assets/audio/wrong_answer.mp3` ✅  
- `assets/audio/applause.mp3` ✅
- `assets/audio/menu_bgm.mp3` ✅

## Cara Menambahkan Background Image

1. Siapkan file gambar dengan nama `level3_bg.jpg`
2. Pastikan ukuran gambar sesuai dengan layar (disarankan 800x600 atau lebih)
3. Copy file ke folder `assets/images/`
4. Pastikan file sudah ditambahkan ke `pubspec.yaml` (sudah ditambahkan)

## Rekomendasi Background Image

Untuk game level 3 "Temukan Benda yang Dibutuhkan", disarankan menggunakan background yang:
- Memiliki tema ruangan atau area yang familiar dengan anak-anak
- Tidak terlalu ramai agar tidak mengganggu gameplay
- Memiliki kontras yang baik dengan gambar benda
- Ukuran file tidak terlalu besar (max 2MB)

## Verifikasi Setup

Setelah menambahkan semua assets, jalankan:
```bash
flutter pub get
flutter clean
flutter run
```

Game level 3 akan tersedia di sub level page dan dapat diakses melalui tombol "Play" pada level 3.
