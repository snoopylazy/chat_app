import 'package:chat_app/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.dark_mode,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Dark Mode",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return CupertinoSwitch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Chat App v1.0",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}