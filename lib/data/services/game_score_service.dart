import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameScoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Update game score if the new score is higher than the current highest score
  /// Returns true if score was updated, false if current score is higher
  Future<bool> updateGameScore(int level, int newScore) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      
      // Check if user role is 'orangtua' - don't save score for parents
      if (userData['role'] == 'orangtua') {
        print('Parent user detected - skipping game score save');
        return false;
      }
      
      final currentGameScore = List<int>.from(userData['gameScore'] ?? List.filled(10, 0));
      
      // Check if new score is higher than current score for this level
      if (newScore > currentGameScore[level - 1]) {
        currentGameScore[level - 1] = newScore;
        
        // Update the gameScore field in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'gameScore': currentGameScore,
        });
        
        return true; // Score was updated
      }
      
      return false; // Current score is higher
    } catch (e) {
      print('Error updating game score: $e');
      return false;
    }
  }

  /// Get current game scores for the user
  Future<List<int>> getCurrentGameScores() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return List.filled(10, 0);

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return List.filled(10, 0);

      final userData = userDoc.data()!;
      return List<int>.from(userData['gameScore'] ?? List.filled(10, 0));
    } catch (e) {
      print('Error getting game scores: $e');
      return List.filled(10, 0);
    }
  }

  /// Get current game score for a specific level
  Future<int> getCurrentGameScore(int level) async {
    try {
      final scores = await getCurrentGameScores();
      return scores[level - 1];
    } catch (e) {
      print('Error getting game score for level $level: $e');
      return 0;
    }
  }
}
