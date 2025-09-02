import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckBadgeAchievements {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> call() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      
      // Convert quizScore from List<dynamic> to List<int>
      List<int> quizScore;
      if (data['quizScore'] != null && data['quizScore'] is List) {
        final rawQuizScore = data['quizScore'] as List;
        quizScore = rawQuizScore.map((e) {
          if (e is int) return e;
          if (e is double) return e.toInt();
          if (e is String) return int.tryParse(e) ?? 0;
          return 0;
        }).toList();
      } else {
        quizScore = List.filled(10, 0);
      }
      
      // Convert gameScore from List<dynamic> to List<int>
      List<int> gameScore;
      if (data['gameScore'] != null && data['gameScore'] is List) {
        final rawGameScore = data['gameScore'] as List;
        gameScore = rawGameScore.map((e) {
          if (e is int) return e;
          if (e is double) return e.toInt();
          if (e is String) return int.tryParse(e) ?? 0;
          return 0;
        }).toList();
      } else {
        gameScore = List.filled(10, 0);
      }
      
      // Convert achieve from List<dynamic> to List<bool>
      List<bool> achieve;
      if (data['achieve'] != null && data['achieve'] is List) {
        final rawAchieve = data['achieve'] as List;
        achieve = rawAchieve.map((e) {
          if (e is bool) return e;
          if (e is String) return e.toLowerCase() == 'true';
          if (e is int) return e != 0;
          return false;
        }).toList();
      } else {
        achieve = List.filled(6, false);
      }
      
      // Ensure arrays have correct size
      if (quizScore.length < 10) {
        quizScore = [...quizScore, ...List.filled(10 - quizScore.length, 0)];
      }
      if (gameScore.length < 10) {
        gameScore = [...gameScore, ...List.filled(10 - gameScore.length, 0)];
      }
      if (achieve.length < 6) {
        achieve = [...achieve, ...List.filled(6 - achieve.length, false)];
      }

      bool updated = false;

      // Badge 1 (index 0): Selesaikan kuis pada semua level dengan minimal skornya 5
      if (!achieve[0]) {
        bool allQuizMin5 = true;
        for (int score in quizScore) {
          if (score < 5) {
            allQuizMin5 = false;
            break;
          }
        }
        if (allQuizMin5) {
          achieve[0] = true;
          updated = true;
        }
      }

      // Badge 4 (index 3): Selesaikan 3 kuis dengan nilai sempurna
      if (!achieve[3]) {
        int perfectQuizCount = quizScore.where((score) => score == 10).length;
        if (perfectQuizCount >= 3) {
          achieve[3] = true;
          updated = true;
        }
      }

      // Badge 5 (index 4): Selesaikan 7 kuis dengan nilai sempurna
      if (!achieve[4]) {
        int perfectQuizCount = quizScore.where((score) => score == 10).length;
        if (perfectQuizCount >= 7) {
          achieve[4] = true;
          updated = true;
        }
      }

      // Badge 6 (index 5): Selesaikan semua kuis dengan nilai sempurna
      if (!achieve[5]) {
        bool allQuizPerfect = true;
        for (int score in quizScore) {
          if (score != 10) {
            allQuizPerfect = false;
            break;
          }
        }
        if (allQuizPerfect) {
          achieve[5] = true;
          updated = true;
        }
      }

      // Define perfect scores for each game level
      final List<int> perfectGameScores = [12, 10, 7, 7, 12, 7, 10, 7, 12, 10];

      // Badge 2 (index 1): Selesaikan 5 game dengan nilai sempurna
      if (!achieve[1]) {
        int perfectGameCount = 0;
        for (int i = 0; i < gameScore.length && i < perfectGameScores.length; i++) {
          if (gameScore[i] == perfectGameScores[i]) {
            perfectGameCount++;
          }
        }
        if (perfectGameCount >= 5) {
          achieve[1] = true;
          updated = true;
        }
      }

      // Badge 3 (index 2): Selesaikan semua game dengan nilai sempurna
      if (!achieve[2]) {
        bool allGamePerfect = true;
        for (int i = 0; i < gameScore.length && i < perfectGameScores.length; i++) {
          if (gameScore[i] != perfectGameScores[i]) {
            allGamePerfect = false;
            break;
          }
        }
        if (allGamePerfect) {
          achieve[2] = true;
          updated = true;
        }
      }

      // Update Firestore if any achievements were unlocked
      if (updated) {
        await _firestore.collection('users').doc(user.uid).update({
          'achieve': achieve,
        });
      }
    } catch (e) {
      print('Error checking badge achievements: $e');
    }
  }
}
