// lib/src/pages/tabs/leaderboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
import '../../state/app_state.dart';
// REMOVED: No longer need to import the main profile page here.
// import 'profile_page.dart';
// ADDED: Import the new page for viewing other members.
import 'member_profile_page.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final board = app.board;
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Leaderboard'),
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
            colors: [
              Color(0xFF81C784), // A light, grassy green
              Color(0xFF4DB6AC), // A soft teal
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
          itemCount: board.length,
          itemBuilder: (context, i) {
            final score = board[i];
            final member = app.members.firstWhere(
                  (m) => m.id == score.userId,
              orElse: () => Member(id: score.userId, name: score.name, starter: score.starter),
            );

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // Don't navigate if the user taps on their own profile in the list
                  if (member.id == app.userId) return;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // *** THIS IS THE FIX ***
                      // Navigate to the new MemberProfilePage and pass the member data.
                      builder: (_) => MemberProfilePage(member: member),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListTile(
                    // If it's the current user, highlight them
                    tileColor: member.id == app.userId ? theme.colorScheme.primary.withOpacity(0.1) : null,
                    leading: _RankIndicator(rank: i + 1),
                    title: Text(
                      score.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text('Weekly XP: ${score.weeklyXp}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${score.allTimeXp} XP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF004D40),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (score.starter != null)
                          Image.network(
                            score.starter!.imageUrl,
                            height: 40,
                            width: 40,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          )
                        else
                          const Icon(Icons.catching_pokemon, color: Colors.grey, size: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
// _RankIndicator widget remains the same...
// --- ADD THIS WIDGET TO THE BOTTOM OF YOUR FILE ---

// A helper widget to display the rank with a styled background.
class _RankIndicator extends StatelessWidget {
  final int rank;
  const _RankIndicator({required this.rank});

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.blueGrey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getRankColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: rank > 3 ? Colors.black54 : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
