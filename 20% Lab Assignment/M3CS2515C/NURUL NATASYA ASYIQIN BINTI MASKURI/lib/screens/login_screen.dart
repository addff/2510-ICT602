import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_home.dart';
import 'lecturer_home.dart';
import 'admin_home.dart';
import 'register_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  String selectedRole = 'student'; // default selection

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.purple)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please enter email and password.");
      return;
    }

    setState(() => loading = true);

    try {
      // Firebase sign in
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Fetch user profile from Firestore
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) {
        showError("User profile not found.");
        return;
      }

      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      String role = userData['role'] ?? 'student'; // default to student

      // Role check: if admin, bypass; otherwise must match selected role
      if (role != 'admin' && role != selectedRole) {
        showError("Role does not match selected login type.");
        return;
      }

      // Navigate based on role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHome(user: userData),
          ),
        );
      } else if (role == 'lecturer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LecturerHome(user: userData),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentHome(user: userData),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = "User not found.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        default:
          message = "Login failed. ${e.message}";
      }
      showError(message);
    } finally {
      setState(() => loading = false);
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscure = false, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1️⃣ PNG image
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(
                      'assets/padlock.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2️⃣ Radio buttons for Student / Lecturer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: 'student',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                    ),
                    const Text('Student', style: TextStyle(color: Colors.purple)),
                    Radio<String>(
                      value: 'lecturer',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                    ),
                    const Text('Lecturer', style: TextStyle(color: Colors.purple)),
                  ],
                ),
                const SizedBox(height: 24),

                // 3️⃣ Email & Password fields
                buildTextField("Email", emailController,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 16),
                buildTextField("Password", passwordController, obscure: true),
                const SizedBox(height: 32),

                // 4️⃣ Login button
                ElevatedButton(
                  onPressed: loading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),

                // 5️⃣ Register hyperlink (only for student)
                if (selectedRole == 'student')
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Don\'t have an account? Register',
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}