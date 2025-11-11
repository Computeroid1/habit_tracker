import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  String icon;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  List<HabitEntry> entries;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.createdAt,
    List<HabitEntry>? entries,
  }) : entries = entries ?? [];

  int getCurrentStreak() {
    if (entries.isEmpty) return 0;
    
    entries.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    for (var entry in entries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      final difference = currentDate.difference(entryDate).inDays;
      
      if (difference == streak && entry.completed) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  double getCompletionRate(int days) {
    if (entries.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    final recentEntries = entries.where((entry) =>
        entry.date.isAfter(startDate) && entry.completed).length;
    
    return (recentEntries / days) * 100;
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return entries.any((entry) =>
        entry.date.year == today.year &&
        entry.date.month == today.month &&
        entry.date.day == today.day &&
        entry.completed);
  }
}

@HiveType(typeId: 1)
class HabitEntry {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  bool completed;

  HabitEntry({
    required this.date,
    required this.completed,
  });
}