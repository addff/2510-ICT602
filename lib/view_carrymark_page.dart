import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewCarryMarkPage extends StatefulWidget {
  const ViewCarryMarkPage({super.key});

  @override
  State<ViewCarryMarkPage> createState() => _ViewCarryMarkPageState();
}

class _ViewCarryMarkPageState extends State<ViewCarryMarkPage> {
  final _matricCtrl = TextEditingController();
  bool _savingMatric = false;

  Future<DocumentSnapshot<Map<String, dynamic>>> _getProfile() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> _saveMatric() async {
    final matric = _matricCtrl.text.trim();
    if (matric.isEmpty) return;

    setState(() => _savingMatric = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      "matric": matric,
      "role": "student",
      "email": FirebaseAuth.instance.currentUser!.email,
    }, SetOptions(merge: true));

    setState(() => _savingMatric = false);
  }

  @override
  void dispose() {
    _matricCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectColors = [
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.orange.shade50,
      Colors.purple.shade50,
      Colors.teal.shade50,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("My Carry Marks")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getProfile(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() ?? {};
          final matric = (data['matric'] ?? '').toString().trim();

          ///FIRST TIME — STUDENT HAS NO MATRIC
          if (matric.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.badge, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    "Enter your matric number",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _matricCtrl,
                    decoration: const InputDecoration(
                      labelText: "Matric Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savingMatric ? null : _saveMatric,
                      child: _savingMatric
                          ? const CircularProgressIndicator()
                          : const Text("Save Matric"),
                    ),
                  ),
                ],
              ),
            );
          }

          ///SHOW STUDENT ID + SUBJECT CARDS
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Student ID: $matric",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('carrymarks')
                      .where('studentMatric', isEqualTo: matric)
                      .snapshots(),
                  builder: (context, markSnap) {
                    if (!markSnap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final docs = markSnap.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                          child: Text("No carry marks yet"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final d = docs[i].data();
                        final total =
                            (d['total50'] as num?)?.toDouble() ?? 0;

                        final bool atRisk = total <= 30;

                        final bgColor = atRisk
                            ? Colors.red.shade50
                            : subjectColors[i % subjectColors.length];

                        return AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          margin:
                              const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.assignment,
                              color:
                                  atRisk ? Colors.red : Colors.black,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  d['subjectCode'] ?? 'Subject',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (atRisk) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.red.shade100,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '⚠ At risk',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  "Total: ${d['total50']} / 50",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: atRisk
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Test: ${d['test20']} / 20"),
                                Text(
                                    "Assignment: ${d['assignment10']} / 10"),
                                Text("Project: ${d['project20']} / 20"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
