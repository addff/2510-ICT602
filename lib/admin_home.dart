import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void _openWebManagement() async {
    const url = 'https://example.com/web-management'; // change to your management URL
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE4E7EB),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Welcome Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.indigo,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome, Admin',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'System Administrator Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Main Function Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.web,
                          size: 60,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Web Based Management',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Access the complete web management system to manage users, courses, and system settings.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _openWebManagement,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Web Management'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Logout Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout from Admin Panel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}