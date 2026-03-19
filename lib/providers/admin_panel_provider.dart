import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';

enum ContentType { lesson, quiz, course }

enum ContentStatus { pending, approved, rejected }

enum UserStatus { pending, active, suspended, banned }

class ContentSubmission {
  final String id;
  final ContentType type;
  final String title;
  final String category;
  final String submittedBy;
  final String submittedById;
  final DateTime submittedAt;
  ContentStatus status;

  ContentSubmission({
    required this.id,
    required this.type,
    required this.title,
    required this.category,
    required this.submittedBy,
    required this.submittedById,
    required this.submittedAt,
    this.status = ContentStatus.pending,
  });
}

class ManagedUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  UserStatus status;
  int xp;
  int streak;
  int completedLessons;
  int completedQuizzes;
  DateTime lastActive;
  String? assignedClass;

  ManagedUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.status = UserStatus.active,
    this.xp = 0,
    this.streak = 0,
    this.completedLessons = 0,
    this.completedQuizzes = 0,
    required this.lastActive,
    this.assignedClass,
  });
}

class AdminPanelProvider extends ChangeNotifier {
  final Map<String, ManagedUser> _users = {};
  final Map<String, ContentSubmission> _submissions = {};

  AdminPanelProvider({bool seedDemoData = false}) {
    if (seedDemoData) {
      _seedUsers();
    }
  }

  List<ManagedUser> get users => _users.values.toList();
  List<ManagedUser> get students =>
      _users.values.where((u) => u.role == UserRole.student).toList();
  List<ManagedUser> get teachers =>
      _users.values.where((u) => u.role == UserRole.teacher).toList();
  List<ManagedUser> get pendingTeachers =>
      _users.values.where((u) => u.role == UserRole.teacher && u.status == UserStatus.pending).toList();

  int get totalStudents => students.length;
  int get totalTeachers => teachers.length;

  int get dailyActiveUsers => _users.values
      .where((u) => DateTime.now().difference(u.lastActive).inDays == 0)
      .length;

  int get totalQuizzesAttempted =>
      _users.values.fold(0, (sum, user) => sum + user.completedQuizzes);

  double get platformEngagement {
    if (_users.isEmpty) return 0;
    final active = _users.values
        .where((u) => DateTime.now().difference(u.lastActive).inDays < 2)
        .length;
    return active / _users.length;
  }

  List<ContentSubmission> get submissions =>
      _submissions.values.toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

  List<ContentSubmission> submissionsByStatus(ContentStatus status) =>
      submissions.where((s) => s.status == status).toList();

  List<ContentSubmission> submissionsByAuthor(String uid) =>
      submissions.where((s) => s.submittedById == uid).toList();

  ContentStatus statusForLesson(String id) {
    final submission = _submissions[_key(ContentType.lesson, id)];
    return submission?.status ?? ContentStatus.approved;
  }

  ContentStatus statusForQuiz(String id) {
    final submission = _submissions[_key(ContentType.quiz, id)];
    return submission?.status ?? ContentStatus.approved;
  }

  bool isLessonApproved(String id) =>
      statusForLesson(id) == ContentStatus.approved;

  bool isQuizApproved(String id) =>
      statusForQuiz(id) == ContentStatus.approved;

  void registerUser(UserModel user) {
    final existing = _users[user.uid];
    final status = existing?.status ??
        (user.role == UserRole.teacher ? UserStatus.pending : UserStatus.active);
    final updated = ManagedUser(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      role: user.role,
      status: status,
      xp: user.xp,
      streak: user.streak,
      completedLessons: user.completedLessons.length,
      completedQuizzes: user.completedQuizzes.length,
      lastActive: user.lastActive,
      assignedClass: existing?.assignedClass,
    );

    final hasChanged = existing == null ||
        existing.status != updated.status ||
        existing.xp != updated.xp ||
        existing.streak != updated.streak ||
        existing.completedLessons != updated.completedLessons ||
        existing.completedQuizzes != updated.completedQuizzes ||
        existing.lastActive != updated.lastActive;

    _users[user.uid] = updated;
    if (hasChanged) {
      notifyListeners();
    }
  }

