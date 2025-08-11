# Color Matching Game - Game Mencocokkan Warna Level 1

## Deskripsi
Color Matching Game adalah permainan interaktif untuk level 1 yang mengajarkan anak-anak tentang warna dalam bahasa Mandarin. Game ini menggunakan materi dari Firebase Firestore dan asset gambar dari Firebase Storage untuk menciptakan pengalaman belajar yang menyenangkan dan edukatif.

## Fitur Utama

### 1. Game Mencocokkan Warna
- **Soal Random**: Menampilkan soal dalam bentuk Hanzi, Pinyin, atau Audio secara acak
- **Grid Gambar**: 12 gambar warna yang dapat dipilih dalam format grid 3x4
- **Feedback Visual**: Indikator benar/salah dengan animasi dan warna
- **Progress Tracking**: Menampilkan skor dan progress permainan

### 2. Tipe Soal
- **Hanzi**: Menampilkan karakter Mandarin untuk warna
- **Pinyin**: Menampilkan pengucapan dengan tanda baca (tanpa arti bahasa Indonesia)
- **Audio**: Tombol untuk mendengarkan pengucapan

### 3. Mekanisme Permainan
- **Randomisasi Awal**: Soal dan urutan materi diacak hanya sekali di awal permainan
- **Urutan Konsisten**: Setelah randomisasi awal, urutan soal tetap konsisten
- **Eliminasi**: Gambar yang sudah benar akan hilang dengan animasi fade
- **Penyelesaian**: Game selesai ketika semua warna sudah dijawab benar
- **Skor**: Menghitung jumlah jawaban benar

### 4. UI/UX yang Menarik
- **Gradient Background**: Orange gradient yang menarik untuk anak-anak
- **Animasi**: Fade in/out dan bounce effects
- **Scrollable Layout**: Tampilan yang dapat di-scroll untuk menghindari terpotong
- **Visual Feedback**: Border hijau untuk benar, merah untuk salah
- **Loading State**: Indikator loading saat gambar sedang dimuat
- **Sound Effects**: Efek suara untuk feedback interaksi

## Struktur Kode

### 1. Game BLoC
```
lib/presentation/blocs/game/
├── game_bloc.dart      # Main BLoC untuk game logic
├── game_event.dart     # Events untuk game
└── game_state.dart     # States untuk game
```

### 2. Game Page
```
lib/presentation/pages/child/
└── color_matching_game_page.dart    # UI untuk game
```

### 3. Services
```
lib/data/services/
└── firebase_storage_service.dart    # Service untuk Firebase Storage
```

### 4. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  audioplayers: ^6.4.0             # Audio playback
  flutter_tts: ^3.8.5              # Text-to-speech
  pinyin: ^3.0.1                   # Pinyin conversion
  cached_network_image: ^3.3.0     # Image caching
  flutter_cache_manager: ^3.3.1    # Cache management
  flutter_bloc: ^9.1.0             # State management
  equatable: ^2.0.7                # Value equality
```

## Cara Kerja

### 1. Game BLoC
```dart
class GameBloc extends Bloc<GameEvent, GameState> {
  final GetMateriByLevel getMateriByLevel;
  final Random _random = Random();
}
```

**Events:**
- `LoadGame`: Memuat materi dari Firebase dan melakukan randomisasi awal
- `StartNewRound`: Memulai ronde baru dengan soal random
- `CheckAnswer`: Memeriksa jawaban yang dipilih
- `PlayAudio`: Memainkan audio untuk soal

**States:**
- `GameInitial`: State awal
- `GameLoading`: Sedang memuat data
- `GameLoaded`: Game siap dimainkan
- `GameCompleted`: Game selesai
- `GameError`: Error terjadi

### 2. Firebase Integration
- **Firestore**: Mengambil materi level 1 dari collection "materi"
- **Storage**: Mengambil gambar dari folder "game_1" dengan nama file sesuai ID materi
- **Real-time**: Update state secara real-time saat game berlangsung

### 3. Randomisasi Soal
```dart
// Random question type (0: Hanzi, 1: Pinyin, 2: Audio)
final questionType = _random.nextInt(3);
// Urutan materi sudah diacak di awal, jadi selalu ambil yang pertama
final currentMateri = currentState.remainingMateri.first;
```

### 4. Image Loading & Shuffling
```dart
// Shuffle materi list only once at the beginning
if (_shuffledMateri.isEmpty) {
  _shuffledMateri = List<Materi>.from(materiList)..shuffle();
}

