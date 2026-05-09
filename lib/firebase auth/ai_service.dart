// lib/firebase auth/ai_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/habit_model.dart';

class AICoachService {
  static const String _model = 'gemini-2.0-flash';

  // ⚠️ Store your Gemini API key here.
  // For production, replace this with a call to your own backend proxy
  // so the key is never shipped in the client bundle.
  // Get a free key at: https://aistudio.google.com/app/apikey
  static const String _apiKey = String.fromEnvironment(
    'AIzaSyC-ezux2CBjnwCHE728OteDashYvGAo32Y',
    defaultValue: '', // leave empty; set via --dart-define at build time
  );

  static String get _apiUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  /// Returns a personalized coaching message based on habit data
  Future<CoachingInsight> getCoachingInsight(List<HabitModel> habits) async {
    if (habits.isEmpty) {
      return CoachingInsight(
        message: "Add your first habit to start your journey! 🌱",
        type: InsightType.motivation,
        emoji: '🌱',
      );
    }

    if (_apiKey.isEmpty) {
      debugPrint('GEMINI_API_KEY not set — using fallback insight.');
      return _fallbackInsight(habits);
    }

    final prompt = _buildPrompt(habits);

    try {
      final response = await http
          .post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {
                'text': '''You are a compassionate, smart habit coach. 
Analyze the user's habit data and respond ONLY with a JSON object in this exact format:
{
  "message": "Your personalized coaching message here (max 2 sentences, warm and specific)",
  "type": "motivation|warning|praise|tip",
  "emoji": "single relevant emoji"
}
- "motivation": user needs encouragement
- "warning": user is losing consistency (be gentle, not harsh)  
- "praise": user is doing great
- "tip": actionable advice based on their patterns
Be specific, reference their actual habits and streaks. Never be generic.
Respond ONLY with the JSON object — no markdown, no backticks, no extra text.''',
              }
            ]
          },
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 300,
            'temperature': 0.7,
          },
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
        data['candidates'][0]['content']['parts'][0]['text'] as String;

        final jsonStr = text
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();

        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

        return CoachingInsight(
          message: parsed['message'] as String,
          type: InsightType.fromString(parsed['type'] as String),
          emoji: parsed['emoji'] as String,
        );
      } else {
        debugPrint('AI API error: ${response.statusCode} ${response.body}');
        return _fallbackInsight(habits);
      }
    } catch (e) {
      debugPrint('AI service error: $e');
      return _fallbackInsight(habits);
    }
  }

  String _buildPrompt(List<HabitModel> habits) {
    final buffer = StringBuffer();
    buffer.writeln('Here is the user\'s habit data:');
    buffer.writeln('Total habits: ${habits.length}');

    for (final habit in habits) {
      buffer.writeln('---');
      buffer.writeln('Habit: ${habit.title}');
      buffer.writeln('Streak: ${habit.streakCount} days');
      buffer.writeln('Frequency: ${habit.frequency}');
      buffer.writeln(
          'Completed today: ${habit.isCompletedToday ? "Yes" : "No"}');
      buffer.writeln(
          'Weekly completion rate: ${(habit.completionRateThisWeek * 100).toInt()}%');
      buffer.writeln('Total completions: ${habit.completedDates.length}');
      if (habit.smartTimeSuggestion != null) {
        buffer.writeln('Pattern: ${habit.smartTimeSuggestion}');
      }
    }

    final completedToday = habits.where((h) => h.isCompletedToday).length;
    buffer.writeln('---');
    buffer.writeln('Completed today: $completedToday / ${habits.length}');
    buffer.writeln('\nGive a personalized coaching insight based on this data.');

    return buffer.toString();
  }

  /// Rule-based fallback when API is unavailable
  CoachingInsight _fallbackInsight(List<HabitModel> habits) {
    final completedToday = habits.where((h) => h.isCompletedToday).length;
    final total = habits.length;
    final rate = total > 0 ? completedToday / total : 0.0;

    final streakAtRisk =
    habits.where((h) => h.streakCount > 3 && !h.isCompletedToday).toList();

    if (streakAtRisk.isNotEmpty) {
      final habit = streakAtRisk.first;
      return CoachingInsight(
        message:
        "Your ${habit.streakCount}-day streak on '${habit.title}' is at risk! Complete it today to keep the momentum going.",
        type: InsightType.warning,
        emoji: '⚠️',
      );
    }

    if (rate == 1.0) {
      return CoachingInsight(
        message:
        "Incredible! You've completed all your habits today. You're building unstoppable momentum! 🔥",
        type: InsightType.praise,
        emoji: '🏆',
      );
    }

    if (rate >= 0.5) {
      return CoachingInsight(
        message:
        "You're halfway there! Keep pushing — consistency is what separates dreamers from achievers.",
        type: InsightType.motivation,
        emoji: '💪',
      );
    }

    return CoachingInsight(
      message:
      "Every habit you complete today is a vote for the person you want to become. Start with just one!",
      type: InsightType.motivation,
      emoji: '✨',
    );
  }
}

enum InsightType {
  motivation,
  warning,
  praise,
  tip;

  static InsightType fromString(String value) {
    switch (value) {
      case 'warning':
        return InsightType.warning;
      case 'praise':
        return InsightType.praise;
      case 'tip':
        return InsightType.tip;
      default:
        return InsightType.motivation;
    }
  }
}

class CoachingInsight {
  final String message;
  final InsightType type;
  final String emoji;

  CoachingInsight({
    required this.message,
    required this.type,
    required this.emoji,
  });
}