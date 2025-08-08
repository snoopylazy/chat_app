import 'package:chat_app/themes/theme_provider.dart';
import 'package:chat_app/modals/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBuddle extends StatelessWidget {
  const ChatBuddle({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.isDeleted = false,
    this.removedBy,
    this.timestamp,
    this.status = MessageStatus.sent,
    this.isEdited = false,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.replyToMessage,
  });

  final String message;
  final bool isCurrentUser;
  final bool isDeleted;
  final String? removedBy;
  final Timestamp? timestamp;
  final MessageStatus status;
  final bool isEdited;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final String? replyToMessage;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDeleted) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade200,
        ),
        child: Text(
          removedBy != null && removedBy!.isNotEmpty
              ? "Message removed by $removedBy"
              : "Message has been removed",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Reply message if exists
          if (replyToMessage != null && replyToMessage!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                replyToMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Main message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message text
                Text(
                  message,
                  style: TextStyle(
                    color: isCurrentUser
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.w400,
                  ),
                ),

                // Edited indicator
                if (isEdited)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'edited',
                      style: TextStyle(
                        color: isCurrentUser
                            ? Theme.of(
                                context,
                              ).colorScheme.onPrimary.withOpacity(0.7)
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Timestamp and status
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timestamp
                if (timestamp != null)
                  Text(
                    _formatTimestamp(timestamp!),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),

                const SizedBox(width: 8),

                // Status indicators (only for current user's messages)
                if (isCurrentUser) ...[_buildStatusIndicator(context)],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case MessageStatus.sent:
        iconData = Icons.check;
        iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all;
        iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        iconColor = Colors.blue;
        break;
      case MessageStatus.failed:
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
    }

    return Icon(iconData, size: 16, color: iconColor);
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, h:mm a').format(messageTime);
    } else if (difference.inHours > 0) {
      return DateFormat('h:mm a').format(messageTime);
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
