import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/sounds.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  List<UserModel> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUser(UserModel user) {
    _currentUser = user;
    _hydrateLeaderboard(user);
    notifyListeners();
  }

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate loading user from local storage
      // In a real app, this would fetch from Firebase
      _currentUser = UserModel(
        uid: uid,
        email: 'user@example.com',
        displayName: 'Learner',
        role: UserRole.student,
        level: 1,
        xp: 0,
        gems: 0,
        hearts: 5,
        streakFreezes: 1,
        streak: 0,
        completedLessons: const [],
        completedQuizzes: const [],
        achievements: const [],
        trophies: const [],
        certificates: const [],
        lastActive: DateTime.now(),
      );

      _hydrateLeaderboard(_currentUser!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _hydrateLeaderboard(UserModel user) {
    _leaderboard = [
      user,
      UserModel(
        uid: 'user2',
        email: 'user2@example.com',
        displayName: 'Alex',
        level: 9,
        xp: 450,
        lastActive: DateTime.now(),
      ),
      UserModel(
        uid: 'user3',
        email: 'user3@example.com',
        displayName: 'Mia',
        level: 8,
        xp: 390,
        lastActive: DateTime.now(),
      ),
      UserModel(
        uid: 'user4',
        email: 'user4@example.com',
        displayName: 'John',
        level: 7,
        xp: 210,
        lastActive: DateTime.now(),
      ),
      UserModel(
        uid: 'user5',
        email: 'user5@example.com',
        displayName: 'Sarah',
        level: 6,
        xp: 180,
        lastActive: DateTime.now(),
      ),
    ];
    _leaderboard.sort((a, b) => b.xp.compareTo(a.xp));
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _currentUser = updatedUser;
      final index =
          _leaderboard.indexWhere((leader) => leader.uid == updatedUser.uid);
      if (index == -1) {
        _leaderboard.insert(0, updatedUser);
      } else {
        _leaderboard[index] = updatedUser;
      }
      _leaderboard.sort((a, b) => b.xp.compareTo(a.xp));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> addXP(int amount) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      xp: _currentUser!.xp + amount,
    );

    while (_currentUser!.xp >= _currentUser!.xpForNextLevel) {
      _currentUser = _currentUser!.copyWith(
        level: _currentUser!.level + 1,
      );
    }

    await updateUser(_currentUser!);
  }

  Future<void> updateStreak() async {
    if (_currentUser == null) return;

    final now = DateTime.now();
    final lastUpdate = _currentUser!.lastStreakUpdate;
    int newStreak = _currentUser!.streak;

    if (lastUpdate == null) {
      newStreak = 1;
    } else {
      final difference = now.difference(lastUpdate).inDays;
      if (difference == 1) {
        newStreak = _currentUser!.streak + 1;
      } else if (difference > 1) {
        if (_currentUser!.streakFreezes > 0) {
          _currentUser = _currentUser!.copyWith(
            streakFreezes: _currentUser!.streakFreezes - 1,
          );
          newStreak = _currentUser!.streak;
        } else {
          newStreak = 1;
        }
      }
    }

    _currentUser = _currentUser!.copyWith(
      streak: newStreak,
      lastStreakUpdate: now,
      lastActive: now,
    );

    await updateUser(_currentUser!);
  }

  Future<void> addStreakFreeze({int amount = 1}) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      streakFreezes: _currentUser!.streakFreezes + amount,
    );
    await updateUser(_currentUser!);
  }

  Future<void> useStreakFreeze() async {
    if (_currentUser == null) return;
    if (_currentUser!.streakFreezes <= 0) return;
    _currentUser = _currentUser!.copyWith(
      streakFreezes: _currentUser!.streakFreezes - 1,
    );
    await updateUser(_currentUser!);
  }

  Future<void> useHeart() async {
    if (_currentUser == null || _currentUser!.hearts <= 0) return;
    _currentUser = _currentUser!.copyWith(
      hearts: _currentUser!.hearts - 1,
    );
    await updateUser(_currentUser!);
  }

  Future<void> refillHearts() async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(hearts: 5);
    await updateUser(_currentUser!);
  }

  Future<void> addGems(int amount) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      gems: _currentUser!.gems + amount,
    );
    await updateUser(_currentUser!);
  }

  Future<void> completeLesson(String lessonId) async {
    if (_currentUser == null) return;
    final newList = List<String>.from(_currentUser!.completedLessons);
    if (!newList.contains(lessonId)) {
      newList.add(lessonId);
      _currentUser = _currentUser!.copyWith(completedLessons: newList);
      await updateUser(_currentUser!);
    }
  }

  Future<void> completeQuiz(String quizId) async {
    if (_currentUser == null) return;
    final newList = List<String>.from(_currentUser!.completedQuizzes);
    if (!newList.contains(quizId)) {
      newList.add(quizId);
      _currentUser = _currentUser!.copyWith(completedQuizzes: newList);
      await updateUser(_currentUser!);
    }
  }

  Future<void> addAchievement(String achievementId) async {
    if (_currentUser == null) return;
    final newList = List<String>.from(_currentUser!.achievements);
    if (!newList.contains(achievementId)) {
      newList.add(achievementId);
      _currentUser = _currentUser!.copyWith(achievements: newList);
      await updateUser(_currentUser!);
    }
  }

  Future<bool> addTrophy(String trophyId) async {
    if (_currentUser == null) return false;
    if (_currentUser!.role == UserRole.student) {
      return false;
    }
    final newList = List<String>.from(_currentUser!.trophies);
    if (newList.contains(trophyId)) {
      return false;
    }
    newList.add(trophyId);
    _currentUser = _currentUser!.copyWith(trophies: newList);
    await updateUser(_currentUser!);
    await SoundManager().playTrophySound();
    return true;
  }

  Future<void> addCertificate(String certificateId) async {
    if (_currentUser == null) return;
    final newList = List<String>.from(_currentUser!.certificates);
    if (!newList.contains(certificateId)) {
      newList.add(certificateId);
      _currentUser = _currentUser!.copyWith(certificates: newList);
      await updateUser(_currentUser!);
    }
  }

  int getUserRank(String uid) {
    // Mock implementation - returns rank in leaderboard
    int rank = 1;
    for (int i = 0; i < _leaderboard.length; i++) {
      if (_leaderboard[i].uid == uid) {
        return i + 1;
      }
    }
    return rank;
  }
}
