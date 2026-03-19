enum UserRole { student, teacher, admin }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final UserRole role;
  int level;
  int xp;
  int streak;
  int gems;
  int hearts;
  int streakFreezes;
  List<String> completedLessons;
  List<String> completedQuizzes;
  List<String> achievements;
  List<String> trophies;
  List<String> certificates;
  Map<String, dynamic> courseProgress;
  DateTime lastActive;
  DateTime? lastStreakUpdate;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.role = UserRole.student,
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
    this.gems = 0,
    this.hearts = 5,
    this.streakFreezes = 1,
    this.completedLessons = const [],
    this.completedQuizzes = const [],
    this.achievements = const [],
    this.trophies = const [],
    this.certificates = const [],
    this.courseProgress = const {},
    required this.lastActive,
    this.lastStreakUpdate,
  });

  int get xpForNextLevel => level * 100;
  double get levelProgress => xp / xpForNextLevel;
  bool get hasHearts => hearts > 0;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role.name,
      'level': level,
      'xp': xp,
      'streak': streak,
      'gems': gems,
      'hearts': hearts,
      'streakFreezes': streakFreezes,
      'completedLessons': completedLessons,
      'completedQuizzes': completedQuizzes,
      'achievements': achievements,
      'trophies': trophies,
      'certificates': certificates,
      'courseProgress': courseProgress,
      'lastActive': lastActive.toIso8601String(),
      'lastStreakUpdate': lastStreakUpdate?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      role: _roleFromString(map['role']),
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      streak: map['streak'] ?? 0,
      gems: map['gems'] ?? 0,
      hearts: map['hearts'] ?? 5,
      streakFreezes: map['streakFreezes'] ?? 1,
      completedLessons: List<String>.from(map['completedLessons'] ?? []),
      completedQuizzes: List<String>.from(map['completedQuizzes'] ?? []),
      achievements: List<String>.from(map['achievements'] ?? []),
      trophies: List<String>.from(map['trophies'] ?? []),
      certificates: List<String>.from(map['certificates'] ?? []),
      courseProgress: Map<String, dynamic>.from(map['courseProgress'] ?? {}),
      lastActive: DateTime.parse(map['lastActive']),
      lastStreakUpdate: map['lastStreakUpdate'] != null
          ? DateTime.parse(map['lastStreakUpdate'])
          : null,
    );
  }

  UserModel copyWith({
    UserRole? role,
    int? level,
    int? xp,
    int? streak,
    int? gems,
    int? hearts,
    int? streakFreezes,
    List<String>? completedLessons,
    List<String>? completedQuizzes,
    List<String>? achievements,
    List<String>? trophies,
    List<String>? certificates,
    Map<String, dynamic>? courseProgress,
    DateTime? lastActive,
    DateTime? lastStreakUpdate,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      role: role ?? this.role,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      gems: gems ?? this.gems,
      hearts: hearts ?? this.hearts,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      completedLessons: completedLessons ?? this.completedLessons,
      completedQuizzes: completedQuizzes ?? this.completedQuizzes,
      achievements: achievements ?? this.achievements,
      trophies: trophies ?? this.trophies,
      certificates: certificates ?? this.certificates,
      courseProgress: courseProgress ?? this.courseProgress,
      lastActive: lastActive ?? this.lastActive,
      lastStreakUpdate: lastStreakUpdate ?? this.lastStreakUpdate,
    );
  }
}

UserRole _roleFromString(String? value) {
  switch (value) {
    case 'teacher':
      return UserRole.teacher;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.student;
  }
}
