import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlprac/models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            dateCreated INTEGER,
            dueDate INTEGER,
            isStarred INTEGER,
            isComplete INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Handle database migration or upgrade logic here
      },
    );
  }

  Future close() async {
    final db = await instance.database;
    db?.close();
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    if (db != null) {
      return await db.insert('tasks', task.toMap());
    }
    return -1;
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        orderBy: 'dateCreated DESC',
      );
      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    }
    return [];
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    if (db != null) {
      return await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    }
    return -1;
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    if (db != null) {
      return await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return -1;
  }
}
