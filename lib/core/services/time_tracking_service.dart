import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimeTrackingService {
  static final TimeTrackingService _instance = TimeTrackingService._internal();
  factory TimeTrackingService() => _instance;
  TimeTrackingService._internal();

  Timer? _timer;
  DateTime? _sessionStartTime;
  DateTime? _lastUpdateTime;
  String? _currentUserId;
  bool _isTracking = false;
  bool _isAppInForeground = true;

  // Getter untuk status tracking
  bool get isTracking => _isTracking;
  bool get isAppInForeground => _isAppInForeground;

  // Start tracking waktu untuk user
  void startTracking(String userId) {
    if (_isTracking && _currentUserId == userId) return;
    
    _currentUserId = userId;
    _sessionStartTime = DateTime.now();
    _lastUpdateTime = DateTime.now();
    _isTracking = true;
    _isAppInForeground = true;

    // Start timer untuk update setiap 10 detik
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isTracking && _isAppInForeground && _currentUserId != null) {
        _updateTimeTracking();
      }
    });

    debugPrint('Time tracking started for user: $userId');
  }

  // Stop tracking waktu
  void stopTracking() {
    if (!_isTracking) return;

    // Update terakhir sebelum stop
    if (_isAppInForeground && _currentUserId != null) {
      _updateTimeTracking();
    }

    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _currentUserId = null;
    _sessionStartTime = null;
    _lastUpdateTime = null;

    debugPrint('Time tracking stopped');
  }

  // Handle app lifecycle changes
  void onAppResumed() {
    if (_isTracking && _currentUserId != null) {
      _isAppInForeground = true;
      _sessionStartTime = DateTime.now();
      _lastUpdateTime = DateTime.now();
      debugPrint('App resumed - time tracking continued');
    }
  }

  void onAppPaused() {
    if (_isTracking && _currentUserId != null) {
      _isAppInForeground = false;
      // Update terakhir sebelum pause
      _updateTimeTracking();
      debugPrint('App paused - time tracking paused');
    }
  }

  // Update time tracking ke Firestore
  Future<void> _updateTimeTracking() async {
    if (_currentUserId == null || _sessionStartTime == null || _lastUpdateTime == null) return;

    try {
      final now = DateTime.now();
      final sessionDuration = now.difference(_lastUpdateTime!).inSeconds;
      
      if (sessionDuration <= 0) return;

      // Ambil data user saat ini
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId!)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final currentTodayTime = userData['todayTime'] ?? 0;
      final currentAllTime = userData['allTime'] ?? 0;

      // Check apakah sudah ganti hari
      final lastUpdateDate = _lastUpdateTime!.toLocal();
      final currentDate = now.toLocal();
      final isNewDay = lastUpdateDate.day != currentDate.day || 
                      lastUpdateDate.month != currentDate.month || 
                      lastUpdateDate.year != currentDate.year;

      int newTodayTime = currentTodayTime;
      int newAllTime = currentAllTime + sessionDuration;

      // Reset todayTime jika ganti hari
      if (isNewDay) {
        newTodayTime = sessionDuration;
        debugPrint('New day detected - resetting todayTime');
      } else {
        newTodayTime = currentTodayTime + sessionDuration;
      }

      // Update ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId!)
          .update({
        'todayTime': newTodayTime,
        'allTime': newAllTime,
      });

      _lastUpdateTime = now;

      debugPrint('Time updated - todayTime: $newTodayTime, allTime: $newAllTime');
    } catch (e) {
      debugPrint('Error updating time tracking: $e');
    }
  }

  // Force update time tracking (untuk logout atau app close)
  Future<void> forceUpdate() async {
    if (_isTracking && _currentUserId != null) {
      await _updateTimeTracking();
    }
  }

  // Check apakah user adalah anak
  Future<bool> isChildUser(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (!userDoc.exists) return false;
      
      final userData = userDoc.data()!;
      return userData['role'] == 'anak';
    } catch (e) {
      debugPrint('Error checking user role: $e');
      return false;
    }
  }

  // Cleanup resources
  void dispose() {
    stopTracking();
  }
}
