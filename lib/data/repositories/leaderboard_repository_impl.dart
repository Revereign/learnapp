import '../../domain/entities/leaderboard.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_data_source.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LeaderboardEntity>> getLeaderboard(int level) async {
    final List<LeaderboardModel> models = await remoteDataSource.getLeaderboard(level);
    
    return models.map((model) => LeaderboardEntity(
      uid: model.uid,
      name: model.name,
      score: model.score,
      time: model.time,
      equipBadge: model.equipBadge,
    )).toList();
  }
}
