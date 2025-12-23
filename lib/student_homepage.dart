import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'target_grade_page.dart';
import 'view_carrymark_page.dart';

class StudentHomepage extends StatelessWidget {
  StudentHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //Disable system back button on dashboard
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                //ONLY sign out
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
                      MaterialPageRoute(
                        builder: (_) => ViewCarryMarkPage(),
                      ),
                    );
                  },
                  child: const Text('View Carry Marks'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TargetGradePage(),
                      ),
                    );
                  },
                  child: const Text('Target Grade Calculator'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
