# Main Menu Audio Implementation

## Overview
Implementasi audio untuk halaman Main Menu menggunakan audioplayers dengan BGM management yang disederhanakan.

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

### Inisialisasi di main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();
  
  runApp(const MyApp());
}
```

### Struktur File
```
assets/
  audio/
    menu_bgm.mp3       # BGM untuk main menu
    correct_answer.mp3  # SFX untuk game
    wrong_answer.mp3    # SFX untuk game
    applause.mp3        # SFX untuk game
firebase_storage/
  main_menu/
    background.jpg     # Background image
```

## Cara Kerja

### 1. Loading Assets
```dart
Future<void> _loadAssets() async {
  // Load background image dan BGM URL dari Firebase Storage
  // Start BGM menggunakan AudioManager
  await _startBGM();
}
```

### 2. BGM dengan AudioManager
```dart
Future<void> _startBGM() async {
  try {
    _audioManager.initialize().then((_) {
      _audioManager.startBGM('menu_bgm.mp3');
    });
  } catch (e) {
    // Fallback jika gagal
    debugPrint('BGM failed to start: $e');
  }
}
```

### 3. BGM Management
```dart
// Stop BGM when entering activities
void _onButtonTap(String route) {
  if (route == '/logout') {
    _audioManager.stopAllAudio();
  } else {
    // BGM continues playing for navigation
    Navigator.pushNamed(context, route);
  }
}
```

## Error Handling

### 1. BGM Error Handling
- Jika audioplayers gagal, aplikasi tetap berjalan tanpa BGM
- Graceful degradation untuk pengalaman yang konsisten

### 2. Network Error Handling
- Jika Firebase Storage tidak dapat diakses, background image akan menampilkan fallback color
- BGM akan gagal load tapi aplikasi tetap berjalan

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