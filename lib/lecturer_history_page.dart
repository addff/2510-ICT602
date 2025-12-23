import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_carrymark_page.dart';

class LecturerHistoryPage extends StatelessWidget {
  const LecturerHistoryPage({super.key});

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
      appBar: AppBar(title: const Text('Carry Mark History')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

          //GROUP BY studentMatric
          final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
              grouped = {};

          for (final d in docs) {
            final matric = d['studentMatric'];
            grouped.putIfAbsent(matric, () => []);
            grouped[matric]!.add(d);
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children:
                grouped.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final matric = entry.value.key;
              final items = entry.value.value;

              return Card(
                color: colors[index % colors.length],
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //STUDENT HEADER
                      Text(
                        'Student: $matric',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),

                      //SUBJECT LIST (with separator line between subjects)
                      ...items.asMap().entries.expand((e) {
                        final idx = e.key;
                        final doc = e.value;
                        final d = doc.data();

                        final subjectWidget = Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d['subjectCode'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Test: ${d['test20']} / 20'),
                                    Text(
                                        'Assignment: ${d['assignment10']} / 10'),
                                    Text(
                                        'Project: ${d['project20']} / 20'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total: ${d['total50']} / 50',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditCarryMarkPage(
                                            docId: doc.id,
                                            data: d,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text(
                                              'Delete Carry Mark'),
                                          content: const Text(
                                              'Are you sure you want to delete this record?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                    Colors.red,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (ok == true) {
                                        await FirebaseFirestore.instance
                                            .collection('carrymarks')
                                            .doc(doc.id)
                                            .delete();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Carry mark deleted'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );

                        // Add a divider after each subject
                        final isLast = idx == items.length - 1;
                        if (isLast) return [subjectWidget];

                        return [
                          subjectWidget,
                          Divider(
                            height: 12,
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
    );
  }
}
