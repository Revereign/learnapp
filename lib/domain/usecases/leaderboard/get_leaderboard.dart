import '../../entities/leaderboard.dart';
import '../../repositories/leaderboard_repository.dart';

class GetLeaderboard {
  final LeaderboardRepository repository;

  GetLeaderboard({required this.repository});

  Future<List<LeaderboardEntity>> call(int level) {
    return repository.getLeaderboard(level);
  }
}
