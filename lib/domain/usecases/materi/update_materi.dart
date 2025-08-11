import '../../entities/materi.dart';
import '../../repositories/materi_repository.dart';

class UpdateMateri {
  final MateriRepository repository;

  UpdateMateri(this.repository);

  Future<void> call(Materi materi) {
    return repository.updateMateri(materi);
  }
}
