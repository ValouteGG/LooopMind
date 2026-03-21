import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../view_models/task_viewmodel.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../../models/task_model.dart';
import '../../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoopMind'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => Navigator.pushNamed(context, '/chat')),
          IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      body: Consumer2<TaskViewModel, AuthViewModel>(
        builder: (context, taskVM, authVM, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTasksTab(taskVM.todaysTasks, taskVM),
              _buildTasksTab(taskVM.upcomingTasks, taskVM),
              _buildTasksTab(taskVM.completedTasks, taskVM),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-task'),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTasksTab(List<TaskModel> tasks, TaskViewModel taskVM) {
    if (taskVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (taskVM.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 80, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error: ${taskVM.error}',
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: taskVM.clearError,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get started with a new task!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TaskCard(
            task: task,
            onMarkDone: task.completed
                ? null
                : () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marking task as done...')),
                    );
                    final updatedTask = task.copyWith(
                      completed: true,
                      completedAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    final success = await taskVM.updateTask(updatedTask);
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task completed! 🎉'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Update failed: ${taskVM.error ?? "Unknown"}')),
                          );
                        }
                      }
                    });
                  },
            onEdit: () => Navigator.pushNamed(
              context,
              '/task-detail',
              arguments: {'id': task.id, 'mode': 'edit'},
            ),
            onDelete: () => _showDeleteDialog(context, task, taskVM),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, TaskModel task, TaskViewModel taskVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text('Delete Task')),
          ],
        ),
        content: Text('"${task.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting task...')),
              );
              final success = await taskVM.deleteTask(task.id);
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Delete failed: ${taskVM.error ?? "Unknown"}')),
                    );
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchTasks() async {
    if (!mounted) return;
    final taskVM = context.read<TaskViewModel>();
    final authVM = context.read<AuthViewModel>();
    if (authVM.isAuthenticated &&
        authVM.user?.id != null &&
        taskVM.tasks.isEmpty &&
        !taskVM.isLoading) {
      await taskVM.fetchTasks(authVM.user!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
