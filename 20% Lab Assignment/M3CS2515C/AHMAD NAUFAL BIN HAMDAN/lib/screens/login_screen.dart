import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true, // This handles keyboard overlap
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                // Background Design (Simplified)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF667EEA),
                        Color(0xFF764BA2),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Column(
                        children: [
                          // Title
                          Text(
                            'Carry Mark Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLoginMode
                                ? 'Welcome back! Please sign in'
                                : 'Create your account to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Auth Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Mode Toggle
                                  Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() => _isLoginMode = true);
                                              _clearFields();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _isLoginMode
                                                    ? Colors.blue
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'LOGIN',
                                                  style: TextStyle(
                                                    color: _isLoginMode
                                                        ? Colors.white
                                                        : Colors.grey[600],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() => _isLoginMode = false);
                                              _clearFields();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: !_isLoginMode
                                                    ? Colors.blue
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'SIGN UP',
                                                  style: TextStyle(
                                                    color: !_isLoginMode
                                                        ? Colors.white
                                                        : Colors.grey[600],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Notices
                                  if (_isLoginMode) ...[
                                    _buildInfoCard(
                                      'Login with Gmail account only',
                                      Icons.info_outline_rounded,
                                      Colors.blue,
                                    ),
                                    const SizedBox(height: 16),
                                  ] else ...[
                                    // Role Selection
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedRole,
                                          isExpanded: true,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          icon: Icon(
                                            Icons.arrow_drop_down_rounded,
                                            color: Colors.grey[600],
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 14,
                                          ),
                                          items: ['admin', 'lecturer', 'student']
                                              .map((role) => DropdownMenuItem(
                                                    value: role,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _getRoleColor(
                                                                    role)
                                                                .withOpacity(0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(6),
                                                          ),
                                                          child: Icon(
                                                            _getRoleIcon(role),
                                                            size: 16,
                                                            color:
                                                                _getRoleColor(role),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Text(role.toUpperCase()),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() => _selectedRole =
                                                value ?? 'student');
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedRole == 'student') ...[
                                      _buildInfoCard(
                                        'Use your Gmail account to register',
                                        Icons.email_rounded,
                                        Colors.blue,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ],

                                  // Student ID Field (for student signup)
                                  if (!_isLoginMode && _selectedRole == 'student')
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextFormField(
                                        controller: _studentIdController,
                                        style: const TextStyle(fontSize: 14),
                                        decoration: InputDecoration(
                                          hintText: 'Enter Student ID',
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          prefixIcon: Container(
                                            margin:
                                                const EdgeInsets.only(right: 12),
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  const BorderRadius.horizontal(
                                                left: Radius.circular(12),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.badge_rounded,
                                              color: Colors.blue[600],
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (!_isLoginMode &&
                                              _selectedRole == 'student' &&
                                              (value == null || value.isEmpty)) {
                                            return 'Student ID is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  if (!_isLoginMode && _selectedRole == 'student')
                                    const SizedBox(height: 16),

                                  // Email Field
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'your.email@gmail.com',
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        prefixIcon: Container(
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                              left: Radius.circular(12),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.email_rounded,
                                            color: Colors.orange[600],
                                          ),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.g_mobiledata_rounded,
                                          color: Colors.red[600],
                                          size: 20,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!value.endsWith('@gmail.com')) {
                                          return 'Please use Gmail account';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Password Field
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your password',
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        prefixIcon: Container(
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.purple[50],
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                              left: Radius.circular(12),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.lock_rounded,
                                            color: Colors.purple[600],
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword);
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password is required';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Error Message
                                  if (authProvider.errorMessage.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red[100]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            color: Colors.red[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              authProvider.errorMessage,
                                              style: TextStyle(
                                                color: Colors.red[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (authProvider.errorMessage.isNotEmpty)
                                    const SizedBox(height: 16),

                                  // Login/Signup Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : () => _handleAuth(context, authProvider),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  _isLoginMode
                                                      ? Icons.login_rounded
                                                      : Icons.person_add_rounded,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _isLoginMode
                                                      ? 'SIGN IN'
                                                      : 'CREATE ACCOUNT',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Toggle text
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode;
                                _clearFields();
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                text: _isLoginMode
                                    ? "Don't have an account? "
                                    : 'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isLoginMode ? 'Sign up' : 'Login',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom padding for keyboard
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0
                      ? 100
                      : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'lecturer':
        return Colors.purple;
      case 'student':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'lecturer':
        return Icons.school_rounded;
      case 'student':
        return Icons.person_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _studentIdController.clear();
  }

  void _handleAuth(BuildContext context, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final studentId = _studentIdController.text.trim();

    bool success;

    if (_isLoginMode) {
      // Email login only
      success = await authProvider.login(email, password);
    } else {
      // Sign up mode
      success = await authProvider.signup(
        email,
        password,
        _selectedRole,
        studentId: _selectedRole == 'student' ? studentId : null,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLoginMode ? 'Login successful' : 'Sign up successful',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.green,
        ),
      );
      _clearFields();
    }
  }
}