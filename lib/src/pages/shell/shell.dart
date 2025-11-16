// lib/src/pages/shell/shell.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models.dart';
import '../tabs/leaderboard_page.dart';
import '../tabs/mart_page.dart';
import '../tabs/quests_page.dart';
import '../tabs/main_profile_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final chosenPokemon = appState.starter;

    final List<Widget> pages = [
      const QuestsPage(),
      const MartPage(),
      const LeaderboardPage(),
      const MainProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: [
          const NavigationDestination(
            // Snorlax for Quests (often found sleeping/blocking the way)
            icon: _NavIcon(pokemonId: 143),
            label: 'Quests',
          ),
          const NavigationDestination(
            // Psyduck for Mart (often confused, like when shopping)
            icon: _NavIcon(pokemonId: 54),
            label: 'Mart',
          ),
          const NavigationDestination(
            // Arcanine for Leaders (a noble and powerful leader-like Pokémon)
            icon: _NavIcon(pokemonId: 59),
            label: 'Leaders',
          ),
          // This part remains the same, keeping the dynamic profile icon
          NavigationDestination(
            icon: _NavIcon(pokemonId: chosenPokemon?.id ?? 1), // Fallback to Bulbasaur
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// A custom helper widget to display Pokémon sprites as navigation icons.
class _NavIcon extends StatelessWidget {
  final int pokemonId;
  const _NavIcon({required this.pokemonId});

  static String art(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Opacity(
      opacity: 0.7,
      child: Image.network(
        art(pokemonId),
        width: 32,
        height: 32,
        errorBuilder: (_, __, ___) => Icon(Icons.help_outline, color: colors.onSurfaceVariant),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      ),
    );
  }
}
