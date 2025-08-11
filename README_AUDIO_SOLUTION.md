# Audio Solution Documentation

## Overview
Dokumentasi solusi audio untuk aplikasi pembelajaran Mandarin menggunakan audioplayers dengan BGM management yang disederhanakan.

## Fitur Audio

### 1. Background Music (BGM)
- **Source**: Local assets (`assets/audio/menu_bgm.mp3`)
- **Looping**: Ya, menggunakan `audioplayers` dengan `ReleaseMode.loop`
- **Volume**: 0.6 (60%)
- **Management**: BGM hanya dimainkan sampai pemilihan sub-level

### 2. Sound Effects (SFX)
- **Source**: Local assets (untuk game dan aktivitas lain)
- **Method**: `audioplayers` dengan timing management
- **Volume**: 0.4 (40%)

## Implementasi

### Dependencies
```yaml
dependencies:
  audioplayers: ^6.4.0
```

### Audio Manager
```dart
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isBgmPlaying = false;
  bool _isInitialized = false;
  String? _currentBgm;
  
  // AudioPlayers for audio playback
  AudioPlayer? _bgmPlayer;
  AudioPlayer? _sfxPlayer;
  
  // Timer for managing audio timing
  Timer? _sfxTimer;
  bool _isSfxPlaying = false;
}
```

### BGM Management
```dart
// Start BGM
_audioManager.startBGM('menu_bgm.mp3');

// Stop BGM when entering activities
_audioManager.stopBGM();

// Resume BGM when returning from activities
_audioManager.startBGM('menu_bgm.mp3');
```

### SFX Management
```dart
// Play SFX with timing management
_audioManager.playSFX('correct_answer.mp3', volume: 0.4);
```

## Struktur File
```
assets/
  audio/
    menu_bgm.mp3       # BGM untuk main menu
    correct_answer.mp3  # SFX untuk game
    wrong_answer.mp3    # SFX untuk game
    applause.mp3        # SFX untuk game
```

## Cara Kerja

### 1. BGM Lifecycle
- **Main Menu**: BGM starts
- **Choose Level**: BGM continues
- **Sub Level**: BGM continues
- **Enter Activity**: BGM stops
- **Exit Activity**: BGM resumes

### 2. SFX Management
- Menggunakan audioplayers untuk semua sound effects
- Timing management untuk mencegah overlapping
- Volume balancing untuk mengurangi konflik

## Error Handling

### 1. BGM Error Handling
- Jika audioplayers gagal, aplikasi tetap berjalan tanpa BGM
- Graceful degradation untuk pengalaman yang konsisten

### 2. SFX Error Handling
- Jika audioplayers gagal, SFX tidak diputar tapi aplikasi tetap berjalan
- Timing management untuk mencegah overlapping

## Keunggulan Implementasi

1. **Simplified Audio System**: Menggunakan audioplayers saja
2. **BGM Management**: BGM hanya dimainkan sampai pemilihan sub-level
3. **Error Resilience**: Aplikasi tetap berjalan meskipun ada masalah audio
4. **Memory Management**: Proper disposal untuk mencegah memory leak

## Troubleshooting

### BGM Tidak Berputar
1. Pastikan file `menu_bgm.mp3` ada di `assets/audio/`
2. Periksa koneksi internet
3. Cek console log untuk error message

### Audio Terputus
1. Pastikan tidak ada konflik dengan audio player lain
2. Periksa volume device
3. Restart aplikasi jika diperlukan 