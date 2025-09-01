import '../entities/leaderboard.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntity>> getLeaderboard(int level);
}
