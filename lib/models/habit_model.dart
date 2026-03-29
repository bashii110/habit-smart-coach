// lib/models/habit_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/app_constants.dart';
import '../utility helpers/data_utils.dart';

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String frequency; // daily | weekly
  final String? preferredTime; // HH:mm format
  int streakCount;
  List<DateTime> completedDates;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? iconEmoji;
  final String? colorHex;
  final List<String> completionHours; // For smart insights

  HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.frequency = AppConstants.frequencyDaily,
    this.preferredTime,
    this.streakCount = 0,
    List<DateTime>? completedDates,
    required this.createdAt,
    this.updatedAt,
    this.iconEmoji,
    this.colorHex,
    List<String>? completionHours,
  })  : completedDates = completedDates ?? [],
        completionHours = completionHours ?? [];

  bool get isCompletedToday {
    return completedDates.any(
          (date) => AppDateUtils.isToday(date),
    );
  }

  String? get smartTimeSuggestion {
    if (completionHours.isEmpty) return null;
    final hourCounts = <int, int>{};
    for (final hourStr in completionHours) {
      final hour = int.tryParse(hourStr);
      if (hour != null) {
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }
    if (hourCounts.isEmpty) return null;
    final mostActiveHour =
        hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final period = mostActiveHour >= 12 ? 'PM' : 'AM';
    final displayHour =
    mostActiveHour > 12 ? mostActiveHour - 12 : mostActiveHour;
    return 'You usually complete this at ${displayHour == 0 ? 12 : displayHour}:00 $period';
  }

  double get completionRateThisWeek {
    final last7Days = AppDateUtils.getLast7Days();
    if (frequency == AppConstants.frequencyDaily) {
      int completedCount = 0;
      for (final day in last7Days) {
        if (completedDates.any((d) => AppDateUtils.isSameDay(d, day))) {
          completedCount++;
        }
      }
      return completedCount / 7;
    }
    return 0.0;
  }

  String get streakLabel {
    if (streakCount >= AppConstants.streakGold) return '🥇 Gold Streak';
    if (streakCount >= AppConstants.streakSilver) return '🥈 Silver Streak';
    if (streakCount >= AppConstants.streakBronze) return '🥉 Bronze Streak';
    if (streakCount > 0) return '🔥 $streakCount day streak';
    return 'No streak yet';
  }

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      frequency: data['frequency'] ?? AppConstants.frequencyDaily,
      preferredTime: data['preferredTime'],
      streakCount: data['streakCount'] ?? 0,
      completedDates: (data['completedDates'] as List<dynamic>?)
          ?.map((e) {
        if (e is Timestamp) return e.toDate();
        if (e is String) return DateTime.parse(e);
        return DateTime.now();
      })
          .toList() ??
          [],
      createdAt:
      (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      iconEmoji: data['iconEmoji'],
      colorHex: data['colorHex'],
      completionHours:
      (data['completionHours'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'frequency': frequency,
      'preferredTime': preferredTime,
      'streakCount': streakCount,
      'completedDates':
      completedDates.map((d) => Timestamp.fromDate(d)).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'iconEmoji': iconEmoji,
      'colorHex': colorHex,
      'completionHours': completionHours,
    };
  }

  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? frequency,
    String? preferredTime,
    int? streakCount,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? iconEmoji,
    String? colorHex,
    List<String>? completionHours,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      preferredTime: preferredTime ?? this.preferredTime,
      streakCount: streakCount ?? this.streakCount,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      colorHex: colorHex ?? this.colorHex,
      completionHours: completionHours ?? this.completionHours,
    );
  }

  @override
  String toString() {
    return 'HabitModel(id: $id, title: $title, streak: $streakCount)';
  }
}