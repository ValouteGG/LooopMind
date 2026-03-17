import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskViewModel extends ChangeNotifier {
  final List<TaskModel> _tasks = [];
  TaskModel? _selectedTask;
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  TaskModel? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TaskModel> get todaysTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((task) {
      final deadline =
          DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      return deadline.compareTo(today) == 0;
    }).toList();
  }

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();
    return _tasks
        .where((task) =>
            task.deadline.isAfter(now) && task.status != TaskStatus.completed)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<TaskModel> get completedTasks {
    return _tasks.where((task) => task.status == TaskStatus.completed).toList();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate fetch delay
      await Future.delayed(const Duration(milliseconds: 800));

      _tasks.clear();
      _tasks.addAll([
        TaskModel(
          id: const Uuid().v4(),
          userId: 'demo',
          title: 'Mathematics - Calculus',
          description: 'Chapter 5: Derivatives and Applications',
          deadline: DateTime.now().add(const Duration(days: 2)),
          estimatedDuration: 120,
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          category: TaskCategory.mathematics,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TaskModel(
          id: const Uuid().v4(),
          userId: 'demo',
          title: 'History Essay',
          description: 'World War II: Causes and Consequences',
          deadline: DateTime.now().add(const Duration(days: 4)),
          estimatedDuration: 180,
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          category: TaskCategory.history,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TaskModel(
          id: const Uuid().v4(),
          userId: 'demo',
          title: 'Chemistry Lab',
          description: 'Organic Synthesis Experiment',
          deadline: DateTime.now().add(const Duration(days: 7)),
          estimatedDuration: 150,
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          category: TaskCategory.science,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch tasks: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(TaskModel task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate create delay
      await Future.delayed(const Duration(milliseconds: 500));

      _tasks.add(task);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create task: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate update delay
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update task: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate delete delay
      await Future.delayed(const Duration(milliseconds: 500));

      _tasks.removeWhere((t) => t.id == taskId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete task: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectTask(TaskModel task) {
    _selectedTask = task;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
