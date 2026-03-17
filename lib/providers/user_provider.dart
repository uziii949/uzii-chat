import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  UserModel? _userProfile;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get userProfile => _userProfile;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void loadUsers(String currentUid) {
    _firestore
        .collection('users')
        .snapshots()
        .listen((snap) {
      _users = snap.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => user.uid != currentUid)
          .toList();
      notifyListeners();
    });
  }

  void listenToUserProfile(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _userProfile = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    });
  }

  Future<void> getUserProfile(String uid) async {
    _setLoading(true);
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userProfile = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<bool> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required String phone,
  }) async {
    _setLoading(true);
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'bio': bio,
        'phone': phone,
      });
      _userProfile = _userProfile?.copyWith(
        name: name,
        bio: bio,
        phone: phone,
      );
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> uploadProfilePicture({required String uid}) async {
    try {
      final File? image = await _storageService.pickImage();
      if (image == null) return false;
      _setLoading(true);
      final url = await _storageService.uploadProfilePicture(
        uid: uid,
        imageFile: image,
      );
      if (url != null) {
        await _firestore.collection('users').doc(uid).update({
          'profileImageUrl': url,
        });
        _userProfile = _userProfile?.copyWith(profileImageUrl: url);
        notifyListeners();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateOnlineStatus({
    required String uid,
    required bool isOnline,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
      });
      final updatedList = List<String>.from(
          [...(_userProfile?.blockedUsers ?? []), blockedUserId]
      );
      _userProfile = _userProfile?.copyWith(blockedUsers: updatedList);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
      });
      final updatedList = List<String>.from(
          (_userProfile?.blockedUsers ?? [])
              .where((id) => id != blockedUserId)
              .toList()
      );
      _userProfile = _userProfile?.copyWith(blockedUsers: updatedList);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
  bool isUserBlocked(String userId) {
    return _userProfile?.blockedUsers.contains(userId) ?? false;
  }
  Stream<UserModel> streamUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data()!));
  }
}