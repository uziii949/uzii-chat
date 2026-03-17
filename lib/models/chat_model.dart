import 'message_model.dart';

class ChatModel {
  final String chatId;
  final List<String> participantIds;
  final MessageModel? lastMessage;
  final DateTime updatedAt;
  final Map<String, int> unreadCounts;

  ChatModel({
    required this.chatId,
    required this.participantIds,
    this.lastMessage,
    required this.updatedAt,
    this.unreadCounts = const {},
  });

  // Current user ka unread count
  int getUnreadCount(String uid) =>
      unreadCounts['unreadCount_$uid'] ?? 0;

  Map<String, dynamic> toMap() => {
    'chatId':         chatId,
    'participantIds': participantIds,
    'lastMessage':    lastMessage?.toMap(),
    'updatedAt':      updatedAt.toIso8601String(),
  };

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    final Map<String, int> unreadCounts = {};
    map.forEach((key, value) {
      if (key.startsWith('unreadCount_')) {
        // int ya num dono handle karo
        if (value is int) {
          unreadCounts[key] = value;
        } else if (value is num) {
          unreadCounts[key] = value.toInt();
        }
      }
    });

    return ChatModel(
      chatId:         map['chatId'] ?? '',
      participantIds: List<String>.from(
          map['participantIds'] ?? []),
      lastMessage: map['lastMessage'] != null
          ? MessageModel.fromMap(
          Map<String, dynamic>.from(map['lastMessage']))
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      unreadCounts: unreadCounts,
    );
  }
}