import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService      _authService      = AuthService();
  final NotificationService _notifService  = NotificationService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status       = AuthStatus.initial;
  UserModel? _currentUser;
  String     _errorMessage = '';

  AuthStatus get status       => _status;
  UserModel? get currentUser  => _currentUser;
  String     get errorMessage => _errorMessage;
  bool       get isLoading    => _status == AuthStatus.loading;

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  Future<void> _saveFcmToken(String uid) async {
    try {
      final token = await _notifService.getToken();
      if (token != null) {
        await _firestoreService.saveFcmToken(
          uid:   uid,
          token: token,
        );
        debugPrint('FCM token saved: $token');
      }
    } catch (e) {
      debugPrint('FCM token save error: $e');
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _setStatus(AuthStatus.loading);
    final error = await _authService.register(
      email:    email,
      password: password,
      name:     name,
      phone:    phone,
    );
    if (error == null) {
      await _loadCurrentUser();

      if (_currentUser != null) {
        await _saveFcmToken(_currentUser!.uid);
      }
      _setStatus(AuthStatus.authenticated);
      return true;
    } else {
      _errorMessage = error;
      _setStatus(AuthStatus.error);
      return false;
    }
  }


  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    final error = await _authService.login(
      email:    email,
      password: password,
    );
    if (error == null) {
      await _loadCurrentUser();
      // FCM token save karo
      if (_currentUser != null) {
        await _saveFcmToken(_currentUser!.uid);
      }
      _setStatus(AuthStatus.authenticated);
      return true;
    } else {
      _errorMessage = error;
      _setStatus(AuthStatus.error);
      return false;
    }
  }


  Future<bool> signInWithGoogle() async {
    _setStatus(AuthStatus.loading);
    final error = await _authService.signInWithGoogle();
    if (error == null) {
      await _loadCurrentUser();
      // FCM token save karo
      if (_currentUser != null) {
        await _saveFcmToken(_currentUser!.uid);
      }
      _setStatus(AuthStatus.authenticated);
      return true;
    } else {
      _errorMessage = error;
      _setStatus(AuthStatus.error);
      return false;
    }
  }


  Future<bool> forgotPassword(String email) async {
    _setStatus(AuthStatus.loading);
    final error = await _authService.forgotPassword(email);
    if (error == null) {
      _setStatus(AuthStatus.unauthenticated);
      return true;
    } else {
      _errorMessage = error;
      _setStatus(AuthStatus.error);
      return false;
    }
  }


  Future<void> logout() async {

    try {
      final uid = _authService.currentUserId;
      if (uid != null) {
        await _firestoreService.saveFcmToken(
          uid:   uid,
          token: '',
        );
      }
    } catch (e) {
      debugPrint('Token clear error: $e');
    }
    await _authService.logout();
    _currentUser = null;
    _setStatus(AuthStatus.unauthenticated);
  }


  Future<void> _loadCurrentUser() async {
    final uid = _authService.currentUserId;
    if (uid != null) {
      _currentUser = await _authService.getUserData(uid);
      notifyListeners();
    }
  }


  Future<void> checkAuthState() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _loadCurrentUser();
      // FCM token refresh karo app start par
      if (_currentUser != null) {
        await _saveFcmToken(_currentUser!.uid);
      }
      _setStatus(AuthStatus.authenticated);
    } else {
      _setStatus(AuthStatus.unauthenticated);
    }
  }
}