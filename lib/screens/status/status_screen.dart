import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../models/status_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/status_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<StatusProvider>().loadStatuses(uid);
      }
    });
  }

  void _showAddStatusOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
      isDark ? AppColors.cardDark : AppColors.cardLight,
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
                    ? AppColors.textHintDark
                    : AppColors.textHintLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Add Status',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  )),
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.image_rounded,
                    color: AppColors.primary),
              ),
              title: Text('Photo Status',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  )),
              subtitle: Text('Share a photo',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  )),
              onTap: () {
                Navigator.pop(context);
                _uploadImageStatus();
              },
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.text_fields_rounded,
                    color: AppColors.accent),
              ),
              title: Text('Text Status',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  )),
              subtitle: Text('Share a thought',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  )),
              onTap: () {
                Navigator.pop(context);
                _showTextStatusDialog();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImageStatus() async {
    final auth         = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final profile      = userProvider.userProfile;
    final uid          = auth.currentUser?.uid;
    if (uid == null) return;

    final success = await context.read<StatusProvider>()
        .uploadImageStatus(
      uid:       uid,
      userName:  profile?.name  ?? 'User',
      userImage: profile?.profileImageUrl ?? '',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          success ? 'Status uploaded!' : 'Upload failed',
          style: AppTextStyles.bodySmall
              .copyWith(color: Colors.white),
        ),
        backgroundColor:
        success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _showTextStatusDialog() {
    final controller = TextEditingController();
    int selectedColor = 0xFF6C63FF;
    final colors = [
      0xFF6C63FF, 0xFF00D9A6, 0xFFFF4D6D,
      0xFFFFB347, 0xFF4B44CC, 0xFF0F0E17,
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor:
          isDark ? AppColors.cardDark : AppColors.cardLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text('Text Status',
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(selectedColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    controller.text.isEmpty
                        ? 'Your status...'
                        : controller.text,
                    style: AppTextStyles.headingMedium
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(
                            color: AppColors.primary,
                            width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLength:  150,
                maxLines:   3,
                onChanged:  (_) => setDialogState(() {}),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your status...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textHintDark
                        : AppColors.textHintLight,
                  ),
                  filled:    true,
                  fillColor: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:   BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(context);
                final auth         = context.read<AuthProvider>();
                final userProvider = context.read<UserProvider>();
                final profile      = userProvider.userProfile;
                final uid          = auth.currentUser?.uid;
                if (uid == null) return;
                await context.read<StatusProvider>()
                    .uploadTextStatus(
                  uid:             uid,
                  userName:        profile?.name ?? 'User',
                  userImage:       profile?.profileImageUrl ?? '',
                  text:            controller.text.trim(),
                  backgroundColor: selectedColor,
                );
              },
              child: Text('Post',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid        = context.read<AuthProvider>().currentUser?.uid ?? '';
    final provider   = context.watch<StatusProvider>();
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final myStatuses = provider.myStatuses(uid);
    final others     = provider.latestStatusPerUser(uid);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            child: Text('My Status',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  letterSpacing: 1,
                )),
          ),

          ListTile(
            onTap: myStatuses.isEmpty
                ? _showAddStatusOptions
                : () => _viewStatuses(myStatuses, uid),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: myStatuses.isEmpty
                      ? const Icon(Icons.person,
                      color: AppColors.primary)
                      : null,
                ),
                if (myStatuses.isEmpty)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(
                        color:  AppColors.primary,
                        shape:  BoxShape.circle,
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 14),
                    ),
                  ),
                if (myStatuses.isNotEmpty)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              myStatuses.isEmpty ? 'My Status' : 'My Status',
              style: AppTextStyles.chatName.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            subtitle: Text(
              myStatuses.isEmpty
                  ? 'Tap to add status update'
                  : '${myStatuses.length} status update${myStatuses.length > 1 ? 's' : ''}',
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary),
              onPressed: _showAddStatusOptions,
            ),
          ),

          if (provider.isUploading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Uploading status...',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      )),
                ],
              ),
            ),

          const Divider(height: 24),

          if (others.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              child: Text('Recent Updates',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    letterSpacing: 1,
                  )),
            ),
            ...others.map((status) =>
                _buildStatusTile(status, uid, isDark)),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.circle_outlined,
                        size: 52,
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHintLight),
                    const SizedBox(height: 12),
                    Text('No recent updates',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStatusOptions,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildStatusTile(
      StatusModel status, String currentUid, bool isDark) {
    final userStatuses = context
        .read<StatusProvider>()
        .allStatuses
        .where((s) => s.userId == status.userId)
        .toList();
    final hasSeen = status.seenBy.contains(currentUid);

    return ListTile(
      onTap: () => _viewStatuses(userStatuses, currentUid),
      leading: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasSeen
                ? AppColors.textHintLight
                : AppColors.primary,
            width: 2.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.15),
            backgroundImage: status.userImage.isNotEmpty
                ? CachedNetworkImageProvider(status.userImage)
                : null,
            child: status.userImage.isEmpty
                ? Text(
              status.userName.isNotEmpty
                  ? status.userName[0].toUpperCase()
                  : '?',
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.primary),
            )
                : null,
          ),
        ),
      ),
      title: Text(status.userName,
          style: AppTextStyles.chatName.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          )),
      subtitle: Text(
        _formatStatusTime(status.createdAt),
        style: AppTextStyles.caption.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  void _viewStatuses(List<StatusModel> statuses, String currentUid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatusViewScreen(
          statuses:   statuses,
          currentUid: currentUid,
        ),
      ),
    );
  }

  String _formatStatusTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inHours < 1)    return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)     return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class StatusViewScreen extends StatefulWidget {
  final List<StatusModel> statuses;
  final String            currentUid;

  const StatusViewScreen({
    super.key,
    required this.statuses,
    required this.currentUid,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _progressController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 5),
    );
    _startProgress();
    _markCurrentAsSeen();
  }

  void _startProgress() {
    _progressController.forward(from: 0);
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStatus();
      }
    });
  }

  void _nextStatus() {
    if (_currentIndex < widget.statuses.length - 1) {
      setState(() => _currentIndex++);
      _markCurrentAsSeen();
      _progressController.forward(from: 0);
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStatus() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _progressController.forward(from: 0);
    }
  }

  void _markCurrentAsSeen() {
    final status = widget.statuses[_currentIndex];
    if (!status.seenBy.contains(widget.currentUid)) {
      context.read<StatusProvider>().markAsSeen(
        statusId: status.statusId,
        viewerId: widget.currentUid,
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status  = widget.statuses[_currentIndex];
    final isMyStatus = status.userId == widget.currentUid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            _previousStatus();
          } else {
            _nextStatus();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [

            status.type == StatusType.image
                ? CachedNetworkImage(
              imageUrl:   status.content,
              fit:        BoxFit.cover,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
            )
                : Container(
              color: Color(
                  status.backgroundColor ?? 0xFF6C63FF),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    status.content,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   28,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8, right: 8,
              child: Row(
                children: List.generate(
                  widget.statuses.length,
                      (i) => Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 2),
                      child: i < _currentIndex
                          ? Container(color: Colors.white)
                          : i == _currentIndex
                          ? AnimatedBuilder(
                        animation: _progressController,
                        builder: (_, __) =>
                            LinearProgressIndicator(
                              value: _progressController.value,
                              backgroundColor:
                              Colors.white38,
                              valueColor:
                              const AlwaysStoppedAnimation(
                                  Colors.white),
                              minHeight: 2,
                            ),
                      )
                          : Container(
                          color: Colors.white38),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 16, right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                    AppColors.primary.withOpacity(0.3),
                    backgroundImage: status.userImage.isNotEmpty
                        ? CachedNetworkImageProvider(
                        status.userImage)
                        : null,
                    child: status.userImage.isEmpty
                        ? Text(
                      status.userName.isNotEmpty
                          ? status.userName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white),
                    )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status.userName,
                            style: const TextStyle(
                              color:      Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize:   14,
                            )),
                        Text(
                          _formatTime(status.createdAt),
                          style: const TextStyle(
                            color:    Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                  if (isMyStatus)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.white),
                      onPressed: () async {
                        await context
                            .read<StatusProvider>()
                            .deleteStatus(status.statusId);
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),


            if (status.caption != null &&
                status.caption!.isNotEmpty)
              Positioned(
                bottom: 80,
                left: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:        Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.caption!,
                    style: const TextStyle(
                      color:    Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            if (isMyStatus)
              Positioned(
                bottom: 30,
                left: 16, right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.remove_red_eye_outlined,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${status.seenBy.length} seen',
                      style: const TextStyle(
                        color:    Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inHours < 1)    return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}