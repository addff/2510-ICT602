import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/app_state.dart';

class AdminDbPage extends StatelessWidget {
  final AppState appState;
  const AdminDbPage({super.key, required this.appState});
  String _toCsv() {
    final rows = <String>[];
    rows.add('student_id,test,assignment,project,total');
    for (final e in appState.allMarks()) {
      final id = e.key; final m = e.value;
      rows.add('$id,${m.test20},${m.assignment10},${m.project20},${m.total}');
    }
    return rows.join('\n');
  }
  @override
  Widget build(BuildContext context) {
    final entries = appState.allMarks();
    return Scaffold(
      appBar: AppBar(title: const Text('Marks Database')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Switch(
                    value: appState.remoteEnabled,
                    onChanged: (v) => appState.setRemoteEnabled(v),
                  ),
                  const SizedBox(width: 8),
                  Text(appState.remoteEnabled ? 'Remote sync enabled' : 'Remote sync disabled'),
                  const Spacer(),
                  if (appState.lastSyncError != null)
                    Text('Error: ${appState.lastSyncError}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: () async { await appState.retrySync(); }, child: const Text('Retry Sync')),
                ]),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(child: TextField(
                    decoration: const InputDecoration(labelText: 'Firebase ID Token (testing)'),
                    onSubmitted: (v) => appState.saveIdToken(v),
                  )),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: () async { await appState.clearIdToken(); }, child: const Text('Clear Token')),
                ]),
              ),
            ),
            Row(children: [
              FilledButton(
                onPressed: () {
                  final csv = _toCsv();
                  final messenger = ScaffoldMessenger.of(context);
                  Clipboard.setData(ClipboardData(text: csv)).then((_) {
                    messenger.showSnackBar(const SnackBar(content: Text('CSV copied')));
                  });
                },
                child: const Text('Export CSV')
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  appState.clearMarks();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cleared')));
                },
                child: const Text('Clear All')
              ),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(columns: const [
                  DataColumn(label: Text('Student')),
                  DataColumn(label: Text('Test')),
                  DataColumn(label: Text('Assign')),
                  DataColumn(label: Text('Project')),
                  DataColumn(label: Text('Total')),
                ], rows: entries.map((e) {
                  final m = e.value; final id = e.key;
                  return DataRow(cells: [
                    DataCell(Text(id)),
                    DataCell(Text(m.test20.toString())),
                    DataCell(Text(m.assignment10.toString())),
                    DataCell(Text(m.project20.toString())),
                    DataCell(Text(m.total.toString())),
                  ]);
                }).toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
