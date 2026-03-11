import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/analytics_viewmodel.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../widgets/chart_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.user != null) {
        context.read<AnalyticsViewModel>().fetchAnalytics(authVM.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer<AnalyticsViewModel>(
        builder: (context, analyticsVM, _) {
          if (analyticsVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final analytics = analyticsVM.analytics;
          if (analytics == null) {
            return const Center(child: Text('No analytics data'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This Week',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              '${analyticsVM.totalHours}:${analyticsVM.totalMinutes.toString().padLeft(2, '0')}',
                              'Study Hours',
                            ),
                            _buildStatCard('${analytics.tasksCompleted}', 'Tasks Done'),
                            _buildStatCard(
                              '${analytics.completionRate.toStringAsFixed(0)}%',
                              'Completion',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Study Time by Subject',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ChartWidget(studyTimeBySubject: analytics.studyTimeBySubject),
                const SizedBox(height: 24),
                const Text(
                  'Current Streaks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildStreakCard('📚', 'Study Days', '${analytics.currentStreak} days'),
                const SizedBox(height: 12),
                _buildStreakCard('⏱️', 'Daily Goal', '${analytics.currentStreak - 4} days'),
                const SizedBox(height: 12),
                _buildStreakCard('✅', 'Task Completion', '${analytics.currentStreak - 7} days'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStreakCard(String emoji, String label, String streak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(streak, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.trending_up, color: Colors.green),
          ],
        ),
      ),
    );
  }
}