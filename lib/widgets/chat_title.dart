import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId;
  final String otherUserName;
  final String otherUserImage;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.otherUserName,
    required this.otherUserImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMsg    = chat.lastMessage?.content ?? '';
    final time       = Helpers.formatChatTime(chat.updatedAt);
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final scheme     = Theme.of(context).colorScheme;
    final unreadCount = chat.getUnreadCount(currentUserId);
    final hasUnread   = unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical:   10,
        ),
        child: Row(
          children: [


            CircleAvatar(
              radius: AppSizes.avatarM / 2,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              backgroundImage: otherUserImage.isNotEmpty
                  ? CachedNetworkImageProvider(otherUserImage)
                  : null,
              child: otherUserImage.isEmpty
                  ? Text(
                Helpers.getInitials(otherUserName),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              )
                  : null,
            ),

            const SizedBox(width: 14),


            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: AppTextStyles.chatName.copyWith(
                      color:      scheme.onSurface,
                      fontWeight: hasUnread
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.chatPreview.copyWith(
                      color: hasUnread
                          ? scheme.onSurface
                          : isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: hasUnread
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),


            Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: AppTextStyles.messageTime.copyWith(
                    color: hasUnread
                        ? AppColors.primary
                        : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: hasUnread
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    constraints: const BoxConstraints(
                      minWidth:  20,
                      minHeight: 20,
                    ),
                    decoration: BoxDecoration(
                      color:        AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount > 99
                          ? '99+'
                          : '$unreadCount',
                      style: AppTextStyles.unreadBadge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}