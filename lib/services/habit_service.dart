import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class HabitService extends ChangeNotifier {
  late Box<Habit> _habitBox;

  HabitService() {
    _habitBox = Hive.box<Habit>('habits');
  }

  List<Habit> get habits => _habitBox.values.toList();

  Future<void> addHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await habit.save();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
    notifyListeners();
  }

  Future<void> toggleHabitForDate(Habit habit, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    final existingEntryIndex = habit.entries.indexWhere((entry) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      return entryDate.isAtSameMomentAs(normalizedDate);
    });

    if (existingEntryIndex != -1) {
      habit.entries[existingEntryIndex].completed = 
          !habit.entries[existingEntryIndex].completed;
    } else {
      habit.entries.add(HabitEntry(
        date: normalizedDate,
        completed: true,
      ));
    }

    await habit.save();
    notifyListeners();
  }

  Map<String, int> getWeeklySummary() {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final summary = <String, int>{};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = weekDays[date.weekday - 1];
      int completedCount = 0;

      for (var habit in habits) {
        final entry = habit.entries.where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day &&
            e.completed);
        completedCount += entry.length;
      }

      summary[dayName] = completedCount;
    }

    return summary;
  }

  int getTotalCompletedToday() {
    
    return habits.where((habit) => habit.isCompletedToday()).length;
  }

  double getOverallCompletionRate() {
    if (habits.isEmpty) return 0.0;
    return habits.map((h) => h.getCompletionRate(30)).reduce((a, b) => a + b) / habits.length;
  }
}