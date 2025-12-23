import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login and return role
  Future<String?> login(String email, String password) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);

      String uid = result.user!.uid;

      // Fetch role from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.get('role'); // admin, lecturer, student
      } else {
        return null; // no role found
      }
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  // Optional: logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Optional: register new user
  Future<String?> register(String email, String password, String role) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);

      String uid = result.user!.uid;

      // Save role to Firestore
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': role,
      });

      return role;
    } on FirebaseAuthException catch (e) {
      print('Register error: ${e.code}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }
}