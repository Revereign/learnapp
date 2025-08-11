import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseStorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadMateriImage(File file, String materiId) async {
    final fileName = '$materiId-${basename(file.path)}';
    final ref = _storage.ref().child('materi_images/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
