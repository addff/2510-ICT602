import 'package:flutter/material.dart';
import 'login_page.dart';
import 'database_helper.dart';

class LecturerPage extends StatefulWidget {
  const LecturerPage({super.key});
  @override
  State<LecturerPage> createState() => _LecturerPageState();
}

class _LecturerPageState extends State<LecturerPage> {
  String? selectedStudent;
  double test = 0, assignment = 0, project = 0;
  List<Map<String, dynamic>> students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    final studentList = await DatabaseHelper.instance.getStudents();
    
    setState(() {
      students = studentList;
      if (students.isNotEmpty) {
        selectedStudent = students.first['username'] as String;
      }
      _isLoading = false;
    });
    
    if (selectedStudent != null) {
      await _loadMarks();
    }
  }

  Future<void> _loadMarks() async {
    if (selectedStudent == null) return;

    final marks = await DatabaseHelper.instance.getStudentMarks(selectedStudent!);
    
    setState(() {
      if (marks != null) {
        test = (marks['test_20'] as num).toDouble();
        assignment = (marks['assignment_10'] as num).toDouble();
        project = (marks['project_20'] as num).toDouble();
      } else {
        test = 0;
        assignment = 0;
        project = 0;
      }
    });
  }

  Future<void> _saveMarks() async {
    if (selectedStudent == null) return;

    await DatabaseHelper.instance.saveMarks(
      studentUsername: selectedStudent!,
      testMark: test,
      assignmentMark: assignment,
      projectMark: project,
    );

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Marks saved successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildMarkInput(String label, String hint, double value, Function(double) onChanged) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                suffixText: '/100',
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              controller: TextEditingController(text: value.toString()),
              onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    // Header Card
                    Card(
                      elevation: 4,
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
                                Icons.school,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ICT602 - Carry Marks',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Weight: Test(20%) + Assignment(10%) + Project(20%)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
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

                    // Student Selection
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
                              'Select Student',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (students.isEmpty)
                              const Text(
                                'No students available',
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedStudent,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  items: students
                                      .map((student) => DropdownMenuItem(
                                            value:
                                                student['username'] as String,
                                            child: Text(
                                              student['username'] as String,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStudent = value;
                                    });
                                    _loadMarks();
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Marks Input Section
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
                              'Enter Carry Marks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMarkInput(
                              'Test (20% weight)',
                              'Enter test marks',
                              test,
                              (value) => setState(() => test = value),
                            ),
                            const SizedBox(height: 16),
                            _buildMarkInput(
                              'Assignment (10% weight)',
                              'Enter assignment marks',
                              assignment,
                              (value) => setState(() => assignment = value),
                            ),
                            const SizedBox(height: 16),
                            _buildMarkInput(
                              'Project (20% weight)',
                              'Enter project marks',
                              project,
                              (value) => setState(() => project = value),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _saveMarks,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Save Marks',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Current Total Preview
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
                              'Current Carry Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildScoreItem('Test', test, 0.20),
                            _buildScoreItem('Assignment', assignment, 0.10),
                            _buildScoreItem('Project', project, 0.20),
                            const Divider(height: 24),
                            _buildTotalScore(),
                          ],
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

  Widget _buildScoreItem(String label, double score, double weight) {
    final contribution = score * weight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label (${(weight * 100).toInt()}%)',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${contribution.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScore() {
    final total = test * 0.20 + assignment * 0.10 + project * 0.20;
    return Row(
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
          '${total.toStringAsFixed(2)} / 50.00',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}