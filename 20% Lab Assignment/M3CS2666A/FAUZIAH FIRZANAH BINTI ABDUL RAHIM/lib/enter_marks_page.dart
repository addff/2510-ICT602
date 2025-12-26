import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'lecturer_page.dart'; // back to lecturer main menu
import 'login_page.dart';   // for logout

class EnterMarksPage extends StatefulWidget {
  const EnterMarksPage({super.key});

  @override
  _EnterMarksPageState createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  final studentId = TextEditingController();
  final test = TextEditingController();
  final assignment = TextEditingController();
  final project = TextEditingController();

  Future<void> saveMark() async {
    if (studentId.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Student ID.")),
      );
      return;
    }

    await FirebaseDatabase.instance.ref("marks/${studentId.text}").set({
      "test": double.tryParse(test.text) ?? 0,
      "assignment": double.tryParse(assignment.text) ?? 0,
      "project": double.tryParse(project.text) ?? 0,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Carry mark saved successfully.")),
    );

    studentId.clear();
    test.clear();
    assignment.clear();
    project.clear();
  }

  @override
  void dispose() {
    studentId.dispose();
    test.dispose();
    assignment.dispose();
    project.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.purple.shade700,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF7C4DFF),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌸 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE8D9FF),
                  Color(0xFFF3EFFF),
                  Color(0xFFF9F5FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🌸 Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E8C)),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LecturerPage()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Lecturer – Enter Carry Marks",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF5A3E8C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Enter the marks for each assessment.\nPlease ensure Student ID is correct.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5A3E8C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🌸 Card Input
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                                controller: studentId,
                                decoration: _inputDeco("Student ID")),
                            const SizedBox(height: 15),

                            TextField(
                                controller: test,
                                keyboardType: TextInputType.number,
                                decoration: _inputDeco("Test 20%")),
                            const SizedBox(height: 15),

                            TextField(
                                controller: assignment,
                                keyboardType: TextInputType.number,
                                decoration: _inputDeco("Assignment 10%")),
                            const SizedBox(height: 15),

                            TextField(
                                controller: project,
                                keyboardType: TextInputType.number,
                                decoration: _inputDeco("Project 20%")),

                            const SizedBox(height: 25),

                            ElevatedButton(
                              onPressed: saveMark,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C4DFF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                "Save Marks",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
