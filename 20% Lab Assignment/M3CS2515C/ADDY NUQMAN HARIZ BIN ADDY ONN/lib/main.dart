import 'dart:io'; // Needed for Windows check
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Windows DB
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // THIS BLOCK FIXES THE ERROR:
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false));
}

// ================== LOGIN PAGE ==================
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  void _handleLogin() async {
    // 1. Check Admin (No DB needed)
    if (userController.text == "admin" && passController.text == "123") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage()));
      return;
    }

    // 2. Check Database Users
    try {
      var user = await DatabaseHelper.instance.login(
        userController.text,
        passController.text,
      );

      if (user != null) {
        if (user['role'] == 'lecturer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LecturerPage()),
          );
        } else if (user['role'] == 'student') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentPage(username: user['username']),
            ),
          );
        } else if (user['role'] == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid Login! Try lecturer/123")),
        );
      }
    } catch (e) {
      // Show the error on screen if DB fails
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ICT602 Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _handleLogin, child: Text("Login")),
          ],
        ),
      ),
    );
  }
}

// ================== ADMIN PAGE ==================
class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Center(
        child: ElevatedButton(
          child: Text("Go to Web Based Management"),
          onPressed: () async {
            final Uri url = Uri.parse('https://uitm.edu.my');
            if (!await launchUrl(url)) throw 'Could not launch $url';
          },
        ),
      ),
    );
  }
}

// ================== LECTURER PAGE ==================
class LecturerPage extends StatefulWidget {
  @override
  _LecturerPageState createState() => _LecturerPageState();
}

class _LecturerPageState extends State<LecturerPage> {
  final _testCtrl = TextEditingController();
  final _assignCtrl = TextEditingController();
  final _projCtrl = TextEditingController();

  void _saveMarks() async {
    await DatabaseHelper.instance.updateMarks(
      'student',
      int.tryParse(_testCtrl.text) ?? 0,
      int.tryParse(_assignCtrl.text) ?? 0,
      int.tryParse(_projCtrl.text) ?? 0,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Marks Updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lecturer: Enter Carry Marks")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Update marks for Student",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _testCtrl,
              decoration: InputDecoration(labelText: "Test (Max 20)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _assignCtrl,
              decoration: InputDecoration(labelText: "Assignment (Max 10)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _projCtrl,
              decoration: InputDecoration(labelText: "Project (Max 20)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveMarks, child: Text("Save Marks")),
          ],
        ),
      ),
    );
  }
}

// ================== STUDENT PAGE ==================
class StudentPage extends StatefulWidget {
  final String username;
  StudentPage({required this.username});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  Map<String, dynamic>? marks;
  String selectedTarget = 'A+';

  final Map<String, int> gradeScales = {
    'A+': 90,
    'A': 80,
    'A-': 75,
    'B+': 70,
    'B': 65,
    'B-': 60,
    'C+': 55,
    'C': 50,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var data = await DatabaseHelper.instance.getMarks(widget.username);
    setState(() {
      marks = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (marks == null)
      return Scaffold(body: Center(child: CircularProgressIndicator()));

    int test = marks!['test'];
    int assign = marks!['assignment'];
    int project = marks!['project'];
    int currentCarryMark = test + assign + project;

    int targetScore = gradeScales[selectedTarget]!;
    int neededInFinal = targetScore - currentCarryMark;

    return Scaffold(
      appBar: AppBar(title: Text("Student Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Carry Marks",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Test: $test / 20"),
            Text("Assignment: $assign / 10"),
            Text("Project: $project / 20"),
            Divider(thickness: 2),
            Text(
              "Total Carry Mark: $currentCarryMark / 50",
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),

            SizedBox(height: 30),
            Text(
              "Target Grade Calculator",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text("I want to get: "),
                DropdownButton<String>(
                  value: selectedTarget,
                  items: gradeScales.keys.map((String val) {
                    return DropdownMenuItem(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedTarget = val!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(15),
              color: Colors.grey[200],
              child: Text(
                neededInFinal > 50
                    ? "IMPOSSIBLE: You need $neededInFinal/50"
                    : neededInFinal <= 0
                    ? "SAFE: You already have enough marks!"
                    : "You need to score: $neededInFinal / 50 in Final Exam",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: neededInFinal > 50 ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
