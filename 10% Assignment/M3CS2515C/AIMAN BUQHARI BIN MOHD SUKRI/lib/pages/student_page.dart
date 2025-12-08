import 'package:flutter/material.dart';
import '../state/app_state.dart';

class StudentPage extends StatefulWidget {
  final AppState appState;
  const StudentPage({super.key, required this.appState});
  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final TextEditingController studentId = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  CarryMark? mark;
  int? selectedMin;
  final Map<String, double> t20 = {};
  final Map<String, double> a10 = {};
  final Map<String, double> p20 = {};
  final Map<String, int> subjectMin = {};

  void load() {
    final id = studentId.text.trim();
    setState(() => mark = widget.appState.getMark(id));
    final current = widget.appState.getStudentTarget(id);
    setState(() => selectedMin = current);
  }

  void addSubject(String id) {
    final s = subjectController.text.trim();
    if (s.isEmpty) return;
    widget.appState.addSubject(id, s);
    subjectController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject added')));
  }

  void saveSubjectCarry(String id, String subject) {
    final cm = widget.appState.getSubjectCarry(id, subject);
    final tv = t20[subject] ?? (cm?.test20 ?? 0);
    final av = a10[subject] ?? (cm?.assignment10 ?? 0);
    final pv = p20[subject] ?? (cm?.project20 ?? 0);
    widget.appState.setSubjectCarry(id, subject, tv, av, pv);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final carry = mark?.total ?? 0;
    final targets = widget.appState.examTargets(carry);
    final isStudent = widget.appState.currentUser?.role == UserRole.student;
    final currentId = widget.appState.currentUser?.id;
    if (isStudent && currentId != null) {
      studentId.text = studentId.text.isEmpty ? currentId : studentId.text;
      mark ??= widget.appState.getMark(currentId);
      selectedMin ??= widget.appState.getStudentTarget(currentId);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Student')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              primary: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isStudent)
                    Row(children: [
                      Expanded(child: TextField(controller: studentId, decoration: const InputDecoration(labelText: 'Student ID'))),
                      const SizedBox(width: 12),
                      FilledButton(onPressed: load, child: const Text('View')),
                    ])
                  else
                    Align(alignment: Alignment.centerLeft, child: Text('ID: $currentId')),
                  const SizedBox(height: 16),
                  if (mark == null)
                    const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No marks found')))
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [const Text('Test'), Text(mark!.test20.toString())]),
                            Column(children: [const Text('Assignment'), Text(mark!.assignment10.toString())]),
                            Column(children: [const Text('Project'), Text(mark!.project20.toString())]),
                            Column(children: [const Text('Carry Total'), Text(carry.toString())]),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Set Target Grade'),
                          const SizedBox(height: 12),
                          SegmentedButton<int>(
                            segments: const <ButtonSegment<int>>[
                              ButtonSegment(value: 90, label: Text('A+')),
                              ButtonSegment(value: 80, label: Text('A')),
                              ButtonSegment(value: 75, label: Text('A-')),
                              ButtonSegment(value: 70, label: Text('B+')),
                              ButtonSegment(value: 65, label: Text('B')),
                              ButtonSegment(value: 60, label: Text('B-')),
                              ButtonSegment(value: 55, label: Text('C+')),
                              ButtonSegment(value: 50, label: Text('C')),
                            ],
                            selected: {selectedMin ?? 80},
                            onSelectionChanged: (s) {
                              final min = s.first;
                              setState(() => selectedMin = min);
                              final id = isStudent ? currentId! : studentId.text.trim();
                              if (id.isNotEmpty) widget.appState.setStudentTarget(id, min);
                            },
                          ),
                          const SizedBox(height: 12),
                          Builder(builder: (_) {
                            final min = selectedMin ?? 80;
                            final req = widget.appState.requiredExamForTarget(carry, min);
                            final text = req > 100 ? 'Not possible' : '$req/100';
                            return Text('Required exam for target: $text');
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Builder(builder: (context) {
                    final viewId = isStudent ? currentId ?? '' : studentId.text.trim();
                    final subs = widget.appState.getSubjects(viewId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(child: TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject'))),
                                const SizedBox(width: 12),
                                FilledButton(onPressed: viewId.isEmpty ? null : () => addSubject(viewId), child: const Text('Add')),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(builder: (ctx, cons) {
                          final w = cons.maxWidth;
                          final cols = w >= 900 ? 3 : (w >= 600 ? 2 : 1);
                          const gap = 12.0;
                          final itemW = cols == 1 ? w : (w - gap * (cols - 1)) / cols;
                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: subs.map((s) {
                              final cm = widget.appState.getSubjectCarry(viewId, s);
                              final minSel = subjectMin[s] ?? (widget.appState.getSubjectTarget(viewId, s) ?? 80);
                              final carryTotal = cm?.total ?? 0;
                              final req = widget.appState.requiredExamForTarget(carryTotal, minSel);
                              final reqText = req > 100 ? 'Not possible' : '$req/100';
                              return SizedBox(
                                width: itemW,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s, style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                initialValue: (cm?.test20 ?? 0).toString(),
                                                decoration: const InputDecoration(labelText: 'Test (20)'),
                                                onChanged: (v) {
                                                  var x = double.tryParse(v) ?? 0;
                                                  if (x < 0) x = 0; if (x > 20) x = 20;
                                                  t20[s] = x;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                initialValue: (cm?.assignment10 ?? 0).toString(),
                                                decoration: const InputDecoration(labelText: 'Assignment (10)'),
                                                onChanged: (v) {
                                                  var x = double.tryParse(v) ?? 0;
                                                  if (x < 0) x = 0; if (x > 10) x = 10;
                                                  a10[s] = x;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                initialValue: (cm?.project20 ?? 0).toString(),
                                                decoration: const InputDecoration(labelText: 'Project (20)'),
                                                onChanged: (v) {
                                                  var x = double.tryParse(v) ?? 0;
                                                  if (x < 0) x = 0; if (x > 20) x = 20;
                                                  p20[s] = x;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            FilledButton(onPressed: viewId.isEmpty ? null : () => saveSubjectCarry(viewId, s), child: const Text('Save Carry')),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SegmentedButton<int>(
                                          segments: const <ButtonSegment<int>>[
                                            ButtonSegment(value: 90, label: Text('A+')),
                                            ButtonSegment(value: 80, label: Text('A')),
                                            ButtonSegment(value: 75, label: Text('A-')),
                                            ButtonSegment(value: 70, label: Text('B+')),
                                            ButtonSegment(value: 65, label: Text('B')),
                                            ButtonSegment(value: 60, label: Text('B-')),
                                            ButtonSegment(value: 55, label: Text('C+')),
                                            ButtonSegment(value: 50, label: Text('C')),
                                          ],
                                          selected: {minSel},
                                          onSelectionChanged: (sel) {
                                            final m = sel.first;
                                            subjectMin[s] = m;
                                            if (viewId.isNotEmpty) widget.appState.setSubjectTarget(viewId, s, m);
                                            setState(() {});
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Required exam: $reqText'),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    );
                  }),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(columns: const [
                          DataColumn(label: Text('Grade')),
                          DataColumn(label: Text('Required Exam')),
                        ], rows: targets.map((t) => DataRow(cells: [
                          DataCell(Text(t['label']!)),
                          DataCell(Text(t['required']!)),
                        ])).toList()),
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
      ),
    );
  }
}
