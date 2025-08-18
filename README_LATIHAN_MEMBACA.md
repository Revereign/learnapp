# Fitur Latihan Membaca - LearnApp

## Deskripsi
Halaman "Latihan Membaca" adalah fitur pembelajaran yang memungkinkan anak-anak berlatih membaca karakter Hanzi dengan bantuan teknologi Text-to-Speech (TTS) dan Speech-to-Text (STT). Fitur ini dirancang khusus untuk anak-anak di bawah usia 6 tahun dengan UI yang menarik dan interaktif.

## Fitur Utama

### **1. Tampilan Kosakata**
- **Hanzi**: Karakter Chinese yang besar dan jelas
- **Arti**: Terjemahan dalam bahasa Indonesia
- **Gambar**: Ilustrasi yang membantu pemahaman
- **Progress**: Indikator posisi kosakata (X/Y)

### **2. Text-to-Speech (TTS)**
- **Tombol Audio**: Tombol biru dengan icon speaker
- **Bahasa**: Chinese (zh-CN) untuk pengucapan yang akurat
- **Kecepatan**: Diatur lambat (0.5x) untuk anak-anak
- **Volume**: Maksimal untuk kejelasan suara

### **3. Speech-to-Text (STT)**
- **Tombol Mikrofon**: Tombol hijau/merah yang berubah saat aktif
- **Mode Tahan**: User harus menahan tombol sambil berbicara
- **Durasi**: Maksimal 10 detik dengan pause 3 detik
- **Locale**: Chinese (zh-CN) untuk pengenalan yang lebih baik

### **4. Pengecekan Pengucapan**
- **Algoritma**: Pengecekan sederhana berdasarkan kemiripan teks
- **Feedback Visual**: Warna hijau (benar) atau merah (salah)
- **Sound Effect**: Suara benar/salah sesuai hasil
- **Confidence Score**: Persentase kepercayaan pengenalan suara

## Struktur Halaman

### **Header**
- Tombol back dengan icon `Icons.arrow_back_ios`
- Judul "Latihan Membaca Level X"
- Background gradient orange

### **Progress Indicator**
- Container transparan dengan border putih
- Format "X / Y" untuk menunjukkan posisi
- Styling yang menarik dengan shadow

### **Vocabulary Card**
- **Gambar**: 120x120 dengan border radius dan shadow
- **Hanzi**: Font size 48, warna orange
- **Arti**: Font size 24, warna grey
- **Tombol Audio**: 80x80 dengan warna biru

### **Speech Recognition Section**
- **Judul**: "Tes Membaca" dengan warna orange
- **Instruksi**: Panduan penggunaan yang jelas
- **Tombol Mikrofon**: 120x120 dengan animasi warna
- **Hasil Pengenalan**: Container dengan teks yang diucapkan
- **Feedback Hasil**: Container dengan warna dan icon sesuai hasil

### **Navigation Buttons**
- **Tombol Sebelumnya**: Muncul jika bukan kosakata pertama
- **Tombol Selanjutnya**: Muncul jika bukan kosakata terakhir
- **Styling**: Container transparan dengan border putih

## Teknologi yang Digunakan

### **Dependencies**
```yaml
flutter_tts: ^3.8.5          # Text-to-Speech
speech_to_text: ^6.6.0       # Speech Recognition
cloud_firestore: ^5.6.5      # Database
flutter_bloc: ^9.1.0         # State Management
```

### **Permissions Android**
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## Cara Kerja

### **1. Loading Data**
- Halaman memuat data dari Firebase Firestore
- Filter berdasarkan level yang dipilih
- Inisialisasi pronunciation results array

### **2. Text-to-Speech**
- Setup TTS dengan bahasa Chinese
- Konfigurasi kecepatan dan volume
- Play suara saat tombol audio ditekan

### **3. Speech Recognition**
- Inisialisasi speech recognition
- Start listening saat tombol ditekan
- Stop listening saat tombol dilepas
- Process hasil pengenalan suara

### **4. Pronunciation Checking**
- Bandingkan teks yang diucapkan dengan arti
- Check kemiripan dengan Hanzi
- Update pronunciation results
- Tampilkan feedback visual

