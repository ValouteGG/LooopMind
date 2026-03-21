import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final session = _supabase.auth.currentSession;
    if (session != null && session.user.id.isNotEmpty) {
      try {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', session.user.id)
            .maybeSingle();

        if (response != null) {
          _user = UserModel(
            id: response['id'] as String,
            email: response['email'] as String,
            currentStreak: (response['current_streak'] as int?) ?? 0,
            longestStreak: (response['longest_streak'] as int?) ?? 0,
            xpPoints: (response['xp_points'] as int?) ?? 0,
            avatarUrl: response['avatar_url'] as String?,
            createdAt: DateTime.parse(response['created_at'].toString()),
            updatedAt: DateTime.parse(response['updated_at'].toString()),
          );
        } else {
          // Fallback - insert basic user with required email
          final userEmail =
              session.user.email ?? 'user@${session.user.id.split('-')[0]}.com';
          await _supabase.from('users').upsert({
            'id': session.user.id,
            'email': userEmail,
          });
          _user = UserModel(
            id: session.user.id,
            email: userEmail,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      } catch (e) {
        print('User fetch error: $e');
        _user = UserModel(
          id: session.user.id,
          email: session.user.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } else {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await checkAuthStatus();
      return true;
    } on AuthException catch (e) {
      _error =
          e.message.contains('Invalid') ? 'Invalid credentials' : e.message;
      return false;
    } catch (e) {
      _error = 'Login failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // User table insert triggered by auth? Or upsert
        await _supabase.from('users').upsert({
          'id': response.user!.id,
          'email': email,
        });
        await checkAuthStatus();
        _error = 'Check email for confirmation';
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _error = 'Signup failed: ${e.message}';
      return false;
    } catch (e) {
      _error = 'Signup failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateUser(UserModel updatedUser) async {
    if (_user == null) return false;
    try {
      final data = {
        'id': updatedUser.id,
        'avatar_url': updatedUser.avatarUrl,
        // Add other fields if editable
        'updated_at': updatedUser.updatedAt.toIso8601String(),
      };
      await _supabase.from('users').upsert(data);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update failed: $e';
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
