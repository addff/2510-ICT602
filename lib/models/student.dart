class Student {
  final int? id;
  final int userId; // FK to users table
  final String name;

  Student({this.id, required this.userId, required this.name});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
    );
  }
}
