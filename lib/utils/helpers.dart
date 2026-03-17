import 'package:intl/intl.dart';

class Helpers {

  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(msgDay).inDays;

    if (diff == 0) return DateFormat('hh:mm a').format(dateTime);
    if (diff == 1) return 'Yesterday';
    return DateFormat('dd/MM/yy').format(dateTime);
  }


  static String formatMessageTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }


  static String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }


  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}