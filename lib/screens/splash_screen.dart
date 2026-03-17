import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/auth/login_screen.dart';
import '../screens/chat/home_screen.dart';
import '../app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve:  Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve:  const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _textController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve:  Curves.easeIn,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end:   Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve:  Curves.easeOut,
      ),
    );
    _taglineController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 500),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve:  Curves.easeIn,
      ),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => const AuthWrapper(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SizedBox(
          width:  double.infinity,
          height: double.infinity,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.splashGradient,
            ),
            child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width:  96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient:     AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color:      AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset:     const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_rounded,
                    color: Colors.white,
                    size:  48,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: SlideTransition(
                      position: _textSlide,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Uzii Chat',
                  style: AppTextStyles.displayLarge.copyWith(
                    color:          Colors.white,
                    letterSpacing:  -1,
                    fontWeight:     FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 8),


              AnimatedBuilder(
                animation: _taglineController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _taglineOpacity.value,
                    child: child,
                  );
                },
                child: Text(
                  'Connect Instantly',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:         AppColors.primaryLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              AnimatedBuilder(
                animation: _taglineController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _taglineOpacity.value,
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    children: [
                      SizedBox(
                        width:  24,
                        height: 24,
                        child:  CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading...',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    ));
  }
}