import '../entities/materi.dart';

abstract class MateriRepository {
  Future<List<Materi>> getAllMateri();
  Future<List<Materi>> getMateriByLevel(int level);
  Future<void> addMateri(Materi materi);
  Future<void> updateMateri(Materi materi);
  Future<void> deleteMateri(String id);
}
