import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/carry_mark_service.dart';
import 'login_page.dart';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  final AuthService _authService = AuthService();
  final CarryMarkService _carryMarkService = CarryMarkService();

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateToAddMarks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCarryMarksPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lecturer Dashboard - ICT602'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.school,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome, Lecturer',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage ICT602 Carry Marks',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _navigateToAddMarks,
                icon: const Icon(Icons.add),
                label: const Text('Enter/Update Carry Marks'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewAllCarryMarksPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('View All Student Marks'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carry Mark Components for ICT602',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text('📝 Test: 20 marks'),
                    const Text('📋 Assignment: 10 marks'),
                    const Text('📊 Project: 20 marks'),
                    const SizedBox(height: 8),
                    const Text(
                      'Total Carry Mark: 50 marks (50% of final grade)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCarryMarksPage extends StatefulWidget {
  const AddCarryMarksPage({super.key});

  @override
  State<AddCarryMarksPage> createState() => _AddCarryMarksPageState();
}

class _AddCarryMarksPageState extends State<AddCarryMarksPage> {
  final CarryMarkService _carryMarkService = CarryMarkService();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _testMarkController = TextEditingController();
  final TextEditingController _assignmentMarkController = TextEditingController();
  final TextEditingController _projectMarkController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _studentEmailController.dispose();
    _testMarkController.dispose();
    _assignmentMarkController.dispose();
    _projectMarkController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveMarks() async {
    if (_studentIdController.text.isEmpty ||
        _studentNameController.text.isEmpty ||
        _studentEmailController.text.isEmpty ||
        _testMarkController.text.isEmpty ||
        _assignmentMarkController.text.isEmpty ||
        _projectMarkController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
        _successMessage = null;
      });
      return;
    }

    try {
      final testMark = double.parse(_testMarkController.text);
      final assignmentMark = double.parse(_assignmentMarkController.text);
      final projectMark = double.parse(_projectMarkController.text);

      if (testMark < 0 || testMark > 20 ||
          assignmentMark < 0 || assignmentMark > 10 ||
          projectMark < 0 || projectMark > 20) {
        setState(() {
          _errorMessage = 'Invalid mark values. Test (0-20), Assignment (0-10), Project (0-20)';
          _successMessage = null;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _carryMarkService.setCarryMarks(
        studentId: _studentIdController.text.trim(),
        studentEmail: _studentEmailController.text.trim(),
        studentName: _studentNameController.text.trim(),
        testMark: testMark,
        assignmentMark: assignmentMark,
        projectMark: projectMark,
      );

      setState(() {
        _successMessage = 'Marks saved successfully!';
        _errorMessage = null;
      });

      // Clear fields after successful save
      _studentIdController.clear();
      _studentNameController.clear();
      _studentEmailController.clear();
      _testMarkController.clear();
      _assignmentMarkController.clear();
      _projectMarkController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Carry Marks'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(
                labelText: 'Student ID',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentNameController,
              decoration: InputDecoration(
                labelText: 'Student Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentEmailController,
              decoration: InputDecoration(
                labelText: 'Student Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            Text(
              'Carry Mark Components',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _testMarkController,
              decoration: InputDecoration(
                labelText: 'Test Mark (0-20)',
                prefixIcon: const Icon(Icons.check_circle),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _assignmentMarkController,
              decoration: InputDecoration(
                labelText: 'Assignment Mark (0-10)',
                prefixIcon: const Icon(Icons.assignment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _projectMarkController,
              decoration: InputDecoration(
                labelText: 'Project Mark (0-20)',
                prefixIcon: const Icon(Icons.engineering),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSaveMarks,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Marks'),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewAllCarryMarksPage extends StatefulWidget {
  const ViewAllCarryMarksPage({super.key});

  @override
  State<ViewAllCarryMarksPage> createState() => _ViewAllCarryMarksPageState();
}

class _ViewAllCarryMarksPageState extends State<ViewAllCarryMarksPage> {
  final CarryMarkService _carryMarkService = CarryMarkService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Student Marks'),
      ),
      body: StreamBuilder<List<CarryMark>>(
        stream: _carryMarkService.getAllCarryMarksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final carryMarks = snapshot.data ?? [];

          if (carryMarks.isEmpty) {
            return const Center(
              child: Text('No student marks yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: carryMarks.length,
            itemBuilder: (context, index) {
              final mark = carryMarks[index];
              final carryPercentage = mark.getCarryMarkPercentage();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(mark.studentName),
                  subtitle: Text(mark.studentEmail),
                  trailing: SizedBox(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Chip(
                          label: Text('${carryPercentage.toStringAsFixed(1)}%'),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCarryMarksPage(carryMark: mark),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Marks'),
                                content: Text('Delete marks for ${mark.studentName}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _carryMarkService.deleteCarryMarks(mark.studentId);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(mark.studentName),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${mark.studentEmail}'),
                            const SizedBox(height: 16),
                            const Text(
                              'Carry Marks:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Test: ${mark.testMark}/20'),
                            Text('Assignment: ${mark.assignmentMark}/10'),
                            Text('Project: ${mark.projectMark}/20'),
                            const SizedBox(height: 8),
                            Text(
                              'Total: ${carryPercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditCarryMarksPage extends StatefulWidget {
  final CarryMark carryMark;

  const EditCarryMarksPage({super.key, required this.carryMark});

  @override
  State<EditCarryMarksPage> createState() => _EditCarryMarksPageState();
}

class _EditCarryMarksPageState extends State<EditCarryMarksPage> {
  final CarryMarkService _carryMarkService = CarryMarkService();
  late TextEditingController _studentIdController;
  late TextEditingController _studentNameController;
  late TextEditingController _studentEmailController;
  late TextEditingController _testMarkController;
  late TextEditingController _assignmentMarkController;
  late TextEditingController _projectMarkController;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _studentIdController = TextEditingController(text: widget.carryMark.studentId);
    _studentNameController = TextEditingController(text: widget.carryMark.studentName);
    _studentEmailController = TextEditingController(text: widget.carryMark.studentEmail);
    _testMarkController = TextEditingController(text: widget.carryMark.testMark.toString());
    _assignmentMarkController = TextEditingController(text: widget.carryMark.assignmentMark.toString());
    _projectMarkController = TextEditingController(text: widget.carryMark.projectMark.toString());
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _studentEmailController.dispose();
    _testMarkController.dispose();
    _assignmentMarkController.dispose();
    _projectMarkController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_studentIdController.text.isEmpty ||
        _studentNameController.text.isEmpty ||
        _studentEmailController.text.isEmpty ||
        _testMarkController.text.isEmpty ||
        _assignmentMarkController.text.isEmpty ||
        _projectMarkController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
        _successMessage = null;
      });
      return;
    }

    try {
      final testMark = double.parse(_testMarkController.text);
      final assignmentMark = double.parse(_assignmentMarkController.text);
      final projectMark = double.parse(_projectMarkController.text);

      if (testMark < 0 || testMark > 20 ||
          assignmentMark < 0 || assignmentMark > 10 ||
          projectMark < 0 || projectMark > 20) {
        setState(() {
          _errorMessage = 'Invalid mark values. Test (0-20), Assignment (0-10), Project (0-20)';
          _successMessage = null;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _carryMarkService.setCarryMarks(
        studentId: _studentIdController.text.trim(),
        studentEmail: _studentEmailController.text.trim(),
        studentName: _studentNameController.text.trim(),
        testMark: testMark,
        assignmentMark: assignmentMark,
        projectMark: projectMark,
      );

      setState(() {
        _successMessage = 'Marks updated successfully!';
        _errorMessage = null;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Carry Marks'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _studentIdController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Student ID',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentNameController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Student Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentEmailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Student Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Edit Carry Mark Components',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _testMarkController,
              decoration: InputDecoration(
                labelText: 'Test Mark (0-20)',
                prefixIcon: const Icon(Icons.check_circle),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _assignmentMarkController,
              decoration: InputDecoration(
                labelText: 'Assignment Mark (0-10)',
                prefixIcon: const Icon(Icons.assignment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _projectMarkController,
              decoration: InputDecoration(
                labelText: 'Project Mark (0-20)',
                prefixIcon: const Icon(Icons.engineering),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSaveChanges,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Marks'),
            ),
          ],
        ),
      ),
    );
  }
}
