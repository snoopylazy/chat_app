import 'package:chat_app/components/chat_buddle.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chats/chat_service.dart';
import 'package:chat_app/modals/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:async';
import 'package:chat_app/gen_l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String receivedEmail;
  final String receivedId;
  final String? chatRoomId;
  final bool isGroupChat;

  const ChatScreen({
    super.key,
    required this.receivedEmail,
    required this.receivedId,
    this.chatRoomId,
    this.isGroupChat = false,
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

  Set<String> _deletedMessages = {};
  bool _isTyping = false;
  Timer? _typingTimer;
  String? _replyToMessageId;
  String? _replyToMessageText;
  String? _replyToMessageSenderEmail;
  // String? _editingMessageId;
  // String? _editingMessageText;

  @override
  void initState() {
    super.initState();

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _chatService.markChatAsReadOnOpen(currentUserId, widget.receivedId);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), scrollDown);
        _chatService.markChatAsReadOnOpen(currentUserId, widget.receivedId);
      }
    });

    // Start typing indicator when user starts typing
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final chatRoomId =
        widget.chatRoomId ??
        _chatService.getChatRoomId(
          _authService.getCurrentUser()!.uid,
          widget.receivedId,
        );

    if (_messageController.text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      _chatService.setTypingStatus(chatRoomId, true);
    } else if (_messageController.text.isEmpty && _isTyping) {
      setState(() {
        _isTyping = false;
      });
      _chatService.setTypingStatus(chatRoomId, false);
    }

    // Reset typing timer
    _typingTimer?.cancel();
    if (_messageController.text.isNotEmpty) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          _chatService.setTypingStatus(chatRoomId, false);
        }
      });
    }
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
      final chatRoomId =
          widget.chatRoomId ??
          _chatService.getChatRoomId(
            _authService.getCurrentUser()!.uid,
            widget.receivedId,
          );

      await _chatService.sendMessage(
        widget.receivedId,
        _messageController.text,
        chatRoomId: chatRoomId,
        metadata: _replyToMessageSenderEmail == null
            ? null
            : {'replyToSenderEmail': _replyToMessageSenderEmail},
        replyToMessageId: _replyToMessageId,
        replyToMessageText: _replyToMessageText,
      );

      _messageController.clear();
      setState(() {
        _replyToMessageId = null;
        _replyToMessageText = null;
        _replyToMessageSenderEmail = null;
      });
      // Close keyboard
      _focusNode.unfocus();
      _chatService.setTypingStatus(chatRoomId, false);

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
          title: Text(AppLocalizations.of(context)!.deleteMessageTitle),
          content: Text(
            AppLocalizations.of(context)!.areYouSureYouWantToDeleteThisMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final currentUserId = _authService.getCurrentUser()!.uid;
      final chatRoomId =
          widget.chatRoomId ??
          _chatService.getChatRoomId(currentUserId, widget.receivedId);

      await _chatService.deleteMessage(chatRoomId, doc.id);
      setState(() {
        _deletedMessages.add(doc.id);
      });
    }
  }

  Future<void> _editMessage(DocumentSnapshot doc, String currentMessage) async {
    final TextEditingController editController = TextEditingController(
      text: currentMessage,
    );

    final String? newMessage = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editMessageTitle),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.edit,
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(editController.text),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );

    if (newMessage != null &&
        newMessage.isNotEmpty &&
        newMessage != currentMessage) {
      final currentUserId = _authService.getCurrentUser()!.uid;
      final chatRoomId =
          widget.chatRoomId ??
          _chatService.getChatRoomId(currentUserId, widget.receivedId);

      await _chatService.editMessage(chatRoomId, doc.id, newMessage);
    }
  }

  Widget _buildUserAvatar(
    String userName,
    bool isOnline,
    bool isRecentlyActive,
  ) {
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
                  color: _getStatusColor(
                    isOnline,
                    isRecentlyActive,
                  ).withOpacity(0.6),
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

            final userData =
                snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final bool isOnline = userData['isOnline'] ?? false;
            final bool isRecentlyActive = _authService.isRecentlyActive(
              userData,
            );
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lastSeenText,
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline
                              ? Colors.green[600]
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: isOnline
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOnline || isRecentlyActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        isOnline,
                        isRecentlyActive,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          isOnline,
                          isRecentlyActive,
                        ).withOpacity(0.3),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          // PopupMenuButton<String>(
          //   onSelected: (value) {
          //     switch (value) {
          //       case 'clear':
          //         _clearChat();
          //         break;
          //       case 'block':
          //         _blockUser();
          //         break;
          //     }
          //   },
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //       value: 'clear',
          //       child: Row(
          //         children: [
          //           Icon(Icons.clear_all),
          //           SizedBox(width: 8),
          //           Text(AppLocalizations.of(context)!.clearChat),
          //         ],
          //       ),
          //     ),
          //     PopupMenuItem(
          //       value: 'block',
          //       child: Row(
          //         children: [
          //           Icon(Icons.block),
          //           SizedBox(width: 8),
          //           Text(AppLocalizations.of(context)!.blockUser),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          Expanded(child: _buildMessageList()),
          _buildTypingIndicator(),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = _authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
        senderId,
        widget.receivedId,
        chatRoomId: widget.chatRoomId,
      ),
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
                  "${AppLocalizations.of(context)!.error}: ${snapshot.error}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
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
                  AppLocalizations.of(context)!.noMessagesYet,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.startTheConversation,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(10.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: _buildMessageItem(docs[index])),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    final bool isDeleted =
        (data['deleted'] ?? false) == true || _deletedMessages.contains(doc.id);
    final MessageStatus status = MessageStatus.values.firstWhere(
      (e) => e.name == (data['status'] ?? 'sent'),
      orElse: () => MessageStatus.sent,
    );
    final bool isEdited = (data['isEdited'] ?? false) == true;
    final Timestamp? timestamp = data['timestamp'];
    final Timestamp? editedAt = data['editedAt'];
    final String? replyToMessageText = data['replyToMessageText'];
    final String? replyToSender = data['senderEmail'];

    String? removedBy = data['deletedByEmail'];
    if (removedBy == null || removedBy.isEmpty) {
      removedBy = 'Unknown';
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptions(doc, data, isCurrentUser),
      child: ChatBuddle(
        key: ValueKey(doc.id),
        message: data['message'],
        isCurrentUser: isCurrentUser,
        isDeleted: isDeleted,
        removedBy: removedBy,
        timestamp: timestamp,
        deletedAt: data['deletedAt'],
        editedAt: editedAt,
        status: status,
        isEdited: isEdited,
        replyToMessage: replyToMessageText,
        replyToMessageSender:
            (replyToMessageText != null && replyToMessageText.isNotEmpty)
            ? (replyToSender?.split('@').first ?? '')
            : null,
      ),
    );
  }

  void _showMessageOptions(
    DocumentSnapshot doc,
    Map<String, dynamic> data,
    bool isCurrentUser,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentUser && (data['deleted'] != true)) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(AppLocalizations.of(context)!.edit),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(doc, data['message']);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(AppLocalizations.of(context)!.delete),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessageConfirm(doc);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.reply),
                title: Text(AppLocalizations.of(context)!.reply),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyToMessageId = doc.id;
                    _replyToMessageText = data['message'] ?? '';
                    _replyToMessageSenderEmail = data['senderEmail'] as String?;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    final chatRoomId =
        widget.chatRoomId ??
        _chatService.getChatRoomId(
          _authService.getCurrentUser()!.uid,
          widget.receivedId,
        );

    return StreamBuilder<Map<String, bool>>(
      stream: _chatService.getTypingStatusStream(chatRoomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final typingUsers = snapshot.data!;
        final currentUserEmail = _authService.getCurrentUser()!.email!;
        typingUsers.remove(currentUserEmail);

        if (typingUsers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${typingUsers.keys.first} is typing...}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
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
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () => _showAttachmentOptions(),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_replyToMessageText != null &&
                      _replyToMessageText!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _replyToMessageText!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() {
                              _replyToMessageId = null;
                              _replyToMessageText = null;
                            }),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
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
                        hintText: AppLocalizations.of(context)!.typeAMessage,
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
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
                ],
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(AppLocalizations.of(context)!.image),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement image picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_present),
                title: Text(AppLocalizations.of(context)!.file),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement file picker
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.searchMessages),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchMessagesHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (searchController.text.isNotEmpty) {
                  _searchMessages(searchController.text);
                }
              },
              child: Text(AppLocalizations.of(context)!.search),
            ),
          ],
        );
      },
    );
  }

  void _searchMessages(String query) {
    // TODO: Implement message search functionality
  }

  void _clearChat() {
    // TODO: Implement clear chat functionality
  }

  void _blockUser() {
    // TODO: Implement block user functionality
  }
}
