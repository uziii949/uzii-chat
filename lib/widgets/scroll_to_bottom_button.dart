import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;

  const ScrollToBottomButton({
    super.key,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:      AppColors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size:  24,
            ),
          ),


          if (unreadCount > 0)
            Positioned(
              top:   -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth:  18,
                  minHeight: 18,
                ),
                decoration: BoxDecoration(
                  color:        AppColors.error,
                  shape:        BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    fontSize:   9,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}