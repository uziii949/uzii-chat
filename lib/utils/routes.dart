import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/chat/home_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';
  static const String chat     = '/chat';
  static const String profile  = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    login:    (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home:     (_) => const HomeScreen(),
    profile:  (_) => const ProfileScreen(),
  };
}