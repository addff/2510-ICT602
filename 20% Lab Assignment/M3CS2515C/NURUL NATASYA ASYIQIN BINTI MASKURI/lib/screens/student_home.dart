import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'profile_home.dart';

class StudentHome extends StatefulWidget {
  final Map<String, dynamic>? user; 
  const StudentHome({super.key, this.user});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  //store user data safely
  Map<String, dynamic>? userData;

  double test = 0;
  double assignment = 0;
  double project = 0;
  double totalCarry = 0;
  String selectedGrade = 'A (80-89)';
  double requiredFinalExam = 0;
  bool showResult = false;

  final Map<String, double> gradeRanges = {
    'A+ (90-100)': 95,
    'A (80-89)': 84.5,
    'A- (75-79)': 77,
    'B+ (70-74)': 72,
    'B (65-69)': 67,
    'B- (60-64)': 62,
    'C+ (55-59)': 57,
    'C (50-54)': 52,
  };

  final TextEditingController carryMarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userData = widget.user; // keep same structure
    fetchCarryMarks();
    fetchUserProfile(); // refreshes from Firestore
  }

  // FETCH CARRY MARKS
  Future<void> fetchCarryMarks() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('carry_marks')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          test = (doc['test'] ?? 0).toDouble();
          assignment = (doc['assignment'] ?? 0).toDouble();
          project = (doc['project'] ?? 0).toDouble();
          totalCarry = test + assignment + project;
          carryMarkController.text = totalCarry.toString();
          calculateRequiredFinalExam();
        });
      }
    } catch (_) {}
  }

  // FETCH USER PROFILE
  Future<void> fetchUserProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (_) {}
  }

  void calculateRequiredFinalExam() {
    double carryPercent = totalCarry;
    double targetPercent = gradeRanges[selectedGrade] ?? 80;

    requiredFinalExam = ((targetPercent - carryPercent) / 0.5).clamp(0, 100);

    setState(() {
      showResult = true;
    });
  }

  Color getResultColor() {
    if (requiredFinalExam > 100) return Colors.red;
    if (requiredFinalExam >= 80) return Colors.orange;
    if (requiredFinalExam >= 60) return Colors.blue;
    return Colors.green;
  }

  String getResultMessage() {
    if (requiredFinalExam > 100) return '⚠ Impossible to achieve target grade';
    if (requiredFinalExam >= 80) return '🎯 Challenging - Need to study hard';
    if (requiredFinalExam >= 60) return '📚 Achievable with good preparation';
    return '✅ Easily achievable';
  }

  DataRow buildGradeRow(String grade, String range, String desc) {
    return DataRow(cells: [
      DataCell(Text(grade)),
      DataCell(Text(range)),
      DataCell(Text(desc)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // WELCOME CARD
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.person, size: 60, color: Colors.purple),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome, ${userData?['fullName'] ?? 'Student'}!',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Matric: ${userData?['matricNumber'] ?? 'Not set'}',
                      ),
                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                      onPressed: () async {
                        if (userData != null) {
                          final updatedUser = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileHome(user: userData!),
                            ),
                          );

                          // Apply updated user data immediately
                          if (updatedUser != null) {
                            setState(() {
                              userData = updatedUser;
                            });
                          }

                          // fetch fresh data from Firestore
                          fetchUserProfile();
                        }
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CARRY MARKS
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Your Carry Marks',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple)),
                      const SizedBox(height: 10),
                      Text('Test: $test / 20'),
                      Text('Assignment: $assignment / 10'),
                      Text('Project: $project / 20'),
                      Text('Total Carry: $totalCarry / 50',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TARGET GRADE
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Target Grade:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: selectedGrade,
                        isExpanded: true,
                        items: gradeRanges.keys.map((grade) {
                          return DropdownMenuItem<String>(
                            value: grade,
                            child: Text(grade),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGrade = value!;
                            calculateRequiredFinalExam();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (showResult)
                Card(
                  color: getResultColor().withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Calculation Result',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          'Required Final Exam Score: ${requiredFinalExam.toStringAsFixed(1)} / 50',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: getResultColor()),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          getResultMessage(),
                          style: TextStyle(
                              color: getResultColor(),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // GRADE TABLE
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 ICT602 Grade Scale',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Grade')),
                          DataColumn(label: Text('Range')),
                          DataColumn(label: Text('Description')),
                        ],
                        rows: [
                          buildGradeRow('A+', '90-100', 'Excellent'),
                          buildGradeRow('A', '80-89', 'Very Good'),
                          buildGradeRow('A-', '75-79', 'Good'),
                          buildGradeRow('B+', '70-74', 'Satisfactory+'),
                          buildGradeRow('B', '65-69', 'Satisfactory'),
                          buildGradeRow('B-', '60-64', 'Satisfactory-'),
                          buildGradeRow('C+', '55-59', 'Pass+'),
                          buildGradeRow('C', '50-54', 'Pass'),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text('Note: Carry Mark = 50%, Final Exam = 50%',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}