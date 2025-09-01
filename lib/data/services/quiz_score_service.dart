import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Update quiz score if the new score is higher than the current highest score
  /// Returns true if score was updated, false if current score is higher
  Future<bool> updateQuizScore(int level, int newScore) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      final currentQuizScore = List<int>.from(userData['quizScore'] ?? List.filled(10, 0));
      
      // Check if new score is higher than current score for this level
      if (newScore > currentQuizScore[level - 1]) {
        currentQuizScore[level - 1] = newScore;
        
        // Update the quizScore field in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'quizScore': currentQuizScore,
        });
        
        return true; // Score was updated
      }
      
      return false; // Current score is higher
    } catch (e) {
      print('Error updating quiz score: $e');
      return false;
    }
  }

  /// Update quiz time if the new time is faster (smaller) than the current best time
  /// Returns true if time was updated, false if current time is faster
  Future<bool> updateQuizTime(int level, int newTime) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      final currentQuizTime = List<int>.from(userData['quizTime'] ?? List.filled(10, 0));
      
      // Check if new time is faster (smaller) than current time for this level
      // If current time is 0 (no record), update it
      if (currentQuizTime[level - 1] == 0 || newTime < currentQuizTime[level - 1]) {
        currentQuizTime[level - 1] = newTime;
        
        // Update the quizTime field in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'quizTime': currentQuizTime,
        });
        
        return true; // Time was updated
      }
      
      return false; // Current time is faster
    } catch (e) {
      print('Error updating quiz time: $e');
      return false;
    }
  }

  /// Get current quiz scores for the user
  Future<List<int>> getCurrentQuizScores() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return List.filled(10, 0);

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return List.filled(10, 0);

      final userData = userDoc.data()!;
      return List<int>.from(userData['quizScore'] ?? List.filled(10, 0));
    } catch (e) {
      print('Error getting quiz scores: $e');
      return List.filled(10, 0);
    }
  }

  /// Get current quiz times for the user
  Future<List<int>> getCurrentQuizTimes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return List.filled(10, 0);

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return List.filled(10, 0);

      final userData = userDoc.data()!;
      return List<int>.from(userData['quizTime'] ?? List.filled(10, 0));
    } catch (e) {
      print('Error getting quiz times: $e');
      return List.filled(10, 0);
    }
  }

  /// Get current quiz score for a specific level
  Future<int> getCurrentQuizScore(int level) async {
    try {
      final scores = await getCurrentQuizScores();
      return scores[level - 1];
    } catch (e) {
      print('Error getting quiz score for level $level: $e');
      return 0;
    }
  }

  /// Get current quiz time for a specific level
  Future<int> getCurrentQuizTime(int level) async {
    try {
      final times = await getCurrentQuizTimes();
      return times[level - 1];
    } catch (e) {
      print('Error getting quiz time for level $level: $e');
      return 0;
    }
  }
}
