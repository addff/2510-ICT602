import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'lecturer_page.dart'; // back to lecturer main menu

class ViewStudentMarksPage extends StatelessWidget {
  const ViewStudentMarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final marksRef = FirebaseDatabase.instance.ref("marks");

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
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
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

                  const SizedBox(height: 20),

                  const Text(
                    "View Carry Marks",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3E8C),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🌸 Glassmorphism Card Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: StreamBuilder(
                          stream: marksRef.onValue,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data?.snapshot.value == null) {
                              return const Center(
                                child: Text(
                                  "No marks available.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF5A3E8C),
                                  ),
                                ),
                              );
                            }

                            Map marks = snapshot.data!.snapshot.value
                                as Map<dynamic, dynamic>;
                            List entries = marks.entries.toList();

                            return Column(
                              children: entries.map((item) {
                                String studentId = item.key.toString();
                                Map data =
                                    Map<String, dynamic>.from(item.value);

                                double test = data["test"]?.toDouble() ?? 0;
                                double assignment =
                                    data["assignment"]?.toDouble() ?? 0;
                                double project =
                                    data["project"]?.toDouble() ?? 0;
                                double total = test + assignment + project;

                                return Card(
                                  elevation: 5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(15),
                                    title: Text(
                                      "Student ID: $studentId",
                                      style: const TextStyle(
                                        color: Color(0xFF5A3E8C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Test 20%: $test"),
                                        Text("Assignment 10%: $assignment"),
                                        Text("Project 20%: $project"),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Total: $total",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
