import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> getImageUrl(String documentId) async {
    try {
      final ref = _storage.ref().child('game_1/$documentId.png');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting image URL: $e');
      return null;
    }
  }

  Future<Uint8List?> getImageBytes(String documentId) async {
    try {
      final ref = _storage.ref().child('game_1/$documentId.png');
      final data = await ref.getData();
      return data;
    } catch (e) {
      print('Error getting image bytes: $e');
      return null;
    }
  }
} 