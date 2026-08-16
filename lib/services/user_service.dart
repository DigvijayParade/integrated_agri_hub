import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Central service for all user data operations.
/// Handles: profile loading, green coins, streak, daily login bonus, quiz/task limits.
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String? get currentUid => _auth.currentUser?.uid;

  // ──────────────────────────────────────────
  // LOAD FULL FARMER PROFILE
  // ──────────────────────────────────────────
  Future<Map<String, dynamic>?> loadFarmerProfile() async {
    final uid = currentUid;
    if (uid == null) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) return doc.data();
    } catch (e) {
      if (kDebugMode) print('UserService.loadFarmerProfile error: $e');
    }
    return null;
  }

  // ──────────────────────────────────────────
  // DAILY LOGIN BONUS (+10 coins)
  // ──────────────────────────────────────────
  /// Returns true if the bonus was credited (first login of today).
  Future<bool> checkAndGrantDailyLoginBonus() async {
    final uid = currentUid;
    if (uid == null) return false;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) return false;

      final lastLogin = data['lastLoginDate'] as String?;
      if (lastLogin == _today) return false; // Already got bonus today

      // Grant 10 coins and record today
      await _db.collection('users').doc(uid).update({
        'greenCoins': FieldValue.increment(10),
        'lastLoginDate': _today,
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('UserService.dailyLoginBonus error: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────
  // STREAK — call this after task OR quiz completion
  // ──────────────────────────────────────────
  /// Updates streak after a daily activity (task or quiz).
  /// Returns the new streak count. Returns -1 on error.
  Future<int> updateStreakAfterActivity() async {
    final uid = currentUid;
    if (uid == null) return -1;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) return -1;

      final lastActive = data['lastActiveDate'] as String?;
      int currentStreak = data['streak'] as int? ?? 0;

      if (lastActive == _today) {
        // Already active today — no streak change
        return currentStreak;
      }

      // Calculate new streak
      int newStreak;
      if (lastActive == null) {
        newStreak = 1; // First ever activity
      } else {
        final last = DateTime.parse(lastActive);
        final today = DateTime.parse(_today);
        final diff = today.difference(last).inDays;

        if (diff == 1) {
          newStreak = currentStreak + 1; // Consecutive day
        } else {
          newStreak = 1; // Missed a day — reset
        }
      }

      // Check 29-day streak bonus
      Map<String, dynamic> updates = {
        'streak': newStreak,
        'lastActiveDate': _today,
      };

      if (newStreak >= 29) {
        updates['greenCoins'] = FieldValue.increment(100);
        updates['streak'] = 0; // Reset after bonus
        newStreak = 0;
        if (kDebugMode) print('🎉 29-day streak bonus credited!');
      }

      await _db.collection('users').doc(uid).update(updates);
      return newStreak;
    } catch (e) {
      if (kDebugMode) print('UserService.updateStreak error: $e');
      return -1;
    }
  }

  // ──────────────────────────────────────────
  // GREEN COINS — add or deduct
  // ──────────────────────────────────────────
  Future<void> addCoins(int amount) async {
    final uid = currentUid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).update({
        'greenCoins': FieldValue.increment(amount),
      });
    } catch (e) {
      if (kDebugMode) print('UserService.addCoins error: $e');
    }
  }

  Future<bool> deductCoins(int amount) async {
    final uid = currentUid;
    if (uid == null) return false;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final coins = doc.data()?['greenCoins'] as int? ?? 0;
      if (coins < amount) return false; // Insufficient coins

      await _db.collection('users').doc(uid).update({
        'greenCoins': FieldValue.increment(-amount),
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('UserService.deductCoins error: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────
  // QUIZ LIMIT — 1 rewarded quiz per day
  // ──────────────────────────────────────────
  /// Returns true if the farmer can earn coins from a quiz today.
  Future<bool> canEarnQuizRewardToday() async {
    final uid = currentUid;
    if (uid == null) return false;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final lastQuizDate = doc.data()?['lastQuizDate'] as String?;
      return lastQuizDate != _today;
    } catch (e) {
      return false;
    }
  }

  /// Call after rewarding a quiz. Marks today as quiz-rewarded + increments count.
  Future<void> recordQuizCompletion() async {
    final uid = currentUid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).update({
        'lastQuizDate': _today,
        'quizzesCompleted': FieldValue.increment(1),
        'greenCoins': FieldValue.increment(100),
      });
      await updateStreakAfterActivity();
    } catch (e) {
      if (kDebugMode) print('UserService.recordQuizCompletion error: $e');
    }
  }

  // ──────────────────────────────────────────
  // TASK LIMIT — 1 rewarded task per day
  // ──────────────────────────────────────────
  Future<bool> canEarnTaskRewardToday() async {
    final uid = currentUid;
    if (uid == null) return false;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final lastTaskDate = doc.data()?['lastTaskRewardDate'] as String?;
      return lastTaskDate != _today;
    } catch (e) {
      return false;
    }
  }

  /// Call after rewarding a task.
  Future<void> recordTaskCompletion(String taskId, int coinsReward, bool giveReward) async {
    final uid = currentUid;
    if (uid == null) return;
    try {
      final updates = <String, dynamic>{
        'completedTasks': FieldValue.arrayUnion([taskId]),
      };
      
      if (giveReward) {
        updates['lastTaskRewardDate'] = _today;
        updates['greenCoins'] = FieldValue.increment(coinsReward);
      }
      
      await _db.collection('users').doc(uid).update(updates);
      await updateStreakAfterActivity();
    } catch (e) {
      if (kDebugMode) print('UserService.recordTaskCompletion error: $e');
    }
  }

  // ──────────────────────────────────────────
  // SAVE PROFILE EDITS (crops, state)
  // ──────────────────────────────────────────
  Future<void> updateProfile(Map<String, dynamic> fields) async {
    final uid = currentUid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).update(fields);
    } catch (e) {
      if (kDebugMode) print('UserService.updateProfile error: $e');
    }
  }

  // ──────────────────────────────────────────
  // REAL-TIME STREAM — listen to coin/streak changes
  // ──────────────────────────────────────────
  Stream<DocumentSnapshot<Map<String, dynamic>>>? userStream() {
    final uid = currentUid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).snapshots();
  }
}
