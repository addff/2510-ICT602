import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ict602.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Create Users Table
    await db.execute('''
    CREATE TABLE users (
      username TEXT PRIMARY KEY,
      password TEXT,
      role TEXT
    )
    ''');

    // 2. Create Marks Table
    await db.execute('''
    CREATE TABLE marks (
      student_username TEXT PRIMARY KEY,
      test INTEGER,
      assignment INTEGER,
      project INTEGER
    )
    ''');

    // 3. SEED DATA (So you can login immediately)
    await db.insert('users', {
      'username': 'admin',
      'password': '123',
      'role': 'admin',
    });
    await db.insert('users', {
      'username': 'lecturer',
      'password': '123',
      'role': 'lecturer',
    });
    await db.insert('users', {
      'username': 'student',
      'password': '123',
      'role': 'student',
    });

    // Initialize marks for the student (0 initially)
    await db.insert('marks', {
      'student_username': 'student',
      'test': 0,
      'assignment': 0,
      'project': 0,
    });
  }

  Future<Map<String, dynamic>?> login(String user, String pass) async {
    final db = await instance.database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [user, pass],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> updateMarks(
    String studentId,
    int test,
    int assign,
    int project,
  ) async {
    final db = await instance.database;
    await db.update(
      'marks',
      {'test': test, 'assignment': assign, 'project': project},
      where: 'student_username = ?',
      whereArgs: [studentId],
    );
  }

  Future<Map<String, dynamic>> getMarks(String studentId) async {
    final db = await instance.database;
    final res = await db.query(
      'marks',
      where: 'student_username = ?',
      whereArgs: [studentId],
    );
    return res.isNotEmpty
        ? res.first
        : {'test': 0, 'assignment': 0, 'project': 0};
  }
}
