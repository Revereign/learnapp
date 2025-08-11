import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/materi_model.dart';

abstract class MateriRemoteDataSource {
  Future<List<MateriModel>> getAllMateri();
  Future<List<MateriModel>> getMateriByLevel(int level);
  Future<void> addMateri(MateriModel materi);
  Future<void> updateMateri(MateriModel materi);
  Future<void> deleteMateri(String id);
}

class MateriRemoteDataSourceImpl implements MateriRemoteDataSource {
  final FirebaseFirestore firestore;

  MateriRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<MateriModel>> getAllMateri() async {
    final snapshot = await firestore.collection('materi').get();
    return snapshot.docs
        .map((doc) => MateriModel.fromDocumentSnapshot(doc))
        .toList();
  }

  @override
  Future<List<MateriModel>> getMateriByLevel(int level) async {
    final snapshot = await firestore
        .collection('materi')
        .where('level', isEqualTo: level)
        .get();
    return snapshot.docs
        .map((doc) => MateriModel.fromDocumentSnapshot(doc))
        .toList();
  }

  @override
  Future<void> addMateri(MateriModel materi) async {
    await firestore.collection('materi').add(materi.toJson());
  }

  @override
  Future<void> updateMateri(MateriModel materi) async {
    await firestore.collection('materi').doc(materi.id).update(materi.toJson());
  }

  @override
  Future<void> deleteMateri(String id) async {
    await firestore.collection('materi').doc(id).delete();
  }
}
