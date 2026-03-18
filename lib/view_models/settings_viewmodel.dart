import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _notificationsKey = 'notifications';
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';

  bool _notifications = true;
  bool _darkMode = false;
  String _language = 'en';

  bool get notifications => _notifications;
  bool get darkMode => _darkMode;
  String get language => _language;
  List<String> get supportedLanguages =>
      ['en', 'es', 'fr']; // English, Spanish, French

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notifications = prefs.getBool(_notificationsKey) ?? true;
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _language = prefs.getString(_languageKey) ?? 'en';
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _notifications = !_notifications;
    await prefs.setBool(_notificationsKey, _notifications);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = !_darkMode;
    await prefs.setBool(_darkModeKey, _darkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    _language = lang;
    await prefs.setString(_languageKey, _language);
    notifyListeners();
  }
}
