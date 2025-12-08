import 'package:flutter/material.dart';
import '../state/app_state.dart';

class LecturerPage extends StatefulWidget {
  final AppState appState;
  const LecturerPage({super.key, required this.appState});
  @override
  State<LecturerPage> createState() => _LecturerPageState();
}

class _LecturerPageState extends State<LecturerPage> {
  final TextEditingController studentId = TextEditingController();
  final TextEditingController test20 = TextEditingController();
  final TextEditingController assignment10 = TextEditingController();
  final TextEditingController project20 = TextEditingController();
  final TextEditingController _studentFilter = TextEditingController();
  String? info;

  void save() {
    final id = studentId.text.trim();
    final t = double.tryParse(test20.text) ?? -1;
    final a = double.tryParse(assignment10.text) ?? -1;
    final p = double.tryParse(project20.text) ?? -1;
    if (id.isEmpty || t < 0 || a < 0 || p < 0 || t > 20 || a > 10 || p > 20) {
      setState(() => info = 'Enter valid marks: Test<=20 Assignment<=10 Project<=20');
      return;
    }
    widget.appState.saveMark(id, t, a, p);
    setState(() => info = 'Saved for $id');
  }

  void _openStudentPicker() {
    _studentFilter.clear();
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Find Student ID'),
        content: StatefulBuilder(builder: (ctx2, setInner) {
          List<String> ids = widget.appState.students.keys.toList()..sort();
          final q = _studentFilter.text.trim().toLowerCase();
          if (q.isNotEmpty) {
            ids = ids.where((e) => e.toLowerCase().contains(q)).toList();
          }
          return SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _studentFilter,
                  decoration: const InputDecoration(labelText: 'Search ID'),
                  onChanged: (_) => setInner(() {}),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ids.isEmpty
                    ? const Center(child: Text('No students found'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: ids.length,
                        itemBuilder: (_, i) {
                          final id = ids[i];
                          return ListTile(
                            title: Text(id),
                            onTap: () {
                              studentId.text = id;
                              Navigator.of(ctx).pop();
                              setState(() { info = 'Selected $id'; });
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lecturer'),
          bottom: const TabBar(tabs: [Tab(text: 'Entry'), Tab(text: 'Marks')]),
        ),
        body: TabBarView(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(children: [
                                Expanded(child: TextField(controller: studentId, decoration: const InputDecoration(labelText: 'Student ID'))),
                                const SizedBox(width: 8),
                                IconButton(onPressed: _openStudentPicker, icon: const Icon(Icons.search), tooltip: 'Find registered ID'),
                              ]),
                              const SizedBox(height: 12),
                              TextField(controller: test20, decoration: const InputDecoration(labelText: 'Test (0-20)'), keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              TextField(controller: assignment10, decoration: const InputDecoration(labelText: 'Assignment (0-10)'), keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              TextField(controller: project20, decoration: const InputDecoration(labelText: 'Project (0-20)'), keyboardType: TextInputType.number),
                              const SizedBox(height: 16),
                              FilledButton(onPressed: save, child: const Text('Save')),
                              const SizedBox(height: 8),
                              if (info != null) Text(info!),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(onPressed: () { widget.appState.logout(); Navigator.of(context).pop(); }, child: const Text('Logout'))
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(columns: const [
                  DataColumn(label: Text('Student')), 
                  DataColumn(label: Text('Test')), 
                  DataColumn(label: Text('Assign')), 
                  DataColumn(label: Text('Project')), 
                  DataColumn(label: Text('Total')), 
                  DataColumn(label: Text('Actions')),
                ], rows: widget.appState.allMarks().map((e) {
                  final id = e.key; final m = e.value; final total = m.total;
                  return DataRow(cells: [
                    DataCell(Text(id), onTap: () { setState(() { studentId.text = id; test20.text = m.test20.toString(); assignment10.text = m.assignment10.toString(); project20.text = m.project20.toString(); info = 'Loaded $id'; }); }),
                    DataCell(Text(m.test20.toString())),
                    DataCell(Text(m.assignment10.toString())),
                    DataCell(Text(m.project20.toString())),
                    DataCell(Text(total.toString())),
                    DataCell(Row(children: [
                      IconButton(onPressed: () { setState(() { widget.appState.deleteMark(id); }); }, icon: const Icon(Icons.delete)),
                    ])),
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
