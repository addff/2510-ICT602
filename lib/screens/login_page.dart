import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/carry_mark.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    // Support login by username OR email
    final user = await DatabaseHelper.instance.getUserByUsernameOrEmail(identifier);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _error = 'User not found';
        _loading = false;
      });
      return;
    }

    if (user.password != password) {
      setState(() {
        _error = 'Invalid password';
        _loading = false;
      });
      return;
    }

    // success: navigate based on role
    setState(() {
      _loading = false;
    });

    if (user.role == 'admin') {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/admin', arguments: user);
    } else if (user.role == 'lecturer') {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/lecturer', arguments: user);
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/student', arguments: user);
    }
  }

  Future<void> _showRegisterDialog() async {
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String role = 'student';
    String? regError;
    bool regLoading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (dialogContext, setState) {
        return AlertDialog(
          title: const Text('Create account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 8),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 8),
              DropdownButton<String>(value: role, onChanged: (v) => setState(() => role = v ?? 'student'), items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'lecturer', child: Text('Lecturer')),
                DropdownMenuItem(value: 'admin', child: Text('Administrator')),
              ]),
              if (role == 'student') ...[
                const SizedBox(height: 8),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
              ],
              if (regError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(regError!, style: const TextStyle(color: Colors.red))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: regLoading
                  ? null
                  : () async {
                      final username = usernameCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      final password = passwordCtrl.text;
                      final name = nameCtrl.text.trim();

                      if (username.isEmpty || email.isEmpty || password.isEmpty) {
                        setState(() => regError = 'Please fill required fields');
                        return;
                      }

                      if (role == 'student' && name.isEmpty) {
                        setState(() => regError = 'Please enter student full name');
                        return;
                      }

                      setState(() {
                        regLoading = true;
                        regError = null;
                      });

                      // capture navigator and scaffold messenger to avoid using dialogContext after awaits
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      // username uniqueness
                      final existing = await DatabaseHelper.instance.getUserByUsername(username);
                      if (existing != null) {
                        setState(() {
                          regError = 'Username already exists';
                          regLoading = false;
                        });
                        return;
                      }

                      try {
                        final newId = await DatabaseHelper.instance.insertUser(User(username: username, password: password, role: role, email: email));
                        if (role == 'student') {
                          final studentId = await DatabaseHelper.instance.insertStudent(Student(userId: newId, name: name));
                          await DatabaseHelper.instance.insertCarryMark(CarryMark(studentId: studentId, test: 0, assignment: 0, project: 0));
                        }

                        if (!mounted) return;
                        // autofill login form with created credentials
                        _identifierController.text = username;
                        _passwordController.text = password;
                        navigator.pop();
                        messenger.showSnackBar(const SnackBar(content: Text('Account created — you can login now')));
                      } catch (e) {
                        setState(() {
                          regError = 'Failed to create account';
                          regLoading = false;
                        });
                      }
                    },
              child: regLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LOGIN')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ICT602 CarryMark', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text('Sign in to continue', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _identifierController,
                      decoration: const InputDecoration(labelText: 'Username or Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: 8),
                    const Align(alignment: Alignment.centerLeft, child: Text('You can use either your username or email to login.', style: TextStyle(color: Colors.black54, fontSize: 12))),
                    const SizedBox(height: 16),

                    if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),

                    Row(children: [Expanded(child: ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login')))]),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Register button to create new users (admin/lecturer/student)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _showRegisterDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Create an account'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Tip: students require a full name. Accounts are saved locally.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
