import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: FirebaseOptions(
      apiKey: "BEeVmmltkZrYIKe4ATpHbD37RvAKY-xcdo-ZvZeud0-ggvpachW5ry-i6-6AXxP4t97Ui1EIP6V_mjc0HoVUvxM",
      appId: "1:294451402382:android:16d0beb9835ac6c7419bdf",
      messagingSenderId: "294451402382",
      projectId: "ict602-207ec",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: Register(),
    );
  }
}