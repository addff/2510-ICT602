import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'db/database_helper.dart';
import 'screens/login_page.dart';
import 'screens/admin_page.dart';
import 'screens/lecturer_page.dart';
import 'screens/student_page.dart';
import 'screens/manage_users_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On web, sqlite packages are not available — use in-memory fallback.
  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
  } else {
    await DatabaseHelper.instance.initForWeb();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(      debugShowCheckedModeBanner: false,      title: 'ICT602 CarryMark',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(48))),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminPage(),
        '/admin/users': (context) => const ManageUsersPage(),
        '/lecturer': (context) => const LecturerPage(),
        '/student': (context) => const StudentPage(),
      },
    );
  }
}

