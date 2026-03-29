// lib/core/utils/date_utils.dart

import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static List<DateTime> getLast7Days() {
    return List.generate(
      7,
          (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );
  }

  static List<DateTime> getLastNDays(int n) {
    return List.generate(
      n,
          (i) => DateTime.now().subtract(Duration(days: n - 1 - i)),
    );
  }

  static int calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    final sorted = completedDates
        .map((d) => startOfDay(d))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = startOfDay(DateTime.now());
    final yesterday = startOfDay(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    // Start counting from today or yesterday
    if (!isSameDay(sorted.first, today) &&
        !isSameDay(sorted.first, yesterday)) {
      return 0;
    }

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i - 1].difference(sorted[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  static double calculateCompletionRate(
      List<DateTime> completedDates,
      int totalDays,
      ) {
    if (totalDays == 0) return 0.0;
    final uniqueDays =
        completedDates.map((d) => startOfDay(d)).toSet().length;
    return (uniqueDays / totalDays).clamp(0.0, 1.0);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}