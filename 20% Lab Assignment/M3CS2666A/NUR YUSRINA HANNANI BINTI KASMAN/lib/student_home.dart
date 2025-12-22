import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Student Home")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("marks").doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          if (!snapshot.data!.exists) {
            return Center(child: Text("No marks found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Test: ${data['test']}", style: TextStyle(fontSize: 18)),
                Text("Assignment: ${data['assignment']}", style: TextStyle(fontSize: 18)),
                Text("Project: ${data['project']}", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Total Carry: ${data['totalCarry']}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Grade: ${data['grade']}",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
