class StatusModel {
  final String statusId;
  final String userId;
  final String userName;
  final String userImage;
  final String content;
  final StatusType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> seenBy;
  final String? caption;
  final int? backgroundColor;

  StatusModel({
    required this.statusId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.seenBy    = const [],
    this.caption,
    this.backgroundColor,
  });

  bool get isExpired =>
      DateTime.now().isAfter(expiresAt);

  bool get isActive => !isExpired;

  Map<String, dynamic> toMap() => {
    'statusId':         statusId,
    'userId':           userId,
    'userName':         userName,
    'userImage':        userImage,
    'content':          content,
    'type':             type.name,
    'createdAt':        createdAt.toIso8601String(),
    'expiresAt':        expiresAt.toIso8601String(),
    'seenBy':           seenBy,
    'caption':          caption,
    'backgroundColor':  backgroundColor,
  };

  factory StatusModel.fromMap(Map<String, dynamic> map) =>
      StatusModel(
        statusId:        map['statusId'] ?? '',
        userId:          map['userId'] ?? '',
        userName:        map['userName'] ?? '',
        userImage:       map['userImage'] ?? '',
        content:         map['content'] ?? '',
        type: StatusType.values.byName(map['type'] ?? 'text'),
        createdAt:       DateTime.parse(map['createdAt']),
        expiresAt:       DateTime.parse(map['expiresAt']),
        seenBy:          List<String>.from(map['seenBy'] ?? []),
        caption:         map['caption'],
        backgroundColor: map['backgroundColor'],
      );
}

enum StatusType { image, text }