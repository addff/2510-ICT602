import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/carry_mark.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _db;

  // In-memory fallback for web
  final List<User> _inMemoryUsers = [];
  final List<Student> _inMemoryStudents = [];
  final List<CarryMark> _inMemoryMarks = [];

  static const String _kWebUsersKey = 'web_users_v1';
  static const String _kWebStudentsKey = 'web_students_v1';
  static const String _kWebMarksKey = 'web_marks_v1';

  Future<void> initForWeb() async {
    // attempt to load persisted web state first
    final loaded = await _loadWebState();
    if (loaded) return;

    // seed demo data for web (in-memory)
    _inMemoryUsers.clear();
    _inMemoryStudents.clear();
    _inMemoryMarks.clear();

    final admin = User(id: 1, username: 'admin', password: 'admin', role: 'admin', email: 'ahmad.zaki@gmail.com');
    final lecturer = User(id: 2, username: 'lecturer', password: 'lecturer', role: 'lecturer', email: 'aisyah.rahman@gmail.com');
    final studentUser1 = User(id: 3, username: 'student', password: 'student', role: 'student', email: 'nurul.amina@gmail.com');
    final studentUser2 = User(id: 4, username: 'student2', password: 'student2', role: 'student', email: 'ahmad.faiz@gmail.com');
    final studentUser3 = User(id: 5, username: 'student3', password: 'student3', role: 'student', email: 'siti.mariam@gmail.com');
    _inMemoryUsers.addAll([admin, lecturer, studentUser1, studentUser2, studentUser3]);

    final student1 = Student(id: 1, userId: studentUser1.id!, name: 'Nurul Amina');
    final student2 = Student(id: 2, userId: studentUser2.id!, name: 'Ahmad Faiz');
    final student3 = Student(id: 3, userId: studentUser3.id!, name: 'Siti Mariam');
    _inMemoryStudents.addAll([student1, student2, student3]);

    final defaultCarry1 = CarryMark(id: 1, studentId: student1.id!, test: 60, assignment: 60, project: 60);
    final defaultCarry2 = CarryMark(id: 2, studentId: student2.id!, test: 70, assignment: 65, project: 75);
    final defaultCarry3 = CarryMark(id: 3, studentId: student3.id!, test: 50, assignment: 55, project: 60);
    _inMemoryMarks.addAll([defaultCarry1, defaultCarry2, defaultCarry3]);

    // persist initial seed so subsequent reloads keep the seeded data
    await _saveWebState();
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('ict602.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // add email column if missing when upgrading from v1 to v2
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
        // set default emails for existing rows using username with gmail domain
        await db.rawUpdate("UPDATE users SET email = username || '@gmail.com'");
      } catch (e) {
        // ignore if column already exists
      }
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE carry_marks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER,
        test REAL,
        assignment REAL,
        project REAL,
        carry_total REAL
      )
    ''');

    // Seed demo users (with emails)
    await db.insert('users', User(username: 'admin', password: 'admin', role: 'admin', email: 'ahmad.zaki@gmail.com').toMap());
    await db.insert('users', User(username: 'lecturer', password: 'lecturer', role: 'lecturer', email: 'aisyah.rahman@gmail.com').toMap());
    final studentUserId1 = await db.insert('users', User(username: 'student', password: 'student', role: 'student', email: 'nurul.amina@gmail.com').toMap());
    final studentUserId2 = await db.insert('users', User(username: 'student2', password: 'student2', role: 'student', email: 'ahmad.faiz@gmail.com').toMap());
    final studentUserId3 = await db.insert('users', User(username: 'student3', password: 'student3', role: 'student', email: 'siti.mariam@gmail.com').toMap());

    // Seed student records linked to the student users
    final studentId1 = await db.insert('students', Student(userId: studentUserId1, name: 'Nurul Amina').toMap());
    final studentId2 = await db.insert('students', Student(userId: studentUserId2, name: 'Ahmad Faiz').toMap());
    final studentId3 = await db.insert('students', Student(userId: studentUserId3, name: 'Siti Mariam').toMap());

    // Seed carry marks for the sample students
    final defaultCarry1 = CarryMark(studentId: studentId1, test: 60, assignment: 60, project: 60);
    final defaultCarry2 = CarryMark(studentId: studentId2, test: 70, assignment: 65, project: 75);
    final defaultCarry3 = CarryMark(studentId: studentId3, test: 50, assignment: 55, project: 60);
    await db.insert('carry_marks', defaultCarry1.toMap());
    await db.insert('carry_marks', defaultCarry2.toMap());
    await db.insert('carry_marks', defaultCarry3.toMap());
  }

  // User operations
  Future<int> insertUser(User user) async {
    if (kIsWeb) {
      final id = (_inMemoryUsers.isEmpty ? 1 : (_inMemoryUsers.last.id ?? 0) + 1);
      final u = User(id: id, username: user.username, password: user.password, role: user.role, email: user.email);
      _inMemoryUsers.add(u);
      await _saveWebState();
      return id;
    }
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    if (kIsWeb) {
      try {
        final u = _inMemoryUsers.firstWhere((u) => u.username == username);
        return u;
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  /// Find a user by username OR email. Accepts either identifier.
  Future<User?> getUserByUsernameOrEmail(String identifier) async {
    if (kIsWeb) {
      try {
        final u = _inMemoryUsers.firstWhere((u) => u.username == identifier || u.email == identifier);
        return u;
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    final maps = await db.query('users', where: 'username = ? OR email = ?', whereArgs: [identifier, identifier], limit: 1);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<User?> getUserById(int id) async {
    if (kIsWeb) {
      try {
        return _inMemoryUsers.firstWhere((u) => u.id == id);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    if (kIsWeb) {
      return List<User>.from(_inMemoryUsers);
    }
    final db = await database;
    final maps = await db.query('users');
    return maps.map((m) => User.fromMap(m)).toList();
  }

  // Update user
  Future<int> updateUser(User user) async {
    if (kIsWeb) {
      final idx = _inMemoryUsers.indexWhere((u) => u.id == user.id);
      if (idx == -1) return 0;
      _inMemoryUsers[idx] = user;
      await _saveWebState();
      return 1;
    }
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Delete user (and cascade student & carry marks if a student)
  Future<int> deleteUser(int id) async {
    if (kIsWeb) {
      final userIdx = _inMemoryUsers.indexWhere((u) => u.id == id);
      if (userIdx == -1) return 0;
      final user = _inMemoryUsers.removeAt(userIdx);
      // remove student records and marks
      final studentIdx = _inMemoryStudents.indexWhere((s) => s.userId == user.id);
      if (studentIdx != -1) {
        final student = _inMemoryStudents.removeAt(studentIdx);
        _inMemoryMarks.removeWhere((m) => m.studentId == student.id);
      }
      await _saveWebState();
      return 1;
    }

    // native DB path: remove student + marks if any
    final db = await database;
    final studentMaps = await db.query('students', where: 'user_id = ?', whereArgs: [id], limit: 1);
    if (studentMaps.isNotEmpty) {
      final student = Student.fromMap(studentMaps.first);
      await db.delete('carry_marks', where: 'student_id = ?', whereArgs: [student.id]);
      await db.delete('students', where: 'id = ?', whereArgs: [student.id]);
    }
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Update student
  Future<int> updateStudent(Student student) async {
    if (kIsWeb) {
      final idx = _inMemoryStudents.indexWhere((s) => s.id == student.id);
      if (idx == -1) return 0;
      _inMemoryStudents[idx] = student;
      await _saveWebState();
      return 1;
    }
    final db = await database;
    return await db.update('students', student.toMap(), where: 'id = ?', whereArgs: [student.id]);
  }

  // Delete student by user id (and associated marks)
  Future<int> deleteStudentByUserId(int userId) async {
    if (kIsWeb) {
      final idx = _inMemoryStudents.indexWhere((s) => s.userId == userId);
      if (idx == -1) return 0;
      final st = _inMemoryStudents.removeAt(idx);
      _inMemoryMarks.removeWhere((m) => m.studentId == st.id);
      await _saveWebState();
      return 1;
    }
    final db = await database;
    final maps = await db.query('students', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    if (maps.isEmpty) return 0;
    final st = Student.fromMap(maps.first);
    await db.delete('carry_marks', where: 'student_id = ?', whereArgs: [st.id]);
    return await db.delete('students', where: 'id = ?', whereArgs: [st.id]);
  }

  // Delete carry marks by student id
  Future<int> deleteCarryMarksByStudentId(int studentId) async {
    if (kIsWeb) {
      final before = _inMemoryMarks.length;
      _inMemoryMarks.removeWhere((m) => m.studentId == studentId);
      await _saveWebState();
      return before - _inMemoryMarks.length;
    }
    final db = await database;
    return await db.delete('carry_marks', where: 'student_id = ?', whereArgs: [studentId]);
  }

  // Student operations
  Future<int> insertStudent(Student student) async {
    if (kIsWeb) {
      final id = (_inMemoryStudents.isEmpty ? 1 : (_inMemoryStudents.last.id ?? 0) + 1);
      final s = Student(id: id, userId: student.userId, name: student.name);
      _inMemoryStudents.add(s);
      await _saveWebState();
      return id;
    }
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getAllStudents() async {
    if (kIsWeb) {
      return List<Student>.from(_inMemoryStudents);
    }
    final db = await database;
    final maps = await db.query('students');
    return maps.map((m) => Student.fromMap(m)).toList();
  }

  Future<Student?> getStudentByUserId(int userId) async {
    if (kIsWeb) {
      try {
        return _inMemoryStudents.firstWhere((s) => s.userId == userId);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final maps = await db.query('students', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    if (maps.isNotEmpty) return Student.fromMap(maps.first);
    return null;
  }

  // Carry mark operations
  Future<int> insertCarryMark(CarryMark mark) async {
    if (kIsWeb) {
      final id = (_inMemoryMarks.isEmpty ? 1 : (_inMemoryMarks.last.id ?? 0) + 1);
      final m = CarryMark(id: id, studentId: mark.studentId, test: mark.test, assignment: mark.assignment, project: mark.project);
      _inMemoryMarks.add(m);
      await _saveWebState();
      return id;
    }
    final db = await database;
    return await db.insert('carry_marks', mark.toMap());
  }

  Future<int> updateCarryMark(CarryMark mark) async {
    if (kIsWeb) {
      final idx = _inMemoryMarks.indexWhere((m) => m.id == mark.id);
      if (idx == -1) return 0;
      _inMemoryMarks[idx] = CarryMark(id: mark.id, studentId: mark.studentId, test: mark.test, assignment: mark.assignment, project: mark.project);
      await _saveWebState();
      return 1;
    }
    final db = await database;
    return await db.update('carry_marks', mark.toMap(), where: 'id = ?', whereArgs: [mark.id]);
  }

  Future<List<CarryMark>> getCarryMarksByStudentId(int studentId) async {
    if (kIsWeb) {
      return _inMemoryMarks.where((m) => m.studentId == studentId).toList();
    }
    final db = await database;
    final maps = await db.query('carry_marks', where: 'student_id = ?', whereArgs: [studentId]);
    return maps.map((m) => CarryMark.fromMap(m)).toList();
  }

  // Web persistence helpers
  Future<void> _saveWebState() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = jsonEncode(_inMemoryUsers.map((u) => u.toMap()).toList());
    final studentsJson = jsonEncode(_inMemoryStudents.map((s) => s.toMap()).toList());
    final marksJson = jsonEncode(_inMemoryMarks.map((m) => m.toMap()).toList());
    await prefs.setString(_kWebUsersKey, usersJson);
    await prefs.setString(_kWebStudentsKey, studentsJson);
    await prefs.setString(_kWebMarksKey, marksJson);
  }

  Future<bool> _loadWebState() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString(_kWebUsersKey);
    final s = prefs.getString(_kWebStudentsKey);
    final m = prefs.getString(_kWebMarksKey);
    if (u == null || s == null || m == null) return false;
    try {
      final List<dynamic> usersList = jsonDecode(u) as List<dynamic>;
      final List<dynamic> studentsList = jsonDecode(s) as List<dynamic>;
      final List<dynamic> marksList = jsonDecode(m) as List<dynamic>;
      _inMemoryUsers
        ..clear()
        ..addAll(usersList.map((e) => User.fromMap(Map<String, dynamic>.from(e as Map))));
      _inMemoryStudents
        ..clear()
        ..addAll(studentsList.map((e) => Student.fromMap(Map<String, dynamic>.from(e as Map))));
      _inMemoryMarks
        ..clear()
        ..addAll(marksList.map((e) => CarryMark.fromMap(Map<String, dynamic>.from(e as Map))));
      return true;
    } catch (_) {
      return false;
    }
  }
}
