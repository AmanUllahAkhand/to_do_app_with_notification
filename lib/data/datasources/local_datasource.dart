import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';

class LocalDataSource {
  static final LocalDataSource instance = LocalDataSource._init();
  static Database? _database;

  LocalDataSource._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // ← Bump version for priority column
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Create table (first install)
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        notes TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        hasReminder INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 1   -- 0=High, 1=Medium, 2=Low
      )
    ''');
  }

  // Add priority column if upgrading from old version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER NOT NULL DEFAULT 1');
    }
  }

  /// Get all tasks
  Future<List<TaskModel>> getTasks() async {
    final db = await instance.database;
    final maps = await db.query('tasks', orderBy: 'priority ASC, date ASC');
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  /// Add task and return its database ID
  Future<int> addTask(TaskModel task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  /// Update existing task
  Future<void> updateTask(TaskModel task) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Delete task by ID
  Future<void> deleteTask(int id) async {
    final db = await instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Mark task as completed
  Future<void> completeTask(int id) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      {'isCompleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Close database (optional)
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}