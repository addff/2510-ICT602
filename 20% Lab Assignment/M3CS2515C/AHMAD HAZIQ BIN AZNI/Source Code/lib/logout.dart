import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // adjust the path to your login page

void logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}
  