// lib/utility helpers/consistency_detector.dart

import '../models/habit_model.dart';
import 'data_utils.dart';

enum ConsistencyStatus {
  excellent,  // 80%+ completion this week
  good,       // 60–79%
  slipping,   // 40–59%
  atrisk,     // below 40%
  new_,       // less than 3 days of data
}

class ConsistencyReport {
  final ConsistencyStatus status;
  final List<HabitModel> streaksAtRisk;
  final List<HabitModel> improvingHabits;
  final List<HabitModel> decliningHabits;
  final double overallRate;
  final String nudgeMessage;
  final String nudgeEmoji;

  ConsistencyReport({
    required this.status,
    required this.streaksAtRisk,
    required this.improvingHabits,
    required this.decliningHabits,
    required this.overallRate,
    required this.nudgeMessage,
    required this.nudgeEmoji,
  });
}

class ConsistencyDetector {
  /// Full consistency analysis across all habits
  static ConsistencyReport analyze(List<HabitModel> habits) {
    if (habits.isEmpty) {
      return ConsistencyReport(
        status: ConsistencyStatus.new_,
        streaksAtRisk: [],
        improvingHabits: [],
        decliningHabits: [],
        overallRate: 0,
        nudgeMessage: 'Add habits to start tracking your consistency.',
        nudgeEmoji: '🌱',
      );
    }

    final dailyHabits =
        habits.where((h) => h.frequency == 'daily').toList();

    // Overall weekly rate
    double totalRate = 0;
    for (final h in dailyHabits) {
      totalRate += h.completionRateThisWeek;
    }
    final overallRate =
        dailyHabits.isEmpty ? 0.0 : totalRate / dailyHabits.length;

    // Streaks at risk: have a streak > 2 but not completed today
    final streaksAtRisk = habits
        .where((h) => h.streakCount > 2 && !h.isCompletedToday)
        .toList()
      ..sort((a, b) => b.streakCount.compareTo(a.streakCount));

    // Improving: completed today AND streak growing
    final improvingHabits = habits
        .where((h) => h.isCompletedToday && h.streakCount > 0)
        .toList();

    // Declining: daily habit with < 30% completion this week
    final decliningHabits = dailyHabits
        .where((h) => h.completionRateThisWeek < 0.3)
        .toList();

    final status = _calculateStatus(overallRate, habits);
    final nudge = _buildNudge(
      status,
      streaksAtRisk,
      decliningHabits,
      overallRate,
    );

    return ConsistencyReport(
      status: status,
      streaksAtRisk: streaksAtRisk,
      improvingHabits: improvingHabits,
      decliningHabits: decliningHabits,
      overallRate: overallRate,
      nudgeMessage: nudge.$1,
      nudgeEmoji: nudge.$2,
    );
  }

  static ConsistencyStatus _calculateStatus(
      double rate, List<HabitModel> habits) {
    // If all habits are brand new (< 3 total completions across all)
    final totalCompletions =
        habits.fold(0, (sum, h) => sum + h.completedDates.length);
    if (totalCompletions < 3) return ConsistencyStatus.new_;

    if (rate >= 0.8) return ConsistencyStatus.excellent;
    if (rate >= 0.6) return ConsistencyStatus.good;
    if (rate >= 0.4) return ConsistencyStatus.slipping;
    return ConsistencyStatus.atrisk;
  }

  static (String, String) _buildNudge(
    ConsistencyStatus status,
    List<HabitModel> streaksAtRisk,
    List<HabitModel> decliningHabits,
    double rate,
  ) {
    // Highest priority: streak at risk
    if (streaksAtRisk.isNotEmpty) {
      final top = streaksAtRisk.first;
      return (
        "Don't break your ${top.streakCount}-day streak on '${top.title}'! Complete it before the day ends.",
        '⚠️'
      );
    }

    switch (status) {
      case ConsistencyStatus.excellent:
        return (
          "You're on fire this week! ${(rate * 100).toInt()}% completion rate. Keep this energy going!",
          '🔥'
        );
      case ConsistencyStatus.good:
        return (
          "Solid week! You're at ${(rate * 100).toInt()}% — a little push today gets you to excellent.",
          '💪'
        );
      case ConsistencyStatus.slipping:
        if (decliningHabits.isNotEmpty) {
          return (
            "'${decliningHabits.first.title}' needs attention — you've only hit it ${(decliningHabits.first.completionRateThisWeek * 100).toInt()}% this week.",
            '📉'
          );
        }
        return (
          "Your consistency dipped this week. Small actions every day compound into big results.",
          '📉'
        );
      case ConsistencyStatus.atrisk:
        return (
          "It's been a tough week, and that's okay. Just complete one habit right now to restart your momentum.",
          '🆘'
        );
      case ConsistencyStatus.new_:
        return (
          "You're just getting started! Complete your habits daily to build unstoppable streaks.",
          '🌱'
        );
    }
  }

  /// Check if a specific habit is declining over last 2 weeks
  static bool isHabitDeclining(HabitModel habit) {
    final dates = habit.completedDates;
    if (dates.length < 4) return false;

    final now = DateTime.now();
    final thisWeek = AppDateUtils.getLast7Days();
    final lastWeek = List.generate(
      7,
      (i) => now.subtract(Duration(days: 14 - i)),
    );

    int thisWeekCount = 0;
    int lastWeekCount = 0;

    for (final d in dates) {
      if (thisWeek.any((w) => AppDateUtils.isSameDay(w, d))) {
        thisWeekCount++;
      }
      if (lastWeek.any((w) => AppDateUtils.isSameDay(w, d))) {
        lastWeekCount++;
      }
    }

    return lastWeekCount > 0 && thisWeekCount < lastWeekCount;
  }

  /// Get a streak loss warning message for a specific habit
  static String? getStreakWarning(HabitModel habit) {
    if (habit.streakCount == 0) return null;
    if (habit.isCompletedToday) return null;

    final now = DateTime.now();
    final hoursLeft = 23 - now.hour;

    if (habit.streakCount >= 30) {
      return "🚨 Your ${habit.streakCount}-day streak is at risk! $hoursLeft hours left today.";
    }
    if (habit.streakCount >= 7) {
      return "⚠️ Don't lose your ${habit.streakCount}-day streak — complete it today!";
    }
    if (habit.streakCount >= 3) {
      return "🔥 Keep your ${habit.streakCount}-day streak alive!";
    }
    return null;
  }
}
