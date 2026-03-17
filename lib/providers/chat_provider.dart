import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ChatModel>    _chats    = [];
  List<MessageModel> _messages = [];
  final bool         _isLoading = false;

  MessageModel? _replyingTo;
  MessageModel? get replyingTo => _replyingTo;

  StreamSubscription? _chatsSubscription;
  StreamSubscription? _messagesSubscription;

  List<ChatModel>    get chats     => _chats;
  List<MessageModel> get messages  => _messages;
  bool               get isLoading => _isLoading;

  void setReplyingTo(MessageModel? message) {
    _replyingTo = message;
    notifyListeners();
  }

  void clearReply() {
    _replyingTo = null;
    notifyListeners();
  }

  void loadChats(String uid) {
    _chatsSubscription?.cancel();
    _chatsSubscription = _firestoreService
        .getUserChats(uid)
        .listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }

  void loadMessages(String chatId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _firestoreService
        .getMessages(chatId)
        .listen((messages) {
      _messages = messages;
      notifyListeners();
    });
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
    await _firestoreService.sendMessage(
      senderId:         senderId,
      receiverId:       receiverId,
      content:          content,
      type:             type,
      replyToMessageId: replyToMessageId,
      replyToContent:   replyToContent,
      replyToSenderId:  replyToSenderId,
      replyToType:      replyToType,
    );
  }

  Future<void> createChat(String uid1, String uid2) async {
    await _firestoreService.createChat(uid1, uid2);
  }

  String getChatId(String uid1, String uid2) {
    return _firestoreService.getChatId(uid1, uid2);
  }

  Future<void> markMessagesAsRead(
      String chatId, String currentUserId) async {
    await _firestoreService.markMessagesAsRead(chatId, currentUserId);
  }

  Future<void> deleteMessageForMe({
    required String chatId,
    required String messageId,
    required String currentUserId,
  }) async {
    await _firestoreService.deleteMessageForMe(
      chatId:        chatId,
      messageId:     messageId,
      currentUserId: currentUserId,
    );
  }

  Future<void> deleteMessageForEveryone({
    required String chatId,
    required String messageId,
  }) async {
    await _firestoreService.deleteMessageForEveryone(
      chatId:    chatId,
      messageId: messageId,
    );
  }

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    await _firestoreService.addReaction(
      chatId:    chatId,
      messageId: messageId,
      userId:    userId,
      emoji:     emoji,
    );
  }

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    await _firestoreService.removeReaction(
      chatId:    chatId,
      messageId: messageId,
      userId:    userId,
    );
  }

  Future<void> pinMessage({
    required String chatId,
    required String messageId,
    required int hours,
  }) async {
    await _firestoreService.pinMessage(
      chatId:    chatId,
      messageId: messageId,
      hours:     hours,
    );
  }

  Future<void> unpinMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _firestoreService.unpinMessage(
      chatId:    chatId,
      messageId: messageId,
    );
  }

  void clearMessages() {
    _messagesSubscription?.cancel();
    _messages   = [];
    _replyingTo = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}