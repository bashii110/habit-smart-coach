// lib/core/constants/app_constants.dart

class AppConstants {
  // App Info
  static const String appName = 'Smart Habit Coach';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';

  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_complete';
  static const String insightsKey = 'habit_insights';

  // Notification
  static const String notificationChannelId = 'habit_reminders';
  static const String notificationChannelName = 'Habit Reminders';
  static const String notificationChannelDesc =
      'Daily reminders for your habits';

  // Frequency Options
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';

  // Streak Thresholds
  static const int streakBronze = 7;
  static const int streakSilver = 30;
  static const int streakGold = 100;

  // Analytics
  static const int weeksToShow = 4;
  static const int daysInWeek = 7;

  // Validation
  static const int minTitleLength = 2;
  static const int maxTitleLength = 50;
  static const int maxDescLength = 200;
}