import 'package:flutter/material.dart';
import '../models/analytics_model.dart';

class AnalyticsViewModel extends ChangeNotifier {
  AnalyticsModel? _analytics;
  bool _isLoading = false;
  String? _error;

  AnalyticsModel? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalHours {
    return (_analytics?.totalStudyMinutes ?? 0) ~/ 60;
  }

  int get totalMinutes {
    return (_analytics?.totalStudyMinutes ?? 0) % 60;
  }

  Future<void> fetchAnalytics(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate fetch delay
      await Future.delayed(const Duration(milliseconds: 800));

      _analytics = AnalyticsModel(
        userId: userId,
        weekStart: DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
        totalStudyMinutes: 750,
        tasksCompleted: 8,
        completionRate: 92.0,
        studyTimeBySubject: {
          'Mathematics': 510,
          'Science': 360,
          'Languages': 270,
          'History': 180,
        },
        currentStreak: 12,
        dailyMinutes: [120, 150, 90, 180, 100, 110, 0],
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch analytics: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}