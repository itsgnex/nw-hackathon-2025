// lib/src/pages/tabs/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the user's current name
    _nameController = TextEditingController(text: context.read<AppState>().userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _renameUser() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      context.read<AppState>().renameUser(newName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name changed to $newName!')),
      );
      // Optionally pop the screen after renaming
      // Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF81C784), Color(0xFF4DB6AC)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 32),
          children: [
            // Rename Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Change Trainer Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'New Name'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _renameUser,
                      child: const Text('Save Name'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Sign Out Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Sign Out'),
                subtitle: const Text('You will be returned to the login screen.'),
                onTap: () {
                  app.signOut();
                  // Navigate to login and remove all screens behind it
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
