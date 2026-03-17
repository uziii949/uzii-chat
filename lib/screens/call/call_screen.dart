import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final String callerName;
  final bool   isVideoCall;
  final bool   isCaller;

  const CallScreen({
    super.key,
    required this.channelName,
    required this.callerName,
    required this.isVideoCall,
    required this.isCaller,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with TickerProviderStateMixin {

  bool _isMuted      = false;
  bool _isSpeaker    = false;
  bool _isCameraOff  = false;
  bool _isConnected  = false;
  int  _callDuration = 0;

  late AnimationController _pulseController;
  late Animation<double>   _pulseAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _pulseController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(
      parent: _pulseController,
      curve:  Curves.easeInOut,
    ));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isConnected = true);
      _startTimer();
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isConnected) return false;
      setState(() => _callDuration++);
      return true;
    });
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0E17),
              Color(0xFF1A1235),
              Color(0xFF0F0E17),
            ],
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white, size: 24,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isVideoCall
                                    ? Icons.videocam_rounded
                                    : Icons.call_rounded,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.isVideoCall
                                    ? 'Video Call'
                                    : 'Voice Call',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isConnected
                            ? 1.0 : _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_isConnected)
                          Container(
                            width: 160, height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                          ),
                        if (!_isConnected)
                          Container(
                            width: 144, height: 144,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.4),
                                blurRadius:   30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.callerName.isNotEmpty
                                  ? widget.callerName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.displayLarge
                                  .copyWith(
                                color:      Colors.white,
                                fontSize:   52,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    widget.callerName,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isConnected
                        ? Row(
                      key: const ValueKey('connected'),
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.online,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_callDuration),
                          style: AppTextStyles.bodyLarge
                              .copyWith(
                            color: AppColors.online,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      key: const ValueKey('calling'),
                      widget.isCaller
                          ? 'Calling...'
                          : 'Incoming call...',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlBtn(
                              icon:   _isMuted
                                  ? Icons.mic_off_rounded
                                  : Icons.mic_rounded,
                              label:  _isMuted ? 'Unmute' : 'Mute',
                              active: _isMuted,
                              onTap: () => setState(
                                      () => _isMuted = !_isMuted),
                            ),
                            if (widget.isVideoCall)
                              _buildControlBtn(
                                icon:   _isCameraOff
                                    ? Icons.videocam_off_rounded
                                    : Icons.videocam_rounded,
                                label:  _isCameraOff
                                    ? 'Camera On'
                                    : 'Camera Off',
                                active: _isCameraOff,
                                onTap: () => setState(
                                        () => _isCameraOff = !_isCameraOff),
                              ),
                            _buildControlBtn(
                              icon:   _isSpeaker
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_down_rounded,
                              label:  _isSpeaker
                                  ? 'Speaker On'
                                  : 'Speaker',
                              active: _isSpeaker,
                              onTap: () => setState(
                                      () => _isSpeaker = !_isSpeaker),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error
                                      .withValues(alpha: 0.4),
                                  blurRadius:   20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.call_end_rounded,
                              color: Colors.white,
                              size:  32,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'End Call',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58, height: 58,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(icon,
                color: active
                    ? AppColors.primaryLight
                    : Colors.white,
                size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white54,
              )),
        ],
      ),
    );
  }
}