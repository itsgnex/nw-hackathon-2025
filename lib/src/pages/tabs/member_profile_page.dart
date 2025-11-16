// lib/src/pages/tabs/member_profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models.dart';
import '../../state/app_state.dart';

// This is a new page specifically for viewing other members' profiles.
class MemberProfilePage extends StatelessWidget {
  final Member member;

  const MemberProfilePage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    // Find the score details for this specific member from the leaderboard
    final score = appState.board.firstWhere(
          (s) => s.userId == member.id,
      orElse: () => Score(userId: member.id, name: member.name, weeklyXp: 0, allTimeXp: 0, starter: member.starter),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(member.name),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 32),
          children: [
            // --- PROFILE HEADER ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (member.starter != null)
                      Image.network(member.starter!.imageUrl, width: 80, height: 80)
                    else
                      const Icon(Icons.catching_pokemon_rounded, size: 80, color: Colors.grey),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: theme.textTheme.headlineSmall),
                        Text('Member of ${appState.currentHome?.name ?? 'the team'}', style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- XP AND STATS CARD ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trainer Stats', style: theme.textTheme.titleLarge),
                    const Divider(height: 20),
                    ListTile(
                      leading: const Icon(Icons.star_rounded, color: Colors.amber),
                      title: const Text('All-Time XP'),
                      trailing: Text(
                        '${score.allTimeXp}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange),
                      title: const Text('Weekly XP'),
                      trailing: Text(
                        '${score.weeklyXp}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
