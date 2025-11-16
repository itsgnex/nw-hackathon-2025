// lib/src/pages/homeflow/join_home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models.dart';
import '../../state/app_state.dart';
import '../onboarding/character_select_page.dart';

class JoinHomePage extends StatefulWidget {
  const JoinHomePage({super.key});
  @override
  State<JoinHomePage> createState() => _JoinHomePageState();
}

class _JoinHomePageState extends State<JoinHomePage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _onJoin() async {
    if (_codeController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a full 6-character code.'),
        backgroundColor: Colors.orangeAccent,
      ));
      return;
    }
    setState(() => _isLoading = true);

    // --- FIX: This now correctly calls joinHome and proceeds ---
    final app = context.read<AppState>();
    final ok = app.joinHome(_codeController.text.toUpperCase());

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Something went wrong. Please check the code.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;

    final Mon? chosen = await Navigator.of(context).push<Mon>(
      MaterialPageRoute(builder: (_) => const CharacterSelectPage()),
    );

    if (!mounted) return;

    if (chosen != null) {
      app.chooseStarter(chosen);
      Navigator.of(context).pushNamedAndRemoveUntil('/shell', (_) => false);
    } else {
      // If the user backs out of character select, we "undo" the join to let them try again.
      app.leaveHome();
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must choose a starter to join the Gym!')),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (The UI for this page remains the same, only the logic above was fixed) ...
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Join a Gym'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gym Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF004D40), // Dark teal
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _codeController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 8, // Changed to 8
                          decoration: const InputDecoration(
                            hintText: '--------',
                            counterText: '',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton.icon(
                  icon: const Icon(Icons.group_add_rounded),
                  label: const Text('Join & Choose Starter'),
                  onPressed: _onJoin,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    backgroundColor: const Color(0xFF00695C),
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
