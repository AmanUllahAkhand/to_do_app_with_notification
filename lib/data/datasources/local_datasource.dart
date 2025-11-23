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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        notes TEXT,
        isCompleted INTEGER NOT NULL,
        hasReminder INTEGER NOT NULL
      )
    ''');
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await instance.database;
    final maps = await db.query('tasks');
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<void> addTask(TaskModel task) async {
    final db = await instance.database;
    await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await instance.database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> completeTask(int id) async {
    final db = await instance.database;
    await db.update('tasks', {'isCompleted': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}