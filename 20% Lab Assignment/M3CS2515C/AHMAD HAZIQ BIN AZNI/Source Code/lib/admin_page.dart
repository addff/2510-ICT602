import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'logout.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final managementUrl = 'https://your-web-management-link.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.admin_panel_settings, color: Colors.blue, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Administrator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Access the web-based management console to perform administrative tasks.', style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => launchUrlString(managementUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(onPressed: () => launchUrlString(managementUrl), icon: const Icon(Icons.settings), label: const Text('Manage Site')),
                        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.backup), label: const Text('Backup DB')),
                        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.person_add), label: const Text('Add User')),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const Spacer(),

            Text('ICT602 Admin • Mobile App', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
