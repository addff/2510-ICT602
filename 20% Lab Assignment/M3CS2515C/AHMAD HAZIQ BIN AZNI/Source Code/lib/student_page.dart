import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logout.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({Key? key}) : super(key: key);

  double targetFinal(double totalCarry, String grade) {
    double threshold;
    switch (grade) {
      case 'A+': threshold = 90; break;
      case 'A':  threshold = 80; break;
      case 'A-': threshold = 75; break;
      case 'B+': threshold = 70; break;
      case 'B':  threshold = 65; break;
      case 'B-': threshold = 60; break;
      case 'C+': threshold = 55; break;
      case 'C':  threshold = 50; break;
      default: threshold = 0;
    }

    if (totalCarry >= threshold) return 0;
    const double finalExamWeight = 0.5;
    double requiredFinalRaw = ((threshold - totalCarry) / finalExamWeight).clamp(0, 100);
    return requiredFinalRaw;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('marks').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text('No marks found'));

          var data = snapshot.data!.data() as Map<String, dynamic>;
          double total = (data['total'] ?? 0).toDouble();
          double test = (data['test'] ?? 0).toDouble();
          double assignment = (data['assignment'] ?? 0).toDouble();
          double project = (data['project'] ?? 0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Carry Marks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Test: ${test.toStringAsFixed(1)}', style: const TextStyle(fontSize: 16)),
                              Text('Assignment: ${assignment.toStringAsFixed(1)}', style: const TextStyle(fontSize: 16)),
                              Text('Project: ${project.toStringAsFixed(1)}', style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: LinearProgressIndicator(value: (total / 100).clamp(0, 1), minHeight: 10)),
                                  const SizedBox(width: 12),
                                  Text('${total.toStringAsFixed(1)}%')
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Target Final Exam (what you need to score)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _gradeChip('A+', targetFinal(total, 'A+')),
                            _gradeChip('A', targetFinal(total, 'A')),
                            _gradeChip('A-', targetFinal(total, 'A-')),
                            _gradeChip('B+', targetFinal(total, 'B+')),
                            _gradeChip('B', targetFinal(total, 'B')),
                            _gradeChip('B-', targetFinal(total, 'B-')),
                            _gradeChip('C+', targetFinal(total, 'C+')),
                            _gradeChip('C', targetFinal(total, 'C')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Note: Final exam contributes 50% of your total grade.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _gradeChip(String grade, double requiredPercent) {
    final text = requiredPercent <= 0 ? 'No final needed' : '${requiredPercent.toStringAsFixed(0)}%';
    final color = requiredPercent <= 0 ? Colors.green.shade100 : Colors.orange.shade50;
    return Chip(label: Text('$grade: $text'), backgroundColor: color);
  }
}
