import 'package:chat_app/modals/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService{
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

  Future<void>sendMessage(String receiverId, message)async{
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp =  Timestamp.now();

    Message newMessage = Message(senderID: currentUserID, senderEmail: currentUserEmail, receiverID: receiverId, message: message, timestamp: timestamp);

    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    await _firestore.collection('ChatRooms').doc(chatRoomId).collection('Messages').add(newMessage.toMap());
  }

  Stream<QuerySnapshot>getMessages(String userId, otherUserId){
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firestore.collection('ChatRooms').doc(chatRoomId).collection('Messages').orderBy('timestamp', descending: false).snapshots();

  }

}