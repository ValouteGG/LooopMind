import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class GroqService {
  static final GroqService _instance = GroqService._internal();
  factory GroqService() => _instance;
  GroqService._internal();

  static const String _apiKey =
      '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';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<Map<String, dynamic>> _fetchWeeklyStats(String userId) async {
    try {
      // Try existing RPC first
      final List<dynamic> stats =
          await Supabase.instance.client.rpc('get_weekly_stats', params: {
        'p_user_id': userId,
        'p_week_start': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String()
            .split('T')[0],
      });

      if (stats.isNotEmpty) {
        return stats[0] as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) print('RPC failed, using manual query: $e');
    }

    try {
      // Manual fallback query
      final weekStart = DateTime.now().subtract(const Duration(days: 7));
      final now = DateTime.now();
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final List<Map<String, dynamic>> allTasks = await Supabase.instance.client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .gte('created_at', weekStart.toIso8601String())
          .order('deadline');
      final List<Map<String, dynamic>> overdueTasks = allTasks
          .where((t) =>
              !t['completed'] &&
              DateTime.parse(t['deadline']).isBefore(endOfToday))
          .toList();
      final bool hasOverdue = overdueTasks.isNotEmpty;
      final List<Map<String, dynamic>> tasks =
          allTasks.where((t) => t['completed']).toList().take(3).toList();

      final int totalTasks = allTasks.length;
      final int completedTasks =
          allTasks.where((t) => t['completed'] == true).length;
      final double completionRate =
          totalTasks > 0 ? completedTasks / totalTasks : 0.0;

      // Get streak and XP from user
      final Map<String, dynamic> userData = await Supabase.instance.client
              .from('users')
              .select('current_streak, xp_points')
              .eq('id', userId)
              .maybeSingle() as Map<String, dynamic>? ??
          {};

      return {
        'completion_rate': completionRate,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'current_streak': userData['current_streak'] ?? 0,
        'xp_points': userData['xp_points'] ?? 0,
        'tasks': tasks.map((t) => t['title']).toList(),
        'hasOverdue': hasOverdue,
      };
    } catch (e) {
      if (kDebugMode) print('Stats fetch error: $e');
      return {
        'completion_rate': 0.0,
        'current_streak': 0,
        'xp_points': 0,
        'hasOverdue': false
      };
    }
  }

  Future<String> generateWeeklySummary(String userPrompt) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        return 'Please log in to generate your personalized summary! 💪';
      }

      final stats = await _fetchWeeklyStats(userId);

      final statsText = '''
STREAK: ${stats['current_streak']} tasks (ended by late submission 😢)
XP: ${stats['xp_points']}
RECENT WINS: ${stats['tasks'].join(', ')}
COMPLETION: ${stats['completed_tasks']}/${stats['total_tasks']} (${(stats['completion_rate'] * 100).round()}%)
OVERDUE: ${stats['hasOverdue'] ? 'YES' : 'No'}
''';

      final prompt = '''
You are LoopMind Coach - motivational productivity assistant.

USER DATA:
$statsText

USER REQUEST: $userPrompt

Generate weekly summary:

📊 WEEKLY STATS
• Streak: You are on a \${stats['current_streak']} completion task streak \${stats['hasOverdue'] ? '⚠️ (streak ended due to late submission)' : '🔥'}
• XP Earned: \${stats['xp_points']} points
• Recent Wins: \${stats['tasks'].join(', ')}

🎯 HIGHLIGHTS
• You're on a roll with \${stats['current_streak']} task completion streak!
• \${stats['completion_rate'] < 0.5 ? '⚠️ STREAK BROKEN by overdue tasks - rebuild now!' : '[completion insight]'}
• \${stats['hasOverdue'] ? 'Prioritize overdue tasks TODAY!' : '[XP insight]'}

🚀 NEXT WEEK
• Complete all overdue tasks first!
• Hit \${stats['current_streak'] + 1} streak!

💬 MOTTO: "Missed deadlines break streaks - complete or reset! 🔥"

Keep casual with emojis. Plain text only.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim() ??
            'Could not generate summary.';
      } else {
        throw Exception(
            'Groq API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Groq Error: $e');
      return await _generateOfflineSummary();
    }
  }

  Future<String> _generateOfflineSummary() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return 'Login first! 💪';

      final weekStart = DateTime.now().subtract(const Duration(days: 7));
      final dynamic rawStats =
          await Supabase.instance.client.rpc('get_weekly_stats', params: {
        'p_user_id': userId,
        'p_week_start': weekStart.toIso8601String().split('T')[0],
      });
      final List<Map<String, dynamic>> stats = rawStats is List
          ? (rawStats as List).map((e) => Map<String, dynamic>.from(e)).toList()
          : [];

      if (stats.isNotEmpty) {
        final data = stats[0];
        final rate = ((data['completion_rate'] ?? 0) * 100).round();
        final streak = data['current_streak'] ?? 0;

        return '''
🔥 WEEKLY RECAP (Offline Mode)
${rate}% tasks completed | Streak: $streak tasks 
Overdue tasks break streaks - complete them now!
Check Stats tab for details! 💪
        ''';
      }
    } catch (e) {
      if (kDebugMode) print('Offline summary error: $e');
    }
    return 'Coach resting - check your streak! 🔥';
  }

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim() ??
            'Keep crushing those tasks! 🔥';
      } else {
        throw Exception('Groq API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Chat Error: $e');
      return 'LoopMind Coach: 😢 Sad your streak is over due to late submission! Complete overdue tasks to rebuild 🔥';
    }
  }
}
