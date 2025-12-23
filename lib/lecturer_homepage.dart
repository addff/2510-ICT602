import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_carrymark_page.dart';
import 'lecturer_history_page.dart';

class LecturerHomePage extends StatelessWidget {
  const LecturerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddCarryMarkPage()),
                  );
                },
                child: const Text('Add Carry Mark'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LecturerHistoryPage()),
                  );
                },
                child: const Text('Manage Carry Marks'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
