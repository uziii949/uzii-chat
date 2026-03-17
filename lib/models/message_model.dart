enum MessageType { text, image, audio, video, document }

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;
  final bool deletedForEveryone;
  final List<String> deletedFor;
  final Map<String, String> reactions;
  final String? readAt;
  final String? deliveredAt;
  final bool isPinned;
  final String? pinnedUntil;


  final String? replyToMessageId;
  final String? replyToContent;
  final String? replyToSenderId;
  final MessageType? replyToType;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type               = MessageType.text,
    required this.timestamp,
    this.isRead             = false,
    this.isDelivered        = false,
    this.deletedForEveryone = false,
    this.deletedFor         = const [],
    this.reactions          = const {},
    this.readAt,
    this.deliveredAt,
    this.isPinned           = false,
    this.pinnedUntil,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToSenderId,
    this.replyToType,
  });

  bool get hasReply => replyToMessageId != null;

  Map<String, dynamic> toMap() => {
    'messageId':          messageId,
    'senderId':           senderId,
    'receiverId':         receiverId,
    'content':            content,
    'type':               type.name,
    'timestamp':          timestamp.toIso8601String(),
    'isRead':             isRead,
    'isDelivered':        isDelivered,
    'deletedForEveryone': deletedForEveryone,
    'deletedFor':         deletedFor,
    'reactions':          reactions,
    'readAt':             readAt,
    'deliveredAt':        deliveredAt,
    'isPinned':           isPinned,
    'pinnedUntil':        pinnedUntil,
    'replyToMessageId':   replyToMessageId,
    'replyToContent':     replyToContent,
    'replyToSenderId':    replyToSenderId,
    'replyToType':        replyToType?.name,
  };

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
    messageId:          map['messageId'] ?? '',
    senderId:           map['senderId'] ?? '',
    receiverId:         map['receiverId'] ?? '',
    content:            map['content'] ?? '',
    type: MessageType.values.byName(map['type'] ?? 'text'),
    timestamp:          DateTime.parse(map['timestamp']),
    isRead:             map['isRead'] ?? false,
    isDelivered:        map['isDelivered'] ?? false,
    deletedForEveryone: map['deletedForEveryone'] ?? false,
    deletedFor:         List<String>.from(map['deletedFor'] ?? []),
    reactions:          Map<String, String>.from(map['reactions'] ?? {}),
    readAt:             map['readAt'],
    deliveredAt:        map['deliveredAt'],
    isPinned:           map['isPinned'] ?? false,
    pinnedUntil:        map['pinnedUntil'],
    replyToMessageId:   map['replyToMessageId'],
    replyToContent:     map['replyToContent'],
    replyToSenderId:    map['replyToSenderId'],
    replyToType:        map['replyToType'] != null
        ? MessageType.values.byName(map['replyToType'])
        : null,
  );

  MessageModel copyWith({
    bool? isRead,
    bool? isDelivered,
    bool? deletedForEveryone,
    List<String>? deletedFor,
    Map<String, String>? reactions,
    String? readAt,
    String? deliveredAt,
    bool? isPinned,
    String? pinnedUntil,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderId,
    MessageType? replyToType,
  }) => MessageModel(
    messageId:          messageId,
    senderId:           senderId,
    receiverId:         receiverId,
    content:            content,
    type:               type,
    timestamp:          timestamp,
    isRead:             isRead ?? this.isRead,
    isDelivered:        isDelivered ?? this.isDelivered,
    deletedForEveryone: deletedForEveryone ?? this.deletedForEveryone,
    deletedFor:         deletedFor ?? this.deletedFor,
    reactions:          reactions ?? this.reactions,
    readAt:             readAt ?? this.readAt,
    deliveredAt:        deliveredAt ?? this.deliveredAt,
    isPinned:           isPinned ?? this.isPinned,
    pinnedUntil:        pinnedUntil ?? this.pinnedUntil,
    replyToMessageId:   replyToMessageId ?? this.replyToMessageId,
    replyToContent:     replyToContent ?? this.replyToContent,
    replyToSenderId:    replyToSenderId ?? this.replyToSenderId,
    replyToType:        replyToType ?? this.replyToType,
  );

  bool get isPinnedActive {
    if (!isPinned) return false;
    if (pinnedUntil == null) return false;
    return DateTime.now().isBefore(DateTime.parse(pinnedUntil!));
  }
}