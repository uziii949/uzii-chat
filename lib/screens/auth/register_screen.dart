import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _phoneController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey                   = GlobalKey<FormState>();

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = context.read<AuthProvider>();
    final success = await auth.register(
      email:    _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name:     _nameController.text.trim(),
      phone:    _phoneController.text.trim(),
    );
    if (!success && mounted) {
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: 8),

                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Create Account',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Sign up to get started',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: 32),

                _buildField(
                  controller: _nameController,
                  label:      'Full Name',
                  icon:       Icons.person_outlined,
                  isDark:     isDark,
                  scheme:     scheme,
                  validator:  (v) =>
                  v!.isEmpty ? 'Name daalo' : null,
                ),

                const SizedBox(height: 14),

                _buildField(
                  controller: _emailController,
                  label:      'Email',
                  icon:       Icons.email_outlined,
                  isDark:     isDark,
                  scheme:     scheme,
                  keyboard:   TextInputType.emailAddress,
                  validator:  (v) =>
                  v!.isEmpty ? 'Email daalo' : null,
                ),

                const SizedBox(height: 14),

                _buildField(
                  controller: _phoneController,
                  label:      'Phone Number',
                  icon:       Icons.phone_outlined,
                  isDark:     isDark,
                  scheme:     scheme,
                  keyboard:   TextInputType.phone,
                  validator:  (v) =>
                  v!.isEmpty ? 'Phone daalo' : null,
                ),

                const SizedBox(height: 14),

                _buildPasswordField(
                  controller: _passwordController,
                  label:      'Password',
                  obscure:    _obscurePassword,
                  isDark:     isDark,
                  scheme:     scheme,
                  onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                  validator: (v) =>
                  v!.length < 6 ? 'Min 6 characters' : null,
                ),

                const SizedBox(height: 14),

                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label:      'Confirm Password',
                  obscure:    _obscureConfirmPassword,
                  isDark:     isDark,
                  scheme:     scheme,
                  onToggle: () => setState(() =>
                  _obscureConfirmPassword =
                  !_obscureConfirmPassword),
                  validator: (v) =>
                  v != _passwordController.text
                      ? 'Passwords match nahi kar rahe'
                      : null,
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width:  double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _register,
                    child: auth.isLoading
                        ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Text(
                      AppStrings.register,
                      style: AppTextStyles.labelLarge.copyWith(
                        color:      Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.login,
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required ColorScheme scheme,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:   controller,
      keyboardType: keyboard,
      validator:    validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: scheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        prefixIcon: Icon(icon,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            size: 20),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required bool isDark,
    required ColorScheme scheme,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:  controller,
      obscureText: obscure,
      validator:   validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: scheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        prefixIcon: Icon(Icons.lock_outlined,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}