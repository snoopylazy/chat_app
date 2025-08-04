import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
        fontFamily: 'Battambang',
        colorScheme: ColorScheme.dark(
                surface: Colors.grey.shade900,
                primary: Colors.blue.shade400,
                secondary: Colors.grey.shade800,
                tertiary: Colors.grey.shade700,
                inversePrimary: Colors.grey.shade300,
                onSurface: Colors.white70,
                onPrimary: Colors.black,
        ),
        appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey.shade900,
                foregroundColor: Colors.white70,
                elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.black,
                ),
        ),
);