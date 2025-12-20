import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class StudentDashboard extends StatefulWidget {
  final User user;

  const StudentDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _dbService = DatabaseService();
  CarryMark? _carryMark;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCarryMark();
  }

  Future<void> _loadCarryMark() async {
    final mark =
        await _dbService.getCarryMarkByStudentId(widget.user.studentId!);
    setState(() {
      _carryMark = mark;
      _isLoading = false;
    });
  }

  double _calculateRequiredExamMark(double targetGrade) {
    if (_carryMark == null) return 0;
    final carryMarkTotal = _carryMark!.getTotalCarryMark();
    // Carry mark (0-50) + Exam mark (0-50) = Final grade (0-100)
    final requiredExam = (targetGrade - carryMarkTotal) / 0.5;
    return requiredExam.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 768;
    final isVerySmallScreen = screenWidth < 480;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

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
                bottom: isSmallScreen ? 20 : 30,
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
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user.name,
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
                      SizedBox(width: isSmallScreen ? 8 : 16),
                      Container(
                        width: isSmallScreen ? 40 : 50,
                        height: isSmallScreen ? 40 : 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 26,
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
                                'ICT602 - Grade Management',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.user.matrixNo ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
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
            ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A6FFF),
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
                            // Carry Marks Card
                            if (_carryMark != null) ...[
                              Container(
                                padding:
                                    EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Your Carry Marks',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 16 : 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 10 : 12,
                                            vertical: isSmallScreen ? 5 : 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4A6FFF)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${_carryMark!.getTotalCarryMark().toStringAsFixed(1)}/50',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 13 : 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4A6FFF),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isSmallScreen ? 16 : 20),
                                    if (isVerySmallScreen)
                                      Column(
                                        children: [
                                          _buildMarkCard(
                                            'Test',
                                            _carryMark!.testMark,
                                            20,
                                            Icons.quiz,
                                            Colors.blueAccent,
                                            isSmallScreen,
                                          ),
                                          SizedBox(height: 12),
                                          _buildMarkCard(
                                            'Assignment',
                                            _carryMark!.assignmentMark,
                                            10,
                                            Icons.assignment,
                                            Colors.greenAccent,
                                            isSmallScreen,
                                          ),
                                          SizedBox(height: 12),
                                          _buildMarkCard(
                                            'Project',
                                            _carryMark!.projectMark,
                                            20,
                                            Icons.work,
                                            Colors.orangeAccent,
                                            isSmallScreen,
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildMarkCard(
                                              'Test',
                                              _carryMark!.testMark,
                                              20,
                                              Icons.quiz,
                                              Colors.blueAccent,
                                              isSmallScreen,
                                            ),
                                          ),
                                          SizedBox(
                                              width: isSmallScreen ? 8 : 12),
                                          Expanded(
                                            child: _buildMarkCard(
                                              'Assignment',
                                              _carryMark!.assignmentMark,
                                              10,
                                              Icons.assignment,
                                              Colors.greenAccent,
                                              isSmallScreen,
                                            ),
                                          ),
                                          SizedBox(
                                              width: isSmallScreen ? 8 : 12),
                                          Expanded(
                                            child: _buildMarkCard(
                                              'Project',
                                              _carryMark!.projectMark,
                                              20,
                                              Icons.work,
                                              Colors.orangeAccent,
                                              isSmallScreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: isSmallScreen ? 16 : 20),
                                    Container(
                                      padding: EdgeInsets.all(
                                          isSmallScreen ? 12 : 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A6FFF)
                                            .withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF4A6FFF)
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: isVerySmallScreen
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total Carry Mark',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  '${_carryMark!.getTotalCarryMark().toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen ? 22 : 20,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        const Color(0xFF4A6FFF),
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  '(50% of final grade)',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Total Carry Mark (50% of final grade)',
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen ? 13 : 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                Text(
                                                  '${_carryMark!.getTotalCarryMark().toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen ? 22 : 20,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        const Color(0xFF4A6FFF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                            ],

                            // Grade Calculator Section
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.calculate,
                                          color: const Color(0xFF4A6FFF),
                                          size: isSmallScreen ? 18 : 22,
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 10 : 12),
                                      Expanded(
                                        child: Text(
                                          'Grade Calculator',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 16 : 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? 6 : 8),
                                  Text(
                                    'Required exam marks for each target grade',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 13 : 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 16 : 24),
                                  if (_carryMark == null)
                                    Container(
                                      padding: EdgeInsets.all(
                                          isSmallScreen ? 16 : 20),
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
                                            size: isSmallScreen ? 20 : 24,
                                          ),
                                          SizedBox(
                                              width: isSmallScreen ? 12 : 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Carry marks not available',
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen ? 13 : 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Please contact your lecturer for carry mark updates.',
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen ? 11 : 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    _buildGradesTable(
                                        isSmallScreen, isVerySmallScreen),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),

                            // Logout Button
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side:
                                      const BorderSide(color: Colors.redAccent),
                                  minimumSize: Size(
                                      double.infinity, isSmallScreen ? 48 : 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout,
                                        size: isSmallScreen ? 18 : 20),
                                    SizedBox(width: isSmallScreen ? 6 : 8),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 15 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  Widget _buildMarkCard(
    String title,
    double value,
    int max,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    final percentage = (value / max * 100).clamp(0, 100);
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmallScreen ? 32 : 36,
                height: isSmallScreen ? 32 : 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: isSmallScreen ? 22 : 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            '/ $max (${percentage.toStringAsFixed(0)}%)',
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTable(bool isSmallScreen, bool isVerySmallScreen) {
    final grades = [
      {'grade': 'A+', 'min': 90, 'max': 100},
      {'grade': 'A', 'min': 80, 'max': 89},
      {'grade': 'A-', 'min': 75, 'max': 79},
      {'grade': 'B+', 'min': 70, 'max': 74},
      {'grade': 'B', 'min': 65, 'max': 69},
      {'grade': 'B-', 'min': 60, 'max': 64},
      {'grade': 'C+', 'min': 55, 'max': 59},
      {'grade': 'C', 'min': 50, 'max': 54},
    ];

    if (isVerySmallScreen) {
      // Mobile layout
      return Column(
        children: grades.map((g) {
          final gradeStr = g['grade'] as String;
          final minVal = g['min'] as int;
          final maxVal = g['max'] as int;
          final targetGrade = minVal.toDouble();
          final requiredExam = _calculateRequiredExamMark(targetGrade);
          final isAchievable = requiredExam >= 0 && requiredExam <= 100;
          final isEasy = requiredExam < 50 && requiredExam > 0;
          final isImpossible = requiredExam > 100;

          Color getColor() {
            if (requiredExam < 0) return Colors.greenAccent; // Already achieved
            if (requiredExam <= 50) return Colors.greenAccent; // Easy (0-50%)
            if (requiredExam <= 80)
              return Colors.orangeAccent; // Moderate (50-80%)
            return Colors.redAccent; // Hard or Impossible (>80%)
          }

          Color getBgColor() {
            if (requiredExam < 0) return Colors.greenAccent.withOpacity(0.1);
            if (requiredExam <= 50) return Colors.greenAccent.withOpacity(0.1);
            if (requiredExam <= 80) return Colors.orangeAccent.withOpacity(0.1);
            return Colors.redAccent.withOpacity(0.1);
          }

          String getLabel() {
            if (requiredExam < 0) return 'Already Achieved';
            if (isImpossible) return 'Not Possible';
            return '${requiredExam.toStringAsFixed(1)}%';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A6FFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        gradeStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A6FFF),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '$minVal - $maxVal',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: getBgColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Required Exam:',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            getLabel(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: getColor(),
                              fontSize: 14,
                            ),
                          ),
                          if (isAchievable && requiredExam > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: getColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (isSmallScreen) {
      // Tablet layout
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6FFF).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        child: Text(
                          'Grade',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A6FFF),
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        child: Text(
                          'Range',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A6FFF),
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        child: Text(
                          'Required Exam',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A6FFF),
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Table Rows
              ...grades.map((g) {
                final gradeStr = g['grade'] as String;
                final minVal = g['min'] as int;
                final maxVal = g['max'] as int;
                final targetGrade = minVal.toDouble();
                final requiredExam = _calculateRequiredExamMark(targetGrade);
                final isAchievable = requiredExam >= 0 && requiredExam <= 100;
                final isEasy = requiredExam < 50 && requiredExam > 0;
                final isImpossible = requiredExam > 100;

                Color getColor() {
                  if (isImpossible) return Colors.redAccent;
                  if (requiredExam < 0) return Colors.greenAccent;
                  if (requiredExam <= 50) return Colors.greenAccent;
                  if (requiredExam <= 80) return Colors.orangeAccent;
                  return Colors.redAccent;
                }

                Color getBgColor() {
                  if (requiredExam < 0)
                    return Colors.greenAccent.withOpacity(0.1);
                  if (requiredExam <= 50)
                    return Colors.greenAccent.withOpacity(0.1);
                  if (requiredExam <= 80)
                    return Colors.orangeAccent.withOpacity(0.1);
                  return Colors.redAccent.withOpacity(0.1);
                }

                String getLabel() {
                  if (requiredExam < 0) return 'Already Achieved';
                  if (isImpossible) return 'Not Possible';
                  return '${requiredExam.toStringAsFixed(1)}%';
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A6FFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              gradeStr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A6FFF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                          child: Text(
                            '$minVal - $maxVal',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: getBgColor(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getLabel(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: getColor(),
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                                if (isAchievable && requiredExam > 0)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: getColor(),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    } else {
      // Desktop layout
      return Column(
        children: [
          // Table Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A6FFF).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    child: Text(
                      'Target Grade',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A6FFF),
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    child: Text(
                      'Range',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A6FFF),
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    child: Text(
                      'Required Exam Mark',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A6FFF),
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...grades.map((g) {
            final gradeStr = g['grade'] as String;
            final minVal = g['min'] as int;
            final maxVal = g['max'] as int;
            final targetGrade = minVal.toDouble();
            final requiredExam = _calculateRequiredExamMark(targetGrade);
            final isAchievable = requiredExam >= 0 && requiredExam <= 100;
            final isEasy = requiredExam < 50 && requiredExam > 0;
            final isImpossible = requiredExam > 100;

            Color getColor() {
              if (requiredExam < 0) return Colors.greenAccent;
              if (requiredExam <= 50) return Colors.greenAccent;
              if (requiredExam <= 80) return Colors.orangeAccent;
              return Colors.redAccent;
            }

            Color getBgColor() {
              if (requiredExam < 0) return Colors.greenAccent.withOpacity(0.1);
              if (requiredExam <= 50)
                return Colors.greenAccent.withOpacity(0.1);
              if (requiredExam <= 80)
                return Colors.orangeAccent.withOpacity(0.1);
              return Colors.redAccent.withOpacity(0.1);
            }

            String getLabel() {
              if (requiredExam < 0) return 'Already Achieved';
              if (isImpossible) return 'Not Possible';
              return '${requiredExam.toStringAsFixed(1)}%';
            }

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A6FFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gradeStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A6FFF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                      child: Text(
                        '$minVal - $maxVal',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: getBgColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getLabel(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: getColor(),
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            ),
                            if (isAchievable && requiredExam > 0)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: getColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }
  }
}
