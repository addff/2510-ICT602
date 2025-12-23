import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCarryMarkPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditCarryMarkPage({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<EditCarryMarkPage> createState() => _EditCarryMarkPageState();
}

class _EditCarryMarkPageState extends State<EditCarryMarkPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController matricCtrl;
  late TextEditingController subjectCtrl;
  late TextEditingController testCtrl;
  late TextEditingController assignmentCtrl;
  late TextEditingController projectCtrl;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    matricCtrl =
        TextEditingController(text: widget.data['studentMatric']);
    subjectCtrl =
        TextEditingController(text: widget.data['subjectCode']);
    testCtrl =
        TextEditingController(text: widget.data['test20'].toString());
    assignmentCtrl =
        TextEditingController(text: widget.data['assignment10'].toString());
    projectCtrl =
        TextEditingController(text: widget.data['project20'].toString());
  }

  String? _validateNum(String? v, double max) {
    if (v == null || v.isEmpty) return 'Required';
    final n = double.tryParse(v);
    if (n == null) return 'Invalid';
    if (n < 0) return '≥ 0';
    if (n > max) return 'Max $max';
    return null;
  }

  double _val(TextEditingController c) =>
      double.tryParse(c.text) ?? 0;

  double get total =>
      _val(testCtrl) + _val(assignmentCtrl) + _val(projectCtrl);

  TableRow row(String label, Widget field) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: field,
      ),
    ]);
  }

  Future<void> update() async {
    if (!_formKey.currentState!.validate()) return;

    if (total > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total cannot exceed 50%')),
      );
      return;
    }

    setState(() => saving = true);

    await FirebaseFirestore.instance
        .collection('carrymarks')
        .doc(widget.docId)
        .update({
      'test20': _val(testCtrl),
      'assignment10': _val(assignmentCtrl),
      'project20': _val(projectCtrl),
      'total50': total,
    });

    setState(() => saving = false);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carry mark updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Carry Mark')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FixedColumnWidth(130),
                },
                children: [
                  row(
                    'Student Matric',
                    TextFormField(
                      controller: matricCtrl,
                      enabled: false,
                    ),
                  ),
                  row(
                    'Subject Code',
                    TextFormField(
                      controller: subjectCtrl,
                      enabled: false,
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
                onPressed: saving ? null : update,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
