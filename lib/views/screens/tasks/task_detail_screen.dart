import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/task_viewmodel.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _reflectionController = TextEditingController();
  int _difficultyRating = 3;
  int _confidenceRating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskVM, _) {
          final task =
              taskVM.tasks.where((t) => t.id == widget.taskId).firstOrNull;

          if (task == null) {
            return const Center(child: Text('Task not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Priority',
                            task.priority.toString().split('.').last),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                            'Status', task.status.toString().split('.').last),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Deadline',
                          '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Estimated Time',
                          '${task.estimatedDuration} minutes',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Post-Study Reflection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('How well did you understand this topic?'),
                const SizedBox(height: 16),
                const Text('Difficulty Level',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Easy'),
                    Text(_difficultyRating.toString()),
                    const Text('Hard'),
                  ],
                ),
                Slider(
                  value: _difficultyRating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() => _difficultyRating = value.toInt());
                  },
                ),
                const SizedBox(height: 16),
                const Text('Your Confidence',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Low'),
                    Text(_confidenceRating.toString()),
                    const Text('High'),
                  ],
                ),
                Slider(
                  value: _confidenceRating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() => _confidenceRating = value.toInt());
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _reflectionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts and reflection...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Reflection submitted successfully!')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Submit Reflection'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }
}
