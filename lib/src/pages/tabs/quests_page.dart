// lib/src/pages/tabs/quests_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    // Apply overdue penalties whenever the dashboard is shown.
    app.applyOverduePenalties();

    final open = app.myOpenCount(app.userId);
    final dueToday = app.myDueToday(app.userId);
    final overdue = app.myOverdue(app.userId);
    final me = app.board.firstWhere((s) => s.userId == app.userId);

    // --- MAIN BUILD METHOD ---
    // The entire page is wrapped in a Container to apply the background gradient.
    return Container(
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
        // Adjust padding for the new design and to account for the notch
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 100),
        children: [
          // 1. A Clear Page Header
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 20),
            child: Text(
              "Your Quest Log",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black26),
                ],
              ),
            ),
          ),

          // 2. Redesigned KPI Cards in a modern grid
          GridView.count(
            crossAxisCount: 2, // Two cards per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true, // Necessary to use a GridView inside a ListView
            physics: const NeverScrollableScrollPhysics(), // Disable grid's own scrolling
            children: [
              _KpiCard(title: 'Open Quests', value: '$open', icon: Icons.flag_rounded, color: Colors.blue.shade400),
              _KpiCard(title: 'Due Today', value: '$dueToday', icon: Icons.event_available_rounded, color: Colors.orange.shade400),
              _KpiCard(title: 'Overdue', value: '$overdue', icon: Icons.warning_amber_rounded, color: Colors.red.shade400),
              _KpiCard(title: 'Weekly XP', value: '+${me.weeklyXp}', icon: Icons.stars_rounded, color: Colors.green.shade400),
            ],
          ),
          const SizedBox(height: 24),

          // 3. A redesigned, prominent navigation card that looks actionable
          _ManageQuestsCard(
            onTap: () => Navigator.of(context).pushNamed('/manage-quests'),
          ),
        ],
      ),
    );
  }
}

/// A custom widget for a themed Key Performance Indicator (KPI) card.
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95), // "Frosted glass" effect
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with a colored background
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            // Text content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF004D40)),
                ),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom widget for the card that navigates to the quest management page.
class _ManageQuestsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ManageQuestsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap, // This executes the navigation to '/manage-quests'
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              // Icon with a color that matches the app theme
              Icon(Icons.assignment_ind_outlined, color: Color(0xFF00695C), size: 32),
              SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign & Manage Quests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40), // Dark teal for emphasis
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add deadlines, assignees and penalties.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              // Chevron to indicate this is a clickable, navigational item
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
