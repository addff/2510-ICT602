import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'admin_page.dart';
import 'lecturer_home.dart';
import 'student_home.dart';
import 'log_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Optional: run once to fix Firestore roles
  await fixUserRoles();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Role-Based Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(),
    );
  }
}

/// Role-based navigation wrapper
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Not logged in
          return LoginPage();
        }

        final user = snapshot.data!;
        print("Logged in user UID: ${user.uid}");

        // Fetch user doc from Firestore to get role
        return FutureBuilder<DocumentSnapshot>(
          future: _fetchUserDoc(user),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!roleSnap.hasData || !roleSnap.data!.exists) {
              return Scaffold(
                body: Center(
                  child: Text(
                    "Error fetching user profile.\nContact admin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }

            final data = roleSnap.data!.data() as Map<String, dynamic>;
            String role = (data['role'] ?? 'student').toString().toLowerCase();
            print("User role: $role"); // Debug

            switch (role) {
              case 'admin':
                return AdminHome();
              case 'lecturer':
                return LecturerHome();
              case 'student':
              default:
                return StudentHome();
            }
          },
        );
      },
    );
  }

  /// Fetch user doc, create default if missing
  Future<DocumentSnapshot> _fetchUserDoc(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      await docRef.set({'role': 'student', 'email': user.email});
      return await docRef.get();
    }

    return docSnap;
  }
}

/// Optional temporary function to fix roles in Firestore
Future<void> fixUserRoles() async {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final snapshot = await usersRef.get();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final email = data['email']?.toString().toLowerCase() ?? '';

    String correctRole = 'student'; // default

    if (email == 'lecturer@gmail.com') {
      correctRole = 'lecturer';
    } else if (email == 'admin@gmail.com') {
      correctRole = 'admin';
    }

    if (data['role'] != correctRole) {
      await doc.reference.update({'role': correctRole});
      print('Updated ${doc.id} ($email) to role: $correctRole');
    }
  }

  print('✅ User roles updated successfully.');
}
