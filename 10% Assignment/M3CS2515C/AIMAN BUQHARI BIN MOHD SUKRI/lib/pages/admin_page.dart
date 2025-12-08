import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'admin_db_page.dart';
import 'firebase_config_page.dart';

class AdminPage extends StatefulWidget {
  final AppState appState;
  const AdminPage({super.key, required this.appState});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController url = TextEditingController(text: 'https://example.com');
  String? info;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrator')), 
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      const Text('Web Based Management'),
                      const SizedBox(height: 12),
                      TextField(controller: url, decoration: const InputDecoration(labelText: 'Management URL')),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () { setState(() { info = 'Use this URL in browser: ${url.text}'; }); }, child: const Text('Open')),
                      if (info != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(info!)),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminDbPage(appState: widget.appState))); },
                  child: const Text('View Marks Database')
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => FirebaseConfigPage(appState: widget.appState))); },
                  child: const Text('Configure Firebase')
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: () { widget.appState.logout(); Navigator.of(context).pop(); }, child: const Text('Logout'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
