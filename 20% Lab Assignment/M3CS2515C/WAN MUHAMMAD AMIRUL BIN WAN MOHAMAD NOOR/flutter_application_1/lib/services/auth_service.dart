import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Expose firebase auth for listening to auth state changes
  auth.FirebaseAuth get firebaseAuth => _firebaseAuth;

  // Sign up with email, password, role and name
  Future<User?> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
    String? studentId,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = User(
        uid: userCredential.user!.uid,
        email: email,
        role: role,
        name: name,
        studentId: studentId,
      );

      // Save user to Firestore
      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        return User.fromMap(userDoc.data() ?? {});
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final authUser = _firebaseAuth.currentUser;
      if (authUser != null) {
        final userDoc = await _firestore.collection('users').doc(authUser.uid).get();
        if (userDoc.exists) {
          return User.fromMap(userDoc.data() ?? {});
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }
}
