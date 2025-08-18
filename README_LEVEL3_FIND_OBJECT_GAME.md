# Level 3 Find Object Game

## Deskripsi
Game level 3 "Temukan Benda yang Dibutuhkan" adalah permainan edukatif untuk anak-anak berusia di bawah 6 tahun yang bertujuan untuk melatih kemampuan mengenali benda berdasarkan kosakata bahasa Mandarin (Hanzi, Pinyin, atau Audio).

## Fitur Utama

### 1. **Sistem Soal (7 Soal)**
- **Hanzi**: Menampilkan karakter Mandarin
- **Pinyin**: Menampilkan transliterasi Latin
- **Audio**: Tombol untuk mendengar pengucapan

### 2. **Area Permainan**
- Background menggunakan `assets/images/level3_bg.jpg`
- 10 gambar benda tersebar secara **random natural** (tidak menumpuk seluruhnya)
- 7 gambar merupakan jawaban dari soal
- 3 gambar tambahan sebagai distraktor
- **Random positioning dengan minimum distance** untuk distribusi yang natural

### 3. **Sistem Life**
- 4 life menggunakan gambar `assets/images/heart.png`
- Life berkurang setiap jawaban salah
- Game over saat life habis

### 4. **Sistem Skor**
- Format: "X/7" (jawaban benar / total soal)
- Ditampilkan dengan ikon bintang

### 5. **Sound Effects**
- `correct_answer.mp3` untuk jawaban benar
- `wrong_answer.mp3` untuk jawaban salah
- `applause.mp3` untuk completion

### 6. **Sistem Indikator Jawaban**
- **Jawaban Benar**: Gambar langsung hilang + sound effect
- **Jawaban Salah**: Cross merah muncul **di tengah gambar** selama 1 detik + sound effect + life berkurang
- **Tidak ada indikator hijau** untuk jawaban yang benar

## Cara Kerja Permainan

1. **Loading**: Game memuat materi dari Firebase Firestore level 3
2. **Setup**: Membuat 10 game object dengan posisi **random natural**
3. **Soal**: Menampilkan soal secara random (Hanzi/Pinyin/Audio)
4. **Jawaban**: User mencari dan menekan gambar yang sesuai
5. **Feedback**: 
   - **Benar**: Gambar hilang + sound effect
   - **Salah**: Cross merah **di tengah gambar** 1 detik + sound effect + life berkurang
6. **Progress**: Lanjut ke soal berikutnya atau game over

## Struktur Kode

### BLOC Pattern
- **Level3FindObjectBloc**: Logic utama game dengan **natural random positioning algorithm**
- **Level3FindObjectEvent**: Event handling
- **Level3FindObjectState**: State management

### File Utama
- `level3_find_object_game_page.dart`: UI utama game
- `level3_find_object_bloc.dart`: Business logic dengan **natural random positioning**
- `level3_find_object_event.dart`: Event definitions
- `level3_find_object_state.dart`: State definitions

### Integrasi
- Terintegrasi dengan `sub_level_page.dart`
- **Tidak menggunakan game loading page** (gambar langsung dari materi data)
- Menggunakan `AudioManager` untuk sound effects

## Data Materi

Game menggunakan data dari Firebase Firestore dengan struktur:
```json
{
  "arti": "Cabe",
  "gambarBase64": "String Image",
  "kosakata": "辣椒",
  "level": 3
}
```

### **PENTING: Gambar Diambil dari Firestore, BUKAN Firebase Storage**
- Gambar disimpan sebagai `gambarBase64` dalam document materi
- Tidak perlu Firebase Storage service
- Gambar langsung di-decode dari base64 string
- Lebih cepat dan efisien

## UI/UX Features

### Animasi
- **Fade In**: Transisi smooth untuk elemen UI
- **Bounce**: Feedback saat interaksi
- **Timer-based**: Cross merah hilang otomatis setelah 1 detik

### Visual Design
- **Background**: Gradient orange kekuningan (seperti color_matching_game)
- **Container Design**: 
  - **Score Card**: Gradient pink tanpa border, tulisan putih
  - **Life Display**: Gradient kuning cerah tanpa border (seperti counting_game bagian pilih buah)
  - **Question Area**: Gradient blue dengan border dan shadow blue, tulisan putih
- **Gambar Game**: Tanpa bayangan untuk tampilan yang lebih clean
- Warna yang cocok untuk anak-anak (pink, kuning cerah, blue)
- **Indikator Jawaban**:
  - ✅ **Benar**: Gambar langsung hilang
  - ❌ **Salah**: Cross merah **di tengah gambar** dengan background merah transparan

### Responsive Layout
- Menggunakan `MediaQuery` untuk ukuran layar
- `SingleChildScrollView` untuk konten yang panjang
- `SafeArea` untuk kompatibilitas device

## Navigasi

- **Tombol Kembali**: Kembali ke `sub_level_page.dart`
- **Game Over**: Muncul saat life habis
- **Completion**: Muncul saat semua soal terjawab

## Dependencies

- `flutter_bloc`: State management
- `flutter_tts`: Text-to-speech untuk audio
- `pinyin`: Konversi Hanzi ke Pinyin
- `AudioManager`: Manajemen audio
- `dart:async`: Timer untuk indikator jawaban salah
- `dart:convert`: Untuk decode base64 images
- `dart:math`: Untuk positioning algorithm dan distance calculation

## Cara Menjalankan

1. Pastikan semua dependencies terinstall
2. Tambahkan `level3_bg.jpg` ke `assets/images/`
3. Jalankan `flutter pub get`
4. Akses melalui level 3 di sub level page

## Troubleshooting Gambar

### Jika gambar tidak muncul:
1. **Periksa console log** untuk debug info
2. **Pastikan data materi memiliki field `gambarBase64`**
3. **Verifikasi format base64** dalam Firestore
4. **Periksa koneksi internet** untuk akses Firestore

### Debug Info yang Ditampilkan:
- Jumlah materi yang dimuat
- ID dan kosakata setiap materi
- Konfirmasi bahwa gambar tersedia dalam data materi

## Catatan Penting

- Game memerlukan koneksi internet untuk akses Firestore
- Background image harus tersedia di assets
- Audio files harus tersedia di assets/audio
- Game terintegrasi dengan sistem level yang ada
- **Gambar diambil langsung dari data materi Firestore (gambarBase64)**
- Life display tanpa icon favorite (hanya gambar heart)
- **Indikator jawaban salah otomatis hilang setelah 1 detik**
- **Gambar tersebar secara random natural dengan minimum distance**

## Perubahan Terbaru

### ✅ **Yang Sudah Diperbaiki:**
- Background diubah menjadi orange kekuningan
- Icon favorite dihapus dari area life
- **Sistem gambar diperbaiki**: Menggunakan gambarBase64 dari Firestore
- **Tidak lagi menggunakan Firebase Storage**
- Debug logging ditambahkan untuk troubleshooting
- Error handling untuk loading gambar
- **Sistem indikator jawaban diperbaiki**:
  - Gambar langsung hilang jika jawaban benar
  - Cross merah muncul **di tengah gambar** selama 1 detik untuk jawaban salah
  - Tidak ada indikator hijau untuk jawaban benar
  - Timer otomatis untuk menghilangkan cross merah
- **Sistem positioning gambar diperbaiki**:
  - Gambar tersebar secara random natural
  - Menggunakan completely random positioning dengan minimum distance
  - Minimum distance 60px untuk mencegah overlap berlebihan
  - Pemanfaatan area permainan yang natural dan tidak terlalu rapi
- **Visual improvements**:
  - Bayangan pada gambar game dihapus untuk tampilan yang lebih clean
  - Background container diubah dari putih ke gradient yang menarik (seperti counting_game)
  - Score card menggunakan gradient pink tanpa border, tulisan putih
  - Life display menggunakan gradient kuning cerah tanpa border (seperti counting_game bagian pilih buah)
  - Question area menggunakan gradient blue dengan border dan shadow, tulisan putih
- **Game loading dihilangkan**: Tidak perlu loading page karena gambar langsung dari materi data

### 🔧 **Yang Perlu Diperhatikan:**
- Pastikan data materi di Firestore memiliki field `gambarBase64`
- Periksa console log untuk debug info
- Verifikasi materi di Firestore level 3
- Timer indikator jawaban salah menggunakan `dart:async`
- **Gambar di-decode dari base64 string, bukan dari URL**
- **Positioning algorithm menggunakan completely random dengan minimum distance 60px**

## Sistem Indikator Jawaban

### Jawaban Benar ✅
- Gambar langsung hilang dari area permainan
- Sound effect `correct_answer.mp3` diputar
- Skor bertambah
- Lanjut ke soal berikutnya

### Jawaban Salah ❌
- Cross merah **di tengah gambar** dengan background merah transparan muncul
- Sound effect `wrong_answer.mp3` diputar
- Life berkurang 1
- Cross merah otomatis hilang setelah 1 detik
- Game over jika life habis

### Keuntungan Sistem Baru
- **Lebih clean**: Tidak ada indikator hijau yang mengganggu
- **Feedback jelas**: Cross merah **di tengah gambar** memberikan feedback visual yang jelas
- **Otomatis**: Tidak perlu manual menghilangkan indikator
- **User experience**: Lebih smooth dan intuitif
- **Positioning natural**: Gambar tersebar secara random dengan clustering natural

## Sistem Gambar yang Diperbaiki

### Sebelum (Firebase Storage):
- ❌ Mencoba mengambil gambar dari Firebase Storage
- ❌ Perlu URL dan caching
- ❌ Lebih lambat dan kompleks
- ❌ Bisa gagal jika Storage tidak tersedia
- ❌ Gambar berdekatan dan tidak tersebar dengan baik

### Sesudah (Firestore gambarBase64):
- ✅ Gambar langsung dari data materi
- ✅ Tidak perlu Firebase Storage service
- ✅ Lebih cepat dan efisien
- ✅ Lebih reliable dan sederhana
- ✅ Gambar langsung di-decode dari base64
- ✅ **Natural random positioning algorithm** untuk distribusi natural
- ✅ **Completely random approach** dengan minimum distance
- ✅ **Minimum distance enforcement** (60px) untuk mencegah overlap berlebihan

## Natural Random Positioning Algorithm

### Fitur Utama:
1. **Completely Random Distribution**: Posisi gambar benar-benar random di seluruh area permainan
2. **Natural Clustering**: Memungkinkan beberapa gambar berdekatan untuk efek natural
3. **Distance Enforcement**: Memastikan minimum distance 60px antar gambar untuk mencegah overlap berlebihan
4. **Boundary Checking**: Memastikan gambar tidak keluar dari area permainan
5. **Fallback System**: Jika posisi terlalu dekat setelah 15 attempts, gambar tetap ditempatkan

### Parameter:
- **Game Area**: 300x400 pixels
- **Image Size**: 80x80 pixels
- **Minimum Distance**: 60 pixels (reduced untuk natural clustering)
- **Max Attempts**: 15 attempts untuk mencari posisi yang tidak overlap
- **Randomness**: 100% random tanpa grid constraint

### Keuntungan:
- ✅ Posisi gambar benar-benar random dan natural
- ✅ Memungkinkan clustering natural (beberapa gambar berdekatan)
- ✅ Tidak ada alignment yang terlalu rapi atau kaku
- ✅ Visual yang lebih natural dan menarik
- ✅ User experience yang lebih challenging dan realistic