## UI/UX Features

### **Animasi**
- **Fade In**: Transisi smooth saat halaman dibuka (1000ms)
- **Bounce**: Feedback saat tombol ditekan (200ms)
- **Color Transition**: Perubahan warna tombol mikrofon

### **Styling**
- **Gradient Background**: Orange gradient yang menarik
- **Card Design**: Container putih dengan shadow dan border radius
- **Color Coding**: Hijau untuk benar, merah untuk salah
- **Responsive Layout**: SingleChildScrollView untuk konten panjang

### **Visual Feedback**
- **Loading State**: CircularProgressIndicator saat memuat data
- **Empty State**: Pesan error jika tidak ada materi
- **Results Display**: Container dengan warna sesuai hasil
- **Progress Tracking**: Indikator posisi kosakata

## Integrasi dengan Sistem

### **Audio Management**
- **BGM**: Dihentikan saat masuk ke halaman
- **BGM**: Diresume saat kembali ke halaman sebelumnya
- **Sound Effects**: correct_answer.mp3 dan wrong_answer.mp3

### **Navigation**
- **Back Button**: Kembali ke LatihanPage
- **Level Passing**: Level diteruskan dari halaman sebelumnya
- **State Management**: Menggunakan StatefulWidget

### **Data Flow**
- **Firebase**: Load materi berdasarkan level
- **Local State**: Pronunciation results dan current index
- **User Input**: Speech recognition dan TTS

## Error Handling

### **Speech Recognition**
- Check availability saat inisialisasi
- Handle error dengan SnackBar
- Graceful fallback jika tidak tersedia

### **Data Loading**
- Loading state saat memuat data
- Empty state jika tidak ada materi
- Error handling dengan try-catch

### **TTS Setup**
- Async setup dengan error handling
- Fallback jika TTS tidak tersedia

## Optimizations

### **Performance**
- Lazy loading untuk gambar
- Efficient state management
- Proper disposal of resources

### **User Experience**
- Clear visual feedback
- Intuitive button interactions
- Smooth animations
- Responsive design

## Future Enhancements

### **Advanced Pronunciation Checking**
- Phonetic similarity algorithms
- Machine learning models
- Multiple language support

### **Progress Tracking**
- Save results to database
- Progress analytics
- Achievement system

### **Accessibility**
- Voice commands
- Screen reader support
- High contrast mode

## Troubleshooting

### **Speech Recognition Not Working**
1. Check microphone permissions
2. Verify device supports speech recognition
3. Check internet connection
4. Restart app

### **TTS Not Working**
1. Check device language settings
2. Verify TTS engine is installed
3. Check volume settings
4. Restart app

### **Images Not Loading**
1. Check Firebase connection
2. Verify base64 data format
3. Check device storage permissions
4. Clear app cache

## Dependencies Installation

### **Flutter**
```bash
flutter pub get
```

### **Android**
- Minimum SDK: 21
- Target SDK: 33
- Permissions added to AndroidManifest.xml

### **iOS**
- Minimum iOS: 11.0
- Microphone usage description required
- Speech recognition framework

## Testing

### **Manual Testing**
- Test TTS dengan berbagai kosakata
- Test STT dengan pengucapan yang berbeda
- Test navigation antar kosakata
- Test error handling

### **Device Testing**
- Test di berbagai ukuran layar
- Test di device dengan/ tanpa TTS
- Test di device dengan/ tanpa microphone
- Test performance di device low-end

## Conclusion

Fitur Latihan Membaca telah berhasil diimplementasikan dengan semua fitur yang diminta:
- ✅ Tampilan kosakata dari Firebase Firestore
- ✅ Text-to-Speech untuk pengucapan Hanzi
- ✅ Speech-to-Text untuk pengenalan suara
- ✅ Pengecekan pengucapan dengan feedback visual
- ✅ UI yang menarik untuk anak-anak
- ✅ Tidak ada render overflow
- ✅ Integrasi dengan sistem audio yang ada

Fitur ini siap digunakan dan dapat memberikan pengalaman belajar yang interaktif dan menyenangkan bagi anak-anak.
