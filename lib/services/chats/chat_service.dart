import 'package:chat_app/modals/message.dart';
import 'package:chat_app/modals/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Typing indicators
  final Map<String, Timer> _typingTimers = {};
  final Map<String, StreamController<Map<String, bool>>> _typingControllers =
      {};

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // Get only users that current user has chatted with
  Stream<List<Map<String, dynamic>>> getChatUsersStream() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('ChatRooms')
        .where('participants', arrayContains: currentUserId)
        .where('type', isEqualTo: 'direct')
        .snapshots()
        .asyncExpand((chatRoomsSnapshot) {
          if (chatRoomsSnapshot.docs.isEmpty) {
            return Stream.value(<Map<String, dynamic>>[]);
          }

          Set<String> otherUserIds = {};
          for (var doc in chatRoomsSnapshot.docs) {
            List<String> participants = List<String>.from(
              doc.data()['participants'] ?? [],
            );
            for (String userId in participants) {
              if (userId != currentUserId) {
                otherUserIds.add(userId);
              }
            }
          }

          if (otherUserIds.isEmpty) {
            return Stream.value(<Map<String, dynamic>>[]);
          }

          return _firestore
              .collection('Users')
              .where('uid', whereIn: otherUserIds.toList())
              .snapshots()
              .map((userSnapshot) {
                return userSnapshot.docs.map((doc) => doc.data()).toList();
              });
        });
  }

  // Get group chat rooms
  Stream<List<ChatRoom>> getGroupChatRoomsStream() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('ChatRooms')
        .where('participants', arrayContains: currentUserId)
        .where('type', isEqualTo: 'group')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ChatRoom.fromMap(data);
          }).toList();
        });
  }

  // Add user to chat list
  Future<Map<String, dynamic>> addUserToChat(String email) async {
    try {
      final String currentUserId = _auth.currentUser!.uid;

      final userQuery = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return {
          'success': false,
          'message':
              'User with email "$email" not found. Make sure they have an account.',
        };
      }

      final otherUserData = userQuery.docs.first.data();
      final otherUserId =
          (otherUserData['uid'] as String?) ?? userQuery.docs.first.id;

      final ids = [currentUserId, otherUserId]..sort();
      final chatRoomId = ids.join('_');

      final existingChatRoom = await _firestore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .get();

      if (existingChatRoom.exists) {
        return {
          'success': false,
          'message': 'You are already connected with this user.',
        };
      }

      // Create chat room
      await _firestore.collection('ChatRooms').doc(chatRoomId).set({
        'id': chatRoomId,
        'name': '', // Will be auto-generated for direct chats
        'type': 'direct',
        'participants': ids,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserId,
        'lastActivity': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return {'success': true, 'message': 'User added successfully!'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error adding user: ${e.toString()}',
      };
    }
  }

  // Create group chat
  Future<Map<String, dynamic>> createGroupChat(
    String name,
    List<String> participantEmails,
  ) async {
    try {
      final String currentUserId = _auth.currentUser!.uid;
      final Set<String> participantIds = {currentUserId};

      // Get user IDs from emails
      for (String email in participantEmails) {
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: email.toLowerCase())
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final data = userQuery.docs.first.data();
          final uid = (data['uid'] as String?) ?? userQuery.docs.first.id;
          participantIds.add(uid);
        }
      }

      if (participantIds.length < 3) {
        return {
          'success': false,
          'message': 'Group chat must have at least 3 participants.',
        };
      }

      final chatRoomId = _firestore.collection('ChatRooms').doc().id;

      await _firestore.collection('ChatRooms').doc(chatRoomId).set({
        'id': chatRoomId,
        'name': name,
        'type': 'group',
        'participants': participantIds.toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserId,
        'lastActivity': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return {
        'success': true,
        'message': 'Group chat created successfully!',
        'chatRoomId': chatRoomId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating group chat: ${e.toString()}',
      };
    }
  }

  // Send message with enhanced features
  Future<void> sendMessage(
    String receiverId,
    String message, {
    String? chatRoomId,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverId,
      message: message,
      timestamp: timestamp,
      status: MessageStatus.sent,
      type: type,
      metadata: metadata,
      chatRoomId: chatRoomId,
    );

    String roomId = chatRoomId ?? getChatRoomId(currentUserID, receiverId);

    // Prepare room updates (do not touch participants for existing group rooms)
    final Map<String, dynamic> roomUpdate = {
      'lastActivity': FieldValue.serverTimestamp(),
      'lastMessage': message,
      'lastMessageSender': currentUserEmail,
      'lastMessageTime': timestamp,
    };

    if (chatRoomId == null) {
      // Direct chat case; ensure participants are the two users and type is direct
      roomUpdate['participants'] = [currentUserID, receiverId]..sort();
      roomUpdate['type'] = 'direct';
    } else {
      // Group chat; DO NOT modify participants or type
    }

    await _firestore
        .collection('ChatRooms')
        .doc(roomId)
        .set(roomUpdate, SetOptions(merge: true));

    // Send the message
    final messageRef = await _firestore
        .collection('ChatRooms')
        .doc(roomId)
        .collection('Messages')
        .add(newMessage.toMap());

    // Update message with delivery status
    await _firestore
        .collection('ChatRooms')
        .doc(roomId)
        .collection('Messages')
        .doc(messageRef.id)
        .update({
          'status': MessageStatus.delivered.name,
          'deliveredTo': [receiverId],
        });

    // Mark as read for sender
    await markChatAsRead(roomId, currentUserID);
  }

  // Edit message
  Future<void> editMessage(
    String chatRoomId,
    String messageId,
    String newMessage,
  ) async {
    await _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .doc(messageId)
        .update({
          'message': newMessage,
          'isEdited': true,
          'editedAt': FieldValue.serverTimestamp(),
        });
  }

  // Delete message (for self or everyone)
  Future<void> deleteMessage(
    String chatRoomId,
    String messageId, {
    bool forEveryone = false,
  }) async {
    final currentUser = _auth.currentUser!;

    if (forEveryone) {
      // Delete for everyone
      await _firestore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('Messages')
          .doc(messageId)
          .delete();
    } else {
      // Mark as deleted for sender
      await _firestore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('Messages')
          .doc(messageId)
          .update({
            'message': '[deleted]',
            'deleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
            'deletedBy': currentUser.uid,
            'deletedByEmail': currentUser.email ?? '',
          });
    }
  }

  // Get messages with enhanced features
  Stream<QuerySnapshot> getMessages(
    String userId,
    String otherUserId, {
    String? chatRoomId,
  }) {
    String roomId = chatRoomId ?? getChatRoomId(userId, otherUserId);
    return _firestore
        .collection('ChatRooms')
        .doc(roomId)
        .collection('Messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatRoomId, String userId) async {
    try {
      await _firestore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('ReadStatus')
          .doc(userId)
          .set({
            'lastRead': FieldValue.serverTimestamp(),
            'userId': userId,
          }, SetOptions(merge: true));
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  // Mark chat as read when user opens the chat
  Future<void> markChatAsReadOnOpen(
    String currentUserId,
    String otherUserId,
  ) async {
    final ids = [currentUserId, otherUserId]..sort();
    final chatRoomId = ids.join('_');
    await markChatAsRead(chatRoomId, currentUserId);
  }

  // Get chat preview with enhanced features
  Stream<Map<String, dynamic>> getChatPreviewStream(
    String currentUserId,
    String otherUserId,
  ) {
    final ids = [currentUserId, otherUserId]..sort();
    final chatRoomId = ids.join('_');

    final lastMessageStream = _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();

    final readStatusStream = _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('ReadStatus')
        .doc(currentUserId)
        .snapshots();

    return lastMessageStream.asyncExpand((msgSnap) {
      return readStatusStream.map((readSnap) {
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

  // Typing indicators
  void setTypingStatus(String chatRoomId, bool isTyping) {
    final currentUser = _auth.currentUser!;
    final typingRef = _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Typing')
        .doc(currentUser.uid);

    if (isTyping) {
      typingRef.set({
        'isTyping': true,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
      });

      // Clear typing status after 5 seconds
      _typingTimers[chatRoomId]?.cancel();
      _typingTimers[chatRoomId] = Timer(const Duration(seconds: 5), () {
        setTypingStatus(chatRoomId, false);
      });
    } else {
      typingRef.delete();
      _typingTimers[chatRoomId]?.cancel();
    }
  }

  // Get typing status stream
  Stream<Map<String, bool>> getTypingStatusStream(String chatRoomId) {
    if (!_typingControllers.containsKey(chatRoomId)) {
      _typingControllers[chatRoomId] =
          StreamController<Map<String, bool>>.broadcast();
    }

    _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Typing')
        .snapshots()
        .listen((snapshot) {
          final typingUsers = <String, bool>{};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data['isTyping'] == true) {
              typingUsers[data['userEmail'] ?? ''] = true;
            }
          }
          _typingControllers[chatRoomId]?.add(typingUsers);
        });

    return _typingControllers[chatRoomId]!.stream;
  }

  // Search messages
  Stream<QuerySnapshot> searchMessages(String chatRoomId, String query) {
    return _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .where('message', isGreaterThanOrEqualTo: query)
        .where('message', isLessThan: query + '\uf8ff')
        .orderBy('message')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // Get unread message count
  Stream<int> getUnreadMessageCount(String currentUserId, String otherUserId) {
    final ids = [currentUserId, otherUserId]..sort();
    final chatRoomId = ids.join('_');

    return _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('ReadStatus')
        .doc(currentUserId)
        .snapshots()
        .asyncExpand((readSnap) {
          Timestamp? lastRead;
          if (readSnap.exists && readSnap.data() != null) {
            lastRead = readSnap.data()!['lastRead'] as Timestamp?;
          }

          return _firestore
              .collection('ChatRooms')
              .doc(chatRoomId)
              .collection('Messages')
              .where('senderID', isNotEqualTo: currentUserId)
              .snapshots()
              .map((msgSnap) {
                if (lastRead == null) {
                  return msgSnap.docs.length;
                }

                return msgSnap.docs.where((doc) {
                  final data = doc.data();
                  final timestamp = data['timestamp'] as Timestamp;
                  return timestamp.compareTo(lastRead!) > 0;
                }).length;
              });
        });
  }

  // Helper method to create chat room ID
  String getChatRoomId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  // Dispose resources
  void dispose() {
    for (var timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();

    for (var controller in _typingControllers.values) {
      controller.close();
    }
    _typingControllers.clear();
  }

  // One-time migration: ensure ChatRooms.participants contains auth UIDs, not Users doc IDs
  Future<void> migrateParticipantsToAuthUids() async {
    try {
      // Build a map of Users docId -> uid
      final usersSnap = await _firestore.collection('Users').get();
      final Map<String, String> docIdToUid = {};
      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final uid = (data['uid'] as String?) ?? doc.id;
        docIdToUid[doc.id] = uid;
      }

      // Iterate all chat rooms
      final roomsSnap = await _firestore.collection('ChatRooms').get();
      for (final room in roomsSnap.docs) {
        final data = room.data();
        final List<dynamic> raw =
            (data['participants'] as List<dynamic>? ?? []);
        if (raw.isEmpty) continue;

        final Set<String> fixed = {};
        bool changed = false;
        for (final p in raw) {
          final String id = p?.toString() ?? '';
          if (id.isEmpty) continue;
          final String mapped = docIdToUid[id] ?? id;
          if (mapped != id) changed = true;
          fixed.add(mapped);
        }

        if (changed || fixed.length != raw.length) {
          await room.reference.update({'participants': fixed.toList()});
        }
      }
    } catch (e) {
      // Best-effort migration; ignore errors
    }
  }
}
