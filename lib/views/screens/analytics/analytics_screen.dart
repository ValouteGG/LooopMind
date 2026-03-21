import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/analytics_viewmodel.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../../models/weekly_summary_model.dart';

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
        context
            .read<AnalyticsViewModel>()
            .fetchWeeklySummaries(authVM.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Summaries')),
      body: Consumer<AnalyticsViewModel>(
        builder: (context, analyticsVM, _) {
          if (analyticsVM.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (analyticsVM.summaries.isEmpty)
            return const Center(child: Text('No summaries'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: analyticsVM.summaries.length,
            itemBuilder: (context, index) {
              final summary = analyticsVM.summaries[index];
              return Card(
                child: ListTile(
                  title: Text(
                      'Week of ${summary.weekStart.toLocal().toString().split(' ')[0]}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Completion: ${summary.completionRate?.toStringAsFixed(1) ?? 'N/A'}'),
                      Text(
                          '${summary.completedTasks}/${summary.totalTasks} tasks'),
                      Text(summary.summaryText),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
