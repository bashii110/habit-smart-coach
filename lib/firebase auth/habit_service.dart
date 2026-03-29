// lib/services/habit_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_habit_coach/models/habit_model.dart';

import '../utility helpers/data_utils.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _habits => _firestore.collection('habits');

  Stream<List<HabitModel>> habitsStream(String userId) {
    return _habits
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList(),
    );
  }

  Future<List<HabitModel>> fetchHabits(String userId) async {
    final snapshot = await _habits
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList();
  }

  Future<String> addHabit(HabitModel habit) async {
    final docRef = _habits.doc();
    final newHabit = habit.copyWith(id: docRef.id);
    await docRef.set(newHabit.toFirestore());
    return docRef.id;
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _habits.doc(habit.id).update({
      ...habit.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteHabit(String habitId) async {
    await _habits.doc(habitId).delete();
  }

  Future<HabitModel?> markComplete(HabitModel habit) async {
    final now = DateTime.now();
    final today = AppDateUtils.startOfDay(now);

    // Already completed today
    if (habit.completedDates.any((d) => AppDateUtils.isSameDay(d, today))) {
      return null;
    }

    final updatedDates = [...habit.completedDates, now];
    final newStreak = AppDateUtils.calculateStreak(updatedDates);
    final currentHour = now.hour.toString();
    final updatedHours = [...habit.completionHours, currentHour];

    final updated = habit.copyWith(
      completedDates: updatedDates,
      streakCount: newStreak,
      updatedAt: now,
      completionHours: updatedHours,
    );

    await _habits.doc(habit.id).update({
      'completedDates': updatedDates.map((d) => Timestamp.fromDate(d)).toList(),
      'streakCount': newStreak,
      'updatedAt': FieldValue.serverTimestamp(),
      'completionHours': updatedHours,
    });

    return updated;
  }

  Future<HabitModel?> unmarkComplete(HabitModel habit) async {
    final today = AppDateUtils.startOfDay(DateTime.now());
    final updatedDates = habit.completedDates
        .where((d) => !AppDateUtils.isSameDay(d, today))
        .toList();

    final newStreak = AppDateUtils.calculateStreak(updatedDates);

    final updated = habit.copyWith(
      completedDates: updatedDates,
      streakCount: newStreak,
      updatedAt: DateTime.now(),
    );

    await _habits.doc(habit.id).update({
      'completedDates':
      updatedDates.map((d) => Timestamp.fromDate(d)).toList(),
      'streakCount': newStreak,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return updated;
  }

  Future<Map<String, dynamic>> getAnalytics(String userId) async {
    final habits = await fetchHabits(userId);
    int totalCompletions = 0;
    int longestStreak = 0;

    for (final habit in habits) {
      totalCompletions += habit.completedDates.length;
      if (habit.streakCount > longestStreak) {
        longestStreak = habit.streakCount;
      }
    }

    final dailyHabits =
    habits.where((h) => h.frequency == 'daily').toList();
    final last7Days = AppDateUtils.getLast7Days();

    // Calculate weekly completion
    final weeklyData = <String, int>{};
    for (final day in last7Days) {
      int completedCount = 0;
      for (final habit in dailyHabits) {
        if (habit.completedDates.any((d) => AppDateUtils.isSameDay(d, day))) {
          completedCount++;
        }
      }
      weeklyData[AppDateUtils.formatDayOfWeek(day)] = completedCount;
    }

    double completionRate = 0;
    if (dailyHabits.isNotEmpty) {
      int totalPossible = dailyHabits.length * 7;
      int actualCompleted = weeklyData.values.fold(0, (a, b) => a + b);
      completionRate = totalPossible > 0 ? actualCompleted / totalPossible : 0;
    }

    return {
      'totalHabits': habits.length,
      'totalCompletions': totalCompletions,
      'longestStreak': longestStreak,
      'completionRate': completionRate,
      'weeklyData': weeklyData,
      'habits': habits,
    };
  }
}