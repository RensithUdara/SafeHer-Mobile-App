import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthController>(
          builder: (context, authController, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo and Title Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Lottie.asset(
                            'assets/animations/shield_protection.json',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.shield,
                                size: 60,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // App Name
                        const Text(
                          'SafeHer',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          'Your Safety, Our Priority',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Login Form
                  SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome Text
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // Email Field
                          AppTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onSubmitted: (_) => _handleLogin(authController),
                          ),
                          const SizedBox(height: 16),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.toNamed('/forgot-password'),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Login Button
                          AppButton(
                            text: 'Sign In',
                            isLoading: authController.isLoading,
                            onPressed: () => _handleLogin(authController),
                          ),

                          // Error Message
                          if (authController.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authController.errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),

                          // Divider
                          const Row(
                            children: [
                              Expanded(
                                child: Divider(color: AppColors.grey300),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: AppColors.grey300),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Social Login Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  icon: 'assets/icons/google.png',
                                  label: 'Google',
                                  onPressed: () =>
                                      _handleGoogleLogin(authController),
                                  isLoading: authController.isLoading,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSocialButton(
                                  icon: 'assets/icons/facebook.png',
                                  label: 'Facebook',
                                  onPressed: () =>
                                      _handleFacebookLogin(authController),
                                  isLoading: authController.isLoading,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Sign Up Link
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/signup'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    label == 'Google' ? Icons.g_mobiledata : Icons.facebook,
                    size: 20,
                    color: AppColors.primary,
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthController authController) async {
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous errors
    authController.clearError();

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Perform login
    final success = await authController.loginWithEmailPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      // Add haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to main screen
      Get.offAllNamed('/main-navigation');
    }
  }

  Future<void> _handleGoogleLogin(AuthController authController) async {
    authController.clearError();

    final success = await authController.signInWithGoogle();

    if (success) {
      HapticFeedback.lightImpact();
      Get.offAllNamed('/main-navigation');
    }
  }

  Future<void> _handleFacebookLogin(AuthController authController) async {
    authController.clearError();

    final success = await authController.signInWithFacebook();

    if (success) {
      HapticFeedback.lightImpact();
      Get.offAllNamed('/main-navigation');
    }
  }
}
