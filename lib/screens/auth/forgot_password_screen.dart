import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey         = GlobalKey<FormState>();
  bool _emailSent        = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = context.read<AuthProvider>();
    final success = await auth.forgotPassword(
      _emailController.text.trim(),
    );
    if (mounted) {
      if (success) {
        setState(() => _emailSent = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(auth.errorMessage,
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: scheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Forgot Password',
            style: AppTextStyles.headingMedium.copyWith(
              color: scheme.onSurface,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _emailSent
              ? _buildSuccessState(isDark, scheme)
              : _buildFormState(auth, isDark, scheme),
        ),
      ),
    );
  }

  Widget _buildFormState(
      AuthProvider auth, bool isDark, ColorScheme scheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          const SizedBox(height: 40),

          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Reset Password',
            style: AppTextStyles.displayMedium.copyWith(
              color: scheme.onSurface,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Enter your email and we will\nsend you a reset link.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 36),

          TextFormField(
            controller:   _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyMedium.copyWith(
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText:  'Email',
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              prefixIcon: Icon(Icons.email_outlined,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  size: 20),
            ),
            validator: (v) =>
            v!.isEmpty ? 'Email daalo' : null,
          ),

          const SizedBox(height: 28),

          SizedBox(
            width:  double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _resetPassword,
              child: auth.isLoading
                  ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                'Send Reset Link',
                style: AppTextStyles.labelLarge.copyWith(
                  color:      Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back,
                color: AppColors.primary, size: 16),
            label: Text(
              'Back to Login',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSuccessState(bool isDark, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const SizedBox(height: 60),

        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.success,
            size: 50,
          ),
        ),

        const SizedBox(height: 28),

        Text(
          'Email Sent!',
          style: AppTextStyles.displayMedium.copyWith(
            color: scheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Password reset link has been sent\nto your email inbox.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _emailController.text,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 40),

        SizedBox(
          width:  double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back to Login',
              style: AppTextStyles.labelLarge.copyWith(
                color:      Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: Text(
            'Resend Email',
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}