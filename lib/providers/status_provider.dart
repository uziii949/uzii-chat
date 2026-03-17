import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/status_model.dart';

class StatusProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  final _cloudinary = CloudinaryPublic(
    'dymnjgeqk',
    'whatsapp_clone',
    cache: false,
  );

  List<StatusModel> _allStatuses  = [];
  final bool        _isLoading    = false;
  bool              _isUploading  = false;
  String            _errorMessage = '';

  List<StatusModel> get allStatuses  => _allStatuses;
  bool              get isLoading    => _isLoading;
  bool              get isUploading  => _isUploading;
  String            get errorMessage => _errorMessage;

  StreamSubscription? _statusSubscription;

  void loadStatuses(String currentUid) {
    _statusSubscription?.cancel();
    _statusSubscription = _firestore
        .collection('statuses')
        .where('expiresAt',
        isGreaterThan: DateTime.now().toIso8601String())
        .snapshots()
        .listen((snap) {
      _allStatuses = snap.docs
          .map((doc) => StatusModel.fromMap(doc.data()))
          .where((s) => s.isActive)
          .toList();
      _allStatuses.sort((a, b) =>
          b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    });
  }

  List<StatusModel> myStatuses(String uid) =>
      _allStatuses.where((s) => s.userId == uid).toList();

  List<StatusModel> otherStatuses(String uid) =>
      _allStatuses.where((s) => s.userId != uid).toList();

  List<StatusModel> latestStatusPerUser(String currentUid) {
    final Map<String, StatusModel> latest = {};
    for (final s in otherStatuses(currentUid)) {
      if (!latest.containsKey(s.userId) ||
          s.createdAt.isAfter(latest[s.userId]!.createdAt)) {
        latest[s.userId] = s;
      }
    }
    return latest.values.toList();
  }

  Future<bool> uploadImageStatus({
    required String uid,
    required String userName,
    required String userImage,
    String? caption,
  }) async {
    final picker = ImagePicker();
    final image  = await picker.pickImage(
      source:       ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final statusId = _uuid.v4();
      final file     = File(image.path);

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder:       'statuses/$uid',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final url = response.secureUrl;

      final status = StatusModel(
        statusId:  statusId,
        userId:    uid,
        userName:  userName,
        userImage: userImage,
        content:   url,
        type:      StatusType.image,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        caption:   caption,
      );

      await _firestore
          .collection('statuses')
          .doc(statusId)
          .set(status.toMap());

      _isUploading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      _isUploading  = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadTextStatus({
    required String uid,
    required String userName,
    required String userImage,
    required String text,
    required int backgroundColor,
  }) async {
    _isUploading = true;
    notifyListeners();

    try {
      final statusId = _uuid.v4();
      final status   = StatusModel(
        statusId:        statusId,
        userId:          uid,
        userName:        userName,
        userImage:       userImage,
        content:         text,
        type:            StatusType.text,
        createdAt:       DateTime.now(),
        expiresAt:       DateTime.now()
            .add(const Duration(hours: 24)),
        backgroundColor: backgroundColor,
      );

      await _firestore
          .collection('statuses')
          .doc(statusId)
          .set(status.toMap());

      _isUploading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      _isUploading  = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsSeen({
    required String statusId,
    required String viewerId,
  }) async {
    try {
      await _firestore
          .collection('statuses')
          .doc(statusId)
          .update({
        'seenBy': FieldValue.arrayUnion([viewerId]),
      });
    } catch (e) {
      debugPrint('Mark seen error: $e');
    }
  }

  Future<void> deleteStatus(String statusId) async {
    try {
      await _firestore
          .collection('statuses')
          .doc(statusId)
          .delete();
    } catch (e) {
      debugPrint('Delete status error: $e');
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}