enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime deadline;
  final TaskPriority priority;
  final bool completed;
  final DateTime? completedAt;
  final int streakBonus;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.deadline,
    this.priority = TaskPriority.medium,
    this.completed = false,
    this.completedAt,
    this.streakBonus = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      priority: TaskPriority.values.byName(json['priority'] as String),
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      streakBonus: json['streak_bonus'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'priority': priority.name,
        'completed': completed,
        'completed_at': completedAt?.toIso8601String(),
        'streak_bonus': streakBonus,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    bool? completed,
    DateTime? completedAt,
    int? streakBonus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      streakBonus: streakBonus ?? this.streakBonus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
