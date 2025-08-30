# Generate Soal Level-Based - Fitur Generate Soal Berdasarkan Level

## Deskripsi
Fitur ini memungkinkan admin untuk generate soal kuis yang berbasis dari materi setiap level yang tersedia di aplikasi. Soal yang di-generate akan menggunakan kosa kata yang sudah tersedia di level tertentu, tanpa ada kosa kata asing yang tidak masuk dalam kurikulum level tersebut.

## Fitur Utama

### 1. Level Selection
- **Dropdown Level**: Admin dapat memilih level 1-10 untuk generate soal
- **Materi Count**: Menampilkan jumlah kosa kata yang tersedia di level yang dipilih
- **Auto-load**: Materi level akan otomatis dimuat saat level berubah

### 2. Level-Specific Prompt Generation
- **Context-Aware**: Prompt yang dikirim ke Gemini sudah disesuaikan dengan level yang dipilih
- **Vocabulary Constraint**: Gemini hanya akan menggunakan kosa kata yang tersedia di level tersebut
- **Structured Format**: Prompt yang terstruktur untuk hasil yang konsisten

### 3. Preserved Features
- **Save Individual Questions**: Admin tetap bisa menyimpan soal yang diinginkan satu per satu
- **Question Management**: Soal yang disimpan akan masuk ke sistem manajemen soal
- **Level Assignment**: Soal otomatis diberi level sesuai dengan level yang dipilih saat generate

## Cara Kerja

### 1. Flow Generate Soal
1. Admin memilih level dari dropdown (1-10)
2. Sistem memuat materi level tersebut dari Firebase
3. Admin memasukkan prompt dasar (contoh: "tentang warna")
4. Sistem membuat prompt level-specific dengan kosa kata yang tersedia
5. Prompt dikirim ke Gemini Service
6. Gemini generate 10 soal berdasarkan constraint level
7. Soal ditampilkan dengan informasi level

### 2. Level-Specific Prompt Example
```
Buatkan 10 soal kuis bahasa Mandarin untuk anak-anak berusia dibawah 6 tahun pilihan ganda berdasarkan topik berikut:
tentang warna

PENTING: Gunakan HANYA kosa kata yang tersedia di level 1 berikut:
一 (Satu), 二 (Dua), 三 (Tiga), 红色 (Merah), 蓝色 (Biru), 黄色 (Kuning)

Jangan gunakan kosa kata lain yang tidak ada dalam daftar di atas.

Format JSON array:
[
  {
    "soal": "Pertanyaan",
    "a": "Pilihan A",
    "b": "Pilihan B", 
    "c": "Pilihan C",
    "d": "Pilihan D",
    "jawaban": "a"
  },
  ... (10 soal)
]

Hanya tampilkan JSON array saja tanpa penjelasan tambahan.
```

### 3. Integration Points
- **VocabularyBloc**: Untuk memuat materi level tertentu
- **GeminiService**: Untuk generate soal dengan prompt yang sudah disesuaikan
- **ManageQuizBloc**: Untuk menyimpan soal yang di-generate
- **Firebase Firestore**: Untuk menyimpan soal dan mengambil materi level

## Struktur Kode

### 1. Modified Files
- `lib/presentation/pages/admin/generate_soal_page.dart` - Halaman utama dengan fitur level selection

### 2. New Methods
- `_loadMateriForLevel(int level)` - Memuat materi untuk level tertentu
- `_onLevelChanged(int newLevel)` - Handler perubahan level
- `_createLevelSpecificPrompt(String basePrompt)` - Membuat prompt yang disesuaikan dengan level
- `_buildQuestionsDisplay()` - UI untuk menampilkan soal yang di-generate

### 3. State Management
- `_selectedLevel`: Level yang sedang dipilih
- `_levelMateri`: List materi untuk level yang dipilih
- `_isLoadingMateri`: Status loading materi
- `_isGenerating`: Status generate soal

## Penggunaan

### 1. Untuk Admin
1. Buka halaman "Generate Soal dari Prompt"
2. Pilih level yang diinginkan dari dropdown
3. Tunggu materi level dimuat (akan muncul count kosa kata)
4. Masukkan prompt dasar (contoh: "tentang warna", "tentang angka")
5. Tekan tombol "Generate Soal"
6. Tunggu Gemini generate soal
7. Review soal yang dihasilkan
8. Simpan soal yang diinginkan satu per satu

### 2. Contoh Penggunaan
- **Level 1 (Warna & Angka)**: Prompt "tentang warna" akan generate soal tentang 红色, 蓝色, 黄色
- **Level 2 (Keluarga & Binatang)**: Prompt "tentang keluarga" akan generate soal tentang 妈妈, 爸爸
- **Level 3 (Makanan)**: Prompt "tentang makanan" akan generate soal tentang 米饭, 苹果, 面包

## Keunggulan

### 1. Consistency
- Soal yang di-generate konsisten dengan materi level yang tersedia
- Tidak ada kosa kata asing yang membingungkan anak-anak
- Kurikulum yang terstruktur dan terukur

### 2. Efficiency
- Admin tidak perlu manual memilih kosa kata
- Generate soal otomatis sesuai level
- Integrasi seamless dengan sistem yang ada

### 3. Quality Control
- Prompt yang terstruktur untuk hasil yang konsisten
- Constraint vocabulary untuk akurasi materi
- Error handling yang robust

## Error Handling

### 1. Level Validation
- Cek apakah level memiliki materi
- Tampilkan pesan error jika level kosong
- Disable generate button jika tidak ada materi

### 2. Gemini Service Error
- Try-catch untuk error generate soal
- Tampilkan pesan error yang informatif
- Reset state jika terjadi error

### 3. Vocabulary Loading Error
- Handle error loading materi dari Firebase
- Tampilkan status error di UI
- Fallback ke state sebelumnya

## Testing

### 1. Test Cases
- Generate soal untuk level yang memiliki materi
- Generate soal untuk level yang kosong
- Perubahan level saat generate sedang berjalan
- Error handling untuk Gemini service
- Integration dengan VocabularyBloc

### 2. Expected Behavior
- Level selection berfungsi dengan benar
- Materi level dimuat sesuai level yang dipilih
- Prompt yang dihasilkan sesuai dengan level
- Soal yang di-generate hanya menggunakan kosa kata level tersebut
- Fitur save soal tetap berfungsi normal

## Future Enhancements

### 1. Batch Operations
- Generate soal untuk multiple level sekaligus
- Bulk save soal yang di-generate
- Template prompt untuk level tertentu

### 2. Advanced Constraints
- Difficulty level dalam level
- Topic-specific generation
- Custom vocabulary sets

### 3. Analytics
- Track soal yang paling sering di-generate
- Monitor performance Gemini service
- Usage statistics per level

## Dependencies

### 1. Required Blocs
- `VocabularyBloc`: Untuk memuat materi level
- `ManageQuizBloc`: Untuk menyimpan soal

### 2. Required Services
- `GeminiService`: Untuk generate soal dengan AI

### 3. Required Entities
- `Materi`: Untuk data materi level
- `QuizQuestionEntity`: Untuk struktur soal

## Conclusion

Fitur Generate Soal Level-Based ini memberikan solusi yang efektif untuk admin dalam membuat soal kuis yang konsisten dengan kurikulum level yang tersedia. Dengan integrasi yang seamless dengan sistem yang ada, fitur ini mempertahankan semua fungsionalitas sebelumnya sambil menambahkan kemampuan generate soal yang lebih cerdas dan terstruktur.
