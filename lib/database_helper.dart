import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Initialize sqflite for desktop platforms
  static void initialize() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print('🖥️ Initializing sqflite_ffi for desktop platform...');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      print('📱 Using default sqflite for mobile platform...');
    }
  }

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ict602.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop, use documents directory
      final documentsDir = await getDatabasesPath();
      path = join(documentsDir, filePath);
    } else {
      // For mobile, use default path
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }
    
    print('📁 Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    print('🛠️ Creating database tables...');
    
    // Create users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        username TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Create marks table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS marks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_username TEXT NOT NULL,
        test_20 REAL NOT NULL DEFAULT 0,
        assignment_10 REAL NOT NULL DEFAULT 0,
        project_20 REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (student_username) REFERENCES users(username)
      )
    ''');

    print('✅ Tables created successfully');

    // Insert initial data
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    print('📝 Inserting sample data...');
    
    // Check if users already exist
    final existingUsers = await db.query('users');
    
    if (existingUsers.isEmpty) {
      // Insert users
      await db.insert('users', {'username': 'admin', 'password': 'admin123', 'role': 'admin'});
      await db.insert('users', {'username': 'lect1', 'password': 'lect123', 'role': 'lecturer'});
      await db.insert('users', {'username': 'student1', 'password': 'stud123', 'role': 'student'});
      await db.insert('users', {'username': 'student2', 'password': 'stud234', 'role': 'student'});
      
      print("✅ Sample user accounts inserted successfully");
      
      // Insert sample marks
      await db.insert('marks', {
        'student_username': 'student1',
        'test_20': 85.0,
        'assignment_10': 90.0,
        'project_20': 80.0
      });
      
      await db.insert('marks', {
        'student_username': 'student2',
        'test_20': 75.0,
        'assignment_10': 80.0,
        'project_20': 70.0
      });
      
      print("✅ Sample marks inserted successfully");
    } else {
      print("📋 Database already has ${existingUsers.length} users");
    }
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    print('🔐 Login attempt: $username');
    
    final db = await instance.database; 
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    print('📊 Login query result: ${res.length} records found');
    
    if (res.isNotEmpty) {
      print('✅ User found: ${res.first}');
      return res.first;
    } else {
      print('❌ No user found with these credentials');
      return null;
    }
  }
  
  Future<List<Map<String, dynamic>>> getStudents() async {
    print('📋 Getting students list...');
    final db = await instance.database;
    return db.query('users', where: 'role = ?', whereArgs: ['student']);
  }

  Future<Map<String, dynamic>?> getStudentMarks(String studentUsername) async {
    print('📊 Getting marks for: $studentUsername');
    final db = await instance.database;
    final res = await db.query(
      'marks',
      columns: ['test_20', 'assignment_10', 'project_20'],
      where: 'student_username = ?',
      whereArgs: [studentUsername],
      limit: 1,
    );
    
    print('📈 Marks result: ${res.length} records');
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> saveMarks({
    required String studentUsername,
    required double testMark,
    required double assignmentMark,
    required double projectMark,
  }) async {
    print('💾 Saving marks for: $studentUsername');
    final db = await instance.database;

    final existingMarks = await getStudentMarks(studentUsername);

    final data = {
      'student_username': studentUsername,
      'test_20': testMark,
      'assignment_10': assignmentMark,
      'project_20': projectMark,
    };

    if (existingMarks != null) {
      print('🔄 Updating existing marks');
      return db.update(
        'marks',
        data,
        where: 'student_username = ?',
        whereArgs: [studentUsername],
      );
    } else {
      print('➕ Inserting new marks');
      return db.insert('marks', data);
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('🔒 Database closed');
    }
  }
}