  void approveTeacher(String uid) {
    final user = _users[uid];
    if (user == null) return;
    user.status = UserStatus.active;
    notifyListeners();
  }

  void suspendUser(String uid) {
    final user = _users[uid];
    if (user == null) return;
    user.status = UserStatus.suspended;
    notifyListeners();
  }

  void banUser(String uid) {
    final user = _users[uid];
    if (user == null) return;
    user.status = UserStatus.banned;
    notifyListeners();
  }

  void submitLesson(Lesson lesson, UserModel author) {
    _submitContent(
      id: lesson.id,
      type: ContentType.lesson,
      title: lesson.title,
      category: lesson.category,
      author: author,
    );
  }

  void submitQuiz(Quiz quiz, UserModel author) {
    _submitContent(
      id: quiz.id,
      type: ContentType.quiz,
      title: quiz.title,
      category: quiz.category,
      author: author,
    );
  }

  void approveSubmission(ContentSubmission submission) {
    submission.status = ContentStatus.approved;
    notifyListeners();
  }

  void rejectSubmission(ContentSubmission submission) {
    submission.status = ContentStatus.rejected;
    notifyListeners();
  }

  void resubmitSubmission(ContentSubmission submission) {
    submission.status = ContentStatus.pending;
    notifyListeners();
  }

  double averageCompletion({
    required int totalLessons,
    required int totalQuizzes,
  }) {
    if (students.isEmpty) return 0;
    final totalItems = totalLessons + totalQuizzes;
    if (totalItems == 0) return 0;
    final totalCompleted = students.fold<int>(
      0,
      (sum, user) => sum + user.completedLessons + user.completedQuizzes,
    );
    return totalCompleted / (students.length * totalItems);
  }

  void _submitContent({
    required String id,
    required ContentType type,
    required String title,
    required String category,
    required UserModel author,
  }) {
    final key = _key(type, id);
    final current = _submissions[key];
    final status = author.role == UserRole.admin
        ? ContentStatus.approved
        : ContentStatus.pending;
    _submissions[key] = ContentSubmission(
      id: id,
      type: type,
      title: title,
      category: category,
      submittedBy: author.displayName,
      submittedById: author.uid,
      submittedAt: DateTime.now(),
      status: current?.status == ContentStatus.rejected
          ? ContentStatus.pending
          : status,
    );
    notifyListeners();
  }

  String _key(ContentType type, String id) => '${type.name}_$id';

  void _seedUsers() {
    final now = DateTime.now();
    final sample = [
      ManagedUser(
        uid: 'student_1',
        name: 'Alex',
        email: 'alex@student.com',
        role: UserRole.student,
        xp: 420,
        streak: 6,
        completedLessons: 6,
        completedQuizzes: 4,
        lastActive: now.subtract(const Duration(hours: 2)),
      ),
      ManagedUser(
        uid: 'student_2',
        name: 'Mia',
        email: 'mia@student.com',
        role: UserRole.student,
        xp: 380,
        streak: 4,
        completedLessons: 5,
        completedQuizzes: 3,
        lastActive: now.subtract(const Duration(hours: 6)),
      ),
      ManagedUser(
        uid: 'student_3',
        name: 'Jordan',
        email: 'jordan@student.com',
        role: UserRole.student,
        xp: 290,
        streak: 2,
        completedLessons: 4,
        completedQuizzes: 2,
        lastActive: now.subtract(const Duration(days: 1)),
      ),
      ManagedUser(
        uid: 'teacher_1',
        name: 'Priya',
        email: 'priya@school.com',
        role: UserRole.teacher,
        status: UserStatus.active,
        lastActive: now.subtract(const Duration(hours: 3)),
      ),
      ManagedUser(
        uid: 'teacher_2',
        name: 'Rahul',
        email: 'rahul@school.com',
        role: UserRole.teacher,
        status: UserStatus.pending,
        lastActive: now.subtract(const Duration(days: 2)),
      ),
    ];

    for (final user in sample) {
      _users[user.uid] = user;
    }
  }
}
