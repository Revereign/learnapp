# Permainan Berhitung dengan Drag & Drop

## Deskripsi Fitur

Permainan Berhitung adalah fitur baru yang ditambahkan untuk level 2 aplikasi LearnApp. Game ini dirancang khusus untuk anak-anak di bawah 6 tahun dengan mekanisme drag and drop yang interaktif dan menarik.

## Cara Kerja Game

### 1. Mekanisme Permainan
- **Soal**: User diberikan soal seperti "2 + 3 香蕉 ="
- **Tujuan**: User harus drag and drop buah yang sesuai dengan jumlah yang diminta
- **Jawaban**: Untuk soal "2 + 3 香蕉 =", user harus menaruh 5 buah pisang

### 2. Alur Permainan
1. **Loading**: Game memuat materi dari Firebase Firestore level 2
2. **Soal**: 10 soal dengan format "jumlah + nama buah"
3. **Drag & Drop**: User drag buah dari pilihan yang tersedia
4. **Verifikasi**: Tombol "Hitung" untuk mengunci jawaban
5. **Feedback**: Notifikasi benar/salah dengan penjelasan
6. **Progress**: Indikator bintang untuk setiap soal
7. **Hasil**: Skor akhir dan kata-kata motivasi

### 3. Sistem Scoring
- **Passing Grade**: 7/10 atau lebih
- **Kata-kata Selamat**: Jika berhasil
- **Kata-kata Motivasi**: Jika belum berhasil

## Struktur File

### 1. Bloc (Business Logic)
```
lib/presentation/blocs/child/level/counting_game_bloc.dart
```
- **Events**: LoadCountingGame, AnswerQuestion, NextQuestion, ResetGame
- **States**: Initial, Loading, Loaded, Error
- **Models**: CountingQuestion dengan properti lengkap

### 2. UI Page
```
lib/presentation/pages/child/counting_game_page.dart
```
- **Header**: Judul dan navigasi kembali
- **Progress**: Indikator soal dan skor
- **Question Card**: Tampilan soal yang menarik
- **Drop Zone**: Area untuk menaruh buah
- **Available Fruits**: Buah yang bisa di-drag
- **Feedback**: Notifikasi jawaban benar/salah
- **Game Complete**: Hasil akhir dengan animasi

### 3. Integrasi
```
lib/main.dart
```
- BlocProvider untuk CountingGameBloc
- Dependency injection yang proper

```
lib/presentation/pages/child/sub_level_page.dart
```
- Tombol "Mari Bermain" untuk level 2
- Navigasi ke CountingGamePage

## Fitur Teknis

### 1. Drag & Drop
- **Draggable**: Buah yang bisa di-drag
- **DragTarget**: Area drop zone yang responsif
- **Visual Feedback**: Perubahan warna saat drag

### 2. Animasi
- **Fade Animation**: Transisi smooth antar state
- **Bounce Animation**: Feedback tombol yang interaktif
- **Star Animation**: Indikator progress yang menarik

### 3. Audio
- **Correct Answer**: Efek suara untuk jawaban benar
- **Wrong Answer**: Efek suara untuk jawaban salah
- **BGM Management**: Kontrol background music

### 4. Responsive Design
- **Scrollable**: Layout yang tidak overflow
- **Adaptive**: Ukuran yang menyesuaikan layar
- **Child-Friendly**: UI yang cocok untuk anak-anak

## Struktur Data Firebase

### 1. Collection: `materi`
```json
{
  "id": "unique_id",
  "arti": "Pisang",
  "gambarBase64": "base64_encoded_image",
  "kosakata": "香蕉",
  "level": 2
}
```

### 2. Query
```dart
final snapshot = await firestore
    .collection('materi')
    .where('level', isEqualTo: 2)
    .get();
```

## Cara Penggunaan