// Preload all images with cache manager
for (final materi in _shuffledMateri) {
  if (!_imageUrls.containsKey(materi.id)) {
    final url = await _storageService.getImageUrl(materi.id);
    if (url != null) {
      _imageUrls[materi.id] = url;
      // Pre-cache the image
      await _cacheManager.downloadFile(url);
    }
  }
}
```

## Fitur Detail

### 1. Question Area
- **Hanzi Mode**: Font size 48, bold, dengan shadow
- **Pinyin Mode**: Font size 32 dengan tanda baca (tanpa arti bahasa Indonesia)
- **Audio Mode**: Icon volume dengan instruksi "Tap untuk mendengar"

### 2. Answer Grid
- **Layout**: 3x4 grid dengan spacing 10px
- **Images**: Cached network images dari Firebase Storage
- **Shuffled Order**: Urutan gambar diacak hanya sekali di awal permainan
- **States**: 
  - Available: Gambar normal, bisa diklik
  - Correct: Border hijau, overlay check icon
  - Incorrect: Border merah, overlay close icon
  - Completed: Fade out, check circle icon

### 3. Score Display
- **Position**: Top center dengan icon bintang
- **Format**: "X / Y" (skor saat ini / total soal)
- **Style**: White text dengan shadow

### 4. Completion Screen
- **Celebration**: Icon celebration dengan animasi
- **Message**: "Selamat! Kamu telah menyelesaikan permainan!" (tanpa skor)
- **Navigation**: Tombol kembali ke halaman sebelumnya

### 5. Scrollable Layout
- **SingleChildScrollView**: Mencegah konten terpotong
- **Responsive**: Menyesuaikan dengan ukuran layar
- **Loading State**: Indikator loading saat gambar sedang dimuat

## Penggunaan

### 1. Untuk Anak-Anak
1. Pilih Level 1 di ChooseLevelPage
2. Tekan "Mari Bermain" di SubLevelPage
3. Tunggu gambar selesai dimuat (loading indicator)
4. Lihat soal di area atas (Hanzi/Pinyin/Audio)
5. Pilih gambar yang sesuai dengan soal
6. Lihat feedback benar/salah
7. Lanjutkan sampai semua warna terjawab

### 2. Navigasi
- **Back Button**: Kembali ke SubLevelPage
- **Auto Progress**: Otomatis ke soal berikutnya jika benar
- **Completion**: Tampilan selamat tanpa skor

## Technical Implementation

### 1. BLoC Pattern
```dart
// Event handling
on<LoadGame>(_onLoadGame);
on<StartNewRound>(_onStartNewRound);
on<CheckAnswer>(_onCheckAnswer);
on<PlayAudio>(_onPlayAudio);
```

### 2. Firebase Storage Integration
```dart
Future<String?> getImageUrl(String documentId) async {
  final ref = _storage.ref().child('game_1/$documentId.png');
  return await ref.getDownloadURL();
}
```

### 3. Animation System
```dart
// Fade animation for questions
_fadeAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(CurvedAnimation(
  parent: _fadeController,
  curve: Curves.easeInOut,
));

// Bounce animation for answers
_bounceAnimation = Tween<double>(
  begin: 1.0,
  end: 0.95,
).animate(CurvedAnimation(
  parent: _bounceController,
  curve: Curves.easeInOut,
));
```

### 4. Text-to-Speech
```dart
Future<void> _playAudio(Materi materi) async {
  await _flutterTts.speak(materi.kosakata);
}
```

### 5. Sound Effects with Flame Audio
```dart
// Audio Assets Preloading
Future<void> _preloadAudioAssets() async {
  try {
    // Preload all audio assets for better performance
    // Note: Flame Audio automatically adds 'assets/audio/' prefix
    await FlameAudio.audioCache.loadAll([
      'correct_answer.mp3',
      'wrong_answer.mp3',
      'applause.mp3',
    ]);
  } catch (e) {
    print('Error preloading audio assets: $e');
  }
}

// Correct answer sound
Future<void> _playCorrectSound() async {
  try {
    // Play correct sound effect using Flame Audio
    await FlameAudio.play('correct_answer.mp3', volume: 0.3);
  } catch (e) {
    print('Error playing correct sound: $e');
  }
}

// Wrong answer sound
Future<void> _playWrongSound() async {
  try {
    // Play wrong sound effect using Flame Audio
    await FlameAudio.play('wrong_answer.mp3', volume: 0.3);
  } catch (e) {
    print('Error playing wrong sound: $e');
  }
}

// Applause sound (looping)
Future<void> _startApplause() async {
  if (!_isApplausePlaying) {
    try {
      _isApplausePlaying = true;
      // Play applause sound effect with looping using Flame Audio
      await FlameAudio.play('audio/applause.mp3', volume: 0.4, mode: PlayerMode.loop);
    } catch (e) {
      print('Error playing applause: $e');
      _isApplausePlaying = false;
    }
  }
}
```

### 6. Audio Management with Flame Audio
```dart
// Flame Audio provides better audio management for games
// - Multiple audio streams can play simultaneously
// - Built-in support for looping audio
// - Automatic audio caching and preloading
// - Better performance for game audio

