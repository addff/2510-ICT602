import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_page.dart';
import 'screens/admin_dashboard.dart';
import 'screens/lecturer_dashboard.dart';
import 'screens/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseOk = true;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    firebaseOk = false;
    // ignore: avoid_print
    print('Firebase initialization failed: $e');
  }

  runApp(MyApp(firebaseAvailable: firebaseOk));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.firebaseAvailable = true});

  final bool firebaseAvailable;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICT602 Grade Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // <-- Tambah baris ni
      home: _buildHome(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }

  Widget _buildHome() {
    if (!widget.firebaseAvailable) {
      return const FirebaseMissingScreen();
    }

    return StreamBuilder(
      stream: _authService.firebaseAuth.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authSnapshot.data == null) {
          return const LoginPage();
        }

        return FutureBuilder(
          key: ValueKey(authSnapshot.data?.uid),
          future: _authService.getCurrentUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (userSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${userSnapshot.error}'),
                ),
              );
            }

            final user = userSnapshot.data;
            if (user != null) {
              switch (user.role) {
                case 'admin':
                  return const AdminDashboard();
                case 'lecturer':
                  return const LecturerDashboard();
                case 'student':
                  return const StudentDashboard();
                default:
                  return const StudentDashboard();
              }
            }

            return const LoginPage();
          },
        );
      },
    );
  }
}

class FirebaseMissingScreen extends StatelessWidget {
  const FirebaseMissingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration Needed')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Firebase is not configured for this platform or failed to initialize.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'To enable full functionality, configure Firebase for your platform.\nYou can run `flutterfire configure` or update `firebase_options.dart` and platform files.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to login anyway
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
