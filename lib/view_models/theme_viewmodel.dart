import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get currentMode => _mode;

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    switch (_mode) {
      case ThemeMode.system:
        _mode = ThemeMode.dark;
        break;
      case ThemeMode.light:
        _mode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _mode = ThemeMode.light;
        break;
    }
    notifyListeners();
  }
}
