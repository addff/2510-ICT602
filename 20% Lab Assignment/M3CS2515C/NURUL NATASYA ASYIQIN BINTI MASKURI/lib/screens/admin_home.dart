import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class AdminHome extends StatelessWidget {
  final Map<String, dynamic>? user;
  const AdminHome({super.key, this.user}); // optional


  void _openWebManagement() async {
    const url = 'https://your-web-management-link.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white, // <-- make text white
          ),
          onPressed: _openWebManagement,
          child: const Text('Go to Web Management'),
        ),
      ),
    );
  }
}