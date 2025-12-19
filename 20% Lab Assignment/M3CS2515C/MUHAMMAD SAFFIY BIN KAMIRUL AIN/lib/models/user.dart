class User {
  final int? id;
  final String username;
  final String password;
  final String role; // 'admin', 'lecturer', 'student'
  final String name;
  final String? studentId; // For students
  final String? matrixNo; // For students - Matrix Number
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.name,
    this.studentId,
    this.matrixNo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'name': name,
      'student_id': studentId,
      'matrix_no': matrixNo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'student',
      name: map['name'] ?? '',
      studentId: map['student_id'],
      matrixNo: map['matrix_no'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          studentId == other.studentId;

  @override
  int get hashCode => username.hashCode ^ (studentId?.hashCode ?? 0);
}
