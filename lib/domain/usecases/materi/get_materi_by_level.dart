import '../../entities/materi.dart';
import '../../repositories/materi_repository.dart';

class GetMateriByLevel {
  final MateriRepository repository;

  GetMateriByLevel(this.repository);

  Future<List<Materi>> call(int level) {
    return repository.getMateriByLevel(level);
  }
} 