import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Demo credentials
  static const String demoEmail = 'demo@loopmind.com';
  static const String demoPassword = 'password123';

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    // Simulate checking auth status
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate login delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Demo login validation
      if (email == demoEmail && password == demoPassword) {
        _user = UserModel(
          id: 'user_123',
          email: email,
          name: 'Demo User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error =
            'Invalid email or password. Try demo@loopmind.com / password123';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate signup delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        _error = 'Please fill all fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate logout delay
      await Future.delayed(const Duration(milliseconds: 500));
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
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate update
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
