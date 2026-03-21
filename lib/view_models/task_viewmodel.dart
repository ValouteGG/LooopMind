import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_model.dart';

class TaskViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<TaskModel> _tasks = [];
  TaskModel? _selectedTask;
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  TaskModel? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TaskModel> get todaysTasks {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return _tasks
        .where((task) => task.deadline.isBefore(endOfToday) && !task.completed)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();
    return _tasks
        .where((task) => task.deadline.isAfter(now) && !task.completed)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<TaskModel> get completedTasks {
    return _tasks.where((task) => task.completed).toList();
  }

  Future<void> fetchTasks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('deadline', ascending: true);

      _tasks =
          response.map<TaskModel>((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      _error = 'Failed to fetch tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(TaskModel task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _supabase.from('tasks').insert(task.toJson()).select().single();
      final newTask = TaskModel.fromJson(response);
      _tasks.insert(0, newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create task: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _updateStreaksAndXP(task.userId, task.priority, task.streakBonus);

      final response = await _supabase
          .from('tasks')
          .upsert(task.toJson())
          .eq('id', task.id)
          .select()
          .single();

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = TaskModel.fromJson(response);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update task: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateStreaksAndXP(
      String userId, TaskPriority priority, int bonus) async {
    try {
      final int priorityXP = switch (priority) {
        TaskPriority.low => 10,
        TaskPriority.medium => 25,
        TaskPriority.high => 50,
      };
      final int totalXP = priorityXP + bonus;

      final user = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single() as Map<String, dynamic>;
      final int currentXP = user['xp_points'] as int? ?? 0;
      final int currentStreak = user['current_streak'] as int? ?? 0;

      // Check for overdue tasks
      final now = DateTime.now();
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final overdueResponse = await _supabase
          .from('tasks')
          .select('id')
          .eq('user_id', userId)
          .not('completed', 'eq', true)
          .lt('deadline', endOfToday.toIso8601String());
      final bool hasOverdue = overdueResponse.isNotEmpty;

      await _supabase.from('users').update({
        'xp_points': currentXP + totalXP,
        'current_streak': hasOverdue ? 0 : currentStreak + 1,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      print('Stats update failed: $e');
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete task: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
