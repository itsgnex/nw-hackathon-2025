// lib/src/pages/homeflow/home_choice_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../models.dart';
import '../../state/app_state.dart';
import 'create_home_page.dart';
import 'join_home_page.dart';

class HomeChoicePage extends StatelessWidget {
  const HomeChoicePage({super.key});

  final String createHomeImageUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png'; // Venusaur
  final String joinHomeImageUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png'; // Charizard

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final bool hasHome = app.currentHome != null;

    return Scaffold(
      // --- THIS IS THE FIX ---
      extendBodyBehindAppBar: true, // Allow the body's gradient to go behind the AppBar
      // --- END OF FIX ---
      appBar: AppBar(
        title: Text(
          'Welcome, ${app.userName}!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Changed to white for better contrast
            shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
          ),
        ),
        backgroundColor: Colors.transparent, // Make AppBar see-through
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white),
            onPressed: () {
              context.read<AppState>().signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
            },
          ),
        ],
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: hasHome ? _buildEnterHomeView(context, app) : _buildCreateOrJoinView(context, cs),
          ),
        ),
      ),
    );
  }

  // View for when a user is already in a home
  Widget _buildEnterHomeView(BuildContext context, AppState app) {
    // ... (This widget does not need changes)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "You're a member of the",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 8),
        Text(
          "'${app.currentHome!.name}' Gym!",
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5, color: Colors.black45)]),
        ),
        const SizedBox(height: 40),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/shell'),
          icon: const Icon(Icons.meeting_room_rounded),
          label: const Text('Enter Your Gym'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => context.read<AppState>().leaveHome(),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Leave this Gym'),
        ),
      ],
    );
  }

  // View for creating or joining a new home
  Widget _buildCreateOrJoinView(BuildContext context, ColorScheme cs) {
    // ... (This widget does not need changes)
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BigChoiceCard(
            title: 'Create a Home',
            subtitle: 'Become a Gym Leader and invite friends!',
            imageUrl: createHomeImageUrl,
            onTap: () => Navigator.of(context).push(slideUp(const CreateHomePage())),
            color: Colors.white,
            icon: Icons.add_home_rounded,
            iconColor: cs.primary,
          ),
          const SizedBox(height: 24),
          _BigChoiceCard(
            title: 'Join a Home',
            subtitle: "Use a code to join a friend's Gym.",
            imageUrl: joinHomeImageUrl,
            onTap: () => Navigator.of(context).push(slideUp(const JoinHomePage())),
            color: Colors.white,
            icon: Icons.group_add_rounded,
            iconColor: cs.secondary,
          ),
        ],
      ),
    );
  }
}

// The card widget for the choices
class _BigChoiceCard extends StatelessWidget {
  // ... (This widget does not need changes)
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final Color iconColor;

  const _BigChoiceCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(242),
      borderRadius: BorderRadius.circular(28),
      elevation: 8,
      shadowColor: Colors.black.withAlpha(102),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                imageUrl,
                height: 90,
                width: 90,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 90,
                    width: 90,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error_outline, size: 70, color: Colors.grey);
                },
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3B4CCA)),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(0.6), height: 1.3),
              ),
              const SizedBox(height: 20),
              Icon(icon, color: iconColor, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
