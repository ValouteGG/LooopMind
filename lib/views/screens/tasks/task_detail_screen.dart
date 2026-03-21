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
  bool _initialized = false;
  late DateTime _selectedDeadline;
  late TaskPriority _selectedPriority;
  late bool _completed;
  late int _streakBonus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _selectedDeadline = DateTime.now();
    _selectedPriority = TaskPriority.medium;
    _completed = false;
    _streakBonus = 0;
  }

  void _initializeFields(TaskModel task) {
    _titleController.text = task.title;
    _descController.text = task.description ?? '';
    _selectedDeadline = task.deadline;
    _selectedPriority = task.priority;
    _completed = task.completed;
    _streakBonus = task.streakBonus;
  }

  Future<void> _deleteTask(TaskViewModel taskVM) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await taskVM.deleteTask(widget.taskId);
      if (success && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Task deleted')));
        Navigator.pop(context);
      }
    }
  }

  Widget _buildViewMode(TaskModel task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(task.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (task.description != null)
          Text(task.description!,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Priority',
                    task.priority.toString().split('.').last.toUpperCase()),
                const SizedBox(height: 12),
                _buildDetailRow('Completed', task.completed ? 'Yes' : 'No'),
                const SizedBox(height: 12),
                _buildDetailRow('Deadline',
                    '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}'),
                const SizedBox(height: 12),
                _buildDetailRow('Streak Bonus', '${task.streakBonus}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode(TaskModel task) {
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFields(task);
        setState(() => _initialized = true);
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
            hintText: 'Enter task title',
            validator: (value) =>
                value?.isEmpty ?? true ? 'Title required' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _descController,
            label: 'Description',
            hintText: 'Optional description',
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
                      child: Text(
                          priority.toString().split('.').last.toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedPriority = value!),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                  value: _completed,
                  onChanged: (value) => setState(() => _completed = value!)),
              const Text('Completed'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Streak Bonus',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('$_streakBonus'),
            ],
          ),
          Slider(
            value: _streakBonus.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) => setState(() => _streakBonus = value.toInt()),
          ),
          const SizedBox(height: 20),
          const Text('Deadline', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDeadline,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _selectedDeadline = picked);
              },
              child: Text(
                  '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}'),
            ),
          ),
          const SizedBox(height: 30),
          Consumer<TaskViewModel>(
            builder: (context, taskVM, _) => CustomButton(
              text: taskVM.isLoading ? 'Updating...' : 'Update Task',
              isLoading: taskVM.isLoading,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedTask = task.copyWith(
                    title: _titleController.text,
                    description: _descController.text.isEmpty
                        ? null
                        : _descController.text,
                    deadline: _selectedDeadline,
                    priority: _selectedPriority,
                    completed: _completed,
                    completedAt: _completed ? DateTime.now() : null,
                    streakBonus: _streakBonus,
                    updatedAt: DateTime.now(),
                  );
                  final success = await taskVM.updateTask(updatedTask);
                  if (success) Navigator.pop(context);
                }
              },
            ),
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
          if (taskVM.isLoading)
            return const Center(child: CircularProgressIndicator());
          final task = taskVM.tasks.firstWhere((t) => t.id == widget.taskId,
              orElse: () => throw Exception('Task not found'));
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
    super.dispose();
  }
}
