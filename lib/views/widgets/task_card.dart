import 'package:flutter/material.dart';
import '../../../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onMarkDone;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    this.onMarkDone,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.low:
        return Colors.green.shade400;
    }
  }

  String _formatTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    if (difference.isNegative) return '⏰ Overdue!';
    if (difference.inDays > 0) return '📅 ${difference.inDays}d';
    if (difference.inHours > 0) return '⏳ ${difference.inHours}h';
    return '⚡ Today';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final priorityColor = _getPriorityColor(task.priority);
    final cardBg = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(2),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                task.completed ? 12.0 : 20.0,
                task.completed ? 12.0 : 20.0,
                task.completed ? 56.0 : 20.0,
                20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Icon(
                          task.completed ? Icons.emoji_events : Icons.school,
                          color: priorityColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (task.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description!,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                task.priority
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: textColor.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimeRemaining(task.deadline),
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      if (task.streakBonus > 0) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(' +${task.streakBonus}',
                            style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                  if (!task.completed) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onMarkDone,
                            icon: const Icon(Icons.check,
                                size: 16, color: Colors.green),
                            label: const Text('Done',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.green, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon:
                                Icon(Icons.edit, size: 16, color: primaryColor),
                            label: Text('Edit',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (task.completed)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.shade400, size: 24),
                  onPressed: onDelete,
                  tooltip: 'Remove task',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
