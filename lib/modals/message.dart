import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { sent, delivered, read, failed }

enum MessageType { text, image, file, audio, location }

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final MessageStatus status;
  final MessageType type;
  final bool isEdited;
  final Timestamp? editedAt;
  final bool isDeleted;
  final String? deletedBy;
  final String? deletedByEmail;
  final Timestamp? deletedAt;
  final String? replyToMessageId;
  final String? replyToMessageText;
  final Map<String, dynamic>? metadata;
  final String? chatRoomId;
  final List<String>? readBy;
  final List<String>? deliveredTo;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedBy,
    this.deletedByEmail,
    this.deletedAt,
    this.replyToMessageId,
    this.replyToMessageText,
    this.metadata,
    this.chatRoomId,
    this.readBy,
    this.deliveredTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'status': status.name,
      'type': type.name,
      'isEdited': isEdited,
      'editedAt': editedAt,
      'isDeleted': isDeleted,
      'deletedBy': deletedBy,
      'deletedByEmail': deletedByEmail,
      'deletedAt': deletedAt,
      'replyToMessageId': replyToMessageId,
      'replyToMessageText': replyToMessageText,
      'metadata': metadata,
      'chatRoomId': chatRoomId,
      'readBy': readBy ?? [],
      'deliveredTo': deliveredTo ?? [],
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      receiverID: map['receiverID'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'],
      isDeleted: map['isDeleted'] ?? false,
      deletedBy: map['deletedBy'],
      deletedByEmail: map['deletedByEmail'],
      deletedAt: map['deletedAt'],
      replyToMessageId: map['replyToMessageId'],
      replyToMessageText: map['replyToMessageText'],
      metadata: map['metadata'],
      chatRoomId: map['chatRoomId'],
      readBy: List<String>.from(map['readBy'] ?? []),
      deliveredTo: List<String>.from(map['deliveredTo'] ?? []),
    );
  }

  Message copyWith({
    String? senderID,
    String? senderEmail,
    String? receiverID,
    String? message,
    Timestamp? timestamp,
    MessageStatus? status,
    MessageType? type,
    bool? isEdited,
    Timestamp? editedAt,
    bool? isDeleted,
    String? deletedBy,
    String? deletedByEmail,
    Timestamp? deletedAt,
    String? replyToMessageId,
    String? replyToMessageText,
    Map<String, dynamic>? metadata,
    String? chatRoomId,
    List<String>? readBy,
    List<String>? deliveredTo,
  }) {
    return Message(
      senderID: senderID ?? this.senderID,
      senderEmail: senderEmail ?? this.senderEmail,
      receiverID: receiverID ?? this.receiverID,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedBy: deletedBy ?? this.deletedBy,
      deletedByEmail: deletedByEmail ?? this.deletedByEmail,
      deletedAt: deletedAt ?? this.deletedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessageText: replyToMessageText ?? this.replyToMessageText,
      metadata: metadata ?? this.metadata,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      readBy: readBy ?? this.readBy,
      deliveredTo: deliveredTo ?? this.deliveredTo,
    );
  }
}