// Audio preloading for better performance
Future<void> _preloadAudioAssets() async {
  await FlameAudio.audioCache.loadAll([
    'audio/correct_answer.mp3',
    'audio/wrong_answer.mp3',
    'audio/applause.mp3',
  ]);
}

// Playing sound effects
await FlameAudio.play('correct_answer.mp3', volume: 0.3);
await FlameAudio.play('wrong_answer.mp3', volume: 0.3);

// Playing audio (single play)
await FlameAudio.play('applause.mp3', volume: 0.4);
```

**Key Features:**
- **Multiple Audio Streams**: Flame Audio supports multiple simultaneous audio streams
- **Simple API**: Clean and straightforward audio playback API
- **Audio Caching**: Automatic caching and preloading for better performance
- **Game-Optimized**: Designed specifically for game audio requirements
- **BGM Compatibility**: Works seamlessly with background music

### 7. Image Preloading & Caching
```dart
Future<void> _loadImageUrls(List<Materi> materiList) async {
  // Only load images if not already loaded and this is initial load
  if (_imagesLoaded && _imageUrls.isNotEmpty && !_isInitialLoad) {
    return;
  }
  
  if (_isInitialLoad) {
    setState(() {
      _imagesLoaded = false;
    });
    
    // Shuffle materi list only once at the beginning
    if (_shuffledMateri.isEmpty) {
      _shuffledMateri = List<Materi>.from(materiList)..shuffle();
    }
    
    // Preload all images with cache manager
    for (final materi in _shuffledMateri) {
      if (!_imageUrls.containsKey(materi.id)) {
        final url = await _storageService.getImageUrl(materi.id);
        if (url != null) {
          _imageUrls[materi.id] = url;
          // Pre-cache the image
          await _cacheManager.downloadFile(url);
        }
      }
    }
    
    setState(() {
      _imagesLoaded = true;
      _isInitialLoad = false;
    });
  }
}
```

## Error Handling

### 1. Firebase Errors
- **Network Issues**: Fallback dengan placeholder images
- **Storage Errors**: Error widget dengan icon
- **Firestore Errors**: Error screen dengan retry button

### 2. Audio Errors
- **TTS Unavailable**: Graceful degradation
- **Language Issues**: Fallback ke default language
- **Sound Effects**: Error handling untuk efek suara
- **Volume Control**: Volume diatur agar tidak mengganggu BGM
- **Flame Audio**: Multiple audio streams tanpa konflik

### 3. Image Loading Errors
- **Network Issues**: Cached network image dengan placeholder
- **Invalid URLs**: Error widget dengan icon
- **Loading State**: Indikator loading saat gambar sedang dimuat

## Performance Considerations

### 1. Image Caching
- **CachedNetworkImage**: Otomatis cache gambar
- **Flutter Cache Manager**: Advanced caching dengan pre-download
- **Preloading**: Load semua gambar di awal untuk menghindari delay
- **No Re-loading**: Gambar tidak dimuat ulang setelah initial load
- **Memory Management**: Proper disposal

### 2. Animation Performance
- **Hardware Acceleration**: Smooth 60fps animations
- **Optimized Transforms**: Efficient scale and fade animations

### 3. State Management
- **BLoC Pattern**: Efficient state updates
- **Memory Leaks**: Proper disposal of controllers

### 4. Randomization
- **Single Shuffle**: Randomisasi hanya sekali di awal untuk konsistensi
- **Consistent Order**: Urutan assets tetap sama sepanjang permainan
- **Efficient Algorithm**: Menggunakan List.shuffle() yang optimal

## Flame Audio vs Traditional Audio Libraries

### Why Flame Audio?
Flame Audio dipilih karena beberapa keunggulan untuk game audio:

#### **1. Multiple Audio Streams**
- **Flame Audio**: Mendukung multiple audio streams secara bersamaan
- **Traditional Libraries**: Sering mengalami konflik saat multiple audio

#### **2. Simple Audio API**
- **Flame Audio**: Clean dan simple API untuk audio playback
- **Traditional Libraries**: API yang lebih kompleks untuk audio management

#### **3. Game-Optimized Performance**
- **Flame Audio**: Dirancang khusus untuk game audio
- **Traditional Libraries**: General-purpose, kurang optimal untuk game

#### **4. Audio Caching**
- **Flame Audio**: Automatic caching dan preloading
- **Traditional Libraries**: Manual caching management

#### **5. BGM Compatibility**
- **Flame Audio**: Works seamlessly dengan background music
- **Traditional Libraries**: Sering mengganggu BGM

### Implementation Benefits
```dart
// Simple and clean API
await FlameAudio.play('correct_answer.mp3', volume: 0.3);
await FlameAudio.play('applause.mp3', volume: 0.4);

