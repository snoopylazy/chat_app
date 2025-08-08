import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatRoomType { direct, group }

class ChatRoom {
  final String id;
  final String name;
  final ChatRoomType type;
  final List<String> participants;
  final String createdBy;
  final Timestamp createdAt;
  final Timestamp lastActivity;
  final String? lastMessage;
  final String? lastMessageSender;
  final Timestamp? lastMessageTime;
  final Map<String, dynamic>? metadata;
  final String? avatarUrl;
  final bool isActive;
  final Map<String, dynamic>? settings;

  ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
    required this.createdBy,
    required this.createdAt,
    required this.lastActivity,
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageTime,
    this.metadata,
    this.avatarUrl,
    this.isActive = true,
    this.settings,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'participants': participants,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'lastActivity': lastActivity,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageTime': lastMessageTime,
      'metadata': metadata,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'settings': settings,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: ChatRoomType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'direct'),
        orElse: () => ChatRoomType.direct,
      ),
      participants: List<String>.from(map['participants'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      lastActivity: map['lastActivity'] ?? Timestamp.now(),
      lastMessage: map['lastMessage'],
      lastMessageSender: map['lastMessageSender'],
      lastMessageTime: map['lastMessageTime'],
      metadata: map['metadata'],
      avatarUrl: map['avatarUrl'],
      isActive: map['isActive'] ?? true,
      settings: map['settings'],
    );
  }

  ChatRoom copyWith({
    String? id,
    String? name,
    ChatRoomType? type,
    List<String>? participants,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? lastActivity,
    String? lastMessage,
    String? lastMessageSender,
    Timestamp? lastMessageTime,
    Map<String, dynamic>? metadata,
    String? avatarUrl,
    bool? isActive,
    Map<String, dynamic>? settings,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      metadata: metadata ?? this.metadata,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
    );
  }
}
