import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'gameed.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        level INTEGER,
        xp INTEGER,
        streak INTEGER,
        gems INTEGER,
        hearts INTEGER,
        completedLessons TEXT,
        achievements TEXT,
        lastActive TEXT
      )
    ''');

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
        isCompleted INTEGER,
        isOfflineAvailable INTEGER
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
        questions TEXT,
        isCompleted INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        lessonId TEXT,
        quizId TEXT,
        progress REAL,
        isCompleted INTEGER,
        completedAt TEXT
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveLesson(Lesson lesson) async {
    final db = await database;
    await db.insert(
      'lessons',
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Lesson?> getLesson(String id) async {
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

  Future<List<Lesson>> getAllLessons() async {
    final db = await database;
    final result = await db.query('lessons');
    return result.map((map) => Lesson.fromMap(map)).toList();
  }

  Future<void> saveQuiz(Quiz quiz) async {
    final db = await database;
    final data = {
      'id': quiz.id,
      'title': quiz.title,
      'description': quiz.description,
      'timeLimit': quiz.timeLimit,
      'xpReward': quiz.xpReward,
      'gemReward': quiz.gemReward,
      'questions': jsonEncode(quiz.questions.map((q) => q.toMap()).toList()),
      'isCompleted': quiz.isCompleted ? 1 : 0,
    };
    await db.insert('quizzes', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Quiz?> getQuiz(String id) async {
    final db = await database;
    final result = await db.query(
      'quizzes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final data = result.first;
      if (data['questions'] is String) {
        data['questions'] = jsonDecode(data['questions'] as String);
      }
      return Quiz.fromMap(data);
    }
    return null;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
