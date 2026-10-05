import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../state/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    final resetFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: resetFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your admin email address to receive password reset instructions.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: resetEmailController,
                label: 'Admin Email',
                hint: 'admin@nexa.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!resetFormKey.currentState!.validate()) return;
              final auth = context.read<AuthProvider>();
              final success = await auth.resetPassword(resetEmailController.text);
              if (dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password reset email sent. Please check your inbox.'
                          : (auth.errorMessage ?? 'Failed to send reset email'),
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon & Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'NEXA Admin Lite',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in with your administrator credentials',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Error banner if any
                    if (auth.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: auth.clearError,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Admin Email',
                      hint: 'admin@nexa.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    CustomButton(
                      text: 'Sign In',
                      isLoading: auth.isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 24),

                    // Security note footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Secured with Firebase Enterprise Authentication',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
