import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

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
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .maybeSingle(); // Use maybeSingle to handle missing profile

        if (response != null) {
          _user = UserModel(
            id: response['id'] as String,
            email: session.user.email ?? '',
            name: response['name'] as String? ?? '',
            photoUrl: response['photo_url'] as String?,
            createdAt: DateTime.parse(response['created_at'].toString()),
            updatedAt: DateTime.parse(response['updated_at'].toString()),
          );
        } else {
          _user = UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            name: '',
            photoUrl: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      } catch (e) {
        print('Profile fetch error: $e');
        // Fallback user without profile
        _user = UserModel(
          id: session.user.id,
          email: session.user.email ?? '',
          name: '',
          photoUrl: null,
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
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('Invalid password')) {
        _error = 'Incorrect email or password';
      } else {
        _error = 'Login failed: ${e.message}';
      }
      return false;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'name': name,
        });
        _error =
            'Signup successful! Please check your email to confirm your account.';
      } else {
        _error =
            'Signup response missing user. Check Supabase settings (email confirmation may be enabled).';
        return false;
      }

      await checkAuthStatus();
      return true;
    } on AuthException catch (e) {
      if (e.message.contains('already registered') ||
          e.message.contains('duplicate key') ||
          e.message.contains('already exists')) {
        _error = 'User already exists';
      } else {
        _error = 'Sign up failed: ${e.message}';
      }
      return false;
    } catch (e) {
      _error = 'Sign up failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = 'Logout failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser(String name) async {
    if (_user == null) return false;
    try {
      await _supabase
          .from('profiles')
          .upsert({'id': _user!.id, 'name': name}).eq('id', _user!.id);

      _user = _user!.copyWith(name: name, updatedAt: DateTime.now());
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update failed: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
