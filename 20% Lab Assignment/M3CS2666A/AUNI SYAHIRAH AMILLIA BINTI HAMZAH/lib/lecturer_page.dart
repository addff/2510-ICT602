import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'enter_marks.dart';

class LecturerPage extends StatefulWidget {
  final String lecturerId;
  const LecturerPage({super.key, required this.lecturerId});

  @override
  State<LecturerPage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer Dashboard"),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Student',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) =>
                  setState(() => searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = snapshot.data!.docs.where((doc) {
                  final name =
                      (doc['username'] ?? '').toString().toLowerCase();
                  final email =
                      (doc['email'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) ||
                      email.contains(searchQuery);
                }).toList();

                if (students.isEmpty) {
                  return const Center(child: Text("No students found"));
                }

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (_, i) {
                    final student = students[i];
                    final carry = student['carryMark'] ?? {};

                    final test = (carry['test'] ?? 0).toDouble();
                    final assignment = (carry['assignment'] ?? 0).toDouble();
                    final project = (carry['project'] ?? 0).toDouble();

                    final total =
                        test * 0.2 + assignment * 0.1 + project * 0.2;

                    return ListTile(
                      title: Text(student['username']),
                      subtitle: Text(
                        "Total Carry Mark: ${total.toStringAsFixed(2)}%",
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EnterMarksPage(
                              studentId: student.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
