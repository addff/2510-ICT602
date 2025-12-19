import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/carry_mark.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  late final FirebaseFirestore _firestore;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    _firestore = FirebaseFirestore.instance;
    // No longer seeding demo data - users register themselves
  }

  // User operations
  Future<User?> login(String username, String password) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();
      
      if (result.docs.isNotEmpty) {
        return User.fromMap(result.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final result = await _firestore.collection('users').get();
      return result.docs
          .map((doc) => User.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  Future<void> insertUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.username)
          .set(user.toMap());
    } catch (e) {
      print('Insert user error: $e');
    }
  }

  // User registration with validation
  Future<String?> registerUser({
    required String username,
    required String password,
    required String name,
    required String role,
    String? studentId,
    String? matrixNo,
  }) async {
    try {
      // Check if username already exists
      final existing = await _firestore
          .collection('users')
          .doc(username)
          .get();
      
      if (existing.exists) {
        return 'Username already exists';
      }

      // Create new user
      final user = User(
        username: username,
        password: password,
        name: name,
        role: role,
        studentId: studentId ?? '',
        matrixNo: matrixNo ?? '',
      );

      await insertUser(user);
      return null; // Success
    } catch (e) {
      print('Registration error: $e');
      return 'Registration failed: $e';
    }
  }

  // Carry Mark operations
  // Get carry mark by studentId (uses studentId as primary key/document ID)
  Future<CarryMark?> getCarryMarkByStudentId(String studentId) async {
    try {
      final doc = await _firestore
          .collection('carry_marks')
          .doc(studentId)
          .get();
      
      if (doc.exists) {
        return CarryMark.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get carry mark error: $e');
      return null;
    }
  }

  Future<List<CarryMark>> getAllCarryMarks() async {
    try {
      final result = await _firestore.collection('carry_marks').get();
      return result.docs
          .map((doc) => CarryMark.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Get all carry marks error: $e');
      return [];
    }
  }

  Future<void> insertOrUpdateCarryMark(CarryMark carryMark) async {
    try {
      final existing = await getCarryMarkByStudentId(carryMark.studentId);
      
      if (existing != null) {
        // Update
        await _firestore
            .collection('carry_marks')
            .doc(carryMark.studentId)
            .update({
              ...carryMark.toMap(),
              'updated_at': DateTime.now().toIso8601String(),
            });
      } else {
        // Insert
        await _firestore
            .collection('carry_marks')
            .doc(carryMark.studentId)
            .set(carryMark.toMap());
      }
    } catch (e) {
      print('Insert/update carry mark error: $e');
    }
  }
}
