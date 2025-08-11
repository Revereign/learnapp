# Vocabulary Page - Halaman Kosa Kata

## Deskripsi
Halaman Vocabulary Page adalah fitur untuk menampilkan kosa kata bahasa Mandarin berdasarkan level yang dipilih oleh anak-anak. Halaman ini menampilkan materi dari Firebase Firestore dengan tampilan yang menarik dan sesuai untuk anak-anak.

## Fitur Utama

### 1. Tampilan Kosa Kata
- **Gambar Kosa Kata**: Menampilkan gambar dari data base64 yang tersimpan di Firebase
- **Hanzi (Karakter Mandarin)**: Menampilkan karakter Mandarin dengan ukuran yang besar dan jelas
- **Arti Bahasa Indonesia**: Menampilkan terjemahan dalam bahasa Indonesia
- **Nomor Urut**: Setiap kosa kata memiliki nomor urut untuk memudahkan pembelajaran

### 2. State Management
- **Loading State**: Menampilkan loading indicator saat mengambil data
- **Loaded State**: Menampilkan daftar kosa kata yang berhasil diambil
- **Empty State**: Menampilkan pesan ketika tidak ada kosa kata untuk level tertentu
- **Error State**: Menampilkan pesan error dan tombol retry jika terjadi kesalahan

### 3. Animasi dan UI
- **Fade Animation**: Animasi fade in saat halaman dibuka
- **Gradient Background**: Background gradient biru yang menarik
- **Card Design**: Setiap kosa kata ditampilkan dalam card dengan gradient orange
- **Responsive Design**: Tampilan yang responsif untuk berbagai ukuran layar

## Struktur Kode

### 1. Bloc Pattern
```
lib/presentation/blocs/vocabulary/
├── vocabulary_bloc.dart      # Business logic untuk vocabulary
├── vocabulary_event.dart     # Events untuk vocabulary
└── vocabulary_state.dart     # States untuk vocabulary
```

### 2. Use Case
```
lib/domain/usecases/materi/
└── get_materi_by_level.dart  # Use case untuk mengambil materi berdasarkan level
```

### 3. Repository dan Data Source
- **Repository**: `MateriRepositoryImpl` dengan method `getMateriByLevel`
- **Data Source**: `MateriRemoteDataSourceImpl` dengan query Firestore berdasarkan level

## Cara Kerja

### 1. Flow Data
1. User membuka halaman Vocabulary Page
2. `VocabularyBloc` dipanggil dengan event `LoadVocabulary`
3. Use case `GetMateriByLevel` dipanggil
4. Repository mengambil data dari Firebase Firestore
5. Data ditampilkan dalam bentuk list kosa kata

### 2. Query Firebase
```dart
final snapshot = await firestore
    .collection('materi')
    .where('level', isEqualTo: level)
    .get();
```

### 3. Struktur Data Firebase
```json
{
  "id": "unique_id",
  "kosakata": "苹果",
  "arti": "Apel",
  "level": 1,
  "gambarBase64": "base64_encoded_image"
}
```

## Integrasi dengan Aplikasi

### 1. Dependency Injection
Vocabulary bloc sudah diintegrasikan ke dalam `MultiBlocProvider` di `main.dart`:

```dart
BlocProvider(
  create: (context) => VocabularyBloc(
    getMateriByLevel: GetMateriByLevel(
      MateriRepositoryImpl(
        remoteDataSource: MateriRemoteDataSourceImpl(
          firestore: FirebaseFirestore.instance,
        ),
      ),
    ),
  ),
),
```

### 2. Navigation
Halaman Vocabulary Page dapat diakses dari `SubLevelPage` dengan menekan tombol "Kosa Kata".

## Penggunaan

### 1. Untuk Anak-Anak
- Pilih level yang diinginkan
- Tekan tombol "Kosa Kata" di SubLevelPage
- Lihat daftar kosa kata dengan gambar dan artinya
- Pelajari karakter Mandarin (Hanzi) dan artinya

### 2. Untuk Admin
- Gunakan halaman `kelola_materi_page.dart` untuk menambah kosa kata
- Setiap kosa kata harus memiliki level yang sesuai
- Upload gambar dalam format base64
- Pastikan data kosakata dan arti sudah benar

## Error Handling

### 1. Network Error
- Menampilkan pesan error yang informatif
- Tombol "Coba Lagi" untuk retry
- Fallback UI yang user-friendly

### 2. Image Error
- Jika gambar base64 tidak valid, menampilkan placeholder
- Icon "image_not_supported" sebagai fallback

### 3. Empty Data
- Pesan yang jelas ketika tidak ada kosa kata
- Icon dan styling yang konsisten

## Keunggulan

1. **User Experience**: Tampilan yang menarik dan mudah dipahami anak-anak
2. **Performance**: Menggunakan Bloc pattern untuk state management yang efisien
3. **Scalability**: Mudah untuk menambah fitur baru seperti audio pronunciation
4. **Maintainability**: Kode yang terstruktur dan mudah dimaintain
5. **Error Handling**: Penanganan error yang komprehensif

## Future Enhancement

1. **Audio Pronunciation**: Menambahkan suara pengucapan untuk setiap kosa kata
2. **Interactive Learning**: Menambahkan fitur drag and drop atau matching game
3. **Progress Tracking**: Menyimpan progress pembelajaran anak
4. **Offline Support**: Menyimpan data lokal untuk akses offline
5. **Search Function**: Pencarian kosa kata berdasarkan kata kunci 