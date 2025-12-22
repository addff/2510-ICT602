import 'package:flutter/material.dart';
import '../models/student.dart';
import '../db/database_helper.dart';
import '../models/carry_mark.dart';

class CarryMarkEditPage extends StatefulWidget {
  final Student student;
  const CarryMarkEditPage({super.key, required this.student});

  @override
  State<CarryMarkEditPage> createState() => _CarryMarkEditPageState();
}

class _CarryMarkEditPageState extends State<CarryMarkEditPage> {
  final _formKey = GlobalKey<FormState>();
  double _test = 0;
  double _assignment = 0;
  double _project = 0;
  CarryMark? _existing;
  bool _loading = true;

  final _testCtrl = TextEditingController();
  final _assignmentCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _testCtrl.dispose();
    _assignmentCtrl.dispose();
    _projectCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final marks = await DatabaseHelper.instance.getCarryMarksByStudentId(widget.student.id!);
    if (marks.isNotEmpty) {
      final m = marks.first;
      setState(() {
        _existing = m;
        _test = m.test;
        _assignment = m.assignment;
        _project = m.project;
        _testCtrl.text = m.test.toStringAsFixed(0);
        _assignmentCtrl.text = m.assignment.toStringAsFixed(0);
        _projectCtrl.text = m.project.toStringAsFixed(0);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  double get _carryTotal => _test * 0.20 + _assignment * 0.10 + _project * 0.20;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final mark = CarryMark(
      id: _existing?.id,
      studentId: widget.student.id!,
      test: _test,
      assignment: _assignment,
      project: _project,
    );

    if (_existing != null) {
      await DatabaseHelper.instance.updateCarryMark(mark);
    } else {
      await DatabaseHelper.instance.insertCarryMark(mark);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carry mark saved')));
    Navigator.pop(context);
  }

  String? _validateScore(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a number';
    if (n < 0 || n > 100) return '0 - 100';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Carry Mark - ${widget.student.name}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _testCtrl,
                      decoration: const InputDecoration(labelText: 'Test (20%)'),
                      keyboardType: TextInputType.number,
                      validator: _validateScore,
                      onChanged: (v) => setState(() {
                        _test = double.tryParse(v) ?? 0;
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _assignmentCtrl,
                      decoration: const InputDecoration(labelText: 'Assignment (10%)'),
                      keyboardType: TextInputType.number,
                      validator: _validateScore,
                      onChanged: (v) => setState(() {
                        _assignment = double.tryParse(v) ?? 0;
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _projectCtrl,
                      decoration: const InputDecoration(labelText: 'Project (20%)'),
                      keyboardType: TextInputType.number,
                      validator: _validateScore,
                      onChanged: (v) => setState(() {
                        _project = double.tryParse(v) ?? 0;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Carry total:'), Text('${_carryTotal.toStringAsFixed(2)} / 100', style: const TextStyle(fontWeight: FontWeight.bold))]),
                        SizedBox(width: 120, child: LinearProgressIndicator(value: _carryTotal / 100)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _save, child: const Text('Save')),
                  ],
                ),
              ),
            ),
    );
  }
}
