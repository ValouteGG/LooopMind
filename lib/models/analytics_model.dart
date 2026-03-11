class AnalyticsModel {
  final String userId;
  final DateTime weekStart;
  final int totalStudyMinutes;
  final int tasksCompleted;
  final double completionRate;
  final Map<String, int> studyTimeBySubject;
  final int currentStreak;
  final List<int> dailyMinutes;

  AnalyticsModel({
    required this.userId,
    required this.weekStart,
    required this.totalStudyMinutes,
    required this.tasksCompleted,
    required this.completionRate,
    required this.studyTimeBySubject,
    required this.currentStreak,
    required this.dailyMinutes,
  });
}