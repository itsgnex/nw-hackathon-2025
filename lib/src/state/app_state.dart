// lib/src/state/app_state.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models.dart';

class AppState extends ChangeNotifier {
  // ... (Auth, Home, Members, Starter sections remain the same) ...

  // =====================================================
  // Auth
  // =====================================================
  String? _currentUserId;
  String _userName = 'Trainer';

  String get userName => _userName;
  String get userId => _currentUserId ?? 'guest';

  Future<bool> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    final success = _currentUserId != null;
    return success;
  }

  Future<bool> signUp({required String name, required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUserId = 'u_${DateTime.now().millisecondsSinceEpoch}';
    _userName = name.trim().isEmpty ? 'Trainer' : name.trim();
    notifyListeners();
    return true;
  }

  void signOut() {
    _currentUserId = null;
    _userName = 'Trainer';
    _starter = null;
    _currentHome = null;
    _quests.clear();
    _bills.clear();
    notifyListeners();
  }

  // =====================================================
  // Home / Members
  // =====================================================
  Home? _currentHome;
  Home? get currentHome => _currentHome;
  final Map<String, Home> _homesByCode = {};
  final Map<String, String> _nameById = {};
  List<Member> get members {
    final ids = _currentHome?.memberUserIds ?? const <String>[];
    return [for (final id in ids) Member(id: id, name: _nameById[id] ?? 'Member', starter: _board.firstWhere((s) => s.userId == id, orElse: () => const Score(userId: '', name: '', weeklyXp: 0, allTimeXp: 0)).starter)];
  }
  String _code() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Home createHome(String name) {
    final code = _code();
    final h = Home(
      id: 'h_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'My Home' : name.trim(),
      code: code,
      memberUserIds: [userId, 'u2', 'u3'],
    );
    _homesByCode[code] = h;
    _currentHome = h;
    _nameById[userId] = _userName;
    _nameById['u2'] = 'Misty';
    _nameById['u3'] = 'Brock';
    final scoreMisty = _board.indexWhere((s) => s.userId == 'u2');
    if (scoreMisty != -1) _board[scoreMisty] = _board[scoreMisty].copyWith(starter: const Mon(id: 121, name: 'starmie', imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/121.png'));
    final scoreBrock = _board.indexWhere((s) => s.userId == 'u3');
    if (scoreBrock != -1) _board[scoreBrock] = _board[scoreBrock].copyWith(starter: const Mon(id: 95, name: 'onix', imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/95.png'));
    notifyListeners();
    return h;
  }

  bool joinHome(String code) {
    final h = _homesByCode[code];
    if (h == null) {
      // For showcase purposes, let's create a dummy home if the code is new
      final newHome = createHome('Joined Gym');
      _homesByCode[code] = newHome;
      _currentHome = newHome;
    } else {
      if (!h.memberUserIds.contains(userId)) {
        h.memberUserIds.add(userId);
      }
      _currentHome = h;
    }
    _nameById[userId] = _userName;
    notifyListeners();
    return true;
  }

  void leaveHome() {
    final h = _currentHome;
    if (h == null) return;
    h.memberUserIds.remove(userId);
    _currentHome = null;
    notifyListeners();
  }

  // =====================================================
  // Starter
  // =====================================================
  Mon? _starter;
  Mon? get starter => _starter;
  void chooseStarter(Mon mon) {
    _starter = mon;
    final i = _board.indexWhere((s) => s.userId == userId);
    if (i != -1) {
      _board[i] = _board[i].copyWith(starter: mon);
    } else {
      _board.add(Score(userId: userId, name: _userName, weeklyXp: 0, allTimeXp: 0, starter: mon));
    }
    notifyListeners();
  }

  // =====================================================
  // Quests
  // =====================================================
  // --- MORE HARDCODED QUESTS ---
  final List<Quest> _quests = [
    Quest(id: 'q1', title: 'Wash the dishes', room: Room.kitchen, xp: 10, done: true, assigneeId: 'u2'),
    Quest(id: 'q2', title: 'Take out the trash', room: Room.kitchen, due: DateTime.now().add(const Duration(days: 1)), xp: 5, done: false, assigneeId: 'u3'),
    Quest(id: 'q3', title: 'Clean the floor', room: Room.hallway, xp: 15, done: true, assigneeId: 'u3'),
    Quest(id: 'q4', title: 'Wipe the counters', room: Room.kitchen, xp: 10, done: true, assigneeId: 'u2'),
    Quest(id: 'q5', title: 'Scrub the tub', room: Room.bathroom, xp: 20, done: false, assigneeId: 'u2'),
    Quest(id: 'q6', title: 'Water the plants', room: Room.garden, xp: 5, done: true, assigneeId: 'u3'),
  ];
  List<Quest> get quests => List.unmodifiable(_quests..sort((a,b) => a.done ? 1 : -1)); // Keep incomplete quests at the top
  final Set<String> _penalizedOnce = {};

  void addManagedQuest({required String title, required Room room, required String assigneeId, int xp = 10, int penaltyXp = 5, DateTime? due}) {
    _quests.add(Quest(id: 'q_${DateTime.now().microsecondsSinceEpoch}', title: title, room: room, due: due, xp: xp, penaltyXp: penaltyXp, done: false, assigneeId: assigneeId));
    notifyListeners();
  }

  void toggleQuest(String id) {
    final i = _quests.indexWhere((q) => q.id == id);
    if (i == -1) return;
    final q = _quests[i];
    final toggled = q.copyWith(done: !q.done);
    _quests[i] = toggled;
    if (toggled.done) {
      _bumpXp(toggled.assigneeId ?? userId, toggled.xp);
    }
    notifyListeners();
  }
  // ... (applyOverduePenalties, myOpenCount, myDueToday, myOverdue methods are unchanged) ...
  void applyOverduePenalties() {
    final now = DateTime.now();
    for (final q in _quests) {
      if (!q.done && q.due != null && q.due!.isBefore(now) && !_penalizedOnce.contains(q.id) && q.penaltyXp > 0) {
        _penalizedOnce.add(q.id);
        _bumpXp(q.assigneeId ?? userId, -q.penaltyXp);
      }
    }
    notifyListeners();
  }

  int myOpenCount(String uid) => _quests.where((q) => (q.assigneeId ?? uid) == uid && !q.done).length;

  int myDueToday(String uid) {
    final t = DateTime.now();
    return _quests.where((q) {
      if ((q.assigneeId ?? uid) != uid || q.done || q.due == null) return false;
      final d = q.due!;
      return d.year == t.year && d.month == t.month && d.day == t.day;
    }).length;
  }

  int myOverdue(String uid) => _quests.where((q) => (q.assigneeId ?? uid) == uid && !q.done && q.due != null && q.due!.isBefore(DateTime.now())).length;

  // =====================================================
  // Leaderboard / XP
  // =====================================================
  final List<Score> _board = [
    const Score(userId: 'u2', name: 'Misty', weeklyXp: 25, allTimeXp: 210),
    const Score(userId: 'u3', name: 'Brock', weeklyXp: 15, allTimeXp: 180),
  ];
  List<Score> get board {
    final meIdx = _board.indexWhere((s) => s.userId == userId);
    if (meIdx == -1) {
      _board.add(Score(userId: userId, name: _userName, weeklyXp: 0, allTimeXp: 0, starter: _starter));
    } else {
      final s = _board[meIdx];
      if (s.name != _userName || s.starter != _starter) {
        _board[meIdx] = s.copyWith(name: _userName, starter: _starter);
      }
    }
    for (var i = 0; i < _board.length; i++) {
      final id = _board[i].userId;
      final n = _nameById[id];
      if (n != null && n != _board[i].name) {
        _board[i] = _board[i].copyWith(name: n);
      }
    }
    final copy = [..._board]..sort((a, b) => b.allTimeXp.compareTo(a.allTimeXp));
    return copy;
  }

  void _bumpXp(String uid, int xp) {
    final i = _board.indexWhere((s) => s.userId == uid);
    if (i == -1) {
      _board.add(Score(userId: uid, name: _nameById[uid] ?? 'Trainer', weeklyXp: xp, allTimeXp: xp));
    } else {
      final s = _board[i];
      _board[i] = s.copyWith(weeklyXp: s.weeklyXp + xp, allTimeXp: s.allTimeXp + xp);
    }
  }

  // =====================================================
  // Groceries (for PokéMart)
  // =====================================================
  final List<GroceryItem> _toBuy = [
    const GroceryItem(id: 'g1', name: 'Milk', qty: 1, unit: 'item'),
    const GroceryItem(id: 'g2', name: 'Bread', qty: 1, unit: 'item'),
    const GroceryItem(id: 'g3', name: 'Apples', qty: 1, unit: 'item'),
  ];
  List<GroceryItem> get toBuy => List.unmodifiable(_toBuy);

  void addToBuy(String name, double qty, String unit) {
    _toBuy.add(GroceryItem(id: 'g_${DateTime.now().microsecondsSinceEpoch}', name: name, qty: qty, unit: unit));
    notifyListeners();
  }

  void removeFromBuy(String id) {
    _toBuy.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // =====================================================
  // Bill Splitting
  // =====================================================
  // --- MORE HARDCODED BILLS ---
  final List<Bill> _bills = [
    Bill(id: 'bill1', description: 'Weekend Pizza Night', totalAmount: 45.50, paidBy: 'u2', splitWith: {'u2', 'u3'}, date: DateTime.now().subtract(const Duration(days: 2))),
    Bill(id: 'bill2', description: 'Internet Bill', totalAmount: 60.00, paidBy: 'u3', splitWith: {'u2', 'u3'}, date: DateTime.now().subtract(const Duration(days: 5))),
  ];
  List<Bill> get bills => List.unmodifiable(_bills);

  void addBill({required String description, required double totalAmount, required Set<String> splitWith}) {
    if (description.trim().isEmpty || totalAmount <= 0 || splitWith.isEmpty) return;
    final newBill = Bill(id: 'b_${DateTime.now().microsecondsSinceEpoch}', description: description, totalAmount: totalAmount, paidBy: userId, splitWith: splitWith, date: DateTime.now());
    _bills.insert(0, newBill);
    notifyListeners();
  }

  void removeBill(String billId) {
    _bills.removeWhere((b) => b.id == billId);
    notifyListeners();
  }

  // ... (renameUser and other settings helpers remain the same) ...
  void renameUser(String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    _userName = trimmed;
    _nameById[userId] = trimmed;
    final i = _board.indexWhere((s) => s.userId == userId);
    if (i != -1) {
      _board[i] = _board[i].copyWith(name: _userName);
    }
    notifyListeners();
  }
}
