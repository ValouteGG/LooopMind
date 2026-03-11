class ReflectionModel {
  final String id;
  final String userId;
  final String taskId;
  final String question;
  final String response;
  final int difficultyRating;
  final int confidenceRating;
  final DateTime createdAt;
  final String? aiSuggestion;

  ReflectionModel({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.question,
    required this.response,
    required this.difficultyRating,
    required this.confidenceRating,
    required this.createdAt,
    this.aiSuggestion,
  });
}