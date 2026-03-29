// test/habit_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_habit_coach/models/habit_model.dart';

void main() {
  group('HabitModel', () {
    late HabitModel testHabit;

    setUp(() {
      testHabit = HabitModel(
        id: 'test-id',
        userId: 'user-1',
        title: 'Test Habit',
        description: 'A test habit description',
        frequency: 'daily',
        preferredTime: '08:00',
        streakCount: 5,
        completedDates: [],
        createdAt: DateTime(2024, 1, 1),
        iconEmoji: '💪',
        colorHex: '#FF0000',
        completionHours: [],
      );
    });

    group('isCompletedToday', () {
      test('returns false when no dates', () {
        expect(testHabit.isCompletedToday, false);
      });

      test('returns true when completed today', () {
        testHabit.completedDates = [DateTime.now()];
        expect(testHabit.isCompletedToday, true);
      });

      test('returns false when only completed yesterday', () {
        testHabit.completedDates = [
          DateTime.now().subtract(const Duration(days: 1)),
        ];
        expect(testHabit.isCompletedToday, false);
      });
    });

    group('smartTimeSuggestion', () {
      test('returns null when no completion hours', () {
        expect(testHabit.smartTimeSuggestion, null);
      });

      test('returns suggestion for most active hour (PM)', () {
        final habit = testHabit.copyWith(
          completionHours: ['20', '20', '20', '14', '14'],
        );
        final suggestion = habit.smartTimeSuggestion;
        expect(suggestion, isNotNull);
        expect(suggestion, contains('8:00 PM'));
      });

      test('returns suggestion for most active hour (AM)', () {
        final habit = testHabit.copyWith(
          completionHours: ['8', '8', '8', '10'],
        );
        final suggestion = habit.smartTimeSuggestion;
        expect(suggestion, isNotNull);
        expect(suggestion, contains('8:00 AM'));
      });

      test('handles midnight (hour 0)', () {
        final habit = testHabit.copyWith(
          completionHours: ['0', '0', '0'],
        );
        final suggestion = habit.smartTimeSuggestion;
        expect(suggestion, isNotNull);
        expect(suggestion, contains('12:00 AM'));
      });
    });

    group('streakLabel', () {
      test('returns no streak for 0', () {
        final habit = testHabit.copyWith(streakCount: 0);
        expect(habit.streakLabel, 'No streak yet');
      });

      test('returns fire emoji for small streak', () {
        final habit = testHabit.copyWith(streakCount: 3);
        expect(habit.streakLabel, contains('🔥'));
        expect(habit.streakLabel, contains('3'));
      });

      test('returns bronze for 7+ days', () {
        final habit = testHabit.copyWith(streakCount: 7);
        expect(habit.streakLabel, contains('🥉'));
      });

      test('returns silver for 30+ days', () {
        final habit = testHabit.copyWith(streakCount: 30);
        expect(habit.streakLabel, contains('🥈'));
      });

      test('returns gold for 100+ days', () {
        final habit = testHabit.copyWith(streakCount: 100);
        expect(habit.streakLabel, contains('🥇'));
      });
    });

    group('completionRateThisWeek', () {
      test('returns 0 for no completions', () {
        expect(testHabit.completionRateThisWeek, 0.0);
      });

      test('returns 0 for weekly habits', () {
        final habit = testHabit.copyWith(frequency: 'weekly');
        expect(habit.completionRateThisWeek, 0.0);
      });
    });

    group('copyWith', () {
      test('preserves existing values when no args', () {
        final copy = testHabit.copyWith();
        expect(copy.id, testHabit.id);
        expect(copy.title, testHabit.title);
        expect(copy.userId, testHabit.userId);
        expect(copy.frequency, testHabit.frequency);
      });

      test('overrides specified values', () {
        final copy = testHabit.copyWith(
          title: 'New Title',
          streakCount: 99,
        );
        expect(copy.title, 'New Title');
        expect(copy.streakCount, 99);
        expect(copy.id, testHabit.id); // unchanged
      });
    });

    group('toFirestore / fromFirestore roundtrip', () {
      test('toFirestore returns correct map', () {
        final map = testHabit.toFirestore();
        expect(map['userId'], 'user-1');
        expect(map['title'], 'Test Habit');
        expect(map['description'], 'A test habit description');
        expect(map['frequency'], 'daily');
        expect(map['preferredTime'], '08:00');
        expect(map['streakCount'], 5);
        expect(map['iconEmoji'], '💪');
        expect(map['colorHex'], '#FF0000');
      });
    });

    group('toString', () {
      test('returns readable string', () {
        final str = testHabit.toString();
        expect(str, contains('Test Habit'));
        expect(str, contains('test-id'));
        expect(str, contains('5'));
      });
    });
  });
}
