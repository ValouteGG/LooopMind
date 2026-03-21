import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/weekly_summary_model.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<WeeklySummaryModel> _summaries = [];
  bool _isLoading = false;
  String? _error;

  List<WeeklySummaryModel> get summaries => _summaries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeeklySummaries(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('weekly_summaries')
          .select()
          .eq('user_id', userId)
          .order('week_start', ascending: false)
          .limit(4); // Last 4 weeks

      _summaries = response
          .map<WeeklySummaryModel>((json) => WeeklySummaryModel.fromJson(json))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch summaries: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
