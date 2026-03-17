import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  const UnreadBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(
        minWidth:  20,
        minHeight: 20,
      ),
      decoration: BoxDecoration(
        color:        AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: AppTextStyles.unreadBadge,
        textAlign: TextAlign.center,
      ),
    );
  }
}