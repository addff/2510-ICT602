import 'package:flutter/material.dart';
import 'login_page.dart';
import 'database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting ICT602 Carry Marks App...');
  
  // Initialize database for desktop platforms
  DatabaseHelper.initialize();
  
  // Initialize database with error handling
  DatabaseHelper.instance.database.then((_) {
    print('✅ Database initialized successfully');
    runApp(const MyApp());
  }).catchError((error) {
    print('❌ Database initialization failed: $error');
    runApp(const MyApp()); // Still run app even if DB fails
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICT602 Carry Marks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}