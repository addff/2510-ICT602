import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'student_page.dart';
import 'lecturer_page.dart';
import 'admin_page.dart';
import 'register_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marks App',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/studentHome': (context) => StudentPage(),
        '/adminHome': (context) => AdminPage(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/lecturerHome') {
          final lecturerId = settings.arguments as String?;
          if (lecturerId != null) {
            return MaterialPageRoute(
              builder: (context) => LecturerPage(lecturerId: lecturerId),
            );
          } else {
            return MaterialPageRoute(builder: (context) => const LoginPage());
          }
        }
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }
}
