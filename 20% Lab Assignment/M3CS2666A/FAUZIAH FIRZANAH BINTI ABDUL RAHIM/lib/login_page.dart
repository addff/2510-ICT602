import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      DatabaseReference ref =
          FirebaseDatabase.instance.ref("users/${user.user!.uid}");
      DatabaseEvent event = await ref.once();

      if (event.snapshot.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User role not found.")),
        );
        setState(() => loading = false);
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      String role = (data["role"] ?? "").toString().toLowerCase();

      if (role == "admin") {
        Navigator.pushNamed(context, '/admin');
      } else if (role == "lecturer") {
        Navigator.pushNamed(context, '/lecturer');
      } else {
        Navigator.pushNamed(context, '/student');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login failed: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌸 PASTEL PURPLE BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE8D9FF), // pastel lavender
                  Color(0xFFF3EFFF), // very soft purple
                  Color(0xFFF9F5FF), // white-purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Scroll content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🌸 UiTM Logo
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 3),
                      image: const DecorationImage(
                        image: AssetImage("assets/logo.png"),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          spreadRadius: 3,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🌸 Page Title
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

                  // 🌸 GLASSMORPHISM CARD
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
                            // Email field
                            TextField(
                              controller: email,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password field
                            TextField(
                              controller: password,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // 🌸 Login Button
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
                                onPressed: login,
                                child: loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        "LOGIN",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // 🌸 Register Text Button
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              ),
                              child: const Text(
                                "Don't have an account? Register",
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
}
