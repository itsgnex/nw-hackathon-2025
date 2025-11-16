// lib/src/pages/tabs/leaderboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models.dart';
import '../../state/app_state.dart';
import 'member_profile_page.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final board = appState.board;
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
            colors: [Color(0xFF81C784), Color(0xFF4DB6AC)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
          itemCount: board.length,
          itemBuilder: (context, i) {
            final score = board[i];
            final member = appState.members.firstWhere(
                  (m) => m.id == score.userId,
              orElse: () => Member(id: score.userId, name: score.name, starter: score.starter),
            );

            // --- XP PROGRESS CALCULATION ---
            final double progress = (score.allTimeXp / 500).clamp(0.0, 1.0);
            final bool canEvolve = score.allTimeXp >= 500;
            final bool isCurrentUser = member.id == appState.userId;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias, // Important for the progress bar to look good
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MemberProfilePage(member: member)),
                  );
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: ListTile(
                        tileColor: isCurrentUser ? theme.colorScheme.primary.withOpacity(0.1) : null,
                        leading: _RankIndicator(rank: i + 1),
                        title: Text(score.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text('Weekly XP: ${score.weeklyXp}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${score.allTimeXp} XP',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF004D40)),
                            ),
                            const SizedBox(width: 12),
                            if (score.starter != null)
                              Image.network(score.starter!.imageUrl, height: 40, width: 40, errorBuilder: (_, __, ___) => const SizedBox.shrink())
                            else
                              const Icon(Icons.catching_pokemon, color: Colors.grey, size: 32),
                          ],
                        ),
                      ),
                    ),
                    // --- *** THIS IS THE UPDATED PROGRESS/EVOLVE SECTION *** ---
                    if (!canEvolve) // If they CAN'T evolve, show the progress bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Evolution Progress: ${score.allTimeXp} / 500 XP', style: theme.textTheme.bodySmall),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.amber,
                              minHeight: 6,
                            ),
                          ],
                        ),
                      )
                    else // If they CAN evolve, show a clear call to action
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            // Guide the user on what to do next
                            isCurrentUser ? 'Go to Your Profile to Evolve!' : 'Ready to Evolve!',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(color: rank > 3 ? Colors.black54 : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
