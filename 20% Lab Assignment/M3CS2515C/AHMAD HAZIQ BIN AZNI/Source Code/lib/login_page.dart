import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_page.dart';
import 'lecturer_page.dart';
import 'student_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  void login() async {
    setState(() {
      loading = true;
    });

    try {
    
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw 'User UID not found';

 
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw 'User data not found in Firestore';
      }

      String role = (userDoc.data() as Map<String, dynamic>?)?['role'] ?? 'student';

      if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPage()));
      } else if (role == 'lecturer') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LecturerPage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentPage()));
      }

 

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0,6))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.school, color: Colors.white, size: 38),
                    SizedBox(width: 12),
                    Text('ICT602', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Welcome back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Sign in with your account to continue', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 16),

                        loading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ?? false) login();
                                  },
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  child: const Text('Sign In', style: TextStyle(fontSize: 16)),
                                ),
                              ),

                        const SizedBox(height: 10),
                        TextButton(onPressed: () {}, child: const Text('Forgot password?')),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Text('Built for ICT602 • Mobile App', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}