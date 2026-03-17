import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text('About',
            style: AppTextStyles.headingMedium.copyWith(
              color: scheme.onSurface,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 20),

            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            Text('Uzii Chat',
                style: AppTextStyles.headingLarge.copyWith(
                  color: scheme.onSurface,
                  fontSize: 28,
                )),

            const SizedBox(height: 6),

            Text('Version 1.0.0',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                )),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Connect. Chat. Share.',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  )),
            ),

            const SizedBox(height: 40),

            _buildCard(
              isDark: isDark,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                    AppColors.primary.withValues(alpha: 0.15),
                    child: Text('U',
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.primary,
                          fontSize: 30,
                        )),
                  ),
                  const SizedBox(height: 12),
                  Text('Uzair',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: scheme.onSurface,
                      )),
                  const SizedBox(height: 4),
                  Text('Flutter Developer',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      )),
                  const SizedBox(height: 4),
                  Text('Pakistan 🇵🇰',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Tech Stack', isDark),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Flutter',
                      'Firebase',
                      'Firestore',
                      'Cloudinary',
                      'Provider',
                      'FCM',
                    ].map((tech) => _techChip(tech)).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Features', isDark),
                  const SizedBox(height: 12),
                  ...[
                    ('💬', 'Real-time messaging'),
                    ('📸', 'Photo & video sharing'),
                    ('🎵', 'Voice messages'),
                    ('🔔', 'Push notifications'),
                    ('⭕', 'Status / Stories'),
                    ('✍️', 'Typing indicator'),
                    ('↩️', 'Message reply'),
                    ('🌙', 'Dark mode'),
                    ('🔒', 'Block / Unblock'),
                  ].map((item) => _featureRow(item.$1, item.$2, isDark)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildCard(
              isDark: isDark,
              child: Column(
                children: [
                  _infoRow(Icons.info_outline,
                      'Version', '1.0.0', isDark),
                  _divider(isDark),
                  _infoRow(Icons.phone_android,
                      'Platform', 'Android & iOS', isDark),
                  _divider(isDark),
                  _infoRow(Icons.code,
                      'Framework', 'Flutter 3.x', isDark),
                  _divider(isDark),
                  _infoRow(Icons.storage,
                      'Backend', 'Firebase', isDark),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text('Made  by Uzair',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                )),
            const SizedBox(height: 4),
            Text('© 2026 Uzii Chat',
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.textHintDark
                      : AppColors.textHintLight,
                )),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : AppColors.divider,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(title,
        style: AppTextStyles.headingSmall.copyWith(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ));
  }

  Widget _techChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
          )),
    );
  }

  Widget _featureRow(String emoji, String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              )),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label,
      String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              )),
          const Spacer(),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      color: isDark
          ? AppColors.dividerDark : AppColors.divider,
      height: 1,
    );
  }
}