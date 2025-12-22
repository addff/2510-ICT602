import 'package:flutter/material.dart';
import '../models/user.dart';
import '../db/database_helper.dart';
import '../models/student.dart';
import '../models/carry_mark.dart';
import '../utils/grade_utils.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  Student? _student;
  List<CarryMark> _marks = [];
  User? _currentUser;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ModalRoute.of(context)!.settings.arguments as User?;
    if (user == null) return;
    final student = await DatabaseHelper.instance.getStudentByUserId(user.id!);
    if (student != null) {
      final marks = await DatabaseHelper.instance.getCarryMarksByStudentId(student.id!);
      setState(() {
        _currentUser = user;
        _student = student;
        _marks = marks;
        _loading = false;
      });
    } else {
      setState(() {
        _currentUser = user;
        _loading = false;
      });
    }
  }

  double _carryTotal() {
    if (_marks.isEmpty) return 0.0;
    // sum of carry totals (if multiple records, show latest) — take first
    return _marks.first.carryTotal;
  }

  void _showTargetDialog() {
    final carry = _carryTotal();

    // use helper
    final req = requiredForGrades(carryTotal: carry);
    final results = req.entries.map((e) {
      final required = e.value;
      final note = required > 100 ? 'Impossible (needs ${required.toStringAsFixed(1)}%)' : '${required.toStringAsFixed(1)}%';
      return MapEntry(e.key, note);
    }).toList();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Required Final Exam Marks for Each Grade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current carry: ${carry.toStringAsFixed(2)} (counts as 50%)'),
              const SizedBox(height: 8),
              ...results.map((r) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(r.key), Text(r.value)],
                  )),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        );
      },
    );
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
        title: const Text('Student'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: confirmLogout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Student: ${_student?.name ?? '—'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('Email: ${_currentUser?.email ?? '—'}', style: const TextStyle(color: Colors.black54))]),
                            CircleAvatar(child: Text((_student?.name ?? '').split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join())),

                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Carry: ${_carryTotal().toStringAsFixed(2)} / 100'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: _carryTotal() / 100),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _showTargetDialog, child: const Text('Target Grade Calculator')),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text('Grade thresholds:'),
                        const SizedBox(height: 8),
                        // summary view
                        ...requiredForGrades(carryTotal: _carryTotal()).entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key), Text(e.value > 100 ? 'Impossible (${e.value.toStringAsFixed(1)}%)' : '${e.value.toStringAsFixed(1)}%')]),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
