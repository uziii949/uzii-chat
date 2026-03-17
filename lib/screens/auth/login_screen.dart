import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = context.read<AuthProvider>();
    final success = await auth.login(
      email:    _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _googleLogin() async {
    final auth    = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: 60),

                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  AppStrings.appName,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Sign in to continue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: 40),

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
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      size: 20,
                    ),
                  ),
                  validator: (v) =>
                  v!.isEmpty ? 'Email daalo' : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:  _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText:  'Password',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        size: 20,
                      ),
                      onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                  v!.isEmpty ? 'Password daalo' : null,
                ),

                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const ForgotPasswordScreen()),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width:  double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    child: auth.isLoading
                        ? const SizedBox(
                      width:  22,
                      height: 22,
                      child:  CircularProgressIndicator(
                        color:       Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Text(
                      AppStrings.login,
                      style: AppTextStyles.labelLarge.copyWith(
                        color:      Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      child: Text(
                        'OR',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width:  double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: auth.isLoading ? null : _googleLogin,
                    icon: const Icon(Icons.g_mobiledata, size: 26),
                    label: Text(
                      'Continue with Google',
                      style: AppTextStyles.labelLarge,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.onSurface,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.divider,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.register,
                        style: AppTextStyles.bodySmall.copyWith(
                          color:      AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}