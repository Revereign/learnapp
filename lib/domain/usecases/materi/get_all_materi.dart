import '../../entities/materi.dart';
import '../../repositories/materi_repository.dart';

class GetAllMateri {
  final MateriRepository repository;

  GetAllMateri(this.repository);

  Future<List<Materi>> call() {
    return repository.getAllMateri();
  }
}
