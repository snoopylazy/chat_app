import 'package:chat_app/components/chat_buddle.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chats/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String receivedEmail;
  final String receivedId;

  const ChatScreen({
    super.key,
    required this.receivedEmail,
    required this.receivedId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Track deleted message IDs locally for instant UI update
  Set<String> _deletedMessages = {};

  @override
  void initState() {
    super.initState();

    // Mark chat as read when opening
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _chatService.markChatAsReadOnOpen(currentUserId, widget.receivedId);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), scrollDown);
        // Mark as read when user focuses on input (actively engaging)
        _chatService.markChatAsReadOnOpen(currentUserId, widget.receivedId);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receivedId, _messageController.text);
      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollDown();
      });
    }
  }

  Future<void> _deleteMessageConfirm(DocumentSnapshot doc) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this message?"),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Delete")),
          ],
        );
      },
    );

    if (confirmed == true) {
      final currentUserId = _authService.getCurrentUser()!.uid;
      List<String> ids = [currentUserId, widget.receivedId];
      ids.sort();
      String chatRoomId = ids.join('_');

      await _chatService.deleteMessage(chatRoomId, doc.id);
      setState(() {
        _deletedMessages.add(doc.id);
      });
    }
  }

  Widget _buildUserAvatar(String userName, bool isOnline, bool isRecentlyActive) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          radius: 18,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Online status indicator
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(bottom: 1, right: 1),
          decoration: BoxDecoration(
            color: _getStatusColor(isOnline, isRecentlyActive),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 2,
            ),
            boxShadow: [
              if (isOnline)
                BoxShadow(
                  color: _getStatusColor(isOnline, isRecentlyActive).withOpacity(0.6),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: isOnline
              ? Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
              : null,
        ),
      ],
    );
  }

  Color _getStatusColor(bool isOnline, bool isRecentlyActive) {
    if (isOnline) {
      return Colors.green[500]!;
    } else if (isRecentlyActive) {
      return Colors.orange[500]!;
    } else {
      return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.receivedId)
              .snapshots(),
          builder: (context, snapshot) {
            final userName = widget.receivedEmail.split('@')[0];

            if (!snapshot.hasData) {
              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 18,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final bool isOnline = userData['isOnline'] ?? false;
            final bool isRecentlyActive = _authService.isRecentlyActive(userData);
            final String lastSeenText = _authService.getLastSeenText(userData);

            return Row(
              children: [
                _buildUserAvatar(userName, isOnline, isRecentlyActive),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lastSeenText,
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline
                              ? Colors.green[600]
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: isOnline ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                // Optional status badge
                if (isOnline || isRecentlyActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(isOnline, isRecentlyActive).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(isOnline, isRecentlyActive).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isOnline ? 'Online' : 'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(isOnline, isRecentlyActive),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Optional: Add a subtle divider
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = _authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(senderId, widget.receivedId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        final docs = snapshot.data!.docs.reversed.toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  "No messages yet",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Start the conversation!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(10.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(docs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    final bool isDeleted = (data['deleted'] ?? false) == true || _deletedMessages.contains(doc.id);

    // Use deletedByEmail to show friendly identifier
    String? removedBy = data['deletedByEmail'];
    if (removedBy == null || removedBy.isEmpty) {
      removedBy = 'Unknown';
    }

    return GestureDetector(
      onLongPress: () async {
        await Future.delayed(const Duration(seconds: 3));
        if (!isDeleted) {
          _deleteMessageConfirm(doc);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: ChatBuddle(
          key: ValueKey(doc.id),
          message: data['message'],
          isCurrentUser: isCurrentUser,
          isDeleted: isDeleted,
          removedBy: removedBy,
        ),
      ),
    );
  }

  Widget _buildUserInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => sendMessage(),
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: sendMessage,
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}