import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider();

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final email = prefs.getString('email');
      final displayName = prefs.getString('displayName');
      final roleName = prefs.getString('role');

      if (uid != null && email != null && displayName != null) {
        _currentUser = UserModel(
          uid: uid,
          email: email,
          displayName: displayName,
          role: _parseRole(roleName),
          level: 1,
          xp: 0,
          gems: 0,
          hearts: 5,
          streakFreezes: 1,
          streak: 0,
          completedLessons: const [],
          completedQuizzes: const [],
          certificates: const [],
          lastActive: DateTime.now(),
        );
      } else {
        _currentUser = null;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password,
      {UserRole role = UserRole.student}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Local auth (offline-first)
      _currentUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        role: role,
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
      await _persistUser(_currentUser!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName, {
    UserRole role = UserRole.student,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Local auth (offline-first)
      _currentUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        role: role,
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

      await _persistUser(_currentUser!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle({UserRole role = UserRole.student}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        displayName: 'Google User',
        role: role,
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
      await _persistUser(_currentUser!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _clearUser();
    notifyListeners();
  }

  Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('email', user.email);
    await prefs.setString('displayName', user.displayName);
    await prefs.setString('role', user.role.name);
  }

  Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('email');
    await prefs.remove('displayName');
    await prefs.remove('role');
  }

  UserRole _parseRole(String? value) {
    switch (value) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}
