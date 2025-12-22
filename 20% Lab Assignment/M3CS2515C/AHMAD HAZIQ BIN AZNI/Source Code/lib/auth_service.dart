import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Login method
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      print('Logged in UID: $uid');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      print('UserDoc exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        print('Firestore document not found!');
        return null;
      }

      final role = userDoc['role'];
      print('Role: $role');

      return {"uid": uid, "role": role};
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
