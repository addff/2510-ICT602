import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'login_page.dart'; // link balik ke login page

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final studentId = TextEditingController(); // NEW for students
  String selectedRole = "student"; 
  bool loading = false;

  Future<void> register() async {
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    if (selectedRole == "student" && studentId.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Student ID.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      String uid = user.user!.uid;

      DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");

      Map<String, dynamic> userData = {
        "name": name.text.trim(),
        "email": email.text.trim(),
        "role": selectedRole,
      };

      if (selectedRole == "student") {
        userData["studentId"] = studentId.text.trim();

        // Optional: store studentID as key for student data
        DatabaseReference studentRef = FirebaseDatabase.instance
            .ref("students/${studentId.text.trim()}");
        await studentRef.set({
          "name": name.text.trim(),
          "email": email.text.trim(),
        });
      }

      await ref.set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed: ${e.message}")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    studentId.dispose();
    super.dispose();
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

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "ICT602 - MOBILE TECHNOLOGY\nAND DEVELOPMENT",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF5A3E8C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // GLASSMORPHISM CARD
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
                            TextField(
                              controller: name,
                              decoration: _inputDeco("Full Name"),
                            ),
                            const SizedBox(height: 20),

                            TextField(
                              controller: email,
                              decoration: _inputDeco("Email"),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            TextField(
                              controller: password,
                              obscureText: true,
                              decoration: _inputDeco("Password"),
                            ),
                            const SizedBox(height: 20),

                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: _inputDeco("Select Role"),
                              items: const [
                                DropdownMenuItem(
                                    value: "admin", child: Text("Admin")),
                                DropdownMenuItem(
                                    value: "lecturer", child: Text("Lecturer")),
                                DropdownMenuItem(
                                    value: "student", child: Text("Student")),
                              ],
                              onChanged: (v) => setState(() => selectedRole = v!),
                            ),
                            const SizedBox(height: 20),

                            // 🌸 Student ID field only for students
                            if (selectedRole == "student")
                              TextField(
                                controller: studentId,
                                decoration: _inputDeco("Student ID"),
                                keyboardType: TextInputType.number,
                              ),
                            if (selectedRole == "student") const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB69CFF),
                                    Color(0xFF8D6CEB),
                                  ],
                                ),
                              ),
                              child: MaterialButton(
                                onPressed: register,
                                child: loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "REGISTER",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Already have an account? Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5A3E8C),
                                  fontWeight: FontWeight.w600,
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
        ],
      ),
    );
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
}
