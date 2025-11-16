// lib/src/pages/tabs/task_history_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models.dart';
// --- THIS IS THE FIX ---
// The correct path goes up two directories from 'tabs' to 'src' and then down to 'state'.
import '../../state/app_state.dart';

class TaskHistoryPage extends StatelessWidget {
  final Member member;
  const TaskHistoryPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    // This line will now work correctly
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    // Filter quests to show only completed tasks by this member
    final completedQuests = appState.quests
        .where((q) => q.assigneeId == member.id && q.done)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("${member.name}'s Completed Tasks"),
        backgroundColor: const Color(0xFF81C784), // Match the gradient start color
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF81C784), Color(0xFF4DB6AC)],
          ),
        ),
        child: completedQuests.isEmpty
            ? const Center(
          child: Text(
            'No completed tasks yet!',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedQuests.length,
          itemBuilder: (context, index) {
            final quest = completedQuests[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(quest.title),
                subtitle: Text(
                  // Handle potential null due date
                  'Completed on ${quest.due != null ? DateFormat.yMMMd().format(quest.due!) : 'an unknown date'}',
                ),
                trailing: Text(
                  '+${quest.xp} XP',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
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
