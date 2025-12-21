import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  static const Map<String, int> gradeTargets = {
    "A+": 90,
    "A": 80,
    "A-": 75,
    "B+": 70,
    "B": 65,
    "B-": 60,
    "C+": 55,
    "C": 50,
  };

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Carry Marks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No data found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final carry = data['carryMark'] ?? {};

          final double test = (carry['test'] ?? 0).toDouble();
          final double assignment = (carry['assignment'] ?? 0).toDouble();
          final double project = (carry['project'] ?? 0).toDouble();

          // Carry mark calculation
          final double testPercent = test / 100 * 20;
          final double assignmentPercent = assignment / 100 * 10;
          final double projectPercent = project / 100 * 20;
          final double totalCarry = testPercent + assignmentPercent + projectPercent;

          // Target exam calculation
          final Map<String, double> targetExam = {};
          gradeTargets.forEach((grade, target) {
            double needed = (target - totalCarry) / 0.5;
            targetExam[grade] = needed.clamp(0, 100);
          });

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Carry Marks",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),

                Text("Test (20%): $test → ${testPercent.toStringAsFixed(2)}%"),
                Text(
                    "Assignment (10%): $assignment → ${assignmentPercent.toStringAsFixed(2)}%"),
                Text(
                    "Project (20%): $project → ${projectPercent.toStringAsFixed(2)}%"),
                const SizedBox(height: 8),
                Text(
                  "Total Carry Mark (50%): ${totalCarry.toStringAsFixed(2)}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const Divider(height: 30),

                Text(
                  "Target Final Exam Marks",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    children: targetExam.entries.map((e) {
                      return ListTile(
                        title: Text(e.key),
                        trailing:
                            Text("${e.value.toStringAsFixed(1)} / 100"),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
