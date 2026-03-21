class WeeklySummaryModel {
  final String id;
  final String userId;
  final DateTime weekStart;
  final String summaryText;
  final double? completionRate;
  final int totalTasks;
  final int completedTasks;
  final DateTime generatedAt;

  WeeklySummaryModel({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.summaryText,
    this.completionRate,
    this.totalTasks = 0,
    this.completedTasks = 0,
    required this.generatedAt,
  });

  factory WeeklySummaryModel.fromJson(Map<String, dynamic> json) {
    return WeeklySummaryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weekStart: DateTime.parse(json['week_start'] as String),
      summaryText: json['summary_text'] as String,
      completionRate: (json['completion_rate'] as num?)?.toDouble(),
      totalTasks: json['total_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'week_start': weekStart.toIso8601String().split(' ')[0], // DATE
        'summary_text': summaryText,
        'completion_rate': completionRate,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'generated_at': generatedAt.toIso8601String(),
      };

  WeeklySummaryModel copyWith({
    String? id,
    String? userId,
    DateTime? weekStart,
    String? summaryText,
    double? completionRate,
    int? totalTasks,
    int? completedTasks,
    DateTime? generatedAt,
  }) {
    return WeeklySummaryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weekStart: weekStart ?? this.weekStart,
      summaryText: summaryText ?? this.summaryText,
      completionRate: completionRate ?? this.completionRate,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
