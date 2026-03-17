import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/status/status_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final uid  = auth.currentUser?.uid;
      if (uid != null) {
        context.read<ChatProvider>().loadChats(uid);
        context.read<UserProvider>().loadUsers(uid);
        context.read<UserProvider>().listenToUserProfile(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getLastMessagePreview(ChatModel chat, String currentUid) {
    final msg = chat.lastMessage;
    if (msg == null) return 'Tap to start chatting';
    if (msg.deletedForEveryone) return '🚫 Message deleted';
    final isMe   = msg.senderId == currentUid;
    final prefix = isMe ? 'You: ' : '';
    switch (msg.type.name) {
      case 'image':    return '${prefix}📷 Photo';
      case 'video':    return '${prefix}🎥 Video';
      case 'audio':    return '${prefix}🎵 Voice message';
      case 'document': return '${prefix}📄 Document';
      default:         return '$prefix${msg.content}';
    }
  }

  String _formatTime(DateTime time) {
    final now  = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
      return days[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final uid    = auth.currentUser?.uid ?? '';
    final users  = context.watch<UserProvider>().users;
    final chats  = context.watch<ChatProvider>().chats;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final filteredUsers = _searchQuery.isEmpty
        ? users
        : users.where((u) => u.name.toLowerCase()
        .contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: scheme.surface,

      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: Text(
          AppStrings.appName,
          style: AppTextStyles.headingLarge.copyWith(
            color: scheme.onSurface,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const ProfileScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text('U',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: scheme.onSurface),
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthProvider>().logout();
              } else if (value == 'profile') {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(children: [
                  Icon(Icons.person_outline,
                      color: scheme.onSurface, size: 18),
                  const SizedBox(width: 10),
                  Text('Profile',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: scheme.onSurface)),
                ]),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  const Icon(Icons.logout,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Text('Logout',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error)),
                ]),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller:           _tabController,
          indicatorColor:       AppColors.primary,
          indicatorWeight:      2.5,
          labelColor:           AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          labelStyle: AppTextStyles.labelLarge,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Status'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [


          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: scheme.onSurface),
                  onChanged: (v) =>
                      setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textHintDark
                          : AppColors.textHintLight,
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.close, size: 18,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                    filled:    true,
                    fillColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:   BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              Expanded(
                child: users.isEmpty
                    ? _buildEmptyState(isDark)
                    : filteredUsers.isEmpty
                    ? _buildNoResultsState(isDark)
                    : ListView.builder(
                  itemCount: filteredUsers.length,
                  padding: const EdgeInsets.only(top: 4),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final chatId = context
                        .read<ChatProvider>()
                        .getChatId(uid, user.uid);
                    final chat = chats.firstWhere(
                          (c) => c.chatId == chatId,
                      orElse: () => ChatModel(
                        chatId:         chatId,
                        participantIds: [uid, user.uid],
                        updatedAt:      DateTime.now(),
                      ),
                    );
                    return _buildUserTile(
                      context, user, chat,
                      uid, isDark, scheme,
                    );
                  },
                ),
              ),
            ],
          ),


          const StatusScreen(),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.chat_rounded),
      ),
    );
  }

  Widget _buildUserTile(
      BuildContext context,
      UserModel user,
      ChatModel chat,
      String currentUid,
      bool isDark,
      ColorScheme scheme,
      ) {
    final lastMsgPreview = _getLastMessagePreview(chat, currentUid);
    final unreadCount    = chat.getUnreadCount(currentUid);
    final hasUnread      = unreadCount > 0;
    final timeStr        = chat.lastMessage != null
        ? _formatTime(chat.lastMessage!.timestamp)
        : '';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => ChatScreen(receiver: user),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end:   Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve:  Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child:   child,
              ),
            );
          },
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        child: Row(
          children: [

            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                  AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(
                      user.profileImageUrl)
                      : null,
                  child: user.profileImageUrl.isEmpty
                      ? Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.headingMedium
                        .copyWith(color: AppColors.primary),
                  )
                      : null,
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 1, right: 1,
                    child: Container(
                      width: 13, height: 13,
                      decoration: BoxDecoration(
                        color:  AppColors.online,
                        shape:  BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.chatName.copyWith(
                      color: scheme.onSurface,
                      fontWeight: hasUnread
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMsgPreview,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (timeStr.isNotEmpty)
                  Text(
                    timeStr,
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
                const SizedBox(height: 4),
                if (hasUnread)
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
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: AppTextStyles.unreadBadge,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:  AppColors.primary.withValues(alpha: 0.1),
              shape:  BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.noChats,
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              )),
          const SizedBox(height: 6),
          Text(AppStrings.noChatsSubtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              )),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 52,
              color: isDark
                  ? AppColors.textHintDark
                  : AppColors.textHintLight),
          const SizedBox(height: 12),
          Text('No results for "$_searchQuery"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              )),
        ],
      ),
    );
  }
}