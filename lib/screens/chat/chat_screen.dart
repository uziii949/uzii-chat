import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/user_model.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/chat_date_separator.dart';
import '../../widgets/typing_indicator.dart';
import '../../widgets/scroll_to_bottom_button.dart';
import '../call/call_screen.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  const ChatScreen({super.key, required this.receiver});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController  = ScrollController();
  final _storageService    = StorageService();
  final _firestoreService  = FirestoreService();
  final _picker            = ImagePicker();
  final _recorder          = FlutterSoundRecorder();

  late String _chatId;
  late String _currentUserId;

  bool     _isSending           = false;
  bool     _isRecording         = false;
  bool     _recorderInitialized = false;
  bool     _showScrollButton    = false;
  bool     _isTyping            = false;
  String?  _recordingPath;
  Timer?   _typingTimer;

  final Map<String, AudioPlayer> _audioPlayers = {};

  @override
  void initState() {
    super.initState();
    final auth     = context.read<AuthProvider>();
    _currentUserId = auth.currentUser!.uid;
    _chatId        = context.read<ChatProvider>()
        .getChatId(_currentUserId, widget.receiver.uid);
    _initRecorder();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages(_chatId);
      context.read<ChatProvider>()
          .markMessagesAsRead(_chatId, _currentUserId);
      context.read<UserProvider>().getUserProfile(_currentUserId);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final showButton = _scrollController.offset > 300;
    if (showButton != _showScrollButton) {
      setState(() => _showScrollButton = showButton);
    }
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    setState(() => _recorderInitialized = true);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _firestoreService.setTyping(
      chatId:   _chatId,
      userId:   _currentUserId,
      isTyping: false,
    );
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _recorder.closeRecorder();
    for (final p in _audioPlayers.values) p.dispose();
    context.read<ChatProvider>().clearMessages();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    final isBlocked =
    context.read<UserProvider>().isUserBlocked(widget.receiver.uid);
    if (isBlocked) {
      _showSnack('You have blocked this user', isError: true);
      return;
    }
    final replyingTo = context.read<ChatProvider>().replyingTo;
    _messageController.clear();
    setState(() => _isTyping = false);
    context.read<ChatProvider>().clearReply();
    _typingTimer?.cancel();
    _firestoreService.setTyping(
      chatId:   _chatId,
      userId:   _currentUserId,
      isTyping: false,
    );
    await context.read<ChatProvider>().sendMessage(
      senderId:         _currentUserId,
      receiverId:       widget.receiver.uid,
      content:          content,
      replyToMessageId: replyingTo?.messageId,
      replyToContent:   replyingTo?.content,
      replyToSenderId:  replyingTo?.senderId,
      replyToType:      replyingTo?.type,
    );
    _scrollToTop();
  }

  Future<void> _sendImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    setState(() => _isSending = true);
    final url = await _storageService.uploadChatImage(
        chatId: _chatId, imageFile: File(image.path));
    if (url != null) {
      await context.read<ChatProvider>().sendMessage(
        senderId:   _currentUserId,
        receiverId: widget.receiver.uid,
        content:    url,
        type:       MessageType.image,
      );
      _scrollToTop();
    }
    setState(() => _isSending = false);
  }

  Future<void> _sendVideo() async {
    final video = await _storageService.pickVideo();
    if (video == null) return;
    setState(() => _isSending = true);
    final url = await _storageService.uploadChatVideo(
        chatId: _chatId, videoFile: video);
    if (url != null) {
      await context.read<ChatProvider>().sendMessage(
        senderId:   _currentUserId,
        receiverId: widget.receiver.uid,
        content:    url,
        type:       MessageType.video,
      );
      _scrollToTop();
    }
    setState(() => _isSending = false);
  }

  Future<void> _sendDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf','doc','docx','txt','xlsx','pptx'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _isSending = true);
    final file     = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final url = await _storageService.uploadDocument(
        chatId: _chatId, documentFile: file, fileName: fileName);
    if (url != null) {
      await context.read<ChatProvider>().sendMessage(
        senderId:   _currentUserId,
        receiverId: widget.receiver.uid,
        content:    '$fileName|$url',
        type:       MessageType.document,
      );
      _scrollToTop();
    }
    setState(() => _isSending = false);
  }

  Future<void> _startRecording() async {
    if (!_recorderInitialized || _isRecording) return;
    final path =
        '${Directory.systemTemp.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
    try {
      await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
      setState(() { _isRecording = true; _recordingPath = path; });
    } catch (e) { debugPrint('Recording error: $e'); }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    try { await _recorder.stopRecorder(); } catch (e) { debugPrint('$e'); }
    setState(() => _isRecording = false);
    if (_recordingPath == null) return;
    final file = File(_recordingPath!);
    if (!await file.exists()) return;
    setState(() => _isSending = true);
    final url = await _storageService.uploadVoiceMessage(
        chatId: _chatId, audioFile: file);
    if (url != null && mounted) {
      await context.read<ChatProvider>().sendMessage(
        senderId:   _currentUserId,
        receiverId: widget.receiver.uid,
        content:    url,
        type:       MessageType.audio,
      );
      _scrollToTop();
    }
    setState(() => _isSending = false);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
      backgroundColor: isError ? AppColors.error : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _replyContentLabel(String? content, MessageType? type) {
    switch (type) {
      case MessageType.image:    return '📷 Photo';
      case MessageType.audio:    return '🎵 Voice message';
      case MessageType.video:    return '🎥 Video';
      case MessageType.document: return '📄 Document';
      default:                   return content ?? '';
    }
  }


  String _formatLastSeen(DateTime lastSeen) {
    final now  = DateTime.now();
    final diff = now.difference(lastSeen);
    if (diff.inMinutes < 1)  return 'Last seen just now';
    if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes}m ago';
    if (diff.inDays == 0) {
      final h = lastSeen.hour.toString().padLeft(2, '0');
      final m = lastSeen.minute.toString().padLeft(2, '0');
      return 'Last seen at $h:$m';
    }
    if (diff.inDays == 1) return 'Last seen yesterday';
    if (diff.inDays < 7)  return 'Last seen ${diff.inDays} days ago';
    return 'Last seen ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }


  void _showFullScreenAvatar(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque:          false,
        barrierColor:    Colors.black87,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => _FullScreenAvatar(
          uid:      widget.receiver.uid,
          name:     widget.receiver.name,
          imageUrl: widget.receiver.profileImageUrl,
          isOnline: widget.receiver.isOnline,
        ),
      ),
    );
  }



  void _showDeleteOptions(MessageModel message, bool isMe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context:            context,
      backgroundColor:    isDark ? AppColors.cardDark : AppColors.cardLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textHintDark : AppColors.textHintLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['❤️','👍','🔥','😂','😮','😢'].map((emoji) {
                    final hasReacted =
                        message.reactions[_currentUserId] == emoji;
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        if (hasReacted) {
                          await context.read<ChatProvider>().removeReaction(
                            chatId:    _chatId,
                            messageId: message.messageId,
                            userId:    _currentUserId,
                          );
                        } else {
                          await context.read<ChatProvider>().addReaction(
                            chatId:    _chatId,
                            messageId: message.messageId,
                            userId:    _currentUserId,
                            emoji:     emoji,
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hasReacted
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 26)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(color: isDark
                  ? AppColors.dividerDark : AppColors.divider, height: 1),
              _sheetTile(
                icon: Icons.reply_rounded, iconColor: AppColors.primary,
                label: 'Reply', isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatProvider>().setReplyingTo(message);
                },
              ),
              if (message.type == MessageType.text)
                _sheetTile(
                  icon: Icons.copy_rounded, iconColor: AppColors.primary,
                  label: 'Copy', isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Clipboard.setData(
                        ClipboardData(text: message.content));
                    _showSnack('Message copied!');
                  },
                ),
              _sheetTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                label: 'Message Info', isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  _showMessageInfo(message);
                },
              ),
              _sheetTile(
                icon: message.isPinnedActive
                    ? Icons.push_pin : Icons.push_pin_outlined,
                iconColor: AppColors.warning,
                label: message.isPinnedActive
                    ? 'Unpin Message' : 'Pin Message',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  if (message.isPinnedActive) {
                    context.read<ChatProvider>().unpinMessage(
                        chatId: _chatId,
                        messageId: message.messageId);
                  } else {
                    _showPinDurationPicker(message);
                  }
                },
              ),
              _sheetTile(
                icon: Icons.delete_outline_rounded,
                iconColor: AppColors.error,
                label: 'Delete for me', isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<ChatProvider>().deleteMessageForMe(
                    chatId:        _chatId,
                    messageId:     message.messageId,
                    currentUserId: _currentUserId,
                  );
                },
              ),
              if (isMe)
                _sheetTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: AppColors.error,
                  label: 'Delete for everyone', isDark: isDark,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<ChatProvider>()
                        .deleteMessageForEveryone(
                      chatId: _chatId,
                      messageId: message.messageId,
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinDurationPicker(MessageModel message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.textHintDark : AppColors.textHintLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Pin Message For',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  )),
            ),
            Divider(color: isDark
                ? AppColors.dividerDark : AppColors.divider, height: 1),
            for (final entry in [
              {'label': '24 Hours', 'hours': 24},
              {'label': '7 Days',   'hours': 24 * 7},
              {'label': '30 Days',  'hours': 24 * 30},
            ])
              _sheetTile(
                icon: Icons.push_pin_outlined,
                iconColor: AppColors.warning,
                label: entry['label'] as String,
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<ChatProvider>().pinMessage(
                    chatId:    _chatId,
                    messageId: message.messageId,
                    hours:     entry['hours'] as int,
                  );
                  if (mounted) _showSnack('Message pinned!');
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showMessageInfo(MessageModel message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Message Info',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  )),
              const SizedBox(height: 20),
              _infoRow(Icons.check, 'Sent',
                  _formatFullTime(message.timestamp), isDark),
              const SizedBox(height: 14),
              _infoRow(Icons.done_all, 'Delivered',
                  message.isDelivered
                      ? _formatFullTime(message.deliveredAt != null
                      ? DateTime.parse(message.deliveredAt!)
                      : message.timestamp)
                      : 'Not delivered',
                  isDark,
                  color: message.isDelivered
                      ? AppColors.tickDelivered : AppColors.textHintLight),
              const SizedBox(height: 14),
              _infoRow(Icons.done_all, 'Read',
                  message.isRead
                      ? _formatFullTime(message.readAt != null
                      ? DateTime.parse(message.readAt!)
                      : message.timestamp)
                      : 'Not read yet',
                  isDark,
                  color: message.isRead
                      ? AppColors.tickRead : AppColors.textHintLight),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile({
    required IconData icon, required Color iconColor,
    required String label, required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          )),
      onTap: onTap,
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      bool isDark, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? AppColors.textSecondaryLight, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.headingSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            )),
            Text(value, style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            )),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildReactionChips(MessageModel message, bool isMe) {
    final Map<String, int> emojiCount = {};
    message.reactions.forEach((_, emoji) {
      emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
    });
    return emojiCount.entries.map((entry) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMe
                ? Colors.white.withOpacity(0.3)
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Text('${entry.key} ${entry.value}',
            style: const TextStyle(fontSize: 11)),
      );
    }).toList();
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';

  String _formatFullTime(DateTime time) =>
      '${time.day.toString().padLeft(2, '0')}/'
          '${time.month.toString().padLeft(2, '0')}/'
          '${time.year} '
          '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final messages  = context.watch<ChatProvider>().messages;
    final isBlocked = context.watch<UserProvider>()
        .isUserBlocked(widget.receiver.uid);
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final scheme    = Theme.of(context).colorScheme;

    final filteredMessages = isBlocked
        ? messages.where((m) => m.senderId == _currentUserId).toList()
        : messages;
    final pinnedMessages =
    messages.where((m) => m.isPinnedActive).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark : AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark : AppColors.surfaceLight,
        leadingWidth: 40,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [

            GestureDetector(
              onTap: () => _showFullScreenAvatar(context),
              child: Hero(
                tag: 'avatar_${widget.receiver.uid}',
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                      AppColors.primary.withOpacity(0.15),
                      backgroundImage:
                      widget.receiver.profileImageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(
                          widget.receiver.profileImageUrl)
                          : null,
                      child: widget.receiver.profileImageUrl.isEmpty
                          ? Text(
                        widget.receiver.name.isNotEmpty
                            ? widget.receiver.name[0]
                            .toUpperCase()
                            : '?',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary),
                      )
                          : null,
                    ),
                    if (widget.receiver.isOnline)
                      Positioned(
                        bottom: 1, right: 1,
                        child: Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.online,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.receiver.name,
                    style: AppTextStyles.headingSmall
                        .copyWith(color: scheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  StreamBuilder<bool>(
                    stream: _firestoreService.getTypingStream(
                      chatId:      _chatId,
                      otherUserId: widget.receiver.uid,
                    ),
                    builder: (context, snapshot) {
                      final isTyping = snapshot.data ?? false;
                      final statusText = isTyping
                          ? 'typing...'
                          : widget.receiver.isOnline
                          ? AppStrings.online
                          : _formatLastSeen(
                          widget.receiver.lastSeen);
                      return Text(
                        statusText,
                        style: AppTextStyles.caption.copyWith(
                          color: isTyping
                              ? AppColors.primary
                              : widget.receiver.isOnline
                              ? AppColors.online
                              : isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontWeight: isTyping
                              ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call_outlined, color: scheme.onSurface),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => CallScreen(
                  channelName: _chatId,
                  callerName:  widget.receiver.name,
                  isVideoCall: false,
                  isCaller:    true,
                ))),
          ),
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: scheme.onSurface),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => CallScreen(
                  channelName: _chatId,
                  callerName:  widget.receiver.name,
                  isVideoCall: true,
                  isCaller:    true,
                ))),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final blocked =
              userProvider.isUserBlocked(widget.receiver.uid);
              return PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: scheme.onSurface),
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onSelected: (value) async {
                  final uid =
                      context.read<AuthProvider>().currentUser!.uid;
                  if (value == 'block') {
                    await context.read<UserProvider>().blockUser(
                      currentUserId: uid,
                      blockedUserId: widget.receiver.uid,
                    );
                    if (mounted) _showSnack(
                        '${widget.receiver.name} blocked',
                        isError: true);
                  } else if (value == 'unblock') {
                    await context.read<UserProvider>().unblockUser(
                      currentUserId: uid,
                      blockedUserId: widget.receiver.uid,
                    );
                    if (mounted) _showSnack(
                        '${widget.receiver.name} unblocked');
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: blocked ? 'unblock' : 'block',
                    child: Row(children: [
                      Icon(
                        blocked ? Icons.lock_open : Icons.block,
                        color: blocked
                            ? AppColors.success : AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        blocked ? 'Unblock User' : 'Block User',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: blocked
                              ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [

              if (pinnedMessages.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    border: Border(bottom: BorderSide(
                      color: isDark
                          ? AppColors.dividerDark : AppColors.divider,
                      width: 0.5,
                    )),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.push_pin,
                          color: AppColors.warning, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pinnedMessages.first.type == MessageType.text
                              ? pinnedMessages.first.content
                              : '📎 Media message',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isBlocked)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: AppColors.error.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.block,
                          color: AppColors.error, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'You have blocked ${widget.receiver.name}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: filteredMessages.isEmpty
                    ? _buildEmptyChat(isDark)
                    : ListView.builder(
                  controller: _scrollController,
                  reverse:    true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final reversedIndex =
                        filteredMessages.length - 1 - index;
                    final msg  = filteredMessages[reversedIndex];
                    final isMe = msg.senderId == _currentUserId;
                    final showDate = reversedIndex == 0 ||
                        !_isSameDay(
                          filteredMessages[reversedIndex - 1]
                              .timestamp,
                          msg.timestamp,
                        );
                    return Column(
                      children: [
                        if (showDate)
                          ChatDateSeparator(date: msg.timestamp),
                        _buildMessageBubble(msg, isMe, isDark,
                            isBlocked: isBlocked),
                      ],
                    );
                  },
                ),
              ),

              StreamBuilder<bool>(
                stream: _firestoreService.getTypingStream(
                  chatId:      _chatId,
                  otherUserId: widget.receiver.uid,
                ),
                builder: (context, snapshot) {
                  final isReceiverTyping = snapshot.data ?? false;
                  if (!isReceiverTyping) return const SizedBox.shrink();
                  return TypingIndicator(name: widget.receiver.name);
                },
              ),

              if (_isSending)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text('Sending...',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          )),
                    ],
                  ),
                ),

              if (_isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: AppColors.error.withOpacity(0.08),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Recording...',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.error)),
                    ],
                  ),
                ),

              if (!isBlocked)
                _buildInputBar(isDark, scheme)
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  color: isDark
                      ? AppColors.surfaceDark : AppColors.surfaceLight,
                  child: Center(
                    child: Text('Unblock to send messages',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        )),
                  ),
                ),
            ],
          ),

          if (_showScrollButton)
            Positioned(
              bottom: 80, right: 16,
              child: ScrollToBottomButton(onTap: _scrollToTop),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark, ColorScheme scheme) {
    final replyingTo = context.watch<ChatProvider>().replyingTo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        if (replyingTo != null)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.dividerDark : AppColors.divider,
                  width: 0.5,
                ),
                left: const BorderSide(
                    color: AppColors.primary, width: 3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        replyingTo.senderId == _currentUserId
                            ? 'You' : widget.receiver.name,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _replyContentLabel(
                            replyingTo.content, replyingTo.type),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<ChatProvider>().clearReply(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                ),
              ],
            ),
          ),

        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: Border(top: BorderSide(
              color: isDark
                  ? AppColors.dividerDark : AppColors.divider,
              width: 0.5,
            )),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                onPressed: () => _showAttachMenu(isDark),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: scheme.onSurface),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (v) {
                      setState(() => _isTyping = v.isNotEmpty);
                      _firestoreService.setTyping(
                        chatId:   _chatId,
                        userId:   _currentUserId,
                        isTyping: v.isNotEmpty,
                      );
                      _typingTimer?.cancel();
                      if (v.isNotEmpty) {
                        _typingTimer = Timer(
                          const Duration(seconds: 3),
                              () => _firestoreService.setTyping(
                            chatId:   _chatId,
                            userId:   _currentUserId,
                            isTyping: false,
                          ),
                        );
                      }
                    },
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: AppStrings.typeMessage,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHintLight,
                      ),
                      border:         InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _messageController.text.isNotEmpty
                    ? _sendMessage : null,
                onLongPressStart: _messageController.text.isEmpty
                    ? (_) => _startRecording() : null,
                onLongPressEnd: _messageController.text.isEmpty
                    ? (_) => _stopRecording() : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? AppColors.error : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _messageController.text.isNotEmpty
                        ? Icons.send_rounded
                        : (_isRecording
                        ? Icons.mic : Icons.mic_none_rounded),
                    color: Colors.white, size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAttachMenu(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textHintDark : AppColors.textHintLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _attachItem(Icons.image_rounded, 'Image',
                      AppColors.primary, () {
                        Navigator.pop(context); _sendImage();
                      }),
                  _attachItem(Icons.videocam_rounded, 'Video',
                      AppColors.accent, () {
                        Navigator.pop(context); _sendVideo();
                      }),
                  _attachItem(Icons.insert_drive_file_rounded,
                      'Document', AppColors.warning, () {
                        Navigator.pop(context); _sendDocument();
                      }),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachItem(IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color:  color.withOpacity(0.12),
              shape:  BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      MessageModel message, bool isMe, bool isDark,
      {bool isBlocked = false}
      ) {
    if (message.deletedForEveryone) {
      return Align(
        alignment: isMe
            ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('🚫 This message was deleted',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              )),
        ),
      );
    }

    if (message.deletedFor.contains(_currentUserId)) {
      return const SizedBox.shrink();
    }

    final bubbleColor = isMe
        ? (isDark ? AppColors.bubbleSentDark : AppColors.bubbleSentLight)
        : (isDark
        ? AppColors.bubbleReceivedDark
        : AppColors.bubbleReceivedLight);
    final isMedia = message.type == MessageType.image ||
        message.type == MessageType.video;

    return Dismissible(
      key:       Key(message.messageId),
      direction: isMe
          ? DismissDirection.endToStart
          : DismissDirection.startToEnd,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.3,
        DismissDirection.startToEnd: 0.3,
      },
      confirmDismiss: (_) async {
        context.read<ChatProvider>().setReplyingTo(message);
        return false;
      },
      background: Align(
        alignment: isMe
            ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.reply_rounded,
                color: AppColors.primary, size: 20),
          ),
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showDeleteOptions(message, isMe),
        child: Align(
          alignment: isMe
              ? Alignment.centerRight : Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            key: ValueKey(message.messageId),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  isMe ? (1 - value) * 40 : (1 - value) * -40,
                  0,
                ),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width *
                    AppSizes.bubbleMaxWidth,
              ),
              decoration: BoxDecoration(
                color: isMedia ? Colors.transparent : bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: isMedia ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        isDark ? 0.2 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: isMedia
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  if (message.isPinnedActive)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.push_pin, size: 11,
                              color: isMe
                                  ? Colors.white70 : AppColors.warning),
                          const SizedBox(width: 2),
                          Text('Pinned',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isMe
                                    ? Colors.white70 : AppColors.warning,
                              )),
                        ],
                      ),
                    ),

                  if (message.hasReply)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.white.withOpacity(0.15)
                            : isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border(left: BorderSide(
                          color: isMe
                              ? Colors.white54 : AppColors.primary,
                          width: 3,
                        )),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.replyToSenderId == _currentUserId
                                ? 'You' : widget.receiver.name,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isMe
                                  ? Colors.white70 : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _replyContentLabel(
                                message.replyToContent,
                                message.replyToType),
                            style: AppTextStyles.caption.copyWith(
                              color: isMe
                                  ? Colors.white60
                                  : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  if (message.type == MessageType.image)
                    _buildImageBubble(message, isMe)
                  else if (message.type == MessageType.video)
                    _buildVideoThumbnail(isMe)
                  else if (message.type == MessageType.audio)
                      _buildAudioBubble(message, isMe, isDark)
                    else if (message.type == MessageType.document)
                        _buildDocumentBubble(message, isMe)
                      else
                        Text(message.content,
                            style: AppTextStyles.messageText.copyWith(
                              color: isMe
                                  ? Colors.white
                                  : isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            )),

                  Padding(
                    padding: isMedia
                        ? const EdgeInsets.all(6)
                        : const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_formatTime(message.timestamp),
                            style: AppTextStyles.messageTime.copyWith(
                              color: isMe
                                  ? Colors.white60
                                  : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            )),
                        if (isMe && !isBlocked) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead
                                ? Icons.done_all
                                : message.isDelivered
                                ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.isRead
                                ? AppColors.tickRead : Colors.white60,
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (message.reactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(spacing: 4,
                          children: _buildReactionChips(message, isMe)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageBubble(MessageModel message, bool isMe) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(child: InteractiveViewer(
              child: CachedNetworkImage(imageUrl: message.content),
            )),
          ))),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft:     const Radius.circular(18),
          topRight:    const Radius.circular(18),
          bottomLeft:  Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        child: CachedNetworkImage(
          imageUrl: message.content,
          width: 220, height: 220, fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 220, height: 220,
            color: AppColors.surfaceVariantLight,
            child: const Center(child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary)),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 220, height: 220,
            color: AppColors.surfaceVariantLight,
            child: const Icon(Icons.broken_image_outlined,
                color: AppColors.textHintLight),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(bool isMe) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft:     const Radius.circular(18),
        topRight:    const Radius.circular(18),
        bottomLeft:  Radius.circular(isMe ? 18 : 4),
        bottomRight: Radius.circular(isMe ? 4 : 18),
      ),
      child: Container(
        width: 220, height: 160, color: Colors.black87,
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.play_circle_fill, color: Colors.white, size: 52),
            Positioned(bottom: 8, right: 8,
                child: Text('Video',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 11))),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioBubble(
      MessageModel message, bool isMe, bool isDark) {
    final player = _audioPlayers.putIfAbsent(
        message.messageId, () => AudioPlayer());
    return StreamBuilder<bool>(
      stream: player.playingStream,
      initialData: false,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                try {
                  if (isPlaying) {
                    await player.pause();
                  } else {
                    await player.setUrl(message.content);
                    await player.play();
                  }
                } catch (e) { debugPrint('Audio error: $e'); }
              },
              child: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                color: isMe ? Colors.white : AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100, height: 2,
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.white54
                        : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(isPlaying ? 'Playing...' : 'Voice message',
                    style: AppTextStyles.caption.copyWith(
                      color: isMe
                          ? Colors.white70
                          : isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    )),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentBubble(MessageModel message, bool isMe) {
    final parts    = message.content.split('|');
    final fileName = parts.isNotEmpty ? parts[0] : 'Document';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isMe
                ? Colors.white.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.insert_drive_file_rounded,
              color: isMe ? Colors.white : AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(fileName,
              style: AppTextStyles.bodySmall
                  .copyWith(color: isMe ? Colors.white : null),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildEmptyChat(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color:  AppColors.primary.withOpacity(0.1),
              shape:  BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 14),
          Text('No messages yet',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              )),
          const SizedBox(height: 4),
          Text('Say Hello! 👋',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              )),
        ],
      ),
    );
  }
}


class _FullScreenAvatar extends StatelessWidget {
  final String uid;
  final String name;
  final String imageUrl;
  final bool   isOnline;

  const _FullScreenAvatar({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black87,
          child: SafeArea(
            child: Column(
              children: [


                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                  color:      Colors.white,
                                  fontSize:   16,
                                  fontWeight: FontWeight.w600,
                                )),
                            Row(
                              children: [
                                Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? const Color(0xFF00D9A6)
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: isOnline
                                        ? const Color(0xFF00D9A6)
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'avatar_$uid',
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 280, height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6C63FF),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF)
                                    .withOpacity(0.4),
                                blurRadius:   30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit:      BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: const Color(0xFF6C63FF)
                                    .withOpacity(0.15),
                                child: const Center(
                                  child:
                                  CircularProgressIndicator(
                                    color: Color(0xFF6C63FF),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                                : Container(
                              color: const Color(0xFF6C63FF)
                                  .withOpacity(0.15),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color:      Color(0xFF6C63FF),
                                    fontSize:   100,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}