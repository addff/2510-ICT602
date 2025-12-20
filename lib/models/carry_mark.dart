class CarryMark {
  final int? id;
  final String studentId;
  final String studentName;
  final String matrixNo;
  final double testMark; // Test 20%
  final double assignmentMark; // Assignment 10%
  final double projectMark; // Project 20%
  final DateTime createdAt;
  final DateTime? updatedAt;

  CarryMark({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.matrixNo,
    required this.testMark,
    required this.assignmentMark,
    required this.projectMark,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate total carry mark (50%)
  // Test: 20/20 * 20%, Assignment: 10/10 * 10%, Project: 20/20 * 20%
  double getTotalCarryMark() {
    return ((testMark / 20) * 20) +
        ((assignmentMark / 10) * 10) +
        ((projectMark / 20) * 20);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'matrix_no': matrixNo,
      'test_mark': testMark,
      'assignment_mark': assignmentMark,
      'project_mark': projectMark,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory CarryMark.fromMap(Map<String, dynamic> map) {
    return CarryMark(
      id: map['id'],
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'] ?? '',
      matrixNo: map['matrix_no'] ?? '',
      testMark: ((map['test_mark'] ?? 0) as num).toDouble(),
      assignmentMark: ((map['assignment_mark'] ?? 0) as num).toDouble(),
      projectMark: ((map['project_mark'] ?? 0) as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
