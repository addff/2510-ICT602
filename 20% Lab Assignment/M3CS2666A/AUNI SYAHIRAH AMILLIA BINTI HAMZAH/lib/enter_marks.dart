import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnterMarksPage extends StatefulWidget {
  final String studentId;
  const EnterMarksPage({super.key, required this.studentId});

  @override
  State<EnterMarksPage> createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  final testCtrl = TextEditingController();
  final assignmentCtrl = TextEditingController();
  final projectCtrl = TextEditingController();

  Future<void> saveMarks() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.studentId)
        .update({
      'carryMark': {
        'test': double.parse(testCtrl.text),
        'assignment': double.parse(assignmentCtrl.text),
        'project': double.parse(projectCtrl.text),
      }
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Marks")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: testCtrl,
              decoration: const InputDecoration(labelText: "Test (20%)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: assignmentCtrl,
              decoration: const InputDecoration(labelText: "Assignment (10%)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: projectCtrl,
              decoration: const InputDecoration(labelText: "Project (20%)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveMarks, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
