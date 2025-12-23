import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LecturerCarryMarkPage extends StatefulWidget {
  const LecturerCarryMarkPage({super.key});

  @override
  State<LecturerCarryMarkPage> createState() => _LecturerCarryMarkPageState();
}

class _LecturerCarryMarkPageState extends State<LecturerCarryMarkPage> {
  final _matricCtrl = TextEditingController();
  final _testCtrl = TextEditingController(text: "0");
  final _asgCtrl = TextEditingController(text: "0");
  final _projCtrl = TextEditingController(text: "0");

  double _total = 0;
  bool _saving = false;

  double _num(String v) => double.tryParse(v.trim()) ?? 0.0;

  void _recalc() {
    final t = _num(_testCtrl.text);
    final a = _num(_asgCtrl.text);
    final p = _num(_projCtrl.text);

    double safeT = t > 20 ? 20 : (t < 0 ? 0 : t);
    double safeA = a > 10 ? 10 : (a < 0 ? 0 : a);
    double safeP = p > 20 ? 20 : (p < 0 ? 0 : p);

    setState(() => _total = safeT + safeA + safeP);
  }

  @override
  void initState() {
    super.initState();
    _testCtrl.addListener(_recalc);
    _asgCtrl.addListener(_recalc);
    _projCtrl.addListener(_recalc);
    _recalc();
  }

  @override
  void dispose() {
    _matricCtrl.dispose();
    _testCtrl.dispose();
    _asgCtrl.dispose();
    _projCtrl.dispose();
    super.dispose();
  }

  bool _validateMax() {
    final t = _num(_testCtrl.text);
    final a = _num(_asgCtrl.text);
    final p = _num(_projCtrl.text);

    if (t > 20) {
      _showError("Test mark maximum is 20%");
      return false;
    }
    if (a > 10) {
      _showError("Assignment mark maximum is 10%");
      return false;
    }
    if (p > 20) {
      _showError("Project mark maximum is 20%");
      return false;
    }
    if (t < 0 || a < 0 || p < 0) {
      _showError("Marks cannot be negative");
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _save() async {
    final matric = _matricCtrl.text.trim();
    if (matric.isEmpty) {
      _showError("Student matric is required");
      return;
    }

    if (!_validateMax()) return;

    setState(() => _saving = true);

    final lecturerUid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('carrymarks').add({
      "studentMatric": matric,
      "lecturerUid": lecturerUid,
      "subjectCode": "ICT602",
      "test20": _num(_testCtrl.text),
      "assignment10": _num(_asgCtrl.text),
      "project20": _num(_projCtrl.text),
      "total50": _total,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    _matricCtrl.clear();
    _testCtrl.text = "0";
    _asgCtrl.text = "0";
    _projCtrl.text = "0";
    _recalc();

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Carry mark saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Carry Marks")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ADD FORM
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _matricCtrl,
                      decoration: const InputDecoration(
                        labelText: "Student Matric Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _field(_testCtrl, "Test (max 20%)")),
                        const SizedBox(width: 8),
                        Expanded(child: _field(_asgCtrl, "Assignment (max 10%)")),
                        const SizedBox(width: 8),
                        Expanded(child: _field(_projCtrl, "Project (max 20%)")),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Total: ${_total.toStringAsFixed(1)} / 50",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: const Text("Save Carry Mark"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("carrymarks")
                    .where("lecturerUid", isEqualTo: uid)
                    .where("subjectCode", isEqualTo: "ICT602")
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snap.data!.docs.isEmpty) {
                    return const Center(child: Text("No carry marks yet"));
                  }

                  return ListView(
                    children: snap.data!.docs.map((d) {
                      final data = d.data();
                      return Card(
                        child: ListTile(
                          title: Text(data["studentMatric"]),
                          subtitle: Text(
                              "Total: ${data["total50"]} / 50"),
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

  Widget _field(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
