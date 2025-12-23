import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class LecturerHome extends StatefulWidget {
  final Map<String, dynamic>? user;
  const LecturerHome({super.key, this.user});

  @override
  State<LecturerHome> createState() => _LecturerHomeState();
}

class _LecturerHomeState extends State<LecturerHome> {
  String? selectedStudentUid;
  List<Map<String, dynamic>> students = [];

  final TextEditingController testController = TextEditingController();
  final TextEditingController assignmentController = TextEditingController();
  final TextEditingController projectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  void fetchStudents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    setState(() {
      students = snapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          'email': doc['email'],
          'fullName': doc.data().toString().contains('fullName') ? doc['fullName'] : doc['email'],
          'matricNumber': doc.data().toString().contains('matricNumber') ? doc['matricNumber'] : '',
        };
      }).toList();
    });
  }

  Future<void> fetchSelectedStudentMarks() async {
    if (selectedStudentUid == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('carry_marks')
          .doc(selectedStudentUid)
          .get();

      if (doc.exists) {
        setState(() {
          testController.text = (doc['test'] ?? 0).toString();
          assignmentController.text = (doc['assignment'] ?? 0).toString();
          projectController.text = (doc['project'] ?? 0).toString();
        });
      } else {
        setState(() {
          testController.clear();
          assignmentController.clear();
          projectController.clear();
        });
      }
    } catch (e) {
      showError("Failed to fetch marks.");
    }
  }

  void saveCarryMarks() async {
    if (selectedStudentUid == null) {
      showError("Please select a student.");
      return;
    }

    double? test = double.tryParse(testController.text);
    double? assignment = double.tryParse(assignmentController.text);
    double? project = double.tryParse(projectController.text);

    if (test == null || assignment == null || project == null) {
      showError("Please enter valid numbers.");
      return;
    }

    if (test < 0 || test > 20 ||
        assignment < 0 || assignment > 10 ||
        project < 0 || project > 20) {
      showError("Invalid range:\nTest (0–20)\nAssignment (0–10)\nProject (0–20)");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('carry_marks')
          .doc(selectedStudentUid)
          .set({
        'test': test,
        'assignment': assignment,
        'project': project,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Carry marks saved!")));

      // Keep the fields populated after saving
      await fetchSelectedStudentMarks();
    } catch (e) {
      showError("Failed to save data.");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  double getTotalCarry() {
    double t = double.tryParse(testController.text) ?? 0;
    double a = double.tryParse(assignmentController.text) ?? 0;
    double p = double.tryParse(projectController.text) ?? 0;
    return t + a + p;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Select a Student:", style: TextStyle(fontSize: 16)),

            DropdownButton<String>(
              value: selectedStudentUid,
              isExpanded: true,
              hint: const Text("Choose Student"),
              items: students.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> stud) {
                  return DropdownMenuItem<String>(
                    value: stud['uid'],
                    child: Text(stud['fullName']),
                  );
                },
              ).toList(),

              onChanged: (value) async {
                setState(() => selectedStudentUid = value);

                if (selectedStudentUid != null) {
                  try {
                    DocumentSnapshot doc = await FirebaseFirestore.instance
                        .collection('carry_marks')
                        .doc(selectedStudentUid)
                        .get();

                    if (doc.exists) {
                      // Populate the fields with existing marks
                      testController.text = (doc['test'] ?? 0).toString();
                      assignmentController.text = (doc['assignment'] ?? 0).toString();
                      projectController.text = (doc['project'] ?? 0).toString();
                    } else {
                      // No marks yet, clear the fields
                      testController.clear();
                      assignmentController.clear();
                      projectController.clear();
                    }
                  } catch (e) {
                    showError("Failed to fetch marks.");
                  }
                }
              },

            ),

            const SizedBox(height: 20),

            // ⭐ Show total carry marks
            Text('Total Carry Marks: ${getTotalCarry()} / 50',
                style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            TextField(
              controller: testController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Test (0–20)"),
            ),
            TextField(
              controller: assignmentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Assignment (0–10)"),
            ),
            TextField(
              controller: projectController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Project (0–20)"),
            ),

            const SizedBox(height: 20),

           ElevatedButton(
              onPressed: saveCarryMarks,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // text color
              ),
              child: const Text("Save Carry Marks"),
            ),

          ],
        ),
      ),
    );
  }
}