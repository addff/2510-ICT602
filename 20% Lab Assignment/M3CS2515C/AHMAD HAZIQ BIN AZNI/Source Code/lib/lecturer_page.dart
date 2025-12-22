import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'logout.dart';

class LecturerPage extends StatefulWidget {
  const LecturerPage({Key? key}) : super(key: key);

  @override
  State<LecturerPage> createState() => _LecturerPageState();
}

class _LecturerPageState extends State<LecturerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController studentUidController = TextEditingController();
  final TextEditingController testController = TextEditingController();
  final TextEditingController assignmentController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  bool _saving = false;

  Future<void> saveMarks() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final uid = studentUidController.text.trim();
    setState(() => _saving = true);

    double test = double.tryParse(testController.text) ?? 0;
    double assignment = double.tryParse(assignmentController.text) ?? 0;
    double project = double.tryParse(projectController.text) ?? 0;

    // Expected maxima for each component
    const double testMax = 20.0;
    const double assignmentMax = 10.0;
    const double projectMax = 20.0;

    // Clamp raw scores to valid ranges
    test = test.clamp(0, testMax);
    assignment = assignment.clamp(0, assignmentMax);
    project = project.clamp(0, projectMax);

    // Compute carry contribution as percent of final grade (Test 20%, Assignment 10%, Project 20%)
    double testContribution = (test / testMax) * 20.0; // out of 20
    double assignmentContribution = (assignment / assignmentMax) * 10.0; // out of 10
    double projectContribution = (project / projectMax) * 20.0; // out of 20

    double total = testContribution + assignmentContribution + projectContribution; // this will be between 0..50

    try {
      await FirebaseFirestore.instance.collection('marks').doc(uid).set({
        'test': test,
        'assignment': assignment,
        'project': project,
        'total': total,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marks saved for $uid')));

      studentUidController.clear();
      testController.clear();
      assignmentController.clear();
      projectController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter Student Marks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Provide scores (0-100). The app computes the carry total automatically.'),
                    const SizedBox(height: 12),

                    Form(
                      key: _formKey,
                      child: Column(
                          children: [
                          TextFormField(
                            controller: studentUidController,
                            decoration: InputDecoration(labelText: 'Student UID', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter student UID' : null,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: testController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Test (out of 20)', hintText: 'e.g. 16', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))) ,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: assignmentController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Assignment (out of 10)', hintText: 'e.g. 8', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))) ,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: projectController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Project (out of 20)', hintText: 'e.g. 18', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: _saving
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton.icon(
                                    onPressed: saveMarks,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save Marks'),
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Recent Saves', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Saved marks appear in Firestore under collection `marks`. Use the web console to browse entries.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
