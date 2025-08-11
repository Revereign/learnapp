import '../../domain/entities/materi.dart';
import '../../domain/repositories/materi_repository.dart';
import '../datasources/materi_remote_data_source.dart';
import '../models/materi_model.dart';

class MateriRepositoryImpl implements MateriRepository {
  final MateriRemoteDataSource remoteDataSource;

  MateriRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Materi>> getAllMateri() async {
    return await remoteDataSource.getAllMateri();
  }

  @override
  Future<List<Materi>> getMateriByLevel(int level) async {
    return await remoteDataSource.getMateriByLevel(level);
  }

  @override
  Future<void> addMateri(Materi materi) async {
    final model = MateriModel(
      id: materi.id,
      kosakata: materi.kosakata,
      arti: materi.arti,
      level: materi.level,
      gambarBase64: materi.gambarBase64,
    );
    await remoteDataSource.addMateri(model);
  }

  @override
  Future<void> updateMateri(Materi materi) async {
    final model = MateriModel(
      id: materi.id,
      kosakata: materi.kosakata,
      arti: materi.arti,
      level: materi.level,
      gambarBase64: materi.gambarBase64,
    );
    await remoteDataSource.updateMateri(model);
  }

  @override
  Future<void> deleteMateri(String id) async {
    await remoteDataSource.deleteMateri(id);
  }
}
