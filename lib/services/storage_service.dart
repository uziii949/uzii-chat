import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  final _cloudinary = CloudinaryPublic(
    'dymnjgeqk',
    'whatsapp_clone',
    cache: false,
  );
  Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null) return null;
    return File(image.path);
  }
  Future<File?> pickVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (video == null) return null;
    return File(video.path);
  }
  Future<File?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx'],
    );
    if (result == null || result.files.isEmpty) return null;
    return File(result.files.single.path!);
  }
  Future<String?> uploadProfilePicture({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_pictures',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadChatImage({
    required String chatId,
    required File imageFile,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'chat_images/$chatId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadChatVideo({
    required String chatId,
    required File videoFile,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          videoFile.path,
          folder: 'chat_videos/$chatId',
          resourceType: CloudinaryResourceType.Video,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadVoiceMessage({
    required String chatId,
    required File audioFile,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          audioFile.path,
          folder: 'voice_messages/$chatId',
          resourceType: CloudinaryResourceType.Auto,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadDocument({
    required String chatId,
    required File documentFile,
    required String fileName,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          documentFile.path,
          folder: 'documents/$chatId',
          resourceType: CloudinaryResourceType.Auto,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }
}