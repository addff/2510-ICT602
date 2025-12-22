// User model for authentication
class User {
  final String uid;
  final String email;
  final String role; // admin, lecturer, student
  final String name;
  final String? studentId; // Student ID for students

  User({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.studentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      if (studentId != null) 'studentId': studentId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      name: map['name'] ?? '',
      studentId: map['studentId'],
    );
  }
}

// Carry Mark model for students
class CarryMark {
  final String id;
  final String studentId;
  final String studentEmail;
  final String studentName;
  final double testMark; // out of 20
  final double assignmentMark; // out of 10
  final double projectMark; // out of 20
  final DateTime createdAt;
  final DateTime? updatedAt;

  CarryMark({
    required this.id,
    required this.studentId,
    required this.studentEmail,
    required this.studentName,
    required this.testMark,
    required this.assignmentMark,
    required this.projectMark,
    required this.createdAt,
    this.updatedAt,
  });

  // Calculate total carry mark (50% of final grade)
  double getCarryMarkPercentage() {
    double test = (testMark / 20) * 20; // 20% weight
    double assignment = (assignmentMark / 10) * 10; // 10% weight
    double project = (projectMark / 20) * 20; // 20% weight
    return test + assignment + project;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentEmail': studentEmail,
      'studentName': studentName,
      'testMark': testMark,
      'assignmentMark': assignmentMark,
      'projectMark': projectMark,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CarryMark.fromMap(Map<String, dynamic> map, String docId) {
    return CarryMark(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      studentName: map['studentName'] ?? '',
      testMark: (map['testMark'] ?? 0).toDouble(),
      assignmentMark: (map['assignmentMark'] ?? 0).toDouble(),
      projectMark: (map['projectMark'] ?? 0).toDouble(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }
}

// Grade scale model
class GradeTarget {
  final String grade;
  final double minPercentage;
  final double maxPercentage;
  final String description;

  GradeTarget({
    required this.grade,
    required this.minPercentage,
    required this.maxPercentage,
    required this.description,
  });

  static List<GradeTarget> getAllGrades() {
    return [
      GradeTarget(
        grade: 'A+',
        minPercentage: 90,
        maxPercentage: 100,
        description: 'Excellent (90-100%)',
      ),
      GradeTarget(
        grade: 'A',
        minPercentage: 80,
        maxPercentage: 89,
        description: 'Very Good (80-89%)',
      ),
      GradeTarget(
        grade: 'A-',
        minPercentage: 75,
        maxPercentage: 79,
        description: 'Good (75-79%)',
      ),
      GradeTarget(
        grade: 'B+',
        minPercentage: 70,
        maxPercentage: 74,
        description: 'Very Satisfactory (70-74%)',
      ),
      GradeTarget(
        grade: 'B',
        minPercentage: 65,
        maxPercentage: 69,
        description: 'Satisfactory (65-69%)',
      ),
      GradeTarget(
        grade: 'B-',
        minPercentage: 60,
        maxPercentage: 64,
        description: 'Barely Satisfactory (60-64%)',
      ),
      GradeTarget(
        grade: 'C+',
        minPercentage: 55,
        maxPercentage: 59,
        description: 'Minimal Pass (55-59%)',
      ),
      GradeTarget(
        grade: 'C',
        minPercentage: 50,
        maxPercentage: 54,
        description: 'Minimum Pass (50-54%)',
      ),
    ];
  }
}
