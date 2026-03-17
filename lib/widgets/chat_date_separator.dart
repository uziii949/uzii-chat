import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ChatDateSeparator extends StatelessWidget {
  final DateTime date;
  const ChatDateSeparator({super.key, required this.date});

  String _getLabel() {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate   = DateTime(date.year, date.month, date.day);

    if (msgDate == today)     return 'Today';
    if (msgDate == yesterday) return 'Yesterday';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark
                  ? AppColors.dividerDark
                  : AppColors.divider,
              thickness: 0.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.dividerDark
                    : AppColors.divider,
                width: 0.5,
              ),
            ),
            child: Text(
              _getLabel(),
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: isDark
                  ? AppColors.dividerDark
                  : AppColors.divider,
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}