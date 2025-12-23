import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerPage extends StatefulWidget {
  const LecturerPage({super.key});

  @override
  State<LecturerPage> createState() => _LecturerPageState();
}

class _LecturerPageState extends State<LecturerPage> {
  final studentIdController = TextEditingController();
  final testController = TextEditingController();
  final assignmentController = TextEditingController();
  final projectController = TextEditingController();

  void saveMark() async {
    double test = double.parse(testController.text);
    double assignment = double.parse(assignmentController.text);
    double project = double.parse(projectController.text);

    double total = test + assignment + project;

    await FirebaseFirestore.instance
        .collection('carry_marks')
        .doc(studentIdController.text)
        .set({
      'studentId': studentIdController.text,
      'test': test,
      'assignment': assignment,
      'project': project,
      'total': total,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Carry mark saved successfully")),
    );

    testController.clear();
    assignmentController.clear();
    projectController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lecturer Portal")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟣 HEADER (WELCOME LECTURER)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Welcome, Lecturer",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "ICT602 - Mobile Application Development",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Carry Mark Management Portal",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📋 ASSESSMENT BREAKDOWN
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(Icons.info),
                title: Text("Assessment Breakdown"),
                subtitle:
                    Text("Test 20% • Assignment 10% • Project 20%"),
              ),
            ),

            const SizedBox(height: 25),

            // 📝 ENTER / UPDATE MARKS
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter / Update ICT602 Carry Marks",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Total carry mark is out of 50% (20 + 10 + 20).",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: studentIdController,
                      decoration: const InputDecoration(
                        labelText: "Student UID",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: testController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Test (out of 20)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: assignmentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Assignment (out of 10)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: projectController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Project (out of 20)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveMark,
                        child: const Text("Save Carry Mark"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