// Automatic preloading
await FlameAudio.audioCache.loadAll([
  'correct_answer.mp3',
  'wrong_answer.mp3',
  'applause.mp3',
]);
```

### Correct Flame Audio Implementation
```dart
// Correct way to use Flame Audio
Future<void> _playCorrectSound() async {
  try {
    await FlameAudio.play('correct_answer.mp3', volume: 0.3);
  } catch (e) {
    print('Error playing correct sound: $e');
  }
}

Future<void> _playWrongSound() async {
  try {
    await FlameAudio.play('wrong_answer.mp3', volume: 0.3);
  } catch (e) {
    print('Error playing wrong sound: $e');
  }
}

Future<void> _startApplause() async {
  if (!_isApplausePlaying) {
    try {
      _isApplausePlaying = true;
      await FlameAudio.play('applause.mp3', volume: 0.4);
    } catch (e) {
      print('Error playing applause: $e');
      _isApplausePlaying = false;
    }
  }
}
```

### Important Note: Flame Audio Path Convention
Flame Audio automatically adds the `assets/audio/` prefix to file paths. Therefore:
- ❌ **Wrong**: `'audio/correct_answer.mp3'` → becomes `'assets/audio/audio/correct_answer.mp3'`
- ✅ **Correct**: `'correct_answer.mp3'` → becomes `'assets/audio/correct_answer.mp3'`

**File Structure:**
```
assets/
└── audio/
    ├── correct_answer.mp3
    ├── wrong_answer.mp3
    └── applause.mp3
```

## Future Enhancements

### 1. Game Features
- **Timer Mode**: Mode dengan batas waktu
- **Difficulty Levels**: Tingkat kesulitan yang berbeda
- **Streak Counter**: Menghitung jawaban benar berturut-turut

### 2. Audio Features
- **Sound Effects**: Efek suara untuk jawaban benar/salah
- **Applause**: Efek tepuk tangan saat game selesai (looping)
- **Background Music**: Musik latar yang menyenangkan
- **Voice Commands**: Navigasi dengan suara

### 3. UI Improvements
- **Particle Effects**: Efek partikel untuk celebration
- **Haptic Feedback**: Vibrasi saat interaksi
- **Accessibility**: Support untuk screen reader

### 4. Analytics
- **Progress Tracking**: Menyimpan progress per user
- **Performance Metrics**: Tracking waktu dan akurasi
- **Learning Analytics**: Analisis pola pembelajaran

## Keunggulan

1. **Educational Value**: Pembelajaran yang efektif dengan multiple modalities
2. **Engaging UI**: Interface yang menarik dan cocok untuk anak-anak
3. **Consistent Randomization**: Randomisasi yang konsisten dan predictable
4. **Visual Feedback**: Feedback yang jelas dan immediate
5. **Progressive Learning**: Sistem eliminasi yang memastikan semua materi tercover
6. **Performance**: Optimized untuk smooth experience dengan preloading dan caching
7. **Scalability**: Mudah dikembangkan untuk level lain
8. **Scrollable Layout**: Tidak ada konten yang terpotong
9. **Clean UI**: Soal pinyin tanpa arti bahasa Indonesia yang mengganggu
10. **Completion Celebration**: Tampilan selamat yang fokus pada achievement
11. **No Re-loading**: Gambar tidak dimuat ulang setelah initial load
12. **Consistent Assets**: Urutan 12 assets tetap sama sepanjang permainan
13. **Sound Effects**: Efek suara untuk feedback interaksi
14. **Applause Sound**: Efek tepuk tangan saat game selesai
15. **Flame Audio System**: Multiple audio streams tanpa konflik

## Requirements

### Firebase Setup
- **Firestore**: Collection "materi" dengan 12 dokumen level 1
- **Storage**: Folder "game_1" dengan 12 file PNG (nama = ID dokumen)
- **Security Rules**: Proper read permissions

### Audio Assets
- **correct_answer.mp3**: Efek suara untuk jawaban benar
- **wrong_answer.mp3**: Efek suara untuk jawaban salah
- **applause.mp3**: Efek tepuk tangan untuk completion

### Data Structure
```json
{
  "id": "unique_id",
  "arti": "Abu-abu",
  "gambarBase64": "base64_string",
  "kosakata": "灰色",
  "level": 1
}
```

Game ini memberikan pengalaman belajar yang menyenangkan dan efektif untuk anak-anak dalam mempelajari warna dalam bahasa Mandarin dengan semua perbaikan yang diminta! 