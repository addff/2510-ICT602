class User {
  final int? id;
  final String username;
  final String password; // plaintext for demo
  final String role; // 'admin' | 'lecturer' | 'student'
  final String email;

  User({this.id, required this.username, required this.password, required this.role, required this.email});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'password': password,
      'role': role,
      'email': email,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      email: (map['email'] as String?) ?? '',
    );
  }
}
