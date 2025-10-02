import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:provider/provider.dart';import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';

import '../../widgets/common_widgets.dart';import '../../controllers/auth_controller.dart';

import '../../utils/theme.dart';import '../../utils/theme.dart';

import '../../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({Key? key}) : super(key: key);class RegisterScreen extends StatefulWidget {

  const RegisterScreen({super.key});

  @override

  State<RegisterScreen> createState() => _RegisterScreenState();  @override

}  State<RegisterScreen> createState() => _RegisterScreenState();

}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();class _RegisterScreenState extends State<RegisterScreen> {

  final _nameController = TextEditingController();  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();  final _nameController = TextEditingController();

  final _phoneController = TextEditingController();  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();  final _phoneController = TextEditingController();

  final _confirmPasswordController = TextEditingController();  final _passwordController = TextEditingController();

    final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;  bool _obscurePassword = true;

  bool _agreeToTerms = false;  bool _obscureConfirmPassword = true;

  bool _agreeToTerms = false;

  @override

  void dispose() {  @override

    _nameController.dispose();  void dispose() {

    _emailController.dispose();    _nameController.dispose();

    _phoneController.dispose();    _emailController.dispose();

    _passwordController.dispose();    _phoneController.dispose();

    _confirmPasswordController.dispose();    _passwordController.dispose();

    super.dispose();    _confirmPasswordController.dispose();

  }    super.dispose();

  }

  void _register() async {

    if (!_formKey.currentState!.validate()) {  void _register() async {

      return;    if (!_formKey.currentState!.validate()) {

    }      return;

    }

    if (!_agreeToTerms) {

      ScaffoldMessenger.of(context).showSnackBar(    if (!_agreeToTerms) {

        const SnackBar(      ScaffoldMessenger.of(context).showSnackBar(

          content: Text('Please agree to the Terms and Privacy Policy'),        const SnackBar(

          backgroundColor: Colors.red,          content: Text('Please agree to the Terms and Privacy Policy'),

        ),          backgroundColor: Colors.red,

      );        ),

      return;      );

    }      return;

    }

    try {

      final success = await context.read<AuthController>().registerUser(    try {

        name: _nameController.text.trim(),      final success = await context.read<AuthController>().signUp(

        email: _emailController.text.trim(),            name: _nameController.text.trim(),

        password: _passwordController.text,            email: _emailController.text.trim(),

        phoneNumber: _phoneController.text.trim(),            password: _passwordController.text,

      );            phoneNumber: _phoneController.text.trim(),

          );

      if (success && mounted) {

        Navigator.of(context).pushReplacementNamed('/main');      if (success && mounted) {

      }        Navigator.of(context).pushReplacementNamed('/main');

    } catch (e) {      }

      if (mounted) {    } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(      if (mounted) {

          SnackBar(        ScaffoldMessenger.of(context).showSnackBar(

            content: Text('Registration failed: ${e.toString()}'),          SnackBar(

            backgroundColor: Colors.red,            content: Text('Registration failed: ${e.toString()}'),

          ),            backgroundColor: Colors.red,

        );          ),

      }        );

    }      }

  }    }

  }

  @override

  Widget build(BuildContext context) {  @override

    return Scaffold(  Widget build(BuildContext context) {

      body: SafeArea(    return Scaffold(

        child: SingleChildScrollView(      body: SafeArea(

          padding: const EdgeInsets.all(24),        child: SingleChildScrollView(

          child: Form(          padding: const EdgeInsets.all(24),

            key: _formKey,          child: Form(

            child: Column(            key: _formKey,

              crossAxisAlignment: CrossAxisAlignment.start,            child: Column(

              children: [              crossAxisAlignment: CrossAxisAlignment.start,

                const SizedBox(height: 40),              children: [

                                const SizedBox(height: 40),

                // Header

                Center(                // Header

                  child: Column(                Center(

                    children: [                  child: Column(

                      Container(                    children: [

                        padding: const EdgeInsets.all(20),                      Container(

                        decoration: BoxDecoration(                        padding: const EdgeInsets.all(20),

                          color: AppColors.primary.withOpacity(0.1),                        decoration: BoxDecoration(

                          shape: BoxShape.circle,                          color: AppColors.primary.withOpacity(0.1),

                        ),                          shape: BoxShape.circle,

                        child: Icon(                        ),

                          Icons.shield,                        child: const Icon(

                          size: 60,                          Icons.shield,

                          color: AppColors.primary,                          size: 60,

                        ),                          color: AppColors.primary,

                      ),                        ),

                      const SizedBox(height: 24),                      ),

                      Text(                      const SizedBox(height: 24),

                        'Create Account',                      const Text(

                        style: TextStyle(                        'Create Account',

                          fontSize: 28,                        style: TextStyle(

                          fontWeight: FontWeight.bold,                          fontSize: 28,

                          color: AppColors.primary,                          fontWeight: FontWeight.bold,

                        ),                          color: AppColors.primary,

                      ),                        ),

                      const SizedBox(height: 8),                      ),

                      Text(                      const SizedBox(height: 8),

                        'Join SafeHer community and stay protected',                      Text(

                        style: TextStyle(                        'Join SafeHer community and stay protected',

                          fontSize: 16,                        style: TextStyle(

                          color: Colors.grey[600],                          fontSize: 16,

                        ),                          color: Colors.grey[600],

                        textAlign: TextAlign.center,                        ),

                      ),                        textAlign: TextAlign.center,

                    ],                      ),

                  ),                    ],

                ),                  ),

                                ),

                const SizedBox(height: 40),

                const SizedBox(height: 40),

                // Full Name Field

                AppTextField(                // Full Name Field

                  controller: _nameController,                AppTextField(

                  label: 'Full Name',                  controller: _nameController,

                  prefixIcon: const Icon(Icons.person_outline),                  label: 'Full Name',

                  validator: (value) {                  prefixIcon: const Icon(Icons.person_outline),

                    if (value?.isEmpty ?? true) {                  validator: (value) {

                      return 'Please enter your full name';                    if (value?.isEmpty ?? true) {

                    }                      return 'Please enter your full name';

                    if (value!.length < 2) {                    }

                      return 'Name must be at least 2 characters';                    if (value!.length < 2) {

                    }                      return 'Name must be at least 2 characters';

                    return null;                    }

                  },                    return null;

                ),                  },

                                ),

                const SizedBox(height: 16),

                const SizedBox(height: 16),

                // Email Field

                AppTextField(                // Email Field

                  controller: _emailController,                AppTextField(

                  label: 'Email Address',                  controller: _emailController,

                  prefixIcon: const Icon(Icons.email_outlined),                  labelText: 'Email Address',

                  keyboardType: TextInputType.emailAddress,                  prefixIcon: Icons.email_outlined,

                  validator: (value) {                  keyboardType: TextInputType.emailAddress,

                    if (value?.isEmpty ?? true) {                  validator: (value) {

                      return 'Please enter your email';                    if (value?.isEmpty ?? true) {

                    }                      return 'Please enter your email';

                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {                    }

                      return 'Please enter a valid email address';                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')

                    }                        .hasMatch(value!)) {

                    return null;                      return 'Please enter a valid email address';

                  },                    }

                ),                    return null;

                                  },

                const SizedBox(height: 16),                ),



                // Phone Number Field                const SizedBox(height: 16),

                AppTextField(

                  controller: _phoneController,                // Phone Number Field

                  label: 'Phone Number',                AppTextField(

                  prefixIcon: const Icon(Icons.phone_outlined),                  controller: _phoneController,

                  keyboardType: TextInputType.phone,                  labelText: 'Phone Number',

                  validator: (value) {                  prefixIcon: Icons.phone_outlined,

                    if (value?.isEmpty ?? true) {                  keyboardType: TextInputType.phone,

                      return 'Please enter your phone number';                  validator: (value) {

                    }                    if (value?.isEmpty ?? true) {

                    if (value!.length < 10) {                      return 'Please enter your phone number';

                      return 'Please enter a valid phone number';                    }

                    }                    if (value!.length < 10) {

                    return null;                      return 'Please enter a valid phone number';

                  },                    }

                ),                    return null;

                                  },

                const SizedBox(height: 16),                ),



                // Password Field                const SizedBox(height: 16),

                AppTextField(

                  controller: _passwordController,                // Password Field

                  label: 'Password',                AppTextField(

                  prefixIcon: const Icon(Icons.lock_outline),                  controller: _passwordController,

                  obscureText: _obscurePassword,                  labelText: 'Password',

                  suffixIcon: IconButton(                  prefixIcon: Icons.lock_outline,

                    onPressed: () {                  obscureText: _obscurePassword,

                      setState(() {                  suffixIcon: IconButton(

                        _obscurePassword = !_obscurePassword;                    onPressed: () {

                      });                      setState(() {

                    },                        _obscurePassword = !_obscurePassword;

                    icon: Icon(                      });

                      _obscurePassword ? Icons.visibility : Icons.visibility_off,                    },

                    ),                    icon: Icon(

                  ),                      _obscurePassword

                  validator: (value) {                          ? Icons.visibility

                    if (value?.isEmpty ?? true) {                          : Icons.visibility_off,

                      return 'Please enter a password';                    ),

                    }                  ),

                    if (value!.length < 6) {                  validator: (value) {

                      return 'Password must be at least 6 characters';                    if (value?.isEmpty ?? true) {

                    }                      return 'Please enter a password';

                    return null;                    }

                  },                    if (value!.length < 6) {

                ),                      return 'Password must be at least 6 characters';

                                    }

                const SizedBox(height: 16),                    return null;

                  },

                // Confirm Password Field                ),

                AppTextField(

                  controller: _confirmPasswordController,                const SizedBox(height: 16),

                  label: 'Confirm Password',

                  prefixIcon: const Icon(Icons.lock_outline),                // Confirm Password Field

                  obscureText: _obscureConfirmPassword,                AppTextField(

                  suffixIcon: IconButton(                  controller: _confirmPasswordController,

                    onPressed: () {                  labelText: 'Confirm Password',

                      setState(() {                  prefixIcon: Icons.lock_outline,

                        _obscureConfirmPassword = !_obscureConfirmPassword;                  obscureText: _obscureConfirmPassword,

                      });                  suffixIcon: IconButton(

                    },                    onPressed: () {

                    icon: Icon(                      setState(() {

                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,                        _obscureConfirmPassword = !_obscureConfirmPassword;

                    ),                      });

                  ),                    },

                  validator: (value) {                    icon: Icon(

                    if (value?.isEmpty ?? true) {                      _obscureConfirmPassword

                      return 'Please confirm your password';                          ? Icons.visibility

                    }                          : Icons.visibility_off,

                    if (value != _passwordController.text) {                    ),

                      return 'Passwords do not match';                  ),

                    }                  validator: (value) {

                    return null;                    if (value?.isEmpty ?? true) {

                  },                      return 'Please confirm your password';

                ),                    }

                                    if (value != _passwordController.text) {

                const SizedBox(height: 24),                      return 'Passwords do not match';

                    }

                // Terms and Privacy Policy                    return null;

                Row(                  },

                  crossAxisAlignment: CrossAxisAlignment.start,                ),

                  children: [

                    Checkbox(                const SizedBox(height: 24),

                      value: _agreeToTerms,

                      onChanged: (value) {                // Terms and Privacy Policy

                        setState(() {                Row(

                          _agreeToTerms = value!;                  crossAxisAlignment: CrossAxisAlignment.start,

                        });                  children: [

                      },                    Checkbox(

                      activeColor: AppColors.primary,                      value: _agreeToTerms,

                    ),                      onChanged: (value) {

                    Expanded(                        setState(() {

                      child: GestureDetector(                          _agreeToTerms = value!;

                        onTap: () {                        });

                          setState(() {                      },

                            _agreeToTerms = !_agreeToTerms;                      activeColor: AppTheme.primaryColor,

                          });                    ),

                        },                    Expanded(

                        child: Padding(                      child: GestureDetector(

                          padding: const EdgeInsets.only(top: 12),                        onTap: () {

                          child: Text.rich(                          setState(() {

                            TextSpan(                            _agreeToTerms = !_agreeToTerms;

                              text: 'I agree to the ',                          });

                              style: const TextStyle(fontSize: 14),                        },

                              children: [                        child: Padding(

                                TextSpan(                          padding: const EdgeInsets.only(top: 12),

                                  text: 'Terms of Service',                          child: Text.rich(

                                  style: TextStyle(                            TextSpan(

                                    color: AppColors.primary,                              text: 'I agree to the ',

                                    fontWeight: FontWeight.w600,                              style: const TextStyle(fontSize: 14),

                                    decoration: TextDecoration.underline,                              children: [

                                  ),                                TextSpan(

                                ),                                  text: 'Terms of Service',

                                const TextSpan(text: ' and '),                                  style: TextStyle(

                                TextSpan(                                    color: AppTheme.primaryColor,

                                  text: 'Privacy Policy',                                    fontWeight: FontWeight.w600,

                                  style: TextStyle(                                    decoration: TextDecoration.underline,

                                    color: AppColors.primary,                                  ),

                                    fontWeight: FontWeight.w600,                                ),

                                    decoration: TextDecoration.underline,                                const TextSpan(text: ' and '),

                                  ),                                TextSpan(

                                ),                                  text: 'Privacy Policy',

                              ],                                  style: TextStyle(

                            ),                                    color: AppTheme.primaryColor,

                          ),                                    fontWeight: FontWeight.w600,

                        ),                                    decoration: TextDecoration.underline,

                      ),                                  ),

                    ),                                ),

                  ],                              ],

                ),                            ),

                                          ),

                const SizedBox(height: 32),                        ),

                      ),

                // Register Button                    ),

                Consumer<AuthController>(                  ],

                  builder: (context, authController, child) {                ),

                    return AppButton(

                      text: authController.isLoading ? 'Creating Account...' : 'Create Account',                const SizedBox(height: 32),

                      onPressed: authController.isLoading ? null : _register,

                      width: double.infinity,                // Register Button

                      isLoading: authController.isLoading,                Consumer<AuthController>(

                    );                  builder: (context, authController, child) {

                  },                    return AppButton(

                ),                      text: authController.isLoading

                                          ? 'Creating Account...'

                const SizedBox(height: 24),                          : 'Create Account',

                      onPressed: authController.isLoading ? null : _register,

                // Divider                      width: double.infinity,

                Row(                      isLoading: authController.isLoading,

                  children: [                    );

                    Expanded(child: Divider(color: Colors.grey[300])),                  },

                    Padding(                ),

                      padding: const EdgeInsets.symmetric(horizontal: 16),

                      child: Text(                const SizedBox(height: 24),

                        'Or continue with',

                        style: TextStyle(                // Divider

                          color: Colors.grey[600],                Row(

                          fontSize: 14,                  children: [

                        ),                    Expanded(child: Divider(color: Colors.grey[300])),

                      ),                    Padding(

                    ),                      padding: const EdgeInsets.symmetric(horizontal: 16),

                    Expanded(child: Divider(color: Colors.grey[300])),                      child: Text(

                  ],                        'Or continue with',

                ),                        style: TextStyle(

                                          color: Colors.grey[600],

                const SizedBox(height: 24),                          fontSize: 14,

                        ),

                // Social Registration Buttons                      ),

                Row(                    ),

                  children: [                    Expanded(child: Divider(color: Colors.grey[300])),

                    Expanded(                  ],

                      child: OutlinedButton.icon(                ),

                        onPressed: () {

                          // TODO: Implement Google registration                const SizedBox(height: 24),

                        },

                        icon: const Icon(Icons.g_mobiledata, size: 20),                // Social Registration Buttons

                        label: const Text('Google'),                Row(

                        style: OutlinedButton.styleFrom(                  children: [

                          padding: const EdgeInsets.symmetric(vertical: 12),                    Expanded(

                          side: BorderSide(color: Colors.grey[300]!),                      child: OutlinedButton.icon(

                        ),                        onPressed: () {

                      ),                          // TODO: Implement Google registration

                    ),                        },

                    const SizedBox(width: 16),                        icon: Image.asset(

                    Expanded(                          'assets/icons/google.png',

                      child: OutlinedButton.icon(                          height: 20,

                        onPressed: () {                          width: 20,

                          // TODO: Implement Facebook registration                          errorBuilder: (context, error, stackTrace) {

                        },                            return const Icon(Icons.g_mobiledata, size: 20);

                        icon: const Icon(Icons.facebook, size: 20),                          },

                        label: const Text('Facebook'),                        ),

                        style: OutlinedButton.styleFrom(                        label: const Text('Google'),

                          padding: const EdgeInsets.symmetric(vertical: 12),                        style: OutlinedButton.styleFrom(

                          side: BorderSide(color: Colors.grey[300]!),                          padding: const EdgeInsets.symmetric(vertical: 12),

                        ),                          side: BorderSide(color: Colors.grey[300]!),

                      ),                        ),

                    ),                      ),

                  ],                    ),

                ),                    const SizedBox(width: 16),

                                    Expanded(

                const SizedBox(height: 32),                      child: OutlinedButton.icon(

                        onPressed: () {

                // Sign In Link                          // TODO: Implement Facebook registration

                Center(                        },

                  child: TextButton(                        icon: Image.asset(

                    onPressed: () {                          'assets/icons/facebook.png',

                      Navigator.of(context).pushReplacementNamed('/login');                          height: 20,

                    },                          width: 20,

                    child: Text.rich(                          errorBuilder: (context, error, stackTrace) {

                      TextSpan(                            return const Icon(Icons.facebook, size: 20);

                        text: 'Already have an account? ',                          },

                        style: TextStyle(                        ),

                          color: Colors.grey[600],                        label: const Text('Facebook'),

                          fontSize: 14,                        style: OutlinedButton.styleFrom(

                        ),                          padding: const EdgeInsets.symmetric(vertical: 12),

                        children: [                          side: BorderSide(color: Colors.grey[300]!),

                          TextSpan(                        ),

                            text: 'Sign In',                      ),

                            style: TextStyle(                    ),

                              color: AppColors.primary,                  ],

                              fontWeight: FontWeight.w600,                ),

                            ),

                          ),                const SizedBox(height: 32),

                        ],

                      ),                // Sign In Link

                    ),                Center(

                  ),                  child: TextButton(

                ),                    onPressed: () {

                                      Navigator.of(context).pushReplacementNamed('/login');

                const SizedBox(height: 24),                    },

              ],                    child: Text.rich(

            ),                      TextSpan(

          ),                        text: 'Already have an account? ',

        ),                        style: TextStyle(

      ),                          color: Colors.grey[600],

    );                          fontSize: 14,

  }                        ),

}                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
