import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../services/firebase_service.dart';

enum UserRole { admin, lecturer, student }

class User {
  final String id;
  final UserRole role;
  User({required this.id, required this.role});
}

class CarryMark {
  final double test20;
  final double assignment10;
  final double project20;
  CarryMark({required this.test20, required this.assignment10, required this.project20});
  double get total => test20 + assignment10 + project20;
}

class AppState extends ChangeNotifier {
  User? currentUser;
  final Map<String, CarryMark> marks = {};
  final String databaseUrl = 'https://ict602project-d1673-default-rtdb.asia-southeast1.firebasedatabase.app';
  bool remoteEnabled = true;
  String? lastSyncError;
  String? idToken;
  bool useFirebaseSdk = false;
  final Map<String, String> students = {};
  final Map<String, int> targets = {};
  final Map<String, List<String>> subjects = {};
  final Map<String, Map<String, CarryMark>> subjectMarks = {};
  final Map<String, Map<String, int>> subjectTargets = {};

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('marks_json');
    if (json != null && json.isNotEmpty) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(await _decode(json));
      map.forEach((key, value) {
        final v = Map<String, dynamic>.from(value as Map);
        marks[key] = CarryMark(
          test20: (v['test20'] as num).toDouble(),
          assignment10: (v['assignment10'] as num).toDouble(),
          project20: (v['project20'] as num).toDouble(),
        );
      });
      notifyListeners();
    }
    final sj = prefs.getString('students_json');
    if (sj != null && sj.isNotEmpty) {
      final Map<String, dynamic> smap = Map<String, dynamic>.from(await _decode(sj));
      smap.forEach((id, pass) { students[id] = pass as String; });
    }
    final tj = prefs.getString('targets_json');
    if (tj != null && tj.isNotEmpty) {
      final Map<String, dynamic> tmap = Map<String, dynamic>.from(await _decode(tj));
      tmap.forEach((id, min) { targets[id] = (min as num).toInt(); });
    }
    final subj = prefs.getString('subjects_json');
    if (subj != null && subj.isNotEmpty) {
      final Map<String, dynamic> sm = Map<String, dynamic>.from(await _decode(subj));
      sm.forEach((id, list) { subjects[id] = List<String>.from(list as List); });
    }
    final smarks = prefs.getString('subject_marks_json');
    if (smarks != null && smarks.isNotEmpty) {
      final Map<String, dynamic> mm = Map<String, dynamic>.from(await _decode(smarks));
      mm.forEach((id, submap) {
        final Map<String, dynamic> m2 = Map<String, dynamic>.from(submap as Map);
        subjectMarks[id] = {};
        m2.forEach((subject, v) {
          final m = Map<String, dynamic>.from(v as Map);
          subjectMarks[id]![subject] = CarryMark(
            test20: (m['test20'] as num).toDouble(),
            assignment10: (m['assignment10'] as num).toDouble(),
            project20: (m['project20'] as num).toDouble(),
          );
        });
      });
    }
    final stjson = prefs.getString('subject_targets_json');
    if (stjson != null && stjson.isNotEmpty) {
      final Map<String, dynamic> st = Map<String, dynamic>.from(await _decode(stjson));
      st.forEach((id, submap) {
        final Map<String, dynamic> m2 = Map<String, dynamic>.from(submap as Map);
        subjectTargets[id] = {};
        m2.forEach((subject, min) { subjectTargets[id]![subject] = (min as num).toInt(); });
      });
    }
    idToken = prefs.getString('firebase_id_token');
    await FirebaseService.initFromPrefs();
    useFirebaseSdk = FirebaseService.ready;
    await syncFromRemote();
  }

  bool login({required String username, required String password, required UserRole role}) {
    if (role == UserRole.admin) {
      if (username == 'admin' && password == 'admin123') {
        currentUser = User(id: username, role: role);
        notifyListeners();
        return true;
      }
      return false;
    }
    if (role == UserRole.lecturer) {
      if (username == 'lecturer' && password == 'lect123') {
        currentUser = User(id: username, role: role);
        notifyListeners();
        return true;
      }
      return false;
    }
    if (role == UserRole.student) {
      final p = students[username];
      if (p != null && p == password) {
        currentUser = User(id: username, role: role);
        notifyListeners();
        return true;
      }
      return false;
    }
    return false;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void saveMark(String studentId, double test20, double assignment10, double project20) {
    marks[studentId] = CarryMark(test20: test20, assignment10: assignment10, project20: project20);
    notifyListeners();
    _persist();
    if (remoteEnabled) _dbSaveMark(studentId, marks[studentId]!);
  }

  CarryMark? getMark(String studentId) => marks[studentId];

  List<MapEntry<String, CarryMark>> allMarks() => marks.entries.toList();

  void deleteMark(String studentId) {
    marks.remove(studentId);
    notifyListeners();
    _persist();
    if (remoteEnabled) _dbDeleteMark(studentId);
  }

  void clearMarks() {
    marks.clear();
    notifyListeners();
    _persist();
    if (remoteEnabled) _dbClearAll();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, Map<String, double>>{};
    marks.forEach((id, m) {
      map[id] = {'test20': m.test20, 'assignment10': m.assignment10, 'project20': m.project20};
    });
    final json = await _encode(map);
    await prefs.setString('marks_json', json);
    final smap = <String, String>{};
    students.forEach((id, pass) { smap[id] = pass; });
    final sjson = await _encode(smap);
    await prefs.setString('students_json', sjson);
    final tmap = <String, int>{};
    targets.forEach((id, min) { tmap[id] = min; });
    final tjson = await _encode(tmap);
    await prefs.setString('targets_json', tjson);
    final subjmap = <String, List<String>>{};
    subjects.forEach((id, list) { subjmap[id] = List<String>.from(list); });
    final subjjson = await _encode(subjmap);
    await prefs.setString('subjects_json', subjjson);
    final marksOut = <String, Map<String, Map<String, double>>>{};
    subjectMarks.forEach((id, submap) {
      marksOut[id] = {};
      submap.forEach((subject, m) {
        marksOut[id]![subject] = {'test20': m.test20, 'assignment10': m.assignment10, 'project20': m.project20};
      });
    });
    final smjson = await _encode(marksOut);
    await prefs.setString('subject_marks_json', smjson);
    final stOut = <String, Map<String, int>>{};
    subjectTargets.forEach((id, submap) { stOut[id] = Map<String, int>.from(submap); });
    final stOutJson = await _encode(stOut);
    await prefs.setString('subject_targets_json', stOutJson);
  }

  Future<String> _encode(Map<String, dynamic> map) async {
    return const JsonEncoder().convert(map);
  }

  Future<Map<String, dynamic>> _decode(String s) async {
    return const JsonDecoder().convert(s) as Map<String, dynamic>;
  }

  Future<void> syncFromRemote() async {
    try {
      if (!remoteEnabled) return;
      if (useFirebaseSdk) {
        final data = await FirebaseService.fetchMarks();
        marks.clear();
        data.forEach((id, v) {
          final m = Map<String, dynamic>.from(v as Map);
          marks[id] = CarryMark(
            test20: (m['test20'] as num).toDouble(),
            assignment10: (m['assignment10'] as num).toDouble(),
            project20: (m['project20'] as num).toDouble(),
          );
        });
        final sdata = await FirebaseService.fetchStudents();
        students.clear();
        sdata.forEach((id, v) { students[id] = v as String; });
        final tdata = await FirebaseService.fetchTargets();
        targets.clear();
        tdata.forEach((id, v) { targets[id] = (v as num).toInt(); });
        final subjData = await FirebaseService.fetchSubjects();
        subjects.clear();
        subjData.forEach((id, m) {
          final Map<String, dynamic> mm = Map<String, dynamic>.from(m as Map);
          subjects[id] = mm.keys.toList();
        });
        final subjMarksData = await FirebaseService.fetchSubjectMarks();
        subjectMarks.clear();
        subjMarksData.forEach((id, m) {
          final Map<String, dynamic> mm = Map<String, dynamic>.from(m as Map);
          subjectMarks[id] = {};
          mm.forEach((subject, v) {
            final x = Map<String, dynamic>.from(v as Map);
            subjectMarks[id]![subject] = CarryMark(
              test20: (x['test20'] as num).toDouble(),
              assignment10: (x['assignment10'] as num).toDouble(),
              project20: (x['project20'] as num).toDouble(),
            );
          });
        });
        final subjTargetsData = await FirebaseService.fetchSubjectTargets();
        subjectTargets.clear();
        subjTargetsData.forEach((id, m) {
          final Map<String, dynamic> mm = Map<String, dynamic>.from(m as Map);
          subjectTargets[id] = {};
          mm.forEach((subject, min) { subjectTargets[id]![subject] = (min as num).toInt(); });
        });
        notifyListeners();
        await _persist();
        lastSyncError = null;
      } else {
        final uri = _dbUri('/marks.json');
        final resp = await http.get(uri);
        if (resp.statusCode == 200 && resp.body.isNotEmpty && resp.body != 'null') {
          final Map<String, dynamic> data = jsonDecode(resp.body);
          marks.clear();
          data.forEach((id, v) {
            final m = Map<String, dynamic>.from(v as Map);
            marks[id] = CarryMark(
              test20: (m['test20'] as num).toDouble(),
              assignment10: (m['assignment10'] as num).toDouble(),
              project20: (m['project20'] as num).toDouble(),
            );
          });
          final suri = _dbUri('/students.json');
          final sresp = await http.get(suri);
          if (sresp.statusCode == 200 && sresp.body.isNotEmpty && sresp.body != 'null') {
            final Map<String, dynamic> sdata = jsonDecode(sresp.body);
            students.clear();
            sdata.forEach((id, v) { students[id] = v as String; });
          }
          final turi = _dbUri('/targets.json');
          final tresp = await http.get(turi);
          if (tresp.statusCode == 200 && tresp.body.isNotEmpty && tresp.body != 'null') {
            final Map<String, dynamic> tdata = jsonDecode(tresp.body);
            targets.clear();
            tdata.forEach((id, v) { targets[id] = (v as num).toInt(); });
          }
          final subjUri = _dbUri('/subjects.json');
          final subjResp = await http.get(subjUri);
          if (subjResp.statusCode == 200 && subjResp.body.isNotEmpty && subjResp.body != 'null') {
            final Map<String, dynamic> sd = jsonDecode(subjResp.body);
            subjects.clear();
            sd.forEach((id, m) {
              final Map<String, dynamic> mm = Map<String, dynamic>.from(m as Map);
              subjects[id] = mm.keys.toList();
            });
          }
          final smUri = _dbUri('/subjectMarks.json');
          final smResp = await http.get(smUri);
          if (smResp.statusCode == 200 && smResp.body.isNotEmpty && smResp.body != 'null') {
            final Map<String, dynamic> sd = jsonDecode(smResp.body);
            subjectMarks.clear();
            sd.forEach((id, m) {
              final Map<String, dynamic> mm = Map<String, dynamic>.from(m as Map);
              subjectMarks[id] = {};
              mm.forEach((subject, v) {
                final x = Map<String, dynamic>.from(v as Map);
                subjectMarks[id]![subject] = CarryMark(
                  test20: (x['test20'] as num).toDouble(),
                  assignment10: (x['assignment10'] as num).toDouble(),
                  project20: (x['project20'] as num).toDouble(),
                );
              });
            });
          }
          final stUri = _dbUri('/subjectTargets.json');
          final stResp = await http.get(stUri);
          if (stResp.statusCode == 200 && stResp.body.isNotEmpty && stResp.body != 'null') {
            final Map<String, dynamic> sd = jsonDecode(stResp.body);
            subjectTargets.clear();
            sd.forEach((id, m) {
              final Map<String, dynamic> mm = Map<String, dynamic>.from(m as Map);
              subjectTargets[id] = {};
              mm.forEach((subject, min) { subjectTargets[id]![subject] = (min as num).toInt(); });
            });
          }
          notifyListeners();
          await _persist();
          lastSyncError = null;
        } else {
          lastSyncError = 'HTTP ${resp.statusCode}';
        }
      }
    } catch (e) { lastSyncError = e.toString(); }
  }

  Future<void> _dbSaveMark(String id, CarryMark m) async {
    try {
      if (useFirebaseSdk) {
        await FirebaseService.saveMark(id, {'test20': m.test20, 'assignment10': m.assignment10, 'project20': m.project20});
        lastSyncError = null;
      } else {
        final uri = _dbUri('/marks.json');
        final payload = jsonEncode({id: {'test20': m.test20, 'assignment10': m.assignment10, 'project20': m.project20}});
        final resp = await http.patch(uri, headers: {'Content-Type': 'application/json'}, body: payload);
        if (resp.statusCode >= 400) { lastSyncError = 'HTTP ${resp.statusCode}'; notifyListeners(); }
        else { lastSyncError = null; }
      }
    } catch (e) { lastSyncError = e.toString(); notifyListeners(); }
  }

  Future<void> registerStudent(String id, String password) async {
    students[id] = password;
    notifyListeners();
    await _persist();
    if (remoteEnabled) await _dbSaveStudent(id, password);
  }

  Future<void> _dbSaveStudent(String id, String password) async {
    try {
      if (useFirebaseSdk) {
        await FirebaseService.saveStudent(id, password);
        lastSyncError = null;
      } else {
        final uri = _dbUri('/students.json');
        final payload = jsonEncode({id: password});
        final resp = await http.patch(uri, headers: {'Content-Type': 'application/json'}, body: payload);
        if (resp.statusCode >= 400) { lastSyncError = 'HTTP ${resp.statusCode}'; notifyListeners(); }
        else { lastSyncError = null; }
      }
    } catch (e) { lastSyncError = e.toString(); notifyListeners(); }
  }

  int? getStudentTarget(String id) => targets[id];

  Future<void> setStudentTarget(String id, int min) async {
    targets[id] = min;
    notifyListeners();
    await _persist();
    if (remoteEnabled) await _dbSaveTarget(id, min);
  }

  Future<void> _dbSaveTarget(String id, int min) async {
    try {
      if (useFirebaseSdk) {
        await FirebaseService.saveTarget(id, min);
        lastSyncError = null;
      } else {
        final uri = _dbUri('/targets.json');
        final payload = jsonEncode({id: min});
        final resp = await http.patch(uri, headers: {'Content-Type': 'application/json'}, body: payload);
        if (resp.statusCode >= 400) { lastSyncError = 'HTTP ${resp.statusCode}'; notifyListeners(); }
        else { lastSyncError = null; }
      }
    } catch (e) { lastSyncError = e.toString(); notifyListeners(); }
  }

  List<String> getSubjects(String studentId) => subjects[studentId] ?? [];

  Future<void> addSubject(String studentId, String subject) async {
    final list = subjects[studentId] ?? [];
    if (!list.contains(subject)) list.add(subject);
    subjects[studentId] = list;
    notifyListeners();
    await _persist();
    if (remoteEnabled) await _dbSaveSubject(studentId, subject);
  }

  Future<void> setSubjectCarry(String studentId, String subject, double test20, double assignment10, double project20) async {
    subjectMarks[studentId] = subjectMarks[studentId] ?? {};
    subjectMarks[studentId]![subject] = CarryMark(test20: test20, assignment10: assignment10, project20: project20);
    notifyListeners();
    await _persist();
    if (remoteEnabled) await _dbSaveSubjectMark(studentId, subject, subjectMarks[studentId]![subject]!);
  }

  CarryMark? getSubjectCarry(String studentId, String subject) {
    final m = subjectMarks[studentId];
    if (m == null) return null;
    return m[subject];
  }

  int? getSubjectTarget(String studentId, String subject) {
    final m = subjectTargets[studentId];
    if (m == null) return null;
    return m[subject];
  }

  Future<void> setSubjectTarget(String studentId, String subject, int min) async {
    subjectTargets[studentId] = subjectTargets[studentId] ?? {};
    subjectTargets[studentId]![subject] = min;
    notifyListeners();
    await _persist();
    if (remoteEnabled) await _dbSaveSubjectTarget(studentId, subject, min);
  }

  Future<void> _dbSaveSubject(String studentId, String subject) async {
    try {
      if (useFirebaseSdk) {
        await FirebaseService.saveSubject(studentId, subject);
        lastSyncError = null;
      } else {
        final uri = _dbUri('/subjects/$studentId.json');
        final payload = jsonEncode({subject: true});
        final resp = await http.patch(uri, headers: {'Content-Type': 'application/json'}, body: payload);
        if (resp.statusCode >= 400) { lastSyncError = 'HTTP ${resp.statusCode}'; notifyListeners(); }
        else { lastSyncError = null; }
      }
    } catch (e) { lastSyncError = e.toString(); notifyListeners(); }
  }

  Future<void> _dbSaveSubjectMark(String studentId, String subject, CarryMark m) async {
    try {
      if (useFirebaseSdk) {
        await FirebaseService.saveSubjectMark(studentId, subject, {'test20': m.test20, 'assignment10': m.assignment10, 'project20': m.project20});
        lastSyncError = null;
      } else {
        final uri = _dbUri('/subjectMarks/$studentId.json');
        final payload = jsonEncode({subject: {'test20': m.test20, 'assignment10': m.assignment10, 'project20': m.project20}});
        final resp = await http.patch(uri, headers: {'Content-Type': 'application/json'}, body: payload);
        if (resp.statusCode >= 400) { lastSyncError = 'HTTP ${resp.statusCode}'; notifyListeners(); }
        else { lastSyncError = null; }
      }
    } catch (e) { lastSyncError = e.toString(); notifyListeners(); }
  }

  Future<void> _dbSaveSubjectTarget(String studentId, String subject, int min) async {
    try {
      if (useFirebaseSdk) {
        await FirebaseService.saveSubjectTarget(studentId, subject, min);
        lastSyncError = null;
      } else {
        final uri = _dbUri('/subjectTargets/$studentId.json');
        final payload = jsonEncode({subject: min});
        final resp = await http.patch(uri, headers: {'Content-Type': 'application/json'}, body: payload);
        if (resp.statusCode >= 400) { lastSyncError = 'HTTP ${resp.statusCode}'; notifyListeners(); }
        else { lastSyncError = null; }
      }
    } catch (e) { lastSyncError = e.toString(); notifyListeners(); }
  }

  Future<void> _dbDeleteMark(String id) async {
    try {
      if (useFirebaseSdk) {
        await FirebaseService.deleteMark(id);
        lastSyncError = null;
      } else {
        final uri = _dbUri('/marks/$id.json');
        final resp = await http.delete(uri);
        if (resp.statusCode >= 400) { lastSyncError = 'HTTP ${resp.statusCode}'; notifyListeners(); }
        else { lastSyncError = null; }
      }
    } catch (e) { lastSyncError = e.toString(); notifyListeners(); }
  }

  Future<void> _dbClearAll() async {
    try {
      if (useFirebaseSdk) {
        await FirebaseService.clearAll();
        lastSyncError = null;
      } else {
        final uri = _dbUri('/marks.json');
        final resp = await http.delete(uri);
        if (resp.statusCode >= 400) { lastSyncError = 'HTTP ${resp.statusCode}'; notifyListeners(); }
        else { lastSyncError = null; }
      }
    } catch (e) { lastSyncError = e.toString(); notifyListeners(); }
  }

  void setRemoteEnabled(bool enabled) { remoteEnabled = enabled; notifyListeners(); }
  Future<void> retrySync() async { await syncFromRemote(); notifyListeners(); }

  Uri _dbUri(String path) {
    final base = Uri.https('ict602project-d1673-default-rtdb.asia-southeast1.firebasedatabase.app', path);
    if (idToken == null || idToken!.isEmpty) return base;
    final qp = Map<String, dynamic>.from(base.queryParameters);
    qp['auth'] = idToken!;
    return base.replace(queryParameters: qp);
  }

  Future<void> saveIdToken(String token) async {
    idToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase_id_token', token);
    notifyListeners();
  }

  Future<void> clearIdToken() async {
    idToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_id_token');
    notifyListeners();
  }

  int requiredExamForTarget(double carryTotal, int targetMin) {
    final needed = (targetMin - carryTotal) / 0.5;
    if (needed <= 0) return 0;
    if (needed > 100) return 101;
    return needed.ceil();
  }

  List<Map<String, String>> examTargets(double carryTotal) {
    final targets = [
      {'label': 'A+ (90-100)', 'min': '90'},
      {'label': 'A (80-89)', 'min': '80'},
      {'label': 'A- (75-79)', 'min': '75'},
      {'label': 'B+ (70-74)', 'min': '70'},
      {'label': 'B (65-69)', 'min': '65'},
      {'label': 'B- (60-64)', 'min': '60'},
      {'label': 'C+ (55-59)', 'min': '55'},
      {'label': 'C (50-54)', 'min': '50'},
    ];
    return targets.map((t) {
      final min = int.parse(t['min']!);
      final req = requiredExamForTarget(carryTotal, min);
      final text = req > 100 ? 'Not possible' : '$req/100';
      return {'label': t['label']!, 'required': text};
    }).toList();
  }
}
