import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'state/app_state.dart';

void main() {
  runApp(const ICT602App());
}

class ICT602App extends StatefulWidget {
  const ICT602App({super.key});
  @override
  State<ICT602App> createState() => _ICT602AppState();
}

class _ICT602AppState extends State<ICT602App> {
  final AppState appState = AppState();
  @override
  void initState() {
    super.initState();
    appState.init();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICT602',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: LoginPage(appState: appState),
    );
  }
}
