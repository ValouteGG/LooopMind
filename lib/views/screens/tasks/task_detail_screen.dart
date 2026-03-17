import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task_model.dart';
import '../../../view_models/task_viewmodel.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final String mode;

  const TaskDetailScreen({Key? key, required this.taskId, this.mode = 'view'})
      : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _reflectionController;
  bool _initialized = false;
  int _difficultyRating = 3;
  int _confidenceRating = 3;

  late DateTime _selectedDeadline;
  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;
  late TaskCategory _selectedCategory;
  late int _estimatedDuration;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _reflectionController = TextEditingController();
    _selectedDeadline = DateTime.now();
    _selectedPriority = TaskPriority.medium;
    _selectedStatus = TaskStatus.pending;
    _selectedCategory = TaskCategory.other;
    _estimatedDuration = 60;
  }

  void _initializeFields(TaskModel task) {
    _titleController.text = task.title;
    _descController.text = task.description;
    _selectedDeadline = task.deadline;
    _selectedPriority = task.priority;
    _selectedStatus = task.status;
    _selectedCategory = task.category;
    _estimatedDuration = task.estimatedDuration;
  }

  Future<void> _deleteTask(TaskViewModel taskVM) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await taskVM.deleteTask(widget.taskId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete task')),
          );
        }
      }
    }
  }

  Widget _buildViewMode(TaskModel task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                _buildDetailRow(
                    'Priority', task.priority.toString().split('.').last),
                const SizedBox(height: 12),
                _buildDetailRow(
                    'Status', task.status.toString().split('.').last),
                const SizedBox(height: 12),
                _buildDetailRow('Deadline',
                    '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}'),
                const SizedBox(height: 12),
                _buildDetailRow(
                    'Estimated Time', '${task.estimatedDuration} minutes'),
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
          onChanged: (value) =>
              setState(() => _difficultyRating = value.toInt()),
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
          onChanged: (value) =>
              setState(() => _confidenceRating = value.toInt()),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _reflectionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Share your thoughts and reflection...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Reflection submitted successfully!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Submit Reflection'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode(TaskModel task) {
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFields(task);
        if (mounted) setState(() => _initialized = true);
      });
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _titleController,
            label: 'Task Title',
            hintText: 'e.g., Mathematics - Calculus',
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Title is required';
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _descController,
            label: 'Description',
            hintText: 'Add more details about the task',
          ),
          const SizedBox(height: 20),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButton<TaskCategory>(
            value: _selectedCategory,
            isExpanded: true,
            items: TaskCategory.values
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value!),
          ),
          const SizedBox(height: 20),
          const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButton<TaskPriority>(
            value: _selectedPriority,
            isExpanded: true,
            items: TaskPriority.values
                .map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.toString().split('.').last),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedPriority = value!),
          ),
          const SizedBox(height: 20),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButton<TaskStatus>(
            value: _selectedStatus,
            isExpanded: true,
            items: TaskStatus.values
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedStatus = value!),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Duration (minutes)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('$_estimatedDuration min'),
            ],
          ),
          Slider(
            value: _estimatedDuration.toDouble(),
            min: 15,
            max: 240,
            divisions: 45,
            label: '$_estimatedDuration min',
            onChanged: (value) =>
                setState(() => _estimatedDuration = value.toInt()),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Deadline',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                  '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDeadline,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _selectedDeadline = picked);
                }
              },
              child: const Text('Change Deadline'),
            ),
          ),
          const SizedBox(height: 30),
          Consumer2<TaskViewModel, AuthViewModel>(
            builder: (context, taskVM, authVM, _) {
              if (taskVM.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomButton(
                text: taskVM.isLoading ? 'Updating...' : 'Update Task',
                isLoading: taskVM.isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedTask = task.copyWith(
                      title: _titleController.text,
                      description: _descController.text,
                      deadline: _selectedDeadline,
                      estimatedDuration: _estimatedDuration,
                      priority: _selectedPriority,
                      status: _selectedStatus,
                      category: _selectedCategory,
                      updatedAt: DateTime.now(),
                    );
                    final success = await taskVM.updateTask(updatedTask);
                    if (success) {
                      if (mounted) Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Error: ${taskVM.error ?? 'Update failed'}')),
                      );
                      taskVM.clearError();
                    }
                  }
                },
              );
            },
          ),
        ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == 'edit' ? 'Edit Task' : 'Task Details'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: widget.mode == 'edit'
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    final taskVM = context.read<TaskViewModel>();
                    _deleteTask(taskVM);
                  },
                ),
              ]
            : null,
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskVM, _) {
          if (taskVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final task =
              taskVM.tasks.where((t) => t.id == widget.taskId).firstOrNull;
          if (task == null) {
            return const Center(child: Text('Task not found'));
          }
          if (taskVM.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${taskVM.error}')),
              );
              taskVM.clearError();
            });
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: widget.mode == 'edit'
                ? _buildEditMode(task)
                : _buildViewMode(task),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }
}
