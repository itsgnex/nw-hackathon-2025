// lib/src/models.dart

// Basic app models
class Mon {
  final int id;
  final String name;
  final String imageUrl;
  const Mon({required this.id, required this.name, required this.imageUrl});

  Mon copyWith({int? id, String? name, String? imageUrl}) =>
      Mon(id: id ?? this.id, name: name ?? this.name, imageUrl: imageUrl ?? this.imageUrl);
}

enum Room { kitchen, bathroom, living, bedroom, hallway, garden, mart }

class Member {
  final String id;
  final String name;
  final Mon? starter;

  const Member({required this.id, required this.name, this.starter});
}

class Quest {
  final String id;
  final String title;
  final Room room;
  final DateTime? due;
  final int xp;
  final bool done;
  final String? assigneeId;
  final int penaltyXp;

  const Quest({
    required this.id,
    required this.title,
    required this.room,
    this.due,
    this.xp = 10,
    this.done = false,
    this.assigneeId,
    this.penaltyXp = 5,
  });

  Quest copyWith({
    String? id,
    String? title,
    Room? room,
    DateTime? due,
    int? xp,
    bool? done,
    String? assigneeId,
    int? penaltyXp,
  }) =>
      Quest(
        id: id ?? this.id,
        title: title ?? this.title,
        room: room ?? this.room,
        due: due ?? this.due,
        xp: xp ?? this.xp,
        done: done ?? this.done,
        assigneeId: assigneeId ?? this.assigneeId,
        penaltyXp: penaltyXp ?? this.penaltyXp,
      );
}

class Score {
  final String userId;
  final String name;
  final int weeklyXp;
  final int allTimeXp;
  final Mon? starter;

  const Score({
    required this.userId,
    required this.name,
    required this.weeklyXp,
    required this.allTimeXp,
    this.starter,
  });

  Score copyWith({String? userId, String? name, int? weeklyXp, int? allTimeXp, Mon? starter}) => Score(
    userId: userId ?? this.userId,
    name: name ?? this.name,
    weeklyXp: weeklyXp ?? this.weeklyXp,
    allTimeXp: allTimeXp ?? this.allTimeXp,
    starter: starter ?? this.starter,
  );
}

class Home {
  final String id;
  final String name;
  final String code;
  final List<String> memberUserIds;

  Home({
    required this.id,
    required this.name,
    required this.code,
    required this.memberUserIds,
  });

  Home copyWith({
    String? id,
    String? name,
    String? code,
    List<String>? memberUserIds,
  }) =>
      Home(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        memberUserIds: memberUserIds ?? this.memberUserIds,
      );
}

// Grocery / Inventory
class GroceryItem {
  final String id;
  final String name;
  final double qty;
  final String unit; // e.g. pcs, L, kg
  final bool low; // running low flag
  final String? assigneeId;

  const GroceryItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.unit,
    this.low = false,
    this.assigneeId,
  });

  GroceryItem copyWith({String? id, String? name, double? qty, String? unit, bool? low, String? assigneeId}) => GroceryItem(
    id: id ?? this.id,
    name: name ?? this.name,
    qty: qty ?? this.qty,
    unit: unit ?? this.unit,
    low: low ?? this.low,
    assigneeId: assigneeId ?? this.assigneeId,
  );
}

// ============== NEW CLASS FOR BILL SPLITTING ==============
class Bill {
  final String id;
  final String description;
  final double totalAmount;
  final String paidBy; // The ID of the user who paid
  final Set<String> splitWith; // The IDs of users the bill is split with
  final DateTime date;

  const Bill({
    required this.id,
    required this.description,
    required this.totalAmount,
    required this.paidBy,
    required this.splitWith,
    required this.date,
  });
}
