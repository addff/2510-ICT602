import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMarksPage extends StatefulWidget {
  @override
  State<AddMarksPage> createState() => _AddMarksPageState();
}

class _AddMarksPageState extends State<AddMarksPage> {
  String? selectedStudentUID;
  final testCtrl = TextEditingController();
  final assignmentCtrl = TextEditingController();
  final projectCtrl = TextEditingController();

  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // Fetch all students from Firestore
  Future<void> fetchStudents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    setState(() {
      students = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'uid': doc.id, 'email': data['email'] ?? 'Unknown'};
      }).toList();
    });
  }

  // Save marks to Firestore under student UID
  Future<void> saveMarks() async {
    if (selectedStudentUID == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select a student")));
      return;
    }

    final test = int.tryParse(testCtrl.text) ?? 0;
    final assignment = int.tryParse(assignmentCtrl.text) ?? 0;
    final project = int.tryParse(projectCtrl.text) ?? 0;

    final total = test + assignment + project;
    String grade = calculateGrade(total);

    await FirebaseFirestore.instance
        .collection("marks")
        .doc(selectedStudentUID)
        .set({
      "studentID": selectedStudentUID,
      "test": test,
      "assignment": assignment,
      "project": project,
      "totalCarry": total,
      "grade": grade,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Marks saved successfully")));

    // Optional: clear fields after saving
    setState(() {
      testCtrl.clear();
      assignmentCtrl.clear();
      projectCtrl.clear();
      selectedStudentUID = null;
    });
  }

  // Grade calculation
  String calculateGrade(int t) {
    if (t >= 90) return "A+";
    if (t >= 80) return "A";
    if (t >= 75) return "A-";
    if (t >= 70) return "B+";
    if (t >= 65) return "B";
    if (t >= 60) return "C+";
    if (t >= 55) return "C";
    if (t >= 50) return "C-";
    if (t >= 45) return "D";
    return "F";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Carry Marks")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedStudentUID,
              hint: Text("Select a student"),
              items: students.map((student) {
                return DropdownMenuItem<String>(
                  value: student['uid'] as String,
                  child: Text(student['email'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedStudentUID = val),
              decoration: InputDecoration(labelText: "Select Student"),
            ),
            TextField(
              controller: testCtrl,
              decoration: InputDecoration(labelText: "Test Marks"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: assignmentCtrl,
              decoration: InputDecoration(labelText: "Assignment Marks"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: projectCtrl,
              decoration: InputDecoration(labelText: "Project Marks"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveMarks, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}
