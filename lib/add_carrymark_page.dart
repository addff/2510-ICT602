import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCarryMarkPage extends StatefulWidget {
  const AddCarryMarkPage({super.key});

  @override
  State<AddCarryMarkPage> createState() => _AddCarryMarkPageState();
}

class _AddCarryMarkPageState extends State<AddCarryMarkPage> {
  final _formKey = GlobalKey<FormState>();

  final matricCtrl = TextEditingController();
  final subjectCtrl = TextEditingController(text: 'ICT602');
  final testCtrl = TextEditingController();
  final assignmentCtrl = TextEditingController();
  final projectCtrl = TextEditingController();

  bool saving = false;

  
  String _normalizeSubject(String s) {
    return s.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  String? _validateNum(String? v, double max) {
    if (v == null || v.isEmpty) return 'Required';
    final n = double.tryParse(v);
    if (n == null) return 'Invalid';
    if (n < 0) return '≥ 0';
    if (n > max) return 'Max $max';
    return null;
  }

  double _val(TextEditingController c) => double.tryParse(c.text) ?? 0;

  double get total => _val(testCtrl) + _val(assignmentCtrl) + _val(projectCtrl);

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    if (total > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total cannot exceed 50%')),
      );
      return;
    }

    setState(() => saving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fs = FirebaseFirestore.instance;

    final matric = matricCtrl.text.trim();

    
    final subject = _normalizeSubject(subjectCtrl.text);

    
    subjectCtrl.text = subject;

    final dup = await fs
        .collection('carrymarks')
        .where('studentMatric', isEqualTo: matric)
        .where('subjectCode', isEqualTo: subject)
        .limit(1)
        .get();

    if (dup.docs.isNotEmpty) {
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carry mark already exists for this subject'),
        ),
      );
      return;
    }

    await fs.collection('carrymarks').add({
      'studentMatric': matric,
      'subjectCode': subject, 
      'test20': _val(testCtrl),
      'assignment10': _val(assignmentCtrl),
      'project20': _val(projectCtrl),
      'total50': total,
      'lecturerUid': uid,
    });

    matricCtrl.clear();
    testCtrl.clear();
    assignmentCtrl.clear();
    projectCtrl.clear();

    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carry mark saved')),
    );
  }

  TableRow row(String label, Widget field) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: field,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final colors = [
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.orange.shade50,
      Colors.purple.shade50,
      Colors.teal.shade50,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Carry Mark')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ///FORM
            Form(
              key: _formKey,
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {0: FixedColumnWidth(130)},
                children: [
                  row(
                    'Student Matric',
                    TextFormField(
                      controller: matricCtrl,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  row(
                    'Subject Code',
                    TextFormField(
                      controller: subjectCtrl,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  row(
                    'Test (20%)',
                    TextFormField(
                      controller: testCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNum(v, 20),
                    ),
                  ),
                  row(
                    'Assignment (10%)',
                    TextFormField(
                      controller: assignmentCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNum(v, 10),
                    ),
                  ),
                  row(
                    'Project (20%)',
                    TextFormField(
                      controller: projectCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNum(v, 20),
                    ),
                  ),
                  row(
                    'Total (50%)',
                    Text(
                      total.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : save,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ),

            const Divider(height: 32),

            ///GROUPED HISTORY
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('carrymarks')
                    .where('lecturerUid', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text('No carry marks yet'));
                  }

                  final Map<String, List<QueryDocumentSnapshot>> grouped = {};

                  for (final d in docs) {
                    final data = d.data() as Map<String, dynamic>;
                    final matric = data['studentMatric'];
                    grouped.putIfAbsent(matric, () => []);
                    grouped[matric]!.add(d);
                  }

                  return ListView(
                    children: grouped.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final matric = entry.value.key;
                      final items = entry.value.value;

                      return Card(
                        color: colors[index % colors.length],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student: $matric',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              ...items.asMap().entries.expand((e) {
                                final idx = e.key;
                                final doc = e.value;
                                final m =
                                    doc.data() as Map<String, dynamic>;

                                final subject = Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    '${m['subjectCode']} | Total: ${m['total50']} / 50',
                                  ),
                                );

                                final isLast = idx == items.length - 1;
                                if (isLast) return [subject];

                                return [
                                  subject,
                                  Divider(
                                    thickness: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ];
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
