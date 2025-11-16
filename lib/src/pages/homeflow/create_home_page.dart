import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';import '../../models.dart';
import '../onboarding/character_select_page.dart';

class CreateHomePage extends StatefulWidget {
  const CreateHomePage({super.key});
  @override
  State<CreateHomePage> createState() => _CreateHomePageState();
}

class _CreateHomePageState extends State<CreateHomePage> {
  final _form = GlobalKey<FormState>();

  final _homeName = TextEditingController();
  final _totalRent = TextEditingController(text: '0');
  final _memberCount = TextEditingController(text: '1');

  // This function will be called when the create button is pressed.
  Future<void> _onCreate() async {
    // 1. Validate the form fields. If not valid, do nothing.
    if (!_form.currentState!.validate()) return;

    final app = context.read<AppState>();
    final name = _homeName.text.trim();

    // 2. Create the home using the app state.
    app.createHome(name);
    if (!mounted) return;

    // 3. Navigate to the character selection page.
    final Mon? chosen = await Navigator.of(context).push<Mon>(
      MaterialPageRoute(builder: (_) => const CharacterSelectPage()),
    );
    if (!mounted) return;

    // 4. After a character is chosen, update the app state and navigate to the main app shell.
    if (chosen != null) {
      app.chooseStarter(chosen);
      // This removes all previous screens and makes the home shell the new root.
      Navigator.of(context).pushNamedAndRemoveUntil('/shell', (_) => false);
    } else {
      // If no starter is chosen, show a message.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You need to choose a starter Pokémon to continue!'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _homeName.dispose();
    _totalRent.dispose();
    _memberCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar now has a transparent background to blend with the gradient.
      appBar: AppBar(
        title: const Text('Create Your Gym'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      // We extend the body behind the app bar to allow the gradient to cover the full screen.
      extendBodyBehindAppBar: true,
      body: Container(
        // Full screen width and height
        width: double.infinity,
        height: double.infinity,
        // --- UPDATED GRADIENT ---
        // Using the same beautiful gradient from the home choice page.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF81C784), // A light, grassy green
              Color(0xFF4DB6AC), // A soft teal
            ],
          ),
        ),
        child: Form(
          key: _form,
          // We use a SingleChildScrollView to prevent overflow on smaller screens.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 32), // Added top padding for app bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- THEMED POKÉ-STYLE INPUT CARDS ---

                // Input card for the Home Name
                _PokeInputCard(
                  label: 'Gym Name',
                  child: TextFormField(
                    controller: _homeName,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Viridian City Crew',
                      prefixIcon: Icon(Icons.home_work_rounded),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name!' : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Input card for the financial details
                _PokeInputCard(
                  label: 'Rent Details',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _totalRent,
                        decoration: const InputDecoration(
                          hintText: 'Total monthly rent (e.g., 1200)',
                          prefixIcon: Icon(Icons.monetization_on_outlined),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _memberCount,
                        decoration: const InputDecoration(
                          hintText: 'Number of members (e.g., 4)',
                          prefixIcon: Icon(Icons.group_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          return (n == null || n < 1) ? 'At least 1 member' : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // This text provides helpful, dynamic feedback to the user.
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _memberCount,
                        builder: (context, memberValue, _) {
                          return ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _totalRent,
                            builder: (context, rentValue, _) {
                              final members = int.tryParse(memberValue.text) ?? 0;
                              final rent = double.tryParse(rentValue.text) ?? 0.0;
                              final rentPerPerson = members > 0 ? (rent / members) : 0.0;
                              return Text(
                                'Rent will be split as \$${rentPerPerson.toStringAsFixed(2)} per person.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // The main action button, styled to be more prominent and match the new theme.
                FilledButton.icon(
                  onPressed: _onCreate,
                  icon: const Icon(Icons.catching_pokemon, size: 20),
                  label: const Text('Create & Choose Your Starter'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    // --- UPDATED BUTTON COLOR ---
                    backgroundColor: const Color(0xFF00695C), // A deep teal from the theme
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'After creating your Gym, you’ll pick a Pokémon to join you!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A custom widget for a styled input card with a "Pokémon" feel.
class _PokeInputCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _PokeInputCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95), // Slightly transparent white
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A styled label that looks like a header.
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                // --- UPDATED LABEL COLOR ---
                color: Color(0xFF004D40), // A dark, complementary teal
              ),
            ),
            const SizedBox(height: 12),
            // The content of the card (e.g., TextFormField).
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
