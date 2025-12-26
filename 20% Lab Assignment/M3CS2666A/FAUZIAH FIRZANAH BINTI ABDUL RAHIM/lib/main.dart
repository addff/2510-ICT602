import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'login_page.dart';
import 'admin_page.dart';
import 'lecturer_page.dart';
import 'student_page.dart';
import 'app_theme.dart';
import 'register_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Firebase config untuk WEB
    const firebaseConfig = FirebaseOptions(
      apiKey: "AIzaSyBvxqhAaDrk79CUP705GVehP--JYjDymnA",
      authDomain: "ict602-assignment-individual.firebaseapp.com",
      databaseURL: "https://ict602-assignment-individual-default-rtdb.firebaseio.com/",
      projectId: "ict602-assignment-individual",
      storageBucket: "ict602-assignment-individual.appspot.com",
      messagingSenderId: "1024504219452",
      appId: "1:1024504219452:web:dd169829281e98e5d78039",
      measurementId: "G-XXXXXXXXXX",
    );

    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    // MOBILE Android/iOS gunakan google-services.json / plist
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICT602 Assignment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginPage(),
      routes: {
        '/admin': (context) => const AdminPage(),
        '/lecturer': (context) => const LecturerPage(),
        '/student': (context) => const StudentPage(),

        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
