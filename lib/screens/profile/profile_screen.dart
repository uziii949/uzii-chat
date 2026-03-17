import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../about/about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController  = TextEditingController();
  final _bioController   = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey         = GlobalKey<FormState>();
  bool _isEditing        = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<UserProvider>()
            .getUserProfile(auth.currentUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData(dynamic userProfile) {
    _nameController.text  = userProfile.name;
    _bioController.text   = userProfile.bio;
    _phoneController.text = userProfile.phone;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final auth         = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final success      = await userProvider.updateProfile(
      uid:   auth.currentUser!.uid,
      name:  _nameController.text.trim(),
      bio:   _bioController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (mounted) {
      if (success) {
        setState(() => _isEditing = false);
        _showSnack('Profile updated!');
      } else {
        _showSnack(userProvider.errorMessage, isError: true);
      }
    }
  }

  Future<void> _uploadPhoto() async {
    final auth         = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    await userProvider.uploadProfilePicture(
        uid: auth.currentUser!.uid);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: AppTextStyles.bodySmall
              .copyWith(color: Colors.white)),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
        isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Logout',
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            )),
        content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Logout',
                style: AppTextStyles.labelLarge
                    .copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1)   return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)    return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final auth         = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final userProfile  = userProvider.userProfile;
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final scheme       = Theme.of(context).colorScheme;

    if (userProfile != null && !_isEditing) {
      _loadUserData(userProfile);
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: Text('Profile',
            style: AppTextStyles.headingLarge.copyWith(
              color: scheme.onSurface,
            )),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit_outlined,
              color: _isEditing
                  ? AppColors.error : AppColors.primary,
            ),
            onPressed: () =>
                setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),

      body: userProvider.isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 12),

              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.3),
                          blurRadius:   20,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor:
                      AppColors.primary.withValues(alpha: 0.15),
                      backgroundImage:
                      userProfile?.profileImageUrl.isNotEmpty == true
                          ? CachedNetworkImageProvider(
                          userProfile!.profileImageUrl)
                          : null,
                      child: userProfile?.profileImageUrl.isEmpty != false
                          ? Text(
                        userProfile?.name.isNotEmpty == true
                            ? userProfile!.name[0].toUpperCase()
                            : 'U',
                        style: AppTextStyles.displayMedium
                            .copyWith(color: AppColors.primary),
                      )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: GestureDetector(
                      onTap: _uploadPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                userProfile?.name ?? 'Loading...',
                style: AppTextStyles.displayMedium.copyWith(
                  color: scheme.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: userProfile?.isOnline == true
                          ? AppColors.online
                          : AppColors.offline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    userProfile?.isOnline == true
                        ? 'Online' : 'Offline',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: userProfile?.isOnline == true
                          ? AppColors.online
                          : isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (userProfile != null &&
                      !userProfile.isOnline) ...[
                    const SizedBox(width: 8),
                    Text(
                      _formatLastSeen(userProfile.lastSeen),
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHintLight,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              _buildField(
                controller: _nameController,
                label:      'Full Name',
                icon:       Icons.person_outlined,
                enabled:    _isEditing,
                isDark:     isDark,
                validator:  (v) =>
                v!.isEmpty ? 'Name daalo' : null,
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _bioController,
                label:      'Bio',
                icon:       Icons.info_outlined,
                enabled:    _isEditing,
                isDark:     isDark,
                maxLines:   3,
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _phoneController,
                label:      'Phone Number',
                icon:       Icons.phone_outlined,
                enabled:    _isEditing,
                isDark:     isDark,
                keyboard:   TextInputType.phone,
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: TextEditingController(
                    text: auth.currentUser?.email ?? ''),
                label:   'Email',
                icon:    Icons.email_outlined,
                enabled: false,
                isDark:  isDark,
              ),

              const SizedBox(height: 32),

              if (_isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: userProvider.isLoading
                        ? null : _saveProfile,
                    child: userProvider.isLoading
                        ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Text('Save Profile',
                        style: AppTextStyles.labelLarge
                            .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              _buildSectionTitle('Settings', isDark),
              const SizedBox(height: 12),

              _buildSettingsTile(
                icon:      Icons.dark_mode_outlined,
                iconColor: AppColors.primary,
                title:     'Dark Mode',
                isDark:    isDark,
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.primary,
                ),
              ),

              _buildSettingsTile(
                icon:      Icons.notifications_outlined,
                iconColor: AppColors.accent,
                title:     'Notifications',
                isDark:    isDark,
                onTap:     () {},
              ),

              _buildSettingsTile(
                icon:      Icons.lock_outlined,
                iconColor: AppColors.warning,
                title:     'Privacy',
                isDark:    isDark,
                onTap:     () {},
              ),

              _buildSettingsTile(
                icon:      Icons.block,
                iconColor: AppColors.error,
                title:     'Blocked Users',
                isDark:    isDark,
                onTap:     () {},
              ),

              const SizedBox(height: 8),

              _buildSectionTitle('About', isDark),
              const SizedBox(height: 12),

              _buildSettingsTile(
                icon:      Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title:     'About Uzii Chat',
                isDark:    isDark,
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration:
                    const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) =>
                    const AboutScreen(),
                    transitionsBuilder:
                        (_, animation, __, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end:   Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve:  Curves.easeOutCubic,
                        )),
                        child: child,
                      );
                    },
                  ),
                ),
              ),

              _buildSettingsTile(
                icon:      Icons.info_outlined,
                iconColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                title:     AppStrings.appName,
                subtitle:  'Version 1.0.0',
                isDark:    isDark,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width:  double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showLogoutDialog(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size:  20,
                  ),
                  label: Text('Logout',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.error, width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required bool isDark,
    int maxLines          = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:   controller,
      enabled:      enabled,
      maxLines:     maxLines,
      keyboardType: keyboard,
      validator:    validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: enabled
            ? (isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight)
            : (isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight),
      ),
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        prefixIcon: Icon(icon,
            color: enabled
                ? AppColors.primary
                : (isDark
                ? AppColors.textHintDark
                : AppColors.textHintLight),
            size: 20),
        filled:    true,
        fillColor: enabled
            ? (isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight)
            : (isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.5)
            : AppColors.surfaceLight.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.dividerDark : AppColors.divider,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: AppColors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.dividerDark.withValues(alpha: 0.5)
                : AppColors.divider.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark : AppColors.divider,
          width: 0.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            )),
        subtitle: subtitle != null
            ? Text(subtitle,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ))
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right,
                color: isDark
                    ? AppColors.textHintDark
                    : AppColors.textHintLight,
                size: 18)
                : null),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}