import '../../entities/materi.dart';
import '../../repositories/materi_repository.dart';

class AddMateri {
  final MateriRepository repository;

  AddMateri(this.repository);

  Future<void> call(Materi materi) {
    return repository.addMateri(materi);
  }
}
