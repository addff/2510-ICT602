import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../state/app_state.dart';

class FirebaseConfigPage extends StatefulWidget {
  final AppState appState;
  const FirebaseConfigPage({super.key, required this.appState});
  @override
  State<FirebaseConfigPage> createState() => _FirebaseConfigPageState();
}

class _FirebaseConfigPageState extends State<FirebaseConfigPage> {
  final TextEditingController configJson = TextEditingController();
  final TextEditingController dbUrl = TextEditingController(text: 'https://ict602project-d1673-default-rtdb.asia-southeast1.firebasedatabase.app');
  String? info;
  Future<void> save() async {
    try {
      final cfg = jsonDecode(configJson.text) as Map<String, dynamic>;
      await FirebaseService.saveConfig(cfg, dbUrl.text.trim());
      setState(() { info = 'Configured'; });
      widget.appState.useFirebaseSdk = FirebaseService.ready;
      await widget.appState.retrySync();
    } catch (e) {
      setState(() { info = 'Invalid config'; });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Config')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: dbUrl, decoration: const InputDecoration(labelText: 'Database URL')),
          const SizedBox(height: 12),
          TextField(controller: configJson, decoration: const InputDecoration(labelText: 'Web Config JSON'), maxLines: 8),
          const SizedBox(height: 12),
          FilledButton(onPressed: save, child: const Text('Save')),
          if (info != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(info!)),
        ]),
      ),
    );
  }
}
