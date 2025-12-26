import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String? studentId;
  Map<String, dynamic>? studentData;
  double carry = 0;
  Map<String, double> neededFinal = {};

  final studentsRef = FirebaseDatabase.instance.ref("students");
  final marksRef = FirebaseDatabase.instance.ref("marks");

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (currentUser == null) return;
    final email = currentUser!.email;
    DatabaseEvent event = await studentsRef.once();

    if (!event.snapshot.exists) return;

    final Map<dynamic, dynamic> students =
        event.snapshot.value as Map<dynamic, dynamic>;

    students.forEach((key, value) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(value);
      if (data["email"] == email) {
        studentId = key;
        studentData = data;
      }
    });

    if (studentId != null) {
      await loadMark();
    }

    setState(() {});
  }

  Future<void> loadMark() async {
    if (studentId == null) return;

    DatabaseEvent event = await marksRef.child(studentId!).once();

    if (!event.snapshot.exists) {
      setState(() {
        carry = 0;
        neededFinal.clear();
      });
      return;
    }

    Map m = Map<String, dynamic>.from(event.snapshot.value as Map);
    double totalCarry =
        (m["test"] ?? 0) + (m["assignment"] ?? 0) + (m["project"] ?? 0);

    setState(() {
      carry = totalCarry;
      neededFinal = calculateNeeded(totalCarry);
    });
  }

  Map<String, double> calculateNeeded(double carryMark) {
    Map<String, double> grades = {
      "A+": 90,
      "A": 80,
      "A-": 75,
      "B+": 70,
      "B": 65,
      "C": 50,
      "D": 40,
      "F": 0,
    };

    Map<String, double> needed = {};
    grades.forEach((grade, target) {
      double required = (target - carryMark).clamp(0, 50);
      needed[grade] = required;
    });
    return needed;
  }

  @override
  Widget build(BuildContext context) {
    final name = studentData?["name"] ?? "-";
    final email = studentData?["email"] ?? "-";

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    // 🌸 Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E8C)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🌸 Welcome Name (outside boxes)
                    Text(
                      "Welcome, $name",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A3E8C),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // 🌸 Student Details Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow("Student ID", studentId ?? "-"),
                              _buildInfoRow("Name", name),
                              _buildInfoRow("Email", email),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 🌸 Carry Marks Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Carry Mark: ${carry.toStringAsFixed(1)} / 50",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 15),
                              if (neededFinal.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Marks Needed from Final Exam",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    ...neededFinal.entries.map((e) => Text(
                                          "${e.key}: ${e.value.toStringAsFixed(1)} marks",
                                          style: const TextStyle(fontSize: 16),
                                        )),
                                  ],
                                ),
                              const SizedBox(height: 25),
                              // 🌸 Logout Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // ikut login page
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                  ),
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginPage()),
                                    );
                                  },
                                  child: const Text(
                                    "LOGOUT",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
