// import 'package:chat_app/themes/dark_mode.dart';
// import 'package:chat_app/themes/light_mode.dart';
// import 'package:flutter/material.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   ThemeData _themeData = lightMode;
//
//   ThemeData get themeData => _themeData;
//
//   bool get isDarkMode => _themeData == darkMode;
//
//   set themeData(ThemeData themeData) {
//     _themeData = themeData;
//     notifyListeners();
//   }
//
//   void toggleTheme() {
//     if (_themeData == lightMode) {
//       _themeData = darkMode;
//     } else {
//       _themeData = lightMode;
//     }
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeProvider() {
    _loadTheme(); // Load saved theme on startup
  }

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  void toggleTheme() async {
    _themeData = isDarkMode ? lightMode : darkMode;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDarkMode') ?? false;
    _themeData = isDark ? darkMode : lightMode;
    notifyListeners();
  }
}
