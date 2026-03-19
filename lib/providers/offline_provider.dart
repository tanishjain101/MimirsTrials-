import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';

class OfflineProvider extends ChangeNotifier {
  static Database? _database;
  List<Lesson> _downloadedLessons = [];
  List<Quiz> _downloadedQuizzes = [];
  bool _isInitialized = false;
  bool _quizMusicColumnEnsured = false;

  List<Lesson> get downloadedLessons => _downloadedLessons;
  List<Quiz> get downloadedQuizzes => _downloadedQuizzes;
  bool get isInitialized => _isInitialized;
  List<String> get downloadedResources {
    final set = <String>{};
    for (final lesson in _downloadedLessons) {
      set.addAll(lesson.resources.where((resource) => resource.trim().isNotEmpty));
    }
    return set.toList()..sort();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'gameed_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lessons(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        content TEXT,
        type INTEGER,
        duration INTEGER,
        xpReward INTEGER,
        resources TEXT,
        isCompleted INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE quizzes(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        timeLimit INTEGER,
        xpReward INTEGER,
        gemReward INTEGER,
        category TEXT,
        musicAssetPath TEXT,
        questions TEXT,
        isCompleted INTEGER
      )
    ''');
  }

  Future<void> saveLesson(Lesson lesson) async {
    final db = await database;
    await db.insert(
      'lessons',
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadDownloadedLessons();
  }

  Future<void> saveQuiz(Quiz quiz) async {
    final db = await database;
    await _ensureQuizMusicColumn(db);
    await db.insert(
      'quizzes',
      {
        'id': quiz.id,
        'title': quiz.title,
        'description': quiz.description,
        'timeLimit': quiz.timeLimit,
        'xpReward': quiz.xpReward,
        'gemReward': quiz.gemReward,
        'category': quiz.category,
        'musicAssetPath': quiz.musicAssetPath,
        'questions': jsonEncode(quiz.questions.map((q) => q.toMap()).toList()),
        'isCompleted': quiz.isCompleted ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadDownloadedQuizzes();
  }

  Future<void> loadDownloadedLessons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('lessons');

    _downloadedLessons = List.generate(maps.length, (i) {
      return Lesson.fromMap(maps[i]);
    });
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> loadDownloadedQuizzes() async {
    final db = await database;
    await _ensureQuizMusicColumn(db);
    final List<Map<String, dynamic>> maps = await db.query('quizzes');

    _downloadedQuizzes = List.generate(maps.length, (i) {
      final data = maps[i];
      data['questions'] = (jsonDecode(data['questions']) as List)
          .map((q) => Question.fromMap(q))
          .toList();
      return Quiz(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        timeLimit: data['timeLimit'],
        xpReward: data['xpReward'],
        gemReward: data['gemReward'],
        category: data['category'] ?? 'General',
        musicAssetPath: data['musicAssetPath'] as String?,
        questions: data['questions'],
        isCompleted: data['isCompleted'] == 1,
      );
    });
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadDownloadedLessons();
    await loadDownloadedQuizzes();
  }

  Future<void> saveLessonBundle({
    required Lesson lesson,
    List<Quiz> relatedQuizzes = const [],
  }) async {
    await saveLesson(lesson);
    for (final quiz in relatedQuizzes) {
      await saveQuiz(quiz);
    }
    await loadDownloadedLessons();
    await loadDownloadedQuizzes();
  }

  Future<void> saveCategoryBundle({
    required List<Lesson> lessons,
    required List<Quiz> quizzes,
  }) async {
    for (final lesson in lessons) {
      await saveLesson(lesson);
    }
    for (final quiz in quizzes) {
      await saveQuiz(quiz);
    }
    await loadDownloadedLessons();
    await loadDownloadedQuizzes();
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('lessons');
    await db.delete('quizzes');
    _downloadedLessons = [];
    _downloadedQuizzes = [];
    notifyListeners();
  }

  Future<void> deleteLesson(String id) async {
    final db = await database;
    await db.delete(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadDownloadedLessons();
  }

  Future<void> deleteQuiz(String id) async {
    final db = await database;
    await db.delete(
      'quizzes',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadDownloadedQuizzes();
  }

  Future<bool> isLessonDownloaded(String id) async {
    final db = await database;
    final result = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<Lesson?> getOfflineLesson(String id) async {
    final db = await database;
    final result = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Lesson.fromMap(result.first);
    }
    return null;
  }

  Future<Quiz?> getOfflineQuiz(String id) async {
    final db = await database;
    await _ensureQuizMusicColumn(db);
    final result = await db.query(
      'quizzes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final data = result.first;
      final questions = (jsonDecode(data['questions'] as String) as List)
          .map((q) => Question.fromMap(Map<String, dynamic>.from(q)))
          .toList();
      return Quiz(
        id: data['id'] as String,
        title: data['title'] as String,
        description: data['description'] as String,
        timeLimit: data['timeLimit'] as int,
        xpReward: data['xpReward'] as int,
        gemReward: data['gemReward'] as int,
        category: data['category'] as String? ?? 'General',
        musicAssetPath: data['musicAssetPath'] as String?,
        questions: questions,
        isCompleted: (data['isCompleted'] as int? ?? 0) == 1,
      );
    }
    return null;
  }

  Future<void> _ensureQuizMusicColumn(Database db) async {
    if (_quizMusicColumnEnsured) return;
    final tableInfo = await db.rawQuery('PRAGMA table_info(quizzes)');
    final hasColumn = tableInfo.any((row) => row['name'] == 'musicAssetPath');
    if (!hasColumn) {
      try {
        await db.execute('ALTER TABLE quizzes ADD COLUMN musicAssetPath TEXT');
      } catch (_) {
        // Column may have been added by another async call.
      }
    }
    _quizMusicColumnEnsured = true;
  }
}
