// lib/utility helpers/motivation_service.dart

import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class MotivationService {
  static const String _lastQuoteDateKey = 'last_quote_date';
  static const String _lastQuoteIndexKey = 'last_quote_index';

  static const List<Map<String, String>> _quotes = [
    {
      'quote': 'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
      'author': 'Aristotle',
    },
    {
      'quote': 'Small daily improvements are the key to staggering long-term results.',
      'author': 'Robin Sharma',
    },
    {
      'quote': 'You do not rise to the level of your goals. You fall to the level of your systems.',
      'author': 'James Clear',
    },
    {
      'quote': 'Motivation gets you started. Habit keeps you going.',
      'author': 'Jim Ryun',
    },
    {
      'quote': 'The secret of your future is hidden in your daily routine.',
      'author': 'Mike Murdock',
    },
    {
      'quote': 'Success is the sum of small efforts, repeated day in and day out.',
      'author': 'Robert Collier',
    },
    {
      'quote': 'Don\'t watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson',
    },
    {
      'quote': 'Habits are the compound interest of self-improvement.',
      'author': 'James Clear',
    },
    {
      'quote': 'It\'s not what we do once in a while that shapes our lives, but what we do consistently.',
      'author': 'Tony Robbins',
    },
    {
      'quote': 'An ounce of practice is worth more than tons of preaching.',
      'author': 'Mahatma Gandhi',
    },
    {
      'quote': 'The chains of habit are too light to be felt until they are too heavy to be broken.',
      'author': 'Warren Buffett',
    },
    {
      'quote': 'First forget inspiration. Habit is more dependable.',
      'author': 'Octavia Butler',
    },
    {
      'quote': 'You\'ll never change your life until you change something you do daily.',
      'author': 'Mike Murdock',
    },
    {
      'quote': 'Champions don\'t do extraordinary things. They do ordinary things, but they do them without thinking.',
      'author': 'Charles Duhigg',
    },
    {
      'quote': 'Your beliefs become your thoughts. Your thoughts become your habits. Your habits become your destiny.',
      'author': 'Mahatma Gandhi',
    },
    {
      'quote': 'Nothing is particularly hard if you divide it into small jobs.',
      'author': 'Henry Ford',
    },
    {
      'quote': 'Discipline is choosing between what you want now and what you want most.',
      'author': 'Augusta F. Kantra',
    },
    {
      'quote': 'The difference between who you are and who you want to be is what you do.',
      'author': 'Unknown',
    },
    {
      'quote': 'Consistency is what transforms average into excellence.',
      'author': 'Unknown',
    },
    {
      'quote': 'Every action you take is a vote for the type of person you wish to become.',
      'author': 'James Clear',
    },
  ];

  /// Returns today's quote — same quote all day, changes at midnight
  static Future<Map<String, String>> getTodaysQuote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';
      final savedDate = prefs.getString(_lastQuoteDateKey);

      if (savedDate == todayStr) {
        // Return the same quote as this morning
        final index = prefs.getInt(_lastQuoteIndexKey) ?? 0;
        return _quotes[index % _quotes.length];
      }

      // New day — pick a new random quote (avoid repeating yesterday's)
      final lastIndex = prefs.getInt(_lastQuoteIndexKey) ?? -1;
      int newIndex;
      do {
        newIndex = Random().nextInt(_quotes.length);
      } while (newIndex == lastIndex && _quotes.length > 1);

      await prefs.setString(_lastQuoteDateKey, todayStr);
      await prefs.setInt(_lastQuoteIndexKey, newIndex);

      return _quotes[newIndex];
    } catch (_) {
      return _quotes[0];
    }
  }

  /// Returns a streak-specific motivational message
  static String getStreakMessage(int streak) {
    if (streak == 0) return "Start your streak today! Every legend started at day 1.";
    if (streak == 1) return "Day 1 done! The hardest part is starting — you did it.";
    if (streak == 2) return "2 days in! Consistency is starting to take root.";
    if (streak == 3) return "3-day streak! You're building a real habit now.";
    if (streak == 7) return "One full week! 🎉 You've proven you can do this.";
    if (streak == 14) return "Two weeks strong! Your brain is literally rewiring itself.";
    if (streak == 21) return "21 days! Science says habits form around now. You've done it!";
    if (streak == 30) return "30 days! 🥈 A full month of commitment. You're unstoppable.";
    if (streak == 50) return "50 days! You're in the top 1% of habit keepers.";
    if (streak == 100) return "100 DAYS! 🥇 You are an absolute legend. Pure gold.";
    if (streak > 100) return "Day $streak. At this point, this habit IS who you are. 🔥";
    if (streak > 30) return "$streak days! You're building something extraordinary.";
    if (streak > 7) return "$streak-day streak! You're in a groove — don't stop now.";
    return "$streak days in. Keep going!";
  }

  /// Returns a recovery message when a streak is lost
  static String getRecoveryMessage(String habitTitle, int lostStreak) {
    if (lostStreak >= 30) {
      return "You lost a $lostStreak-day streak on '$habitTitle', but that means you BUILT a $lostStreak-day streak. You can do it again — and faster this time.";
    }
    if (lostStreak >= 7) {
      return "Your '$habitTitle' streak reset. That's okay — the data shows you can go at least $lostStreak days. Use that as your new minimum.";
    }
    return "Missed '$habitTitle' yesterday. Today is a fresh start — no looking back!";
  }
}
