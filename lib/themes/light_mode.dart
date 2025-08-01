// light_mode.dart
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Colors.blue.shade600,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
    onSurface: Colors.black87,
    onPrimary: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue.shade600,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
    ),
  ),
);
