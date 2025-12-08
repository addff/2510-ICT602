import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  static FirebaseApp? _app;
  static FirebaseDatabase? _db;
  static String? _databaseUrl;

  static bool get ready => _app != null && _db != null;

  static Future<void> initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cfg = prefs.getString('firebase_web_config');
    final url = prefs.getString('firebase_database_url');
    if (cfg != null && url != null && cfg.isNotEmpty && url.isNotEmpty) {
      final m = jsonDecode(cfg) as Map<String, dynamic>;
      await initWithConfig(m, url);
    }
  }

  static Future<void> initWithConfig(Map<String, dynamic> cfg, String databaseUrl) async {
    _databaseUrl = databaseUrl;
    _app = await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: cfg['apiKey'],
        appId: cfg['appId'],
        projectId: cfg['projectId'],
        messagingSenderId: cfg['messagingSenderId'],
      ),
    );
    _db = FirebaseDatabase.instanceFor(app: _app!, databaseURL: _databaseUrl!);
  }

  static Future<void> saveConfig(Map<String, dynamic> cfg, String databaseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase_web_config', jsonEncode(cfg));
    await prefs.setString('firebase_database_url', databaseUrl);
    await initWithConfig(cfg, databaseUrl);
  }

  static DatabaseReference marksRef() {
    return _db!.ref('marks');
  }

  static DatabaseReference studentsRef() {
    return _db!.ref('students');
  }

  static DatabaseReference targetsRef() {
    return _db!.ref('targets');
  }

  static DatabaseReference subjectsRootRef() {
    return _db!.ref('subjects');
  }

  static DatabaseReference subjectMarksRootRef() {
    return _db!.ref('subjectMarks');
  }

  static DatabaseReference subjectTargetsRootRef() {
    return _db!.ref('subjectTargets');
  }

  static Future<Map<String, dynamic>> fetchMarks() async {
    final snap = await marksRef().get();
    if (!snap.exists) return {};
    final val = snap.value;
    return Map<String, dynamic>.from(val as Map);
  }

  static Future<Map<String, dynamic>> fetchStudents() async {
    final snap = await studentsRef().get();
    if (!snap.exists) return {};
    final val = snap.value;
    return Map<String, dynamic>.from(val as Map);
  }

  static Future<Map<String, dynamic>> fetchTargets() async {
    final snap = await targetsRef().get();
    if (!snap.exists) return {};
    final val = snap.value;
    return Map<String, dynamic>.from(val as Map);
  }

  static Future<Map<String, dynamic>> fetchSubjects() async {
    final snap = await subjectsRootRef().get();
    if (!snap.exists) return {};
    final val = snap.value;
    return Map<String, dynamic>.from(val as Map);
  }

  static Future<Map<String, dynamic>> fetchSubjectMarks() async {
    final snap = await subjectMarksRootRef().get();
    if (!snap.exists) return {};
    final val = snap.value;
    return Map<String, dynamic>.from(val as Map);
  }

  static Future<Map<String, dynamic>> fetchSubjectTargets() async {
    final snap = await subjectTargetsRootRef().get();
    if (!snap.exists) return {};
    final val = snap.value;
    return Map<String, dynamic>.from(val as Map);
  }

  static Future<void> saveMark(String id, Map<String, dynamic> data) async {
    await marksRef().child(id).set(data);
  }

  static Future<void> saveStudent(String id, String password) async {
    await studentsRef().child(id).set(password);
  }

  static Future<void> saveTarget(String id, int min) async {
    await targetsRef().child(id).set(min);
  }

  static Future<void> saveSubject(String studentId, String subject) async {
    await subjectsRootRef().child(studentId).child(subject).set(true);
  }

  static Future<void> saveSubjectMark(String studentId, String subject, Map<String, dynamic> data) async {
    await subjectMarksRootRef().child(studentId).child(subject).set(data);
  }

  static Future<void> saveSubjectTarget(String studentId, String subject, int min) async {
    await subjectTargetsRootRef().child(studentId).child(subject).set(min);
  }

  static Future<void> deleteMark(String id) async {
    await marksRef().child(id).remove();
  }

  static Future<void> clearAll() async {
    await marksRef().remove();
  }
}
