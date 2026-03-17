import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import '../models/message_model.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final bool isBlocked;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isBlocked = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  List<Widget> _buildReactionChips() {
    final Map<String, int> emojiCount = {};
    widget.message.reactions.forEach((_, emoji) {
      emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
    });
    return emojiCount.entries.map((entry) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.isMe
              ? Colors.white.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isMe
                ? Colors.white.withOpacity(0.3)
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Text(
          '${entry.key} ${entry.value}',
          style: const TextStyle(fontSize: 11),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final message = widget.message;
    final isMe    = widget.isMe;


    if (message.deletedForEveryone) {
      return Align(
        alignment: isMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
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
          child: Text(
            '🚫 This message was deleted',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final bubbleColor = isMe
        ? (isDark
        ? AppColors.bubbleSentDark
        : AppColors.bubbleSentLight)
        : (isDark
        ? AppColors.bubbleReceivedDark
        : AppColors.bubbleReceivedLight);

    final isMedia = message.type == MessageType.image ||
        message.type == MessageType.video;

    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
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
          boxShadow: isMedia
              ? null
              : [
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
                    Icon(Icons.push_pin,
                        size: 11,
                        color: isMe
                            ? Colors.white70
                            : AppColors.warning),
                    const SizedBox(width: 2),
                    Text('Pinned',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isMe
                              ? Colors.white70
                              : AppColors.warning,
                        )),
                  ],
                ),
              ),


            if (message.type == MessageType.image)
              _buildImageBubble()
            else if (message.type == MessageType.video)
              _buildVideoThumbnail()
            else if (message.type == MessageType.audio)
                _buildAudioBubble(isDark)
              else if (message.type == MessageType.document)
                  _buildDocumentBubble()
                else
                  Text(
                    message.content,
                    style: AppTextStyles.messageText.copyWith(
                      color: isMe
                          ? Colors.white
                          : isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),


            Padding(
              padding: isMedia
                  ? const EdgeInsets.all(6)
                  : const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.messageTime.copyWith(
                      color: isMe
                          ? Colors.white60
                          : isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (isMe && !widget.isBlocked) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead
                          ? Icons.done_all
                          : message.isDelivered
                          ? Icons.done_all
                          : Icons.done,
                      size: 14,
                      color: message.isRead
                          ? AppColors.tickRead
                          : Colors.white60,
                    ),
                  ],
                ],
              ),
            ),


            if (message.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: _buildReactionChips(),
                ),
              ),
          ],
        ),
      ),
    );
  }



  Widget _buildImageBubble() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme:
              const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                    imageUrl: widget.message.content),
              ),
            ),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft:     const Radius.circular(18),
          topRight:    const Radius.circular(18),
          bottomLeft:  Radius.circular(widget.isMe ? 18 : 4),
          bottomRight: Radius.circular(widget.isMe ? 4 : 18),
        ),
        child: CachedNetworkImage(
          imageUrl:    widget.message.content,
          width:       220,
          height:      220,
          fit:         BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 220, height: 220,
            color: AppColors.surfaceVariantLight,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 220, height: 220,
            color: AppColors.surfaceVariantLight,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textHintLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft:     const Radius.circular(18),
        topRight:    const Radius.circular(18),
        bottomLeft:  Radius.circular(widget.isMe ? 18 : 4),
        bottomRight: Radius.circular(widget.isMe ? 4 : 18),
      ),
      child: Container(
        width: 220, height: 160,
        color: Colors.black87,
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.play_circle_fill,
                color: Colors.white, size: 52),
            Positioned(
              bottom: 8, right: 8,
              child: Text('Video',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioBubble(bool isDark) {
    return StreamBuilder<bool>(
      stream:      _audioPlayer.playingStream,
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
                    await _audioPlayer.pause();
                  } else {
                    await _audioPlayer
                        .setUrl(widget.message.content);
                    await _audioPlayer.play();
                  }
                } catch (e) {
                  debugPrint('Audio error: $e');
                }
              },
              child: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                color: widget.isMe
                    ? Colors.white
                    : AppColors.primary,
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
                    color: widget.isMe
                        ? Colors.white54
                        : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPlaying ? 'Playing...' : 'Voice message',
                  style: AppTextStyles.caption.copyWith(
                    color: widget.isMe
                        ? Colors.white70
                        : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentBubble() {
    final parts    = widget.message.content.split('|');
    final fileName = parts.isNotEmpty ? parts[0] : 'Document';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: widget.isMe
                ? Colors.white.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.insert_drive_file_rounded,
            color: widget.isMe ? Colors.white : AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            fileName,
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.isMe ? Colors.white : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}