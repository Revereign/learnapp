# Game "Jadikan Sempurna" - Level 4

## Deskripsi Game
Game "Jadikan Sempurna" adalah game edukatif untuk level 4 yang menggabungkan dua jenis soal:
1. **Soal Membaca**: User harus mengucapkan arti dari Hanzi yang ditampilkan
2. **Soal Goresan**: User harus menulis Hanzi dengan urutan goresan yang benar

Game ini menggunakan animasi pertumbuhan tanaman sebagai reward visual. Setiap jawaban benar akan membuat tanaman tumbuh ke tahap berikutnya.

## Fitur Utama

### 🎯 **Sistem Soal**
- **Total Soal**: 8 soal (campuran membaca dan goresan)
- **Randomisasi**: Soal diacak secara random dari materi level 4
- **Campuran**: Soal membaca dan goresan muncul secara bergantian

### 🌱 **Animasi Tanaman**
- **5 Tahap Pertumbuhan**: Dari benih hingga tanaman sempurna
- **Progress Visual**: Tanaman tumbuh sesuai skor user
- **Lottie Animation**: Menggunakan `plant.json` untuk animasi yang smooth

### 📚 **Soal Membaca**
- **Implementasi**: Menggunakan fitur dari `latihan_membaca_page.dart`
- **Speech Recognition**: User mengucapkan arti dari Hanzi
- **Kesempatan**: 2x salah sebelum soal dianggap salah
- **Feedback**: Menampilkan teks yang diucapkan user

### ✍️ **Soal Goresan**
- **Implementasi**: Menggunakan fitur dari `latihan_goresan_page.dart`
- **Stroke Order**: User menulis Hanzi dengan urutan goresan yang benar
- **Kesempatan**: 3x salah sebelum soal dianggap salah
- **Karakter Terpisah**: Jika materi berisi 2+ Hanzi, ambil 1 karakter saja

### 🎮 **Game Flow**
1. **Start**: Tanaman kosong (tahap 0)
2. **Soal 1-5**: Tanaman tumbuh bertahap (tahap 1-5)
3. **Soal 6-8**: Tanaman tetap sempurna, hanya scoring
4. **Finish**: Pop-up sukses/gagal dengan skor

## Struktur File

### 📁 **BLOC Files**
- `lib/presentation/blocs/game/jadikan_sempurna_bloc.dart`
  - `JadikanSempurnaEvent`: Events untuk game
  - `JadikanSempurnaState`: States untuk game
  - `JadikanSempurnaBloc`: Logic utama game

### 📱 **UI Files**
- `lib/presentation/pages/child/jadikan_sempurna_game_page.dart`
  - Halaman utama game
  - Integrasi soal membaca dan goresan
  - Animasi tanaman dan UI

### 🛣️ **Routes**
- `lib/core/routes/app_routes.dart`
  - Route `/jadikan-sempurna` untuk game

### ⚙️ **Configuration**
- `lib/main.dart`: BLOC provider untuk `JadikanSempurnaBloc`
- `pubspec.yaml`: Asset `plant.json` dan dependencies

## Implementasi Teknis

### 🔄 **State Management**
```dart
class JadikanSempurnaLoaded extends JadikanSempurnaState {
  final List<JadikanSempurnaQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final int plantGrowthStage;
  final bool isGameCompleted;
  // ... other properties
}
```

### 🎯 **Question Types**
```dart
enum QuestionType { reading, strokeOrder }

class JadikanSempurnaQuestion {
  final Materi materi;
  final QuestionType type;
  final String? selectedCharacter; // For stroke order questions
}
```

### 🌱 **Plant Growth Logic**
```dart
// Calculate plant growth stage based on score
final newPlantStage = (newScore * 5 / 8).floor(); // 5 stages for 8 questions
```

### 🎵 **Audio Management**
- BGM dihentikan saat masuk game
- Sound effects untuk jawaban benar/salah
- BGM dilanjutkan saat kembali ke sub_level_page

## Integrasi dengan Existing Features

### 📖 **Soal Membaca**
- **Reuse**: Menggunakan implementasi dari `latihan_membaca_page.dart`
- **Speech Recognition**: `speech_to_text` library
- **Pronunciation Check**: Simple string matching

### ✍️ **Soal Goresan**
- **Reuse**: Menggunakan implementasi dari `latihan_goresan_page.dart`
- **Stroke Order**: `stroke_order_animator` library
- **Quiz Mode**: Integrated stroke order testing

### 🎨 **UI Consistency**
- **Colors**: Mengikuti tema game sebelumnya
- **Layout**: Responsive design untuk anak-anak
- **Animations**: Smooth transitions dan feedback

## Cara Penggunaan

### 🚀 **Memulai Game**
1. User memilih level 4 di `choose_level.dart`
2. User masuk ke `sub_level_page.dart`
3. User menekan tombol "Mari Bermain"
4. Game "Jadikan Sempurna" dimulai

### 🎮 **Gameplay**
1. **Soal Membaca**:
   - Tampil Hanzi, gambar, dan arti
   - User tekan mikrofon dan ucapkan arti
   - Sistem cek pronunciation
   - Jika benar: tanaman tumbuh, lanjut soal berikutnya

2. **Soal Goresan**:
   - Tampil Hanzi, gambar, dan arti
   - User tekan "Mulai Tes Goresan"
   - User tulis Hanzi dengan urutan goresan benar
   - Jika benar: tanaman tumbuh, lanjut soal berikutnya

### 🏁 **Game Over**
- **Sukses**: Tanaman tumbuh sempurna (5 tahap)
- **Gagal**: Tanaman belum sempurna setelah 8 soal
- **Pop-up**: Menampilkan skor dan tombol kembali

## Dependencies

### 📦 **Required Packages**
```yaml
dependencies:
  lottie: ^3.2.0
  speech_to_text: ^6.6.0
  stroke_order_animator: ^3.3.1
  http: ^1.1.0
  flutter_bloc: ^9.1.0
```

### 🎨 **Assets**
```
assets/animations/plant.json  # Lottie animation untuk tanaman
```

## Troubleshooting

### ❌ **Common Issues**
1. **Plant Animation Not Working**
   - Pastikan `plant.json` ada di `assets/animations/`
   - Check Lottie dependency version

2. **Speech Recognition Error**
   - Pastikan permission microphone di Android
   - Check `speech_to_text` initialization

3. **Stroke Order Not Loading**
   - Check internet connection
   - Verify API endpoint availability

### 🔧 **Debug Tips**
- Gunakan `flutter analyze` untuk check errors
- Test di device fisik untuk speech recognition
- Monitor console untuk API responses

## Future Enhancements

### 🚀 **Potential Improvements**
1. **More Animations**: Tambah variasi animasi tanaman
2. **Sound Effects**: Tambah sound untuk setiap tahap pertumbuhan
3. **Progress Saving**: Simpan progress user
4. **Difficulty Levels**: Tambah tingkat kesulitan
5. **Achievement System**: Badge dan rewards

## Conclusion

Game "Jadikan Sempurna" berhasil mengintegrasikan fitur membaca dan goresan dari halaman latihan yang sudah ada, dengan tambahan animasi tanaman yang menarik. Game ini memberikan motivasi visual yang kuat untuk anak-anak belajar Hanzi dengan cara yang menyenangkan dan interaktif.

Game ini menggunakan BLOC pattern yang konsisten dengan game lainnya, dan mengikuti standar UI/UX yang sudah ditetapkan untuk aplikasi LearnApp.
