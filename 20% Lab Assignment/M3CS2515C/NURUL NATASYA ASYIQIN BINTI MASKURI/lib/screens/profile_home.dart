import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHome extends StatefulWidget {
  final Map<String, dynamic> user;
  const ProfileHome({super.key, required this.user});

  @override
  State<ProfileHome> createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  bool loading = false;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user['fullName'] ?? '');
    phoneController = TextEditingController(text: widget.user['phone'] ?? '');
    emailController = TextEditingController(text: widget.user['email'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (currentUser == null) return;

    setState(() => loading = true);

    try {
      // Update Firestore profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'fullName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Return updated user map to StudentHome
      Navigator.pop(context, {
        'fullName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': nameController.text.trim(),
        'matricNumber': widget.user['matricNumber'], // MUST return this or home page won't show it
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Update failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteAccount() async {
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.red)),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => loading = true);

      // Delete profile from Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).delete();

      // Delete Firebase Auth account
      await currentUser!.delete();

      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account deleted."),
          backgroundColor: Colors.red,
        ),
      );

      // Return null to indicate deletion
      Navigator.pop(context, null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Delete failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.purple)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, null), // no changes
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => setState(() => editing = !editing),
            icon: Icon(editing ? Icons.close : Icons.edit, color: Colors.white),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),

            // Name
            TextField(
              controller: nameController,
              enabled: editing,
              decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Phone
            TextField(
              controller: phoneController,
              enabled: editing,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Email
            TextField(
              controller: emailController,
              enabled: editing,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),

            if (editing)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: saveChanges,
                child: const Text("Save Changes"),
              ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: deleteAccount,
              child: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}