import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/student.dart';
import 'carry_mark_edit_page.dart';

class LecturerPage extends StatefulWidget {
  const LecturerPage({super.key});

  @override
  State<LecturerPage> createState() => _LecturerPageState();
}

class _LecturerPageState extends State<LecturerPage> {
  List<Student> _students = [];
  final Map<int, String> _userEmails = {};
  final Map<int, double> _studentCarry = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await DatabaseHelper.instance.getAllStudents();
    final Map<int, String> emails = {};
    final Map<int, double> carries = {};
    for (final s in students) {
      final u = await DatabaseHelper.instance.getUserById(s.userId);
      emails[s.userId] = u?.email ?? '';
      final marks = await DatabaseHelper.instance.getCarryMarksByStudentId(s.id!);
      carries[s.id!] = marks.isNotEmpty ? marks.first.carryTotal : 0.0;
    }
    setState(() {
      _students = students;
      _userEmails.clear();
      _userEmails.addAll(emails);
      _studentCarry.clear();
      _studentCarry.addAll(carries);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    void confirmLogout() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Do you want to logout?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: confirmLogout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final s = _students[index];
                final email = _userEmails[s.userId] ?? '';
                final carry = _studentCarry[s.id] ?? 0.0;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(s.name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join())),
                    title: Text(s.name),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(email, style: const TextStyle(fontSize: 12)), const SizedBox(height: 4), Text('Carry: ${carry.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12))]),
                    trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => CarryMarkEditPage(student: s)));
                      await _loadStudents();
                    }),
                  ),
                );
              },
            ),
    );
  }
}
