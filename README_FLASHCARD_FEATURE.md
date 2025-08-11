# Flashcard Feature - Fitur Kartu Belajar Interaktif

## Deskripsi
Fitur Flashcard adalah pengembangan dari halaman kosa kata yang mengubah tampilan list menjadi kartu belajar interaktif. Setiap kartu dapat dibalik untuk menampilkan informasi yang berbeda di bagian depan dan belakang, dilengkapi dengan fitur text-to-speech untuk pengucapan Hanzi.

## Fitur Utama

### 1. Flashcard Interaktif
- **Bagian Depan**: Menampilkan gambar kosa kata di tengah dan arti bahasa Indonesia
- **Bagian Belakang**: Menampilkan gambar yang sama, Hanzi (karakter Mandarin), dan tombol volume untuk pengucapan
- **Animasi Flip**: Animasi 3D yang smooth saat membalik kartu
- **Tap to Flip**: Tap kartu untuk membalik dari depan ke belakang atau sebaliknya

### 2. Navigasi Geser
- **Swipe Gesture**: Geser ke kiri/kanan untuk pindah ke kartu berikutnya/sebelumnya
- **Circular Navigation**: Dapat berputar dari kartu terakhir ke kartu pertama dan sebaliknya
- **Tombol Navigasi**: Tombol panah kiri/kanan untuk navigasi manual
- **Progress Indicator**: Menampilkan posisi kartu saat ini (misal: 3 dari 10)

### 3. Text-to-Speech
- **Pengucapan Hanzi**: Tombol volume untuk mendengarkan pengucapan karakter Mandarin
- **Visual Feedback**: Icon volume berubah saat sedang berbicara
- **Error Handling**: Fallback jika text-to-speech gagal

### 4. UI/UX yang Menarik
- **Gradient Colors**: Gradient orange untuk bagian depan dan belakang
- **Clean Images**: Gambar tanpa background putih, menggunakan BoxFit.contain
- **Pinyin Display**: Menampilkan pinyin dengan tanda baca di bagian belakang kartu
- **Shadow Effects**: Shadow yang memberikan kesan 3D pada kartu
- **Responsive Design**: Tampilan yang menyesuaikan ukuran layar
- **Child-Friendly**: Desain yang cocok untuk anak-anak dengan warna-warna cerah

## Struktur Kode

### 1. Flashcard Widget
```
lib/presentation/widgets/
└── flashcard_widget.dart    # Widget flashcard yang dapat dibalik
```

### 2. Updated Vocabulary Page
```
lib/presentation/pages/child/
└── vocabulary_page.dart     # Halaman vocabulary dengan flashcard view
```

### 3. Dependencies
```
pubspec.yaml
├── flutter_tts: ^3.8.5      # Library untuk text-to-speech
├── pinyin: ^3.0.1           # Library untuk konversi Hanzi ke Pinyin
└── flutter (existing)       # Framework Flutter
```

## Cara Kerja

### 1. Flashcard Widget
```dart
class FlashcardWidget extends StatefulWidget {
  final dynamic materi;      // Data kosa kata
  final int index;          // Index kartu
  final int totalCards;     // Total kartu
}
```

**Animasi Flip:**
- Menggunakan `AnimationController` untuk mengontrol animasi
- `Transform.rotateY()` untuk efek 3D flip
- Duration 600ms dengan curve `Curves.easeInOut`

**Text-to-Speech:**
- Menggunakan library `flutter_tts`
- Async function untuk pengucapan
- State management untuk visual feedback
- Support untuk bahasa Mandarin (zh-CN)
- Menggunakan hanzi untuk pengucapan

**Pinyin Support:**
- Menggunakan library `pinyin`
- Konversi otomatis dari Hanzi ke Pinyin
- Menampilkan pinyin dengan tanda baca
- Fallback ke Hanzi jika konversi gagal

### 2. Navigation System
```dart
class _VocabularyPageState extends State<VocabularyPage> {
  late PageController _pageController;
  int _currentIndex = 0;
}
```

**Swipe Detection:**
- `GestureDetector` dengan `onHorizontalDragEnd`
- `PageView.builder` untuk smooth scrolling
- Circular navigation dengan wrap-around

### 3. State Management
- Tetap menggunakan BLoC pattern yang sudah ada
- Tidak ada perubahan pada state management
- Hanya mengubah UI presentation

## Fitur Detail

### 1. Bagian Depan Kartu
- **Gradient**: Orange gradient (300, 500, 700)
- **Gambar**: 200x200 pixel tanpa background putih, menggunakan BoxFit.contain
- **Arti**: Font size 28, bold, dengan shadow
- **Progress**: "X / Y" di bagian atas kartu

### 2. Bagian Belakang Kartu
- **Gradient**: Orange gradient (300, 500, 700) - sama dengan depan
- **Gambar**: 200x200 pixel tanpa background putih, menggunakan BoxFit.contain
- **Hanzi**: Font size 32, bold, dengan shadow
- **Volume Button**: 50x50 pixel, circular, dengan icon
- **Pinyin**: Font size 18, bold, dengan shadow dan tanda baca

