enum TaskPriority { low, medium, high }
enum TaskStatus { pending, inProgress, completed }
enum TaskCategory { mathematics, science, languages, history, arts, other }

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime deadline;
  final int estimatedDuration;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRecurring;
  final String? recurrencePattern;
  final List<String> tags;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.estimatedDuration,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    required this.createdAt,
    required this.updatedAt,
    this.isRecurring = false,
    this.recurrencePattern,
    this.tags = const [],
  });

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? deadline,
    int? estimatedDuration,
    TaskPriority? priority,
    TaskStatus? status,
    TaskCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurrencePattern,
    List<String>? tags,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      tags: tags ?? this.tags,
    );
  }
}