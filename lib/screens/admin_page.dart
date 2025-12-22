import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _controller = TextEditingController();
  bool _loading = true;

  static const _prefKey = 'web_management_url';

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_prefKey) ?? 'https://example.com/web-management';
    _controller.text = url;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _controller.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL saved')));
  }

  Future<void> _openWebManagement() async {
    final urlText = _controller.text.trim();
    if (urlText.isEmpty) return;
    final uri = Uri.tryParse(urlText);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open URL')));
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(alignment: Alignment.centerLeft, child: Text('Web Management URL', style: TextStyle(fontWeight: FontWeight.bold))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _controller,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.link), hintText: 'https://...'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: ElevatedButton.icon(onPressed: _openWebManagement, icon: const Icon(Icons.open_in_browser), label: const Text('Open'))),
                            const SizedBox(width: 8),
                            Expanded(child: ElevatedButton.icon(onPressed: _saveUrl, icon: const Icon(Icons.save), label: const Text('Save'))),
                            const SizedBox(width: 8),
                            Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/admin/users'), icon: const Icon(Icons.manage_accounts), label: const Text('Manage Users'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