### 3. Navigation Controls
- **Swipe Gesture**: Geser ke kiri/kanan untuk navigasi
- **Center Indicator**: "Geser untuk pindah kartu" dengan icon swipe
- **Progress Display**: "X / Y" di bagian atas kartu

## Penggunaan

### 1. Untuk Anak-Anak
1. Pilih level yang diinginkan
2. Tekan "Kosa Kata" di SubLevelPage
3. Lihat kartu dengan gambar dan arti
4. Tap kartu untuk melihat Hanzi
5. Tap tombol volume untuk mendengarkan pengucapan
6. Geser ke kiri/kanan untuk pindah kartu

### 2. Navigasi
- **Swipe Left**: Kartu berikutnya
- **Swipe Right**: Kartu sebelumnya
- **Circular**: Dari kartu terakhir ke pertama dan sebaliknya

## Technical Implementation

### 1. Animation Setup
```dart
void _setupAnimations() {
  _flipController = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );
  _flipAnimation = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(
    parent: _flipController,
    curve: Curves.easeInOut,
  ));
}
```

### 2. Text-to-Speech Setup
```dart
void _setupTextToSpeech() {
  _flutterTts = FlutterTts();
  _initTts();
}

Future<void> _initTts() async {
  await _flutterTts.setLanguage("zh-CN"); // Chinese Mandarin
  await _flutterTts.setSpeechRate(0.5); // Slower speech rate
  await _flutterTts.setVolume(1.0);
  await _flutterTts.setPitch(1.0);
}

String _getPinyin(String hanzi) {
  try {
    return PinyinHelper.getPinyinE(hanzi, defPinyin: '', format: PinyinFormat.WITH_TONE_MARK);
  } catch (e) {
    return hanzi; // Fallback ke hanzi jika pinyin gagal
  }
}

Future<void> _speakHanzi() async {
  if (_isSpeaking) return;
  setState(() { _isSpeaking = true; });
  
  try {
    // Menggunakan hanzi untuk pengucapan
    await _flutterTts.speak(widget.materi.kosakata);
  } catch (e) {
    print('Error speaking: $e');
  } finally {
    setState(() { _isSpeaking = false; });
  }
}
```

### 3. Page Navigation
```dart
void _goToNextCard() {
  if (_currentIndex < _getMateriList().length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    // Wrap to first card
    _pageController.animateToPage(0, ...);
  }
}
```

## Error Handling

### 1. Text-to-Speech Errors
- Try-catch block untuk menangani error
- Visual feedback dengan state `_isSpeaking`
- Fallback jika library tidak tersedia

### 2. Image Loading Errors
- `errorBuilder` untuk gambar yang gagal dimuat
- Placeholder icon untuk gambar yang tidak valid
- Graceful degradation

### 3. Navigation Errors
- Null safety untuk `primaryVelocity`
- Bounds checking untuk index
- Safe navigation dengan PageController

## Performance Considerations

### 1. Memory Management
- Proper disposal of `AnimationController`
- Proper disposal of `PageController`
- Efficient image loading dengan `Image.memory`

### 2. Animation Performance
- Hardware acceleration enabled
- Smooth 60fps animations
- Optimized transform calculations

### 3. Text-to-Speech
- Async operations untuk tidak blocking UI
- State management untuk visual feedback
- Error handling untuk stability

## Future Enhancements

### 1. Audio Features
- **Pinyin Pronunciation**: Pengucapan yang lebih akurat dengan pinyin
- **Multiple Languages**: Support untuk berbagai bahasa
- **Audio Files**: Pre-recorded audio untuk pengucapan yang lebih natural

### 2. Interactive Features
- **Progress Tracking**: Menyimpan progress pembelajaran
- **Favorites**: Mark kartu favorit
- **Quiz Mode**: Mode kuis dengan flashcard

### 3. UI Improvements
- **Custom Animations**: Animasi yang lebih menarik
- **Sound Effects**: Efek suara saat flip dan navigate
- **Haptic Feedback**: Vibrasi saat interaksi

### 4. Accessibility
- **Screen Reader Support**: Support untuk screen reader
- **Voice Commands**: Navigasi dengan suara
- **High Contrast Mode**: Mode kontras tinggi

## Keunggulan

1. **Interactive Learning**: Pembelajaran yang interaktif dan menyenangkan
2. **Visual Appeal**: Desain yang menarik untuk anak-anak
3. **Audio Support**: Pengucapan yang membantu pembelajaran
4. **Smooth Navigation**: Navigasi yang smooth dan intuitif
5. **Responsive Design**: Tampilan yang responsif di berbagai device
6. **Error Handling**: Penanganan error yang robust
7. **Performance**: Performa yang optimal dengan animasi smooth 