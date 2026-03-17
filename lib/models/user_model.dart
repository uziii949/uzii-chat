class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String bio;
  final bool isOnline;
  final DateTime lastSeen;
  final List<String> blockedUsers;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl = '',
    this.bio = '',
    this.isOnline = false,
    required this.lastSeen,
    this.blockedUsers = const [],
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'isOnline': isOnline,
    'lastSeen': lastSeen.toIso8601String(),
    'blockedUsers': blockedUsers,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    profileImageUrl: map['profileImageUrl'] ?? '',
    bio: map['bio'] ?? '',
    isOnline: map['isOnline'] ?? false,
    lastSeen: DateTime.parse(map['lastSeen']),
    blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
  );

  UserModel copyWith({
    String? name,
    String? bio,
    String? phone,
    String? profileImageUrl,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? blockedUsers,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        bio: bio ?? this.bio,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen ?? this.lastSeen,
        blockedUsers: blockedUsers ?? this.blockedUsers,
      );


  bool isBlocked(String userId) => blockedUsers.contains(userId);
}