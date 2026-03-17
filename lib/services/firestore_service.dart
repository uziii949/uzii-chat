import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';



  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection(usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) return UserModel.fromMap(doc.data()!);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .update({
      'isOnline': isOnline,
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<UserModel>> getAllUsers(String currentUid) {
    return _firestore
        .collection(usersCollection)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.uid != currentUid)
        .toList());
  }



  String getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> createChat(String uid1, String uid2) async {
    final chatId = getChatId(uid1, uid2);
    final doc = await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .get();

    if (!doc.exists) {
      final chat = ChatModel(
        chatId: chatId,
        participantIds: [uid1, uid2],
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(chatsCollection)
          .doc(chatId)
          .set(chat.toMap());
    }
  }

  Stream<List<ChatModel>> getUserChats(String uid) {
    return _firestore
        .collection(chatsCollection)
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ChatModel.fromMap(doc.data()))
        .toList());
  }



  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderId,
    MessageType? replyToType,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    final messageId = _uuid.v4();


    bool isDelivered = true;
    try {
      final receiverDoc = await _firestore
          .collection(usersCollection)
          .doc(receiverId)
          .get();
      if (receiverDoc.exists) {
        final blockedUsers = List<String>.from(
          receiverDoc.data()!['blockedUsers'] ?? [],
        );
        if (blockedUsers.contains(senderId)) {
          isDelivered = false;
        }
      }
    } catch (e) {
      isDelivered = true;
    }

    final message = MessageModel(
      messageId: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      isDelivered: isDelivered,
      isRead: false,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      replyToSenderId: replyToSenderId,
      replyToType: replyToType,
    );


    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .set({
      'chatId': chatId,
      'participantIds': [senderId, receiverId],
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));


    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc(messageId)
        .set(message.toMap());


    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .update({
      'lastMessage': message.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
      'unreadCount_$receiverId': FieldValue.increment(1),
      'unreadCount_$senderId': 0,
    });
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => MessageModel.fromMap(doc.data()))
        .toList());
  }

  Future<void> markMessagesAsRead(
      String chatId,
      String currentUserId,
      ) async {
    final messages = await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();

    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .update({
      'unreadCount_$currentUserId': 0,
    });
  }



  Future<void> deleteMessageForMe({
    required String chatId,
    required String messageId,
    required String currentUserId,
  }) async {
    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc(messageId)
        .update({
      'deletedFor': FieldValue.arrayUnion([currentUserId]),
    });
  }



  Future<void> deleteMessageForEveryone({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc(messageId)
        .update({
      'deletedForEveryone': true,
      'content': 'This message was deleted',
    });
  }


  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc(messageId)
        .update({
      'reactions.$userId': emoji,
    });
  }


  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc(messageId)
        .update({
      'reactions.$userId': FieldValue.delete(),
    });
  }


  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(currentUserId)
        .update({
      'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
    });
  }


  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(currentUserId)
        .update({
      'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
    });
  }


  Future<void> pinMessage({
    required String chatId,
    required String messageId,
    required int hours,
  }) async {
    final pinnedUntil = DateTime.now()
        .add(Duration(hours: hours))
        .toIso8601String();

    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc(messageId)
        .update({
      'isPinned': true,
      'pinnedUntil': pinnedUntil,
    });

    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .update({
      'pinnedMessageId': messageId,
      'pinnedUntil': pinnedUntil,
    });
  }

  Future<void> unpinMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc(messageId)
        .update({
      'isPinned': false,
      'pinnedUntil': null,
    });

    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .update({
      'pinnedMessageId': null,
      'pinnedUntil': null,
    });
  }

  Future<void> saveFcmToken({
    required String uid,
    required String token,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .update({
      'fcmToken': token,
      'tokenUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .update({
      'typing_$userId': isTyping,
    });
  }

  Stream<bool> getTypingStream({
    required String chatId,
    required String otherUserId,
  }) {
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return false;
      final data = doc.data();
      if (data == null) return false;
      return data['typing_$otherUserId'] == true;
    });
  }
}