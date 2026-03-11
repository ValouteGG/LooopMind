import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../models/task_model.dart';
import '../../../view_models/task_viewmodel.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskCategory _selectedCategory = TaskCategory.other;
  int _estimatedDuration = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Task Title',
                hintText: 'e.g., Mathematics Chapter 5',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
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
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
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
                onChanged: (value) {
                  setState(() => _selectedPriority = value!);
                },
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
                onChanged: (value) {
                  setState(() => _estimatedDuration = value.toInt());
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Deadline', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
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
                      firstDate: DateTime.now(),
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
                  return CustomButton(
                    text: taskVM.isLoading ? 'Creating...' : 'Create Task',
                    isLoading: taskVM.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && authVM.user != null) {
                        final task = TaskModel(
                          id: const Uuid().v4(),
                          userId: authVM.user!.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          deadline: _selectedDeadline,
                          estimatedDuration: _estimatedDuration,
                          priority: _selectedPriority,
                          category: _selectedCategory,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        final success = await taskVM.createTask(task);
                        if (success && mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}