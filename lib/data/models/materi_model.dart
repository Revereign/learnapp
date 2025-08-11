import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/materi.dart';

class MateriModel extends Materi {
  MateriModel({
    required String id,
    required String kosakata,
    required String arti,
    required int level,
    required String? gambarBase64, // Tambahan
  }) : super(
    id: id,
    kosakata: kosakata,
    arti: arti,
    level: level,
    gambarBase64: gambarBase64, // Tambahan
  );

  factory MateriModel.fromJson(Map<String, dynamic> json, String documentId) {
    return MateriModel(
      id: documentId,
      kosakata: json['kosakata'] ?? '',
      arti: json['arti'] ?? '',
      level: json['level'] ?? 1,
      gambarBase64: json['gambarBase64'] ?? '', // Tambahan
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kosakata': kosakata,
      'arti': arti,
      'level': level,
      'gambarBase64': gambarBase64, // Tambahan
    };
  }

  factory MateriModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return MateriModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }
}
