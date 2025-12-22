import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _userRole = '';
  String _studentId = ''; // Store student ID for current user
  bool _isLoading = true;
  String _errorMessage = '';

  User? get user => _user;
  String get userRole => _userRole;
  String get studentId => _studentId; // Getter for student ID
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _firebaseAuth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserRole(user.uid);
      } else {
        _userRole = '';
        _studentId = '';
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userRole = doc['role'] ?? 'student';
        // If student, store their student ID for auto-loading marks
        if (_userRole == 'student') {
          _studentId = doc['studentId'] ?? '';
        } else {
          _studentId = '';
        }
      }
    } catch (e) {
      print('Error fetching user role: $e');
      _userRole = 'student';
      _studentId = '';
    }
  }

  Future<bool> signup(String email, String password, String role,
      {String? studentId, String? lecturerId}) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': DateTime.now(),
        'studentId': studentId,
        'lecturerId': lecturerId,
      });

      _user = userCredential.user;
      _userRole = role;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Sign up failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      await _fetchUserRole(_user!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Student login using Student ID and password
  Future<bool> loginWithStudentId(String studentId, String password) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Find user by student ID
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('studentId', isEqualTo: studentId)
          .where('role', isEqualTo: 'student')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _errorMessage = 'Student ID not found or invalid role';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      String email = querySnapshot.docs[0]['email'];

      // Login with the email and password
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      _userRole = 'student';
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      _userRole = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
    }
  }
}
