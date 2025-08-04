import 'package:chat_app/modals/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverId, message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Send the message
    await _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .add(newMessage.toMap());

    // Update sender's read status immediately (they've seen their own message)
    await markChatAsRead(chatRoomId, currentUserID);
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

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

  // Enhanced method to mark chat as read when user opens the chat
  Future<void> markChatAsReadOnOpen(String currentUserId, String otherUserId) async {
    final ids = [currentUserId, otherUserId]..sort();
    final chatRoomId = ids.join('_');
    await markChatAsRead(chatRoomId, currentUserId);
  }

  Stream<Map<String, dynamic>> getChatPreviewStream(
      String currentUserId, String otherUserId) {
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
        final lastMsg = msgSnap.docs.isNotEmpty ? msgSnap.docs.first.data() : null;
        final readData = readSnap.data();

        // Get the last read timestamp
        Timestamp? lastRead;
        if (readSnap.exists && readData != null && readData['lastRead'] != null) {
          lastRead = readData['lastRead'] as Timestamp;
        }

        bool isUnread = false;
        String messageText = '';

        if (lastMsg != null) {
          messageText = lastMsg['message'] ?? '';
          final msgTimestamp = lastMsg['timestamp'] as Timestamp;
          final senderId = lastMsg['senderID'] as String;

          // Message is unread if:
          // 1. There's no lastRead timestamp, OR
          // 2. Message timestamp is after lastRead, AND
          // 3. Current user is not the sender
          if (senderId != currentUserId) {
            if (lastRead == null) {
              isUnread = true;
            } else {
              isUnread = msgTimestamp.compareTo(lastRead) > 0;
            }
          }
        }

        return {
          'message': messageText,
          'isUnread': isUnread,
        };
      });
    });
  }

  // Get unread message count for a specific chat
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

  // **Enhanced deleteMessage method**
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    final currentUser = _auth.currentUser!;
    final messageDoc = _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .doc(messageId);

    await messageDoc.update({
      'message': '[deleted]',
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'deletedBy': currentUser.uid,
      'deletedByEmail': currentUser.email ?? '',
    });
  }

  // Helper method to create chat room ID
  String getChatRoomId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }
}