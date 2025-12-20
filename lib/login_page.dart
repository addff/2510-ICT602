import 'package:flutter/material.dart';
import 'admin_home.dart';
import 'lecturer_home.dart';
import 'student_home.dart';
import 'database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? _error;
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    final u = _userController.text.trim();
    final p = _passController.text.trim();
    
    if (u.isEmpty || p.isEmpty) {
      setState(() {
        _error = 'Please enter both username and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔍 Attempting login for user: $u');
      
      // Use database for authentication
      final userData = await DatabaseHelper.instance.login(u, p);
      
      print('📊 Database response: $userData');

      if (userData != null) {
        final role = userData['role'] as String;
        print('✅ Login successful! Role: $role');
        
        // Add small delay for smooth transition
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (!mounted) return;
        
        switch (role) {
          case 'admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminPage()),
            );
            break;
          case 'lecturer':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LecturerPage()),
            );
            break;
          case 'student':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => StudentPage(username: u)),
            );
            break;
          default:
            setState(() {
              _error = 'Invalid role: $role';
              _isLoading = false;
            });
        }
      } else {
        print('❌ Login failed - userData is null');
        setState(() {
          _error = 'Invalid username or password';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error during login: $e');
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _testLogin() async {
    print('🧪 Testing database connection...');
    try {
      // Test dengan credential sample
      _userController.text = 'student1';
      _passController.text = 'stud123';
      _login();
    } catch (e) {
      print('❌ Test failed: $e');
      setState(() {
        _error = 'Database error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Test database connection on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testDatabase();
    });
  }

  void _testDatabase() async {
    print('🔧 Testing database initialization...');
    try {
      final db = await DatabaseHelper.instance.database;
      print('✅ Database initialized successfully');
      
      // Test query
      final users = await DatabaseHelper.instance.getStudents();
      print('📋 Total students in DB: ${users.length}');
    } catch (e) {
      print('❌ Database test failed: $e');
      setState(() {
        _error = 'Database initialization failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C),
              Color(0xFF311B92),
              Color(0xFF1A237E),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 60,
                    color: Colors.indigo,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'ICT602 Carry Marks',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Academic Performance System',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Login Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Username Field
                        TextField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.indigo, width: 2),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password Field
                        TextField(
                          controller: _passController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock, color: Colors.indigo),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.indigo, width: 2),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.indigo,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                        ),
                        
                        // Test Button (for debugging)
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _testLogin,
                          child: const Text('Test Login (student1)'),
                        ),
                        
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Demo Accounts
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Demo Accounts:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildAccountInfo('👑 Admin', 'admin / admin123'),
                              _buildAccountInfo('👨‍🏫 Lecturer', 'lect1 / lect123'),
                              _buildAccountInfo('🎓 Student', 'student1 / stud123'),
                              _buildAccountInfo('🎓 Student', 'student2 / stud234'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Footer
                const Text(
                  '© 2025 ICT602 - Mobile App Development',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(String role, String credentials) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            role,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              credentials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}