// test/date_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_habit_coach/utility helpers/data_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('isSameDay', () {
      test('returns true for same day', () {
        final a = DateTime(2024, 3, 15, 10, 30);
        final b = DateTime(2024, 3, 15, 22, 0);
        expect(AppDateUtils.isSameDay(a, b), true);
      });

      test('returns false for different days', () {
        final a = DateTime(2024, 3, 15);
        final b = DateTime(2024, 3, 16);
        expect(AppDateUtils.isSameDay(a, b), false);
      });

      test('returns false for different months', () {
        final a = DateTime(2024, 3, 15);
        final b = DateTime(2024, 4, 15);
        expect(AppDateUtils.isSameDay(a, b), false);
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        expect(AppDateUtils.isToday(DateTime.now()), true);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(AppDateUtils.isToday(yesterday), false);
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(AppDateUtils.isYesterday(yesterday), true);
      });

      test('returns false for today', () {
        expect(AppDateUtils.isYesterday(DateTime.now()), false);
      });
    });

    group('startOfDay', () {
      test('returns midnight of the given day', () {
        final date = DateTime(2024, 6, 15, 14, 30, 45);
        final start = AppDateUtils.startOfDay(date);
        expect(start.hour, 0);
        expect(start.minute, 0);
        expect(start.second, 0);
        expect(start.day, 15);
        expect(start.month, 6);
      });
    });

    group('getLast7Days', () {
      test('returns 7 dates', () {
        final days = AppDateUtils.getLast7Days();
        expect(days.length, 7);
      });

      test('last element is today', () {
        final days = AppDateUtils.getLast7Days();
        expect(AppDateUtils.isToday(days.last), true);
      });

      test('dates are in ascending order', () {
        final days = AppDateUtils.getLast7Days();
        for (int i = 1; i < days.length; i++) {
          expect(days[i].isAfter(days[i - 1]), true);
        }
      });
    });

    group('calculateStreak', () {
      test('returns 0 for empty list', () {
        expect(AppDateUtils.calculateStreak([]), 0);
      });

      test('returns 1 for today only', () {
        final dates = [DateTime.now()];
        expect(AppDateUtils.calculateStreak(dates), 1);
      });

      test('returns 2 for today and yesterday', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        expect(AppDateUtils.calculateStreak([now, yesterday]), 2);
      });

      test('returns correct streak for consecutive days', () {
        final now = DateTime.now();
        final dates = List.generate(
          5,
          (i) => now.subtract(Duration(days: i)),
        );
        expect(AppDateUtils.calculateStreak(dates), 5);
      });

      test('resets streak when day is missed', () {
        final now = DateTime.now();
        final dates = [
          now,
          now.subtract(const Duration(days: 1)),
          // Skip day 2
          now.subtract(const Duration(days: 3)),
          now.subtract(const Duration(days: 4)),
        ];
        expect(AppDateUtils.calculateStreak(dates), 2);
      });

      test('returns 0 when no recent dates', () {
        final oldDate = DateTime.now().subtract(const Duration(days: 10));
        expect(AppDateUtils.calculateStreak([oldDate]), 0);
      });

      test('handles duplicate dates', () {
        final now = DateTime.now();
        final dates = [
          now,
          now, // Duplicate
          now.subtract(const Duration(days: 1)),
        ];
        expect(AppDateUtils.calculateStreak(dates), 2);
      });
    });

    group('calculateCompletionRate', () {
      test('returns 0 for empty list', () {
        expect(AppDateUtils.calculateCompletionRate([], 7), 0.0);
      });

      test('returns 0 for 0 total days', () {
        expect(
          AppDateUtils.calculateCompletionRate([DateTime.now()], 0),
          0.0,
        );
      });

      test('returns correct rate', () {
        final dates = [
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 2),
          DateTime(2024, 1, 3),
        ];
        final rate = AppDateUtils.calculateCompletionRate(dates, 7);
        expect(rate, closeTo(3 / 7, 0.01));
      });

      test('clamps at 1.0', () {
        final dates = List.generate(
          10,
          (i) => DateTime(2024, 1, i + 1),
        );
        final rate = AppDateUtils.calculateCompletionRate(dates, 5);
        expect(rate, 1.0);
      });
    });

    group('getGreeting', () {
      test('returns a non-empty string', () {
        final greeting = AppDateUtils.getGreeting();
        expect(greeting.isNotEmpty, true);
      });
    });

    group('timeAgo', () {
      test('returns "Just now" for current time', () {
        expect(AppDateUtils.timeAgo(DateTime.now()), 'Just now');
      });

      test('returns minutes ago', () {
        final past = DateTime.now().subtract(const Duration(minutes: 5));
        expect(AppDateUtils.timeAgo(past), '5m ago');
      });

      test('returns hours ago', () {
        final past = DateTime.now().subtract(const Duration(hours: 3));
        expect(AppDateUtils.timeAgo(past), '3h ago');
      });

      test('returns days ago', () {
        final past = DateTime.now().subtract(const Duration(days: 5));
        expect(AppDateUtils.timeAgo(past), '5d ago');
      });
    });

    group('formatDate', () {
      test('formats correctly', () {
        final date = DateTime(2024, 3, 15);
        final formatted = AppDateUtils.formatDate(date);
        expect(formatted, contains('Mar'));
        expect(formatted, contains('15'));
        expect(formatted, contains('2024'));
      });
    });
  });
}
