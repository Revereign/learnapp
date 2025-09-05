import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardModel>> getLeaderboard(int level);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<LeaderboardModel>> getLeaderboard(int level) async {
    try {
      // Get all users with role 'anak' and quizScore > 0 for the specified level
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'anak')
          .get();

      final List<LeaderboardModel> leaderboard = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final quizScore = List<int>.from(data['quizScore'] ?? List.filled(10, 0));
        final quizTime = List<int>.from(data['quizTime'] ?? List.filled(10, 0));
        
        // Check if user has score > 0 for this level
        if (quizScore[level - 1] > 0) {
          leaderboard.add(LeaderboardModel(
            uid: doc.id,
            name: data['name'] ?? 'Unknown User',
            score: quizScore[level - 1],
            time: quizTime[level - 1],
            equipBadge: data['equipBadge'] ?? 0,
          ));
        }
      }

      // Sort by score (highest first), then by time (fastest first)
      leaderboard.sort((a, b) {
        if (a.score != b.score) {
          return b.score.compareTo(a.score); // Higher score first
        } else {
          return a.time.compareTo(b.time); // Faster time first
        }
      });

      // Return top 8 or fill with empty slots if less than 8
      final List<LeaderboardModel> result = [];
      
      // Add actual leaderboard entries
      for (int i = 0; i < leaderboard.length && i < 8; i++) {
        result.add(leaderboard[i]);
      }
      
      // Fill remaining slots with empty entries
      while (result.length < 8) {
        result.add(LeaderboardModel(
          uid: '',
          name: '-',
          score: 0,
          time: 0,
          equipBadge: 0,
        ));
      }

      return result;
    } catch (e) {
      print('Error getting leaderboard: $e');
      return List.generate(8, (index) => LeaderboardModel(
        uid: '',
        name: '-',
        score: 0,
        time: 0,
        equipBadge: 0,
      ));
    }
  }
}
