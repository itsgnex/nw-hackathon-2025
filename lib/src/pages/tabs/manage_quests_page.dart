// lib/src/pages/tabs/manage_quests_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models.dart';
import '../../state/app_state.dart';

class ManageQuestsPage extends StatefulWidget {
  const ManageQuestsPage({super.key});
  @override
  State<ManageQuestsPage> createState() => _ManageQuestsPageState();
}

class _ManageQuestsPageState extends State<ManageQuestsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  Room _room = Room.kitchen;
  String? _assigneeId;
  int _xp = 10;
  int _penalty = 5;
  DateTime? _due;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final today = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: _due ?? today, firstDate: today, lastDate: today.add(const Duration(days: 365)));
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_due ?? today));
    if (t == null) return;
    setState(() => _due = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  void _addQuest() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields.'), backgroundColor: Colors.orangeAccent));
      return;
    }
    context.read<AppState>().addManagedQuest(title: _titleController.text.trim(), room: _room, assigneeId: _assigneeId!, xp: _xp, penaltyXp: _penalty, due: _due);
    _titleController.clear();
    _due = null;
    _assigneeId = null;
    _formKey.currentState!.reset();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New Quest has been assigned!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final people = app.members;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Manage Gym Quests'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.white),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF81C784), Color(0xFF4DB6AC)])),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 32),
          children: [
            // --- FIX: The Form is now wrapped correctly ---
            Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add a New Quest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF004D40))),
                      const SizedBox(height: 16),
                      TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Quest Title', prefixIcon: Icon(Icons.label_important_outline)), validator: (v) => (v == null || v.trim().isEmpty) ? 'A title is required' : null),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: DropdownButtonFormField<Room>(value: _room, items: Room.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(), onChanged: (r) => setState(() => _room = r ?? Room.kitchen), decoration: const InputDecoration(labelText: 'Area', prefixIcon: Icon(Icons.place_outlined)))),
                        const SizedBox(width: 10),
                        Expanded(child: DropdownButtonFormField<String>(value: _assigneeId, items: people.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(), onChanged: (id) => setState(() => _assigneeId = id), decoration: const InputDecoration(labelText: 'Assign To', prefixIcon: Icon(Icons.person_outline)), validator: (id) => (id == null) ? 'Assign a person' : null)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: DropdownButtonFormField<int>(value: _xp, items: const [5, 10, 15, 20, 25, 30, 40, 50].map((v) => DropdownMenuItem(value: v, child: Text('$v XP'))).toList(), onChanged: (v) => setState(() => _xp = v ?? 10), decoration: const InputDecoration(labelText: 'Reward', prefixIcon: Icon(Icons.star_outline)))),
                        const SizedBox(width: 10),
                        Expanded(child: DropdownButtonFormField<int>(value: _penalty, items: const [0, 5, 10, 15, 20, 25].map((v) => DropdownMenuItem(value: v, child: Text('-$v XP'))).toList(), onChanged: (v) => setState(() => _penalty = v ?? 5), decoration: const InputDecoration(labelText: 'Penalty', prefixIcon: Icon(Icons.warning_amber_rounded)))),
                      ]),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.event_available_outlined), label: Text(_due == null ? 'Set Deadline' : DateFormat('MMM d, h:mm a').format(_due!)), onPressed: _pickDue, style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade400), foregroundColor: const Color(0xFF004D40)))),
                        const SizedBox(width: 10),
                        FilledButton.icon(onPressed: _addQuest, icon: const Icon(Icons.add_task), label: const Text('Add'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00695C))),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (app.quests.isNotEmpty)
              ...app.quests.map((q) => _QuestListItem(quest: q, assignee: people.firstWhere((m) => m.id == (q.assigneeId ?? app.userId), orElse: () => people.first), onToggle: () => context.read<AppState>().toggleQuest(q.id))),
          ],
        ),
      ),
    );
  }
}
// _QuestListItem remains the same
class _QuestListItem extends StatelessWidget {
  final Quest quest;
  final Member assignee;
  final VoidCallback onToggle;
  const _QuestListItem({required this.quest, required this.assignee, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = quest.due != null && quest.due!.isBefore(DateTime.now()) && !quest.done;
    final Color statusColor = quest.done ? Colors.green.shade600 : (isOverdue ? Colors.red.shade600 : Colors.blueGrey.shade600);
    final IconData statusIcon = quest.done ? Icons.check_circle : (isOverdue ? Icons.error : Icons.radio_button_unchecked);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: statusColor, width: 1.5)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(statusIcon, color: statusColor, size: 28),
        title: Text(quest.title, style: TextStyle(fontWeight: FontWeight.bold, decoration: quest.done ? TextDecoration.lineThrough : TextDecoration.none)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('For: ${assignee.name} • ${quest.room.name}\n${quest.due != null ? 'Due: ${DateFormat('E, MMM d, h:mm a').format(quest.due!)}' : 'No deadline'}', style: TextStyle(color: Colors.grey.shade700, height: 1.4))),
        trailing: Transform.scale(scale: 1.2, child: Checkbox(value: quest.done, onChanged: (_) => onToggle(), activeColor: statusColor, side: BorderSide(color: statusColor, width: 2))),
        isThreeLine: true,
      ),
    );
  }
}
