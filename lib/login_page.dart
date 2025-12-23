import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedRole;
  bool loading = false;

  Future<void> _showDialog(String title, String message) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      await _showDialog('Login Failed', 'Please fill all fields.');
      return;
    }

    if (selectedRole == null) {
      await _showDialog('Login Failed', 'Please select a role.');
      return;
    }

    setState(() => loading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final firestoreRole =
          (snap.data()?['role'] as String?)?.toLowerCase();
      final selectedRoleLower = selectedRole!.toLowerCase();

      if (firestoreRole == null || firestoreRole != selectedRoleLower) {
        await FirebaseAuth.instance.signOut();
        await _showDialog(
          'Login Failed',
          'You are not registered as $selectedRole.',
        );
        return;
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await _showDialog(
          'Account Not Found',
          'This email is not registered. Please register first.',
        );
      } else if (e.code == 'wrong-password') {
        await _showDialog(
          'Login Failed',
          'Incorrect password. Please try again.',
        );
      } else {
        await _showDialog(
          'Login Failed',
          e.message ?? 'Login failed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _roleRadio(String role) {
    return RadioListTile<String>(
      title: Text(role),
      value: role,
      groupValue: selectedRole,
      onChanged: (value) {
        setState(() => selectedRole = value);
      },
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Login as:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            _roleRadio('Student'),
            _roleRadio('Lecturer'),
            _roleRadio('Admin'),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('Register new account'),
            ),
          ],
        ),
      ),
    );
  }
}
