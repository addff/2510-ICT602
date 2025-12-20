import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/index.dart';
import 'models/index.dart';
import 'services/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:convert';

// Key for storing current user JSON
const _kCurrentUserKey = 'current_user';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DatabaseService().initialize();

  // ---------------------------
  // RESTORE CURRENT USER
  // ---------------------------
  final prefs = await SharedPreferences.getInstance();
  String? storedJson;

  if (kIsWeb) {
    storedJson = html.window.localStorage[_kCurrentUserKey];
    print("Web localStorage user = $storedJson");
  } else {
    storedJson = prefs.getString(_kCurrentUserKey);
    print("SharedPrefs user = $storedJson");
  }

  User? initialUser;

  if (storedJson != null && storedJson.isNotEmpty) {
    final jsonMap = jsonDecode(storedJson);
    initialUser = User.fromMap(jsonMap);
    print("Restored user: ${initialUser.username} (${initialUser.role})");
  }

  runApp(MyApp(initialUser: initialUser));
}

class MyApp extends StatelessWidget {
  final User? initialUser;
  const MyApp({Key? key, this.initialUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ---------------------------
    // SELECT HOME SCREEN
    // ---------------------------

    Widget homeWidget = const LoginScreen();

    if (initialUser != null) {
      switch (initialUser!.role) {
        case 'admin':
          homeWidget = AdminDashboard(user: initialUser!);
          break;
        case 'lecturer':
          homeWidget = const LecturerDashboard(); // FIXED
          break;
        case 'student':
          homeWidget = StudentDashboard(user: initialUser!);
          break;
      }
    }

    return MaterialApp(
      title: 'ICT602 Grade Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: homeWidget,

      // ---------------------------
      // FIXED ROUTES
      // ---------------------------
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        '/admin_dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) return AdminDashboard(user: args);
          return const LoginScreen();
        },

        '/lecturer_dashboard': (context) =>
            const LecturerDashboard(), // FIXED (no args)

        '/student_dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) return StudentDashboard(user: args);
          return const LoginScreen();
        },
      },
    );
  }
}
