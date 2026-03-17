import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/task_viewmodel.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.user != null) {
        context.read<TaskViewModel>().fetchTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoopMind'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: Consumer<TaskViewModel>(
              builder: (context, taskVM, _) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(taskVM.todaysTasks, context),
                    _buildTaskList(taskVM.upcomingTasks, context),
                    _buildTaskList(taskVM.completedTasks, context),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/create-task');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<dynamic> tasks, BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No tasks yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCard(
            title: task.title,
            description: task.description,
            priority: task.priority.toString().split('.').last,
            timeRemaining: _formatTimeRemaining(task.deadline),
            onTap: () {
              Navigator.of(context).pushNamed('/task-detail',
                  arguments: {'id': task.id, 'mode': 'view'});
            },
            onEdit: () {
              Navigator.of(context).pushNamed('/task-detail',
                  arguments: {'id': task.id, 'mode': 'edit'});
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content:
                      Text('Are you sure you want to delete "${task.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final taskVM = context.read<TaskViewModel>();
                final success = await taskVM.deleteTask(task.id);
                if (success) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Task deleted successfully')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to delete task')),
                    );
                  }
                }
              }
            },
          ),
        );
      },
    );
  }

  String _formatTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    } else {
      return 'Overdue';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
