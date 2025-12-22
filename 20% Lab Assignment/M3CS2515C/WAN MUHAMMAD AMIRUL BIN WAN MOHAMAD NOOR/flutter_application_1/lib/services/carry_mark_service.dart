import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class CarryMarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update carry marks for a student
  Future<void> setCarryMarks({
    required String studentId,
    required String studentEmail,
    required String studentName,
    required double testMark,
    required double assignmentMark,
    required double projectMark,
  }) async {
    try {
      final docRef = _firestore.collection('carry_marks').doc(studentId);

      final carryMark = CarryMark(
        id: studentId,
        studentId: studentId,
        studentEmail: studentEmail,
        studentName: studentName,
        testMark: testMark,
        assignmentMark: assignmentMark,
        projectMark: projectMark,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(carryMark.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get carry marks for a student
  Future<CarryMark?> getStudentCarryMarks(String studentId) async {
    try {
      final doc = await _firestore.collection('carry_marks').doc(studentId).get();

      if (doc.exists) {
        return CarryMark.fromMap(doc.data() ?? {}, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get all carry marks (for lecturer)
  Future<List<CarryMark>> getAllCarryMarks() async {
    try {
      final querySnapshot = await _firestore.collection('carry_marks').get();
      return querySnapshot.docs
          .map((doc) => CarryMark.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Stream carry marks for a student (real-time updates)
  Stream<CarryMark?> getStudentCarryMarksStream(String studentId) {
    print('DEBUG: Querying carry marks for studentId: $studentId');
    return _firestore
        .collection('carry_marks')
        .doc(studentId)
        .snapshots()
        .map((snapshot) {
      print('DEBUG: Snapshot exists: ${snapshot.exists}, data: ${snapshot.data()}');
      if (snapshot.exists) {
        return CarryMark.fromMap(snapshot.data() ?? {}, snapshot.id);
      }
      return null;
    });
  }

  // Stream all carry marks (for lecturer - real-time updates)
  Stream<List<CarryMark>> getAllCarryMarksStream() {
    return _firestore.collection('carry_marks').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CarryMark.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Check if carry marks exist for a student
  Future<bool> hasCarryMarks(String studentId) async {
    try {
      final doc = await _firestore.collection('carry_marks').doc(studentId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  // Delete carry marks
  Future<void> deleteCarryMarks(String studentId) async {
    try {
      await _firestore.collection('carry_marks').doc(studentId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
