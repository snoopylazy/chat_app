import 'package:chat_app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBuddle extends StatelessWidget {
  const ChatBuddle({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  final String message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCurrentUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isCurrentUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isCurrentUser
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}