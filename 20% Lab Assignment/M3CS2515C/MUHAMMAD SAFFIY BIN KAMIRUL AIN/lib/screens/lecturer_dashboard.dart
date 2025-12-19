import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'login_screen.dart';
import '../models/index.dart';
import '../services/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

const String _kCurrentUserKey = 'current_user';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({Key? key}) : super(key: key);

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  final _dbService = DatabaseService();

  User? _currentUser;
  bool _isRestoringUser = true;

  List<CarryMark> _carryMarks = [];
  List<User> _allStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _restoreUser();
  }

  Future<void> _restoreUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUsername;

    if (kIsWeb) {
      storedUsername = html.window.localStorage[_kCurrentUserKey];
    } else {
      storedUsername = prefs.getString(_kCurrentUserKey);
    }

    if (storedUsername == null) {
      // No user saved → redirect to login
      if (mounted) Navigator.pushReplacementNamed(context, '/');
      return;
    }

    // Fetch full user from database
    _currentUser = await _dbService.getUserById(storedUsername);

    setState(() {
      _isRestoringUser = false;
    });

    _loadData();
  }

  Future<void> _loadData() async {
    final marks = await _dbService.getAllCarryMarks();
    final students = await _dbService.getAllUsers();

    final studentsList = students.where((u) => u.role == 'student').toList();

    setState(() {
      _carryMarks = marks;
      _allStudents = studentsList;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentUserKey);

    if (kIsWeb) {
      html.window.localStorage.remove(_kCurrentUserKey);
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 768;
    final isVerySmallScreen = screenWidth < 480;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    if (_isRestoringUser) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF4A6FFF),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: isSmallScreen ? 30 : 50,
                bottom: isSmallScreen ? 20 : 24,
                left: isSmallScreen ? 16 : 24,
                right: isSmallScreen ? 16 : 24,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A6FFF),
                    Color(0xFF6A8BFF),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentUser?.name ?? 'Lecturer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: Container(
                          width: isSmallScreen ? 40 : 46,
                          height: isSmallScreen ? 40 : 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isSmallScreen ? 40 : 50,
                          height: isSmallScreen ? 40 : 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.school,
                            color: Colors.white,
                            size: isSmallScreen ? 20 : 26,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ICT602 - Lecturer Dashboard',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 4 : 4),
                              Wrap(
                                spacing: isSmallScreen ? 6 : 8,
                                runSpacing: isSmallScreen ? 6 : 8,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 8 : 10,
                                      vertical: isSmallScreen ? 3 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_allStudents.length} Students',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 11 : 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 8 : 10,
                                      vertical: isSmallScreen ? 3 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_carryMarks.where((m) => m.getTotalCarryMark() > 0).length} Marked',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 11 : 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF4A6FFF),
                      ),
                    )
                  : _allStudents.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: isSmallScreen ? 100 : 120,
                                  height: isSmallScreen ? 100 : 120,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A6FFF)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.group,
                                    size: isSmallScreen ? 40 : 60,
                                    color: const Color(0xFF4A6FFF),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 24),
                                Text(
                                  'No Students Registered',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 6 : 8),
                                Text(
                                  'Students will appear here once they register',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? screenWidth * 0.9 : 1200,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: isSmallScreen ? 36 : 40,
                                      height: isSmallScreen ? 36 : 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A6FFF)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.group,
                                        color: const Color(0xFF4A6FFF),
                                        size: isSmallScreen ? 18 : 22,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 10 : 12),
                                    Expanded(
                                      child: Text(
                                        'Student List',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 4),
                                Text(
                                  'Manage carry marks for each student',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 24),
                                ..._allStudents.map((student) {
                                  final markIndex = _carryMarks.indexWhere(
                                    (m) => m.studentId == student.studentId,
                                  );
                                  final existingMark = markIndex >= 0
                                      ? _carryMarks[markIndex]
                                      : null;
                                  return _buildStudentCard(
                                      student,
                                      existingMark,
                                      isSmallScreen,
                                      isVerySmallScreen);
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(User student, CarryMark? existingMark,
      bool isSmallScreen, bool isVerySmallScreen) {
    final hasMarks = existingMark != null &&
        (existingMark.testMark > 0 ||
            existingMark.assignmentMark > 0 ||
            existingMark.projectMark > 0);
    final totalCarry = existingMark?.getTotalCarryMark() ?? 0;
    final percentage = totalCarry / 50 * 100;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 36 : 40,
                            height: isSmallScreen ? 36 : 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A6FFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person,
                              color: const Color(0xFF4A6FFF),
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isSmallScreen ? 15 : 16,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 2),
                                Text(
                                  student.matrixNo ?? 'No Matrix No',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      if (hasMarks)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carry Marks',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            if (isVerySmallScreen)
                              Column(
                                children: [
                                  _buildMarkPill(
                                    'Test',
                                    existingMark.testMark,
                                    20,
                                    Colors.blueAccent,
                                    isSmallScreen,
                                  ),
                                  SizedBox(height: 8),
                                  _buildMarkPill(
                                    'Assignment',
                                    existingMark.assignmentMark,
                                    10,
                                    Colors.greenAccent,
                                    isSmallScreen,
                                  ),
                                  SizedBox(height: 8),
                                  _buildMarkPill(
                                    'Project',
                                    existingMark.projectMark,
                                    20,
                                    Colors.orangeAccent,
                                    isSmallScreen,
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  _buildMarkPill(
                                    'Test',
                                    existingMark.testMark,
                                    20,
                                    Colors.blueAccent,
                                    isSmallScreen,
                                  ),
                                  SizedBox(width: isSmallScreen ? 6 : 8),
                                  _buildMarkPill(
                                    'Assignment',
                                    existingMark.assignmentMark,
                                    10,
                                    Colors.greenAccent,
                                    isSmallScreen,
                                  ),
                                  SizedBox(width: isSmallScreen ? 6 : 8),
                                  _buildMarkPill(
                                    'Project',
                                    existingMark.projectMark,
                                    20,
                                    Colors.orangeAccent,
                                    isSmallScreen,
                                  ),
                                ],
                              ),
                            SizedBox(height: isSmallScreen ? 10 : 12),
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF4A6FFF).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: isVerySmallScreen
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Carry Mark',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 13 : 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${totalCarry.toStringAsFixed(1)}/50',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 18 : 16,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF4A6FFF),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 8 : 8,
                                                vertical: isSmallScreen ? 3 : 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4A6FFF)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${percentage.toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 11 : 12,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF4A6FFF),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Carry Mark',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 13 : 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${totalCarry.toStringAsFixed(1)}/50',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 18 : 16,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF4A6FFF),
                                              ),
                                            ),
                                            SizedBox(
                                                width: isSmallScreen ? 6 : 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 8 : 8,
                                                vertical: isSmallScreen ? 3 : 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4A6FFF)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${percentage.toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 11 : 12,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF4A6FFF),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange[700],
                                size: isSmallScreen ? 18 : 20,
                              ),
                              SizedBox(width: isSmallScreen ? 10 : 12),
                              Expanded(
                                child: Text(
                                  'No marks entered yet',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A6FFF).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAddEditDialog(existingMark, student, isSmallScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6FFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                  ),
                  icon: Icon(
                    hasMarks ? Icons.edit : Icons.add,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  label: Text(
                    hasMarks ? 'Edit Marks' : 'Add Marks',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkPill(
      String label, double value, int max, Color color, bool isSmallScreen) {
    final percentage = (value / max * 100).clamp(0, 100);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            '${value.toStringAsFixed(1)}/$max',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Container(
            width: isSmallScreen ? 40 : 50,
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(CarryMark? mark, User student, bool isSmallScreen) {
    final isEdit = mark != null;

    final testController = TextEditingController(
      text: isEdit ? mark.testMark.toStringAsFixed(1) : '',
    );
    final assignmentController = TextEditingController(
      text: isEdit ? mark.assignmentMark.toStringAsFixed(1) : '',
    );
    final projectController = TextEditingController(
      text: isEdit ? mark.projectMark.toStringAsFixed(1) : '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              width: isSmallScreen ? double.infinity : 500,
              margin: EdgeInsets.all(isSmallScreen ? 16 : 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog Header
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4A6FFF),
                          Color(0xFF6A8BFF),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isSmallScreen ? 40 : 50,
                          height: isSmallScreen ? 40 : 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit : Icons.add,
                            color: Colors.white,
                            size: isSmallScreen ? 22 : 26,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit
                                    ? 'Edit Carry Mark'
                                    : 'Add New Carry Mark',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Text(
                                student.name,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dialog Content
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Student Info
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A6FFF).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: isSmallScreen ? 36 : 40,
                                height: isSmallScreen ? 36 : 40,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF4A6FFF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF4A6FFF),
                                  size: isSmallScreen ? 18 : 20,
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 10 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Student ID: ${student.studentId}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 13 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 2 : 4),
                                    Text(
                                      'Matrix No: ${student.matrixNo ?? "N/A"}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // Input Fields
                        Column(
                          children: [
                            _buildMarkInput(
                              controller: testController,
                              label: 'Test Mark',
                              max: 20,
                              icon: Icons.quiz,
                              color: Colors.blueAccent,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            _buildMarkInput(
                              controller: assignmentController,
                              label: 'Assignment Mark',
                              max: 10,
                              icon: Icons.assignment,
                              color: Colors.greenAccent,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            _buildMarkInput(
                              controller: projectController,
                              label: 'Project Mark',
                              max: 20,
                              icon: Icons.work,
                              color: Colors.orangeAccent,
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Dialog Actions
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 24,
                              vertical: isSmallScreen ? 10 : 12,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A6FFF).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                // Parse values
                                final test =
                                    double.tryParse(testController.text) ?? 0;
                                final assignment = double.tryParse(
                                        assignmentController.text) ??
                                    0;
                                final project =
                                    double.tryParse(projectController.text) ??
                                        0;

                                // Validate ranges
                                if (test < 0 ||
                                    test > 20 ||
                                    assignment < 0 ||
                                    assignment > 10 ||
                                    project < 0 ||
                                    project > 20) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Invalid mark values'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                // Create or update CarryMark
                                final newMark = CarryMark(
                                  studentId: student.studentId ?? '',
                                  studentName: student.name,
                                  matrixNo: student.matrixNo ?? '',
                                  testMark: test,
                                  assignmentMark: assignment,
                                  projectMark: project,
                                );

                                // Save to database
                                await _dbService
                                    .insertOrUpdateCarryMark(newMark);

                                // Reload dashboard data
                                Navigator.pop(context);
                                _loadData();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEdit
                                        ? 'Carry mark updated successfully'
                                        : 'Carry mark added successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6FFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 20 : 24,
                                vertical: isSmallScreen ? 10 : 12,
                              ),
                            ),
                            child: Text(isEdit ? 'Update Marks' : 'Save Marks'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkInput({
    required TextEditingController controller,
    required String label,
    required int max,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (0-$max)',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
          decoration: InputDecoration(
            hintText: 'Enter mark (0-$max)',
            prefixIcon: Container(
              width: isSmallScreen ? 52 : 56,
              height: isSmallScreen ? 52 : 56,
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            suffixText: '/$max',
            suffixStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 13 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: color,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 14 : 16,
              horizontal: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }
}
