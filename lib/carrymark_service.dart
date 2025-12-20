import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CarryMarkService {
  static Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(join(dbPath, 'ict602.db'));
  }

  static Future<List<String>> getAllStudents() async {
    final db = await _openDb();
    final rows = await db.rawQuery('SELECT username FROM users WHERE role = ?', ['student']);
    await db.close();
    return rows.map((r) => r['username'] as String).toList();
  }

  static Future<Map<String, dynamic>?> getMarks(String studentUsername) async {
    final db = await _openDb();
    final rows = await db.query('marks', where: 'studentUsername = ?', whereArgs: [studentUsername]);
    await db.close();
    if (rows.isEmpty) return null;
    return rows.first;
  }

  static Future<void> upsertMarks(String studentUsername, double test, double assignment, double project) async {
    final db = await _openDb();
    final rows = await db.query('marks', where: 'studentUsername = ?', whereArgs: [studentUsername]);
    if (rows.isEmpty) {
      await db.insert('marks', {'studentUsername': studentUsername, 'test': test, 'assignment': assignment, 'project': project});
    } else {
      await db.update('marks', {'test': test, 'assignment': assignment, 'project': project}, where: 'studentUsername = ?', whereArgs: [studentUsername]);
    }
    await db.close();
  }
}
