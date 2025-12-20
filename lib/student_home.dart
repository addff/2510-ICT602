import 'package:flutter/material.dart';
import 'login_page.dart';
import 'database_helper.dart';

const gradeTargets = <String, double>{
  'A+': 90.0,
  'A': 80.0,
  'A-': 75.0,
  'B+': 70.0,
  'B': 65.0,
  'B-': 60.0,
  'C+': 55.0,
  'C': 50.0,
};

const double finalWeight = 0.50; // 50% final exam weight

class StudentPage extends StatefulWidget {
  final String username;
  const StudentPage({super.key, required this.username});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  double test = 0, assignment = 0, project = 0;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _loadMarks();
  }

  Future<void> _loadMarks() async {
    final marks = await DatabaseHelper.instance.getStudentMarks(widget.username);
    
    if (marks != null) {
      setState(() {
        test = (marks['test_20'] as num).toDouble();
        assignment = (marks['assignment_10'] as num).toDouble();
        project = (marks['project_20'] as num).toDouble();
        loaded = true;
      });
    } else {
      setState(() {
        loaded = true;
      });
    }
  }

  double currentCarry() =>
      test * 0.20 + assignment * 0.10 + project * 0.20;

  double requiredFinalForTarget(double targetPercent) {
    final current = currentCarry();
    final need = (targetPercent - current) / finalWeight;

    if (need <= 0) return 0.0;
    if (need > 100) return 101.0;
    return need;
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final current = currentCarry();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: !loaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF5F7FA),
                    Color(0xFFE4E7EB),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.indigo,
                              child: Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${widget.username}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'ICT602 - Carry Marks View',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Current Marks Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Carry Marks',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMarkRow('Test', test, 0.20),
                            _buildMarkRow('Assignment', assignment, 0.10),
                            _buildMarkRow('Project', project, 0.20),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Carry Mark',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${current.toStringAsFixed(2)} / 50.00',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Grade Targets Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target Grades',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Final exam weight: 50%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...gradeTargets.entries.map((e) {
                              final req = requiredFinalForTarget(e.value);
                              final isAchievable = req <= 100 && req > 0;
                              final isAlreadyAchieved = req <= 0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getGradeColor(e.key),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getGradeColor(e.key),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        e.key,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Target: ${e.value}%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isAlreadyAchieved
                                                ? '✅ Already achieved'
                                                : isAchievable
                                                    ? 'Need final exam: ${req.toStringAsFixed(2)}%'
                                                    : '❌ Impossible (need >100%)',
                                            style: TextStyle(
                                              color: isAlreadyAchieved
                                                  ? Colors.green
                                                  : isAchievable
                                                      ? Colors.blue
                                                      : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Breakdown Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Detailed Breakdown',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildBreakdownRow(
                                        'Test Contribution', test * 0.20),
                                    _buildBreakdownRow(
                                        'Assignment Contribution',
                                        assignment * 0.10),
                                    _buildBreakdownRow(
                                        'Project Contribution', project * 0.20),
                                    const Divider(height: 30),
                                    _buildBreakdownRow('Total Carry Mark',
                                        current),
                                    const SizedBox(height: 30),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.indigo,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.insights),
                        label: const Text('View Detailed Breakdown'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMarkRow(String subject, double mark, double weight) {
    final contribution = mark * weight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(weight * 100).toInt()}% weight',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${mark.toStringAsFixed(1)} / 100',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${contribution.toStringAsFixed(2)} points',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}