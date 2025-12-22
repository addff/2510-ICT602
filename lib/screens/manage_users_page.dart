import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/carry_mark.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<User> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final u = await DatabaseHelper.instance.getAllUsers();
    if (!mounted) return;
    setState(() {
      _users = u;
      _loading = false;
    });
  }

  Future<void> _showEditDialog(User user) async {
    final st = await DatabaseHelper.instance.getStudentByUserId(user.id!);
    if (!mounted) return;

    final emailCtrl = TextEditingController(text: user.email);
    final passwordCtrl = TextEditingController(text: user.password);
    final nameCtrl = TextEditingController(text: st?.name ?? '');
    String role = user.role;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Edit user'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Username: ${user.username}'),
              const SizedBox(height: 8),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password (leave to keep)')),
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
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(onPressed: () async {
              final name = nameCtrl.text.trim();
              final update = User(id: user.id, username: user.username, password: passwordCtrl.text.isEmpty ? user.password : passwordCtrl.text, role: role, email: emailCtrl.text.trim());
              await DatabaseHelper.instance.updateUser(update);
              if (role == 'student') {
                final existing = await DatabaseHelper.instance.getStudentByUserId(user.id!);
                if (existing == null) {
                  final sid = await DatabaseHelper.instance.insertStudent(Student(userId: user.id!, name: name));
                  await DatabaseHelper.instance.insertCarryMark(CarryMark(studentId: sid, test: 0, assignment: 0, project: 0));
                } else {
                  await DatabaseHelper.instance.updateStudent(Student(id: existing.id, userId: existing.userId, name: name));
                }
              } else {
                // if role changed away from student, remove related student record and marks
                await DatabaseHelper.instance.deleteStudentByUserId(user.id!);
              }
              if (!mounted) return;
              Navigator.of(context).pop();
              await _loadUsers();
            }, child: const Text('Save')),
          ],
        );
      }),
    );
  }

  Future<void> _confirmDelete(User user) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete user'),
      content: Text('Delete ${user.username}? This will remove student records if present.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))],
    ));
    if (ok != true) return;
    await DatabaseHelper.instance.deleteUser(user.id!);
    if (!mounted) return;
    await _loadUsers();
  }

  Future<void> _showCreateDialog() async {
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String role = 'student';
    String? err;
    bool loading = false;

    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return AlertDialog(
        title: const Text('Create user'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 8),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 8),
          TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 8),
          DropdownButton<String>(value: role, onChanged: (v) => setState(() => role = v ?? 'student'), items: const [
            DropdownMenuItem(value: 'student', child: Text('Student')),
            DropdownMenuItem(value: 'lecturer', child: Text('Lecturer')),
            DropdownMenuItem(value: 'admin', child: Text('Administrator')),
          ]),
          if (role == 'student') ...[const SizedBox(height: 8), TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name'))],
          if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: Colors.red))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: loading ? null : () async {
            final u = usernameCtrl.text.trim(); final e = emailCtrl.text.trim(); final p = passwordCtrl.text; final n = nameCtrl.text.trim();
            if (u.isEmpty || e.isEmpty || p.isEmpty) { setState(() => err = 'Fill required'); return; }
            final existing = await DatabaseHelper.instance.getUserByUsername(u);
            if (existing != null) { setState(() => err = 'Username exists'); return; }
            setState(() => loading = true);
            final newid = await DatabaseHelper.instance.insertUser(User(username: u, password: p, role: role, email: e));
            if (role == 'student') {
              final sid = await DatabaseHelper.instance.insertStudent(Student(userId: newid, name: n));
              await DatabaseHelper.instance.insertCarryMark(CarryMark(studentId: sid, test: 0, assignment: 0, project: 0));
            }
            if (!mounted) return;
            Navigator.of(context).pop();
            await _loadUsers();
          }, child: const Text('Create')),
        ],
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      floatingActionButton: FloatingActionButton(onPressed: _showCreateDialog, child: const Icon(Icons.add)),

      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final u = _users[index];
          return Card(
            child: ListTile(
              title: Text(u.username),
              subtitle: Text('${u.email} • ${u.role}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(u)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(u)),
              ]),
            ),
          );
        },
      ),
    );
  }
}