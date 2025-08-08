import 'package:chat_app/modals/chat_room.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chats/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupChatTile extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GroupChatTile({
    super.key,
    required this.chatRoom,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _getChatPreviewStream(),
      builder: (context, snapshot) {
        final previewText = snapshot.data?['message'] ?? 'No messages';
        final isUnread = snapshot.data?['isUnread'] ?? false;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isUnread
                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isUnread
                ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: _buildGroupAvatar(),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    chatRoom.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: isUnread
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildParticipantCount(),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (isUnread) ...[
                      Icon(
                        Icons.fiber_manual_record,
                        color: Theme.of(context).colorScheme.primary,
                        size: 8,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        previewText.isEmpty ? 'No messages' : previewText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isUnread
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${chatRoom.participants.length} participants',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUnread)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 8,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        );
      },
    );
  }

  Widget _buildGroupAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.group, color: Colors.white, size: 24),
    );
  }

  Widget _buildParticipantCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Text(
        '${chatRoom.participants.length}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Stream<Map<String, dynamic>> _getChatPreviewStream() {
    final currentUserId = AuthService().getCurrentUser()!.uid;

    return FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(chatRoom.id)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .asyncExpand((msgSnap) {
          return FirebaseFirestore.instance
              .collection('ChatRooms')
              .doc(chatRoom.id)
              .collection('ReadStatus')
              .doc(currentUserId)
              .snapshots()
              .map((readSnap) {
                final lastMsg = msgSnap.docs.isNotEmpty
                    ? msgSnap.docs.first.data()
                    : null;
                final readData = readSnap.data();

                Timestamp? lastRead;
                if (readSnap.exists &&
                    readData != null &&
                    readData['lastRead'] != null) {
                  lastRead = readData['lastRead'] as Timestamp;
                }

                bool isUnread = false;
                String messageText = '';

                if (lastMsg != null) {
                  messageText = lastMsg['message'] ?? '';
                  final msgTimestamp = lastMsg['timestamp'] as Timestamp;
                  final senderId = lastMsg['senderID'] as String;

                  if (senderId != currentUserId) {
                    if (lastRead == null) {
                      isUnread = true;
                    } else {
                      isUnread = msgTimestamp.compareTo(lastRead) > 0;
                    }
                  }
                }

                return {'message': messageText, 'isUnread': isUnread};
              });
        });
  }
}
