class CarryMark {
  final int? id;
  final int studentId; // FK to students table
  final double test; // 0-100
  final double assignment; // 0-100
  final double project; // 0-100
  final double carryTotal; // computed: test*0.2 + assignment*0.1 + project*0.2

  CarryMark({this.id, required this.studentId, required this.test, required this.assignment, required this.project, double? carryTotal})
      : carryTotal = carryTotal ?? (test * 0.20 + assignment * 0.10 + project * 0.20);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'student_id': studentId,
      'test': test,
      'assignment': assignment,
      'project': project,
      'carry_total': carryTotal,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory CarryMark.fromMap(Map<String, dynamic> map) {
    return CarryMark(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      test: (map['test'] as num).toDouble(),
      assignment: (map['assignment'] as num).toDouble(),
      project: (map['project'] as num).toDouble(),
      carryTotal: (map['carry_total'] as num).toDouble(),
    );
  }
}
