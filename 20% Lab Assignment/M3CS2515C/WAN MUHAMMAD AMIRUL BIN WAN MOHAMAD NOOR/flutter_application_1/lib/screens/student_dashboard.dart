import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/carry_mark_service.dart';
import '../services/grade_calculation_service.dart';
import 'login_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final AuthService _authService = AuthService();
  final CarryMarkService _carryMarkService = CarryMarkService();

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard - ICT602'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: FutureBuilder<User?>(
          future: _authService.getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = snapshot.data;
            if (user == null) {
              return const Center(child: Text('Error loading user'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome, Student',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'View your ICT602 Carry Marks & Calculate Target Grades',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewCarryMarksPage(studentId: user.studentId ?? user.email),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('View My Carry Marks'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GradeCalculatorPage(studentId: user.studentId ?? user.email),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Target Grades'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Your Grades',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your final grade is calculated as:',
                        ),
                        const SizedBox(height: 8),
                        const Text('• Carry Mark (50%):'),
                        const Text('  - Test: 20 marks'),
                        const Text('  - Assignment: 10 marks'),
                        const Text('  - Project: 20 marks'),
                        const SizedBox(height: 8),
                        const Text('• Final Exam (50%)'),
                        const SizedBox(height: 12),
                        const Text(
                          'Final Grade = (Carry Mark × 0.5) + (Exam Mark × 0.5)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ViewCarryMarksPage extends StatefulWidget {
  final String studentId;

  const ViewCarryMarksPage({super.key, required this.studentId});

  @override
  State<ViewCarryMarksPage> createState() => _ViewCarryMarksPageState();
}

class _ViewCarryMarksPageState extends State<ViewCarryMarksPage> {
  final CarryMarkService _carryMarkService = CarryMarkService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Carry Marks'),
      ),
      body: StreamBuilder<CarryMark?>(
        stream: _carryMarkService.getStudentCarryMarksStream(widget.studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final carryMark = snapshot.data;

          if (carryMark == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No carry marks yet. Please check back later.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final carryPercentage = carryMark.getCarryMarkPercentage();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ICT602 Carry Marks',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildMarkRow('Test', carryMark.testMark, 20),
                        const SizedBox(height: 12),
                        _buildMarkRow('Assignment', carryMark.assignmentMark, 10),
                        const SizedBox(height: 12),
                        _buildMarkRow('Project', carryMark.projectMark, 20),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Total Carry Mark',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${carryPercentage.toStringAsFixed(1)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '(50% of your final grade)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What\'s Next?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Your carry mark contributes 50% to your final grade',
                      ),
                      Text(
                        '2. The final exam will contribute another 50%',
                      ),
                      Text(
                        '3. Use the Grade Calculator to see what exam mark you need for your target grade',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarkRow(String label, double mark, double maxMark) {
    final percentage = (mark / maxMark) * 100;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${mark.toStringAsFixed(1)}/$maxMark',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: percentage >= 70 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class GradeCalculatorPage extends StatefulWidget {
  final String studentId;

  const GradeCalculatorPage({super.key, required this.studentId});

  @override
  State<GradeCalculatorPage> createState() => _GradeCalculatorPageState();
}

class _GradeCalculatorPageState extends State<GradeCalculatorPage> {
  final CarryMarkService _carryMarkService = CarryMarkService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Calculator'),
      ),
      body: StreamBuilder<CarryMark?>(
        stream: _carryMarkService.getStudentCarryMarksStream(widget.studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final carryMark = snapshot.data;

          if (carryMark == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No carry marks available. Please check back later.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final carryPercentage = carryMark.getCarryMarkPercentage();
          final gradeTargets =
              GradeCalculationService.getGradeTargetsWithExamMarks(
            carryPercentage,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Your Current Carry Mark',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${carryPercentage.toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Exam Mark Needed for Each Grade',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gradeTargets.length,
                  itemBuilder: (context, index) {
                    final gradeData = gradeTargets[index];
                    final grade = gradeData['grade'];
                    final description = gradeData['description'];
                    final examMark = gradeData['examMarkNeeded'];
                    final isAchievable = gradeData['isAchievable'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isAchievable ? Colors.white : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    grade,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Exam: ${examMark.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isAchievable ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (!isAchievable)
                                  const Chip(
                                    label: Text('Not Achievable'),
                                    backgroundColor: Colors.red,
                                    labelStyle: TextStyle(color: Colors.white),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Formula',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          'Final Grade = (Carry Mark × 50%) + (Exam Mark × 50%)'),
                      const SizedBox(height: 12),
                      const Text('In your case:'),
                      Text(
                        'Final Grade = (${carryPercentage.toStringAsFixed(1)} × 0.5) + (Exam Mark × 0.5)',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
