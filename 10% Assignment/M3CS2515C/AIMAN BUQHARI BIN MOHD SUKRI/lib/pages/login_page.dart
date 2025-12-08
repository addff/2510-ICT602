import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'admin_page.dart';
import 'lecturer_page.dart';
import 'student_page.dart';

class LoginPage extends StatefulWidget {
  final AppState appState;
  const LoginPage({super.key, required this.appState});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  UserRole role = UserRole.student;
  String? error;
  bool studentRegisterMode = false;

  void submit() {
    final u = username.text.trim();
    final p = password.text;
    if (role == UserRole.student && studentRegisterMode) {
      if (u.isEmpty || p.isEmpty) { setState(() => error = 'Enter ID and password'); return; }
      widget.appState.registerStudent(u, p);
      setState(() => error = 'Registered. You can now login.');
      return;
    }
    final ok = widget.appState.login(username: u, password: p, role: role);
    if (!ok) { setState(() => error = 'Invalid credentials'); return; }
    setState(() => error = null);
    if (role == UserRole.admin) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminPage(appState: widget.appState)));
    } else if (role == UserRole.lecturer) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => LecturerPage(appState: widget.appState)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudentPage(appState: widget.appState)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ICT602')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<UserRole>(
                    segments: const <ButtonSegment<UserRole>>[
                      ButtonSegment(value: UserRole.admin, label: Text('Admin')),
                      ButtonSegment(value: UserRole.lecturer, label: Text('Lecturer')),
                      ButtonSegment(value: UserRole.student, label: Text('Student')),
                    ],
                    selected: {role},
                    onSelectionChanged: (s) => setState(() => role = s.first),
                  ),
                  if (role == UserRole.student) ...[
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: const <ButtonSegment<bool>>[
                        ButtonSegment(value: false, label: Text('Login')),
                        ButtonSegment(value: true, label: Text('Register')),
                      ],
                      selected: {studentRegisterMode},
                      onSelectionChanged: (s) => setState(() => studentRegisterMode = s.first),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(controller: username, decoration: InputDecoration(labelText: role == UserRole.student ? 'Student ID' : 'Username')), 
                  const SizedBox(height: 12),
                  TextField(controller: password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                  const SizedBox(height: 12),
                  if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: submit, child: Text(role == UserRole.student && studentRegisterMode ? 'Register' : 'Login')),
                  const SizedBox(height: 16),
                  const Text('Admin: admin/admin123  Lecturer: lecturer/lect123  Student: register first')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
