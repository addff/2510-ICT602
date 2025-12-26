import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'enter_marks_page.dart';
import 'view_student_marks_page.dart';
import 'login_page.dart';

class LecturerPage extends StatelessWidget {
  const LecturerPage({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
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
                children: [
                  const Text(
                    "Lecturer Panel",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3E8C),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

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

                        child: Column(
                          children: [
                            // Button 1: Enter Carry Marks
                            _gradientButton(
                              context,
                              "Enter Carry Marks",
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EnterMarksPage()),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Button 2: View Student Marks
                            _gradientButton(
                              context,
                              "View Student Marks",
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ViewStudentMarksPage()),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Button 3: Logout
                            _gradientButton(
                              context,
                              "Logout",
                              () => logout(context),
                              gradientColors: const [
                                Color(0xFFFF5C5C),
                                Color(0xFFE53935),
                              ],
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
        ],
      ),
    );
  }

  Widget _gradientButton(BuildContext context, String label, VoidCallback onTap,
      {List<Color>? gradientColors}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors ??
              const [
                Color(0xFFB69CFF),
                Color(0xFF8D6CEB),
              ],
        ),
      ),
      child: MaterialButton(
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