### 1. Untuk User (Anak-anak)
1. Pilih level 2 dari Choose Level Page
2. Tekan tombol "Mari Bermain" di Sub Level Page
3. Baca soal dengan teliti
4. Drag buah yang sesuai ke drop zone
5. Tekan tombol "Hitung" untuk verifikasi
6. Lihat feedback dan lanjut ke soal berikutnya
7. Selesaikan 10 soal untuk melihat hasil akhir

### 2. Untuk Developer
1. Pastikan Firebase Firestore sudah setup
2. Tambahkan materi level 2 dengan format yang benar
3. Pastikan gambar base64 tersedia
4. Test game flow dari awal sampai akhir

## Keunggulan Fitur

### 1. Educational Value
- **Matematika**: Belajar berhitung dengan visual
- **Bahasa Mandarin**: Pengenalan kosakata buah
- **Logika**: Pemahaman konsep jumlah dan objek

### 2. User Experience
- **Intuitive**: Drag and drop yang mudah dipahami
- **Engaging**: Animasi dan feedback yang menarik
- **Progressive**: Progress tracking yang jelas

### 3. Technical Excellence
- **Performance**: Optimized untuk smooth experience
- **Scalable**: Mudah dikembangkan untuk level lain
- **Maintainable**: Code structure yang rapi

## Error Handling

### 1. Network Issues
- Loading state yang informatif
- Retry mechanism untuk koneksi gagal
- Fallback UI yang user-friendly

### 2. Data Issues
- Validasi materi yang tersedia
- Fallback untuk gambar yang tidak valid
- Error message yang jelas

### 3. Game State Issues
- Reset game yang reliable
- State management yang konsisten
- Navigation yang aman

## Testing

### 1. Unit Tests
- Bloc logic testing
- Event handling testing
- State management testing

### 2. Widget Tests
- UI component testing
- User interaction testing
- Navigation testing

### 3. Integration Tests
- End-to-end game flow
- Firebase integration testing
- Audio system testing

## Future Enhancements

### 1. Additional Levels
- Level 3: Operasi matematika lebih kompleks
- Level 4: Kombinasi buah dan warna
- Level 5: Kalimat matematika dalam Mandarin

### 2. Advanced Features
- **Timer**: Batas waktu per soal
- **Hints**: Petunjuk untuk soal sulit
- **Multiplayer**: Bermain bersama teman
- **Leaderboard**: Ranking skor tertinggi

### 3. Accessibility
- **Voice Commands**: Kontrol suara
- **High Contrast**: Mode untuk penglihatan terbatas
- **Screen Reader**: Support untuk accessibility tools

## Dependencies

### 1. Flutter Packages
- `flutter_bloc`: State management
- `equatable`: Value equality
- `lottie`: Animasi yang menarik
- `cloud_firestore`: Database Firebase

### 2. Custom Services
- `AudioManager`: Manajemen audio
- `MateriRepository`: Data access layer
- `CountingGameBloc`: Business logic

## Troubleshooting

### 1. Common Issues
- **Game tidak load**: Cek koneksi Firebase
- **Drag tidak berfungsi**: Pastikan DragTarget sudah benar
- **Audio tidak ada**: Cek file audio dan AudioManager
- **Overflow error**: Pastikan layout responsive

### 2. Debug Tips
- Gunakan `debugPrint` untuk logging
- Cek state bloc dengan `BlocBuilder`
- Monitor Firebase queries
- Test di berbagai device size

## Conclusion

Permainan Berhitung dengan Drag & Drop adalah fitur yang komprehensif dan well-designed untuk aplikasi LearnApp. Fitur ini memberikan pengalaman belajar yang menyenangkan dan efektif untuk anak-anak dalam mempelajari matematika dan bahasa Mandarin.

Dengan arsitektur yang solid, UI yang menarik, dan fungsionalitas yang lengkap, game ini siap untuk digunakan dan dapat dikembangkan lebih lanjut untuk memberikan nilai edukasi yang lebih besar.
