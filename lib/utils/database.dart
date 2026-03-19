import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'gameed.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        role INTEGER,
        school TEXT,
        grade TEXT,
        xp INTEGER,
        level INTEGER,
        streak INTEGER,
        trophies TEXT,
        completedLessons TEXT,
        completedQuizzes TEXT,
        lastActive TEXT
      )
    ''');

    // Lessons table
    await db.execute('''
      CREATE TABLE lessons(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        category TEXT,
        difficulty TEXT,
        duration INTEGER,
        content TEXT,
        xpReward INTEGER,
        isCompleted INTEGER,
        isOfflineAvailable INTEGER
      )
    ''');

    // Quizzes table
    await db.execute('''
      CREATE TABLE quizzes(
        id TEXT PRIMARY KEY,
        title TEXT,
        questions TEXT,
        xpReward INTEGER,
        trophyReward TEXT,
        isCompleted INTEGER,
        highScore INTEGER
      )
    ''');

    // Trophies table
    await db.execute('''
      CREATE TABLE trophies(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        imagePath TEXT,
        rarity INTEGER,
        isEarned INTEGER,
        earnedAt TEXT
      )
    ''');

    // Progress table
    await db.execute('''
      CREATE TABLE progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        lessonId TEXT,
        quizId TEXT,
        progress REAL,
        isCompleted INTEGER,
        completedAt TEXT,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    Database db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    Database db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    Database db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    Database db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    Database db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}