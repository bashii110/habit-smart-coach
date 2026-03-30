// lib/providers/habit_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_habit_coach/models/habit_model.dart';

import '../components/app_constants.dart';
import '../firebase auth/habit_service.dart';
import '../firebase auth/notification_service.dart';

enum HabitStatus { initial, loading, loaded, error }

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();
  final NotificationService _notificationService = NotificationService();

  List<HabitModel> _habits = [];
  HabitStatus _status = HabitStatus.initial;
  String? _errorMessage;
  StreamSubscription? _subscription;
  Map<String, dynamic>? _analytics;
  bool _analyticsLoading = false;

  List<HabitModel> get habits => _habits;
  HabitStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == HabitStatus.loading;
  Map<String, dynamic>? get analytics => _analytics;
  bool get analyticsLoading => _analyticsLoading;

  List<HabitModel> get dailyHabits =>
      _habits.where((h) => h.frequency == AppConstants.frequencyDaily).toList();

  List<HabitModel> get weeklyHabits =>
      _habits
          .where((h) => h.frequency == AppConstants.frequencyWeekly)
          .toList();

  List<HabitModel> get completedTodayHabits =>
      _habits.where((h) => h.isCompletedToday).toList();

  List<HabitModel> get pendingTodayHabits =>
      _habits.where((h) => !h.isCompletedToday).toList();

  int get completedTodayCount => completedTodayHabits.length;
  int get totalHabitsCount => _habits.length;

  double get todayCompletionRate {
    if (_habits.isEmpty) return 0.0;
    return completedTodayCount / _habits.length;
  }

  void listenToHabits(String userId) {
    _status = HabitStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _habitService.habitsStream(userId).listen(
          (habits) {
        _habits = habits;
        _status = HabitStatus.loaded;
        _errorMessage = null;
        _cacheHabitCount(habits.length);
        notifyListeners();
      },
      onError: (e) {
        _setError(e.toString());
      },
    );
  }

  Future<void> addHabit(HabitModel habit) async {
    try {
      final id = await _habitService.addHabit(habit);
      if (habit.preferredTime != null) {
        final newHabit = habit.copyWith(id: id);
        await _notificationService.scheduleHabitReminder(newHabit);
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _habitService.updateHabit(habit);
      await _notificationService.cancelHabitReminder(habit.id);
      if (habit.preferredTime != null) {
        await _notificationService.scheduleHabitReminder(habit);
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitService.deleteHabit(habitId);
      await _notificationService.cancelHabitReminder(habitId);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Returns true if the habit was just marked complete,
  /// false if it was unmarked OR was already complete (no-op).
  Future<bool> toggleHabitCompletion(HabitModel habit) async {
    try {
      if (habit.isCompletedToday) {
        // Unmark completion
        final updated = await _habitService.unmarkComplete(habit);
        if (updated != null) {
          _updateLocalHabit(updated);
        }
        return false;
      } else {
        // Attempt to mark complete
        final updated = await _habitService.markComplete(habit);
        // ✅ markComplete returns null if already completed in Firestore
        if (updated == null) return false;
        _updateLocalHabit(updated);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void _updateLocalHabit(HabitModel updated) {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index != -1) {
      _habits[index] = updated;
      notifyListeners();
    }
  }

  Future<void> loadAnalytics(String userId) async {
    _analyticsLoading = true;
    notifyListeners();
    try {
      _analytics = await _habitService.getAnalytics(userId);
    } catch (e) {
      debugPrint('Analytics error: $e');
    } finally {
      _analyticsLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cacheHabitCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cached_habit_count', count);
    } catch (_) {}
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void clearHabits() {
    _habits = [];
    _status = HabitStatus.initial;
    _errorMessage = null;
    _analytics = null;
    stopListening();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = HabitStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}