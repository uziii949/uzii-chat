import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}
class NotificationService {
  static final NotificationService _instance =
  NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);
    await _requestPermission();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp
        .listen(_handleMessageOpenedApp);
    final token = await _fcm.getToken();
    debugPrint('FCM Token: $token');
  }
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert:       true,
      badge:       true,
      sound:       true,
      provisional: false,
    );
    debugPrint('FCM Permission: ${settings.authorizationStatus}');
  }
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
  }
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
  }
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
  void listenTokenRefresh(Function(String) onToken) {
    _fcm.onTokenRefresh.listen(onToken);
  }
}