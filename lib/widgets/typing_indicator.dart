import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TypingIndicator extends StatefulWidget {
  final String name;
  const TypingIndicator({super.key, required this.name});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {

  late List<AnimationController> _controllers;
  late List<Animation<double>>   _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) =>
        AnimationController(
          vsync:    this,
          duration: const Duration(milliseconds: 400),
        ),
    );

    _animations = _controllers.map((c) =>
        Tween<double>(begin: 0, end: -6).animate(
          CurvedAnimation(parent: c, curve: Curves.easeInOut),
        ),
    ).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) break;
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 150));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      for (final c in _controllers) {
        if (!mounted) break;
        c.reverse();
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.bubbleReceivedDark
                  : AppColors.bubbleReceivedLight,
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(18),
                topRight:    Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft:  Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset:     const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animations[i].value),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: i < 2 ? 4 : 0),
                        width:  7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.name} typing...',
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}