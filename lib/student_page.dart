import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  String selectedGrade = 'A';
  double targetScore = 80;
  double? finalNeeded;

  final Map<String, double> gradeMap = {
    'A+': 90,
    'A': 80,
    'A-': 75,
    'B+': 70,
    'B': 65,
    'B-': 60,
    'C+': 55,
    'C': 50,
  };

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Student Portal")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('carry_marks')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("No carry mark found"));
          }

          var data = snapshot.data!;
          double carryMark = data['total'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 HEADER CARD (HI, STUDENT)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hi, Student",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "ICT602 - Carry Mark Overview",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Total Carry Mark: $carryMark / 50",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 MARK CARDS
                Row(
                  children: [
                    _markCard("Test", data['test'], 20, Icons.assignment),
                    _markCard("Assignment", data['assignment'], 10, Icons.book),
                    _markCard("Project", data['project'], 20, Icons.computer),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔹 TARGET GRADE CALCULATOR CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Target Grade Calculator",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Select your target grade to see the required final exam mark.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 15),

                        DropdownButton<String>(
                          value: selectedGrade,
                          isExpanded: true,
                          items: gradeMap.keys.map((grade) {
                            return DropdownMenuItem(
                              value: grade,
                              child: Text("$grade (min ${gradeMap[grade]!.toInt()}%)"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedGrade = value!;
                              targetScore = gradeMap[value]!;
                            });
                          },
                        ),

                        const SizedBox(height: 15),

                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              finalNeeded = targetScore - carryMark;
                            });
                          },
                          child: const Text("Calculate Required Final Mark"),
                        ),

                        const SizedBox(height: 15),

                        if (finalNeeded != null)
                          Text(
                            "You need ${finalNeeded!.toStringAsFixed(1)} / 50 in Final Exam",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔧 HELPER WIDGET FOR MARK CARD
  Widget _markCard(String title, num mark, int max, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 5),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("$mark / $max"),
            ],
          ),
        ),
      ),
    );
  }
}
