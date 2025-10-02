import 'package:flutter/material.dart';import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';import 'package:provider/provider.dart';import 'package:provider/provider.dart';

import '../../widgets/common_widgets.dart';

import '../../utils/theme.dart';import '../../controllers/auth_controller.dart';



class RegisterScreen extends StatefulWidget {import '../../widgets/common_widgets.dart';import '../../controllers/auth_controller.dart';

  const RegisterScreen({Key? key}) : super(key: key);

import '../../utils/theme.dart';import '../../utils/theme.dart';

  @override

  State<RegisterScreen> createState() => _RegisterScreenState();import '../../widgets/common_widgets.dart';

}

class RegisterScreen extends StatefulWidget {

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();  const RegisterScreen({super.key});class RegisterScreen extends StatefulWidget {

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();  const RegisterScreen({super.key});

  final _phoneController = TextEditingController();

  final _passwordController = TextEditingController();  @override

  final _confirmPasswordController = TextEditingController();

    State<RegisterScreen> createState() => _RegisterScreenState();  @override

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;}  @override

  bool _agreeToTerms = false;  State<RegisterScreen> createState() => _RegisterScreenState();



  @override}

  void dispose() {

    _nameController.dispose();class _RegisterScreenState extends State<RegisterScreen> {

    _emailController.dispose();

    _phoneController.dispose();  final _formKey = GlobalKey<FormState>();class _RegisterScreenState extends State<RegisterScreen> {

    _passwordController.dispose();

    _confirmPasswordController.dispose();  final nameController = TextEditingController();  final formKey = GlobalKey<FormState>();

    super.dispose();

  }  final emailController = TextEditingController();  final nameController = TextEditingController();



  void _register() async {  final phoneController = TextEditingController();  final emailController = TextEditingController();

    if (!_formKey.currentState!.validate()) {

      return;  final passwordController = TextEditingController();  final phoneController = TextEditingController();

    }

  final confirmPasswordController = TextEditingController();  final passwordController = TextEditingController();

    if (!_agreeToTerms) {

      ScaffoldMessenger.of(context).showSnackBar(    final confirmPasswordController = TextEditingController();

        const SnackBar(

          content: Text('Please agree to the Terms and Privacy Policy'),  bool obscurePassword = true;

          backgroundColor: Colors.red,

        ),  bool obscureConfirmPassword = true;  bool obscurePassword = true;

      );

      return;  bool agreeToTerms = false;  bool obscureConfirmPassword = true;

    }

  bool agreeToTerms = false;

    try {

      final success = await context.read<AuthController>().registerUser(  @override

        name: _nameController.text.trim(),

        email: _emailController.text.trim(),  void dispose() {  @override

        password: _passwordController.text,

        phoneNumber: _phoneController.text.trim(),    nameController.dispose();  void dispose() {

      );

    emailController.dispose();    nameController.dispose();

      if (success && mounted) {

        Navigator.of(context).pushReplacementNamed('/main');    phoneController.dispose();    emailController.dispose();

      }

    } catch (e) {    passwordController.dispose();    phoneController.dispose();

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(    confirmPasswordController.dispose();    passwordController.dispose();

          SnackBar(

            content: Text('Registration failed: ${e.toString()}'),    super.dispose();    confirmPasswordController.dispose();

            backgroundColor: Colors.red,

          ),  }    super.dispose();

        );

      }  }

    }

  }  void register() async {



  @override    if (!formKey.currentState!.validate()) {  void register() async {

  Widget build(BuildContext context) {

    return Scaffold(      return;    if (!formKey.currentState!.validate()) {

      body: SafeArea(

        child: SingleChildScrollView(    }      return;

          padding: const EdgeInsets.all(24),

          child: Form(    }

            key: _formKey,

            child: Column(    if (!agreeToTerms) {

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [      ScaffoldMessenger.of(context).showSnackBar(    if (!_agreeToTerms) {

                const SizedBox(height: 40),

                        const SnackBar(      ScaffoldMessenger.of(context).showSnackBar(

                // Header

                Center(          content: Text('Please agree to the Terms and Privacy Policy'),        const SnackBar(

                  child: Column(

                    children: [          backgroundColor: Colors.red,          content: Text('Please agree to the Terms and Privacy Policy'),

                      Container(

                        padding: const EdgeInsets.all(20),        ),          backgroundColor: Colors.red,

                        decoration: BoxDecoration(

                          color: AppColors.primary.withOpacity(0.1),      );        ),

                          shape: BoxShape.circle,

                        ),      return;      );

                        child: Icon(

                          Icons.shield,    }      return;

                          size: 60,

                          color: AppColors.primary,    }

                        ),

                      ),    try {

                      const SizedBox(height: 24),

                      Text(      final success = await context.read<AuthController>().registerUser(    try {

                        'Create Account',

                        style: TextStyle(        name: _nameController.text.trim(),      final success = await context.read<AuthController>().signUp(

                          fontSize: 28,

                          fontWeight: FontWeight.bold,        email: _emailController.text.trim(),            name: _nameController.text.trim(),

                          color: AppColors.primary,

                        ),        password: _passwordController.text,            email: _emailController.text.trim(),

                      ),

                      const SizedBox(height: 8),        phoneNumber: _phoneController.text.trim(),            password: _passwordController.text,

                      Text(

                        'Join SafeHer community and stay protected',      );            phoneNumber: _phoneController.text.trim(),

                        style: TextStyle(

                          fontSize: 16,          );

                          color: Colors.grey[600],

                        ),      if (success && mounted) {

                        textAlign: TextAlign.center,

                      ),        Navigator.of(context).pushReplacementNamed('/main');      if (success && mounted) {

                    ],

                  ),      }        Navigator.of(context).pushReplacementNamed('/main');

                ),

                    } catch (e) {      }

                const SizedBox(height: 40),

      if (mounted) {    } catch (e) {

                // Full Name Field

                AppTextField(        ScaffoldMessenger.of(context).showSnackBar(      if (mounted) {

                  controller: _nameController,

                  label: 'Full Name',          SnackBar(        ScaffoldMessenger.of(context).showSnackBar(

                  hint: 'Enter your full name',

                  prefixIcon: const Icon(Icons.person_outline),            content: Text('Registration failed: ${e.toString()}'),          SnackBar(

                  validator: (value) {

                    if (value?.isEmpty ?? true) {            backgroundColor: Colors.red,            content: Text('Registration failed: ${e.toString()}'),

                      return 'Please enter your full name';

                    }          ),            backgroundColor: Colors.red,

                    if (value!.length < 2) {

                      return 'Name must be at least 2 characters';        );          ),

                    }

                    return null;      }        );

                  },

                ),    }      }

                

                const SizedBox(height: 16),  }    }



                // Email Field  }

                AppTextField(

                  controller: _emailController,  @override

                  label: 'Email Address',

                  hint: 'Enter your email',  Widget build(BuildContext context) {  @override

                  prefixIcon: const Icon(Icons.email_outlined),

                  keyboardType: TextInputType.emailAddress,    return Scaffold(  Widget build(BuildContext context) {

                  validator: (value) {

                    if (value?.isEmpty ?? true) {      body: SafeArea(    return Scaffold(

                      return 'Please enter your email';

                    }        child: SingleChildScrollView(      body: SafeArea(

                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {

                      return 'Please enter a valid email address';          padding: const EdgeInsets.all(24),        child: SingleChildScrollView(

                    }

                    return null;          child: Form(          padding: const EdgeInsets.all(24),

                  },

                ),            key: _formKey,          child: Form(

                

                const SizedBox(height: 16),            child: Column(            key: _formKey,



                // Phone Number Field              crossAxisAlignment: CrossAxisAlignment.start,            child: Column(

                AppTextField(

                  controller: _phoneController,              children: [              crossAxisAlignment: CrossAxisAlignment.start,

                  label: 'Phone Number',

                  hint: 'Enter your phone number',                const SizedBox(height: 40),              children: [

                  prefixIcon: const Icon(Icons.phone_outlined),

                  keyboardType: TextInputType.phone,                                const SizedBox(height: 40),

                  validator: (value) {

                    if (value?.isEmpty ?? true) {                // Header

                      return 'Please enter your phone number';

                    }                Center(                // Header

                    if (value!.length < 10) {

                      return 'Please enter a valid phone number';                  child: Column(                Center(

                    }

                    return null;                    children: [                  child: Column(

                  },

                ),                      Container(                    children: [

                

                const SizedBox(height: 16),                        padding: const EdgeInsets.all(20),                      Container(



                // Password Field                        decoration: BoxDecoration(                        padding: const EdgeInsets.all(20),

                AppTextField(

                  controller: _passwordController,                          color: AppColors.primary.withOpacity(0.1),                        decoration: BoxDecoration(

                  label: 'Password',

                  hint: 'Enter your password',                          shape: BoxShape.circle,                          color: AppColors.primary.withOpacity(0.1),

                  prefixIcon: const Icon(Icons.lock_outline),

                  obscureText: _obscurePassword,                        ),                          shape: BoxShape.circle,

                  suffixIcon: IconButton(

                    onPressed: () {                        child: Icon(                        ),

                      setState(() {

                        _obscurePassword = !_obscurePassword;                          Icons.shield,                        child: const Icon(

                      });

                    },                          size: 60,                          Icons.shield,

                    icon: Icon(

                      _obscurePassword ? Icons.visibility : Icons.visibility_off,                          color: AppColors.primary,                          size: 60,

                    ),

                  ),                        ),                          color: AppColors.primary,

                  validator: (value) {

                    if (value?.isEmpty ?? true) {                      ),                        ),

                      return 'Please enter a password';

                    }                      const SizedBox(height: 24),                      ),

                    if (value!.length < 6) {

                      return 'Password must be at least 6 characters';                      Text(                      const SizedBox(height: 24),

                    }

                    return null;                        'Create Account',                      const Text(

                  },

                ),                        style: TextStyle(                        'Create Account',

                

                const SizedBox(height: 16),                          fontSize: 28,                        style: TextStyle(



                // Confirm Password Field                          fontWeight: FontWeight.bold,                          fontSize: 28,

                AppTextField(

                  controller: _confirmPasswordController,                          color: AppColors.primary,                          fontWeight: FontWeight.bold,

                  label: 'Confirm Password',

                  hint: 'Re-enter your password',                        ),                          color: AppColors.primary,

                  prefixIcon: const Icon(Icons.lock_outline),

                  obscureText: _obscureConfirmPassword,                      ),                        ),

                  suffixIcon: IconButton(

                    onPressed: () {                      const SizedBox(height: 8),                      ),

                      setState(() {

                        _obscureConfirmPassword = !_obscureConfirmPassword;                      Text(                      const SizedBox(height: 8),

                      });

                    },                        'Join SafeHer community and stay protected',                      Text(

                    icon: Icon(

                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,                        style: TextStyle(                        'Join SafeHer community and stay protected',

                    ),

                  ),                          fontSize: 16,                        style: TextStyle(

                  validator: (value) {

                    if (value?.isEmpty ?? true) {                          color: Colors.grey[600],                          fontSize: 16,

                      return 'Please confirm your password';

                    }                        ),                          color: Colors.grey[600],

                    if (value != _passwordController.text) {

                      return 'Passwords do not match';                        textAlign: TextAlign.center,                        ),

                    }

                    return null;                      ),                        textAlign: TextAlign.center,

                  },

                ),                    ],                      ),

                

                const SizedBox(height: 24),                  ),                    ],



                // Terms and Privacy Policy                ),                  ),

                Row(

                  crossAxisAlignment: CrossAxisAlignment.start,                                ),

                  children: [

                    Checkbox(                const SizedBox(height: 40),

                      value: _agreeToTerms,

                      onChanged: (value) {                const SizedBox(height: 40),

                        setState(() {

                          _agreeToTerms = value!;                // Full Name Field

                        });

                      },                AppTextField(                // Full Name Field

                      activeColor: AppColors.primary,

                    ),                  controller: _nameController,                AppTextField(

                    Expanded(

                      child: GestureDetector(                  label: 'Full Name',                  controller: _nameController,

                        onTap: () {

                          setState(() {                  prefixIcon: const Icon(Icons.person_outline),                  label: 'Full Name',

                            _agreeToTerms = !_agreeToTerms;

                          });                  validator: (value) {                  prefixIcon: const Icon(Icons.person_outline),

                        },

                        child: Padding(                    if (value?.isEmpty ?? true) {                  validator: (value) {

                          padding: const EdgeInsets.only(top: 12),

                          child: Text.rich(                      return 'Please enter your full name';                    if (value?.isEmpty ?? true) {

                            TextSpan(

                              text: 'I agree to the ',                    }                      return 'Please enter your full name';

                              style: const TextStyle(fontSize: 14),

                              children: [                    if (value!.length < 2) {                    }

                                TextSpan(

                                  text: 'Terms of Service',                      return 'Name must be at least 2 characters';                    if (value!.length < 2) {

                                  style: TextStyle(

                                    color: AppColors.primary,                    }                      return 'Name must be at least 2 characters';

                                    fontWeight: FontWeight.w600,

                                    decoration: TextDecoration.underline,                    return null;                    }

                                  ),

                                ),                  },                    return null;

                                const TextSpan(text: ' and '),

                                TextSpan(                ),                  },

                                  text: 'Privacy Policy',

                                  style: TextStyle(                                ),

                                    color: AppColors.primary,

                                    fontWeight: FontWeight.w600,                const SizedBox(height: 16),

                                    decoration: TextDecoration.underline,

                                  ),                const SizedBox(height: 16),

                                ),

                              ],                // Email Field

                            ),

                          ),                AppTextField(                // Email Field

                        ),

                      ),                  controller: _emailController,                AppTextField(

                    ),

                  ],                  label: 'Email Address',                  controller: _emailController,

                ),

                                  prefixIcon: const Icon(Icons.email_outlined),                  labelText: 'Email Address',

                const SizedBox(height: 32),

                  keyboardType: TextInputType.emailAddress,                  prefixIcon: Icons.email_outlined,

                // Register Button

                Consumer<AuthController>(                  validator: (value) {                  keyboardType: TextInputType.emailAddress,

                  builder: (context, authController, child) {

                    return AppButton(                    if (value?.isEmpty ?? true) {                  validator: (value) {

                      text: authController.isLoading ? 'Creating Account...' : 'Create Account',

                      onPressed: authController.isLoading ? null : _register,                      return 'Please enter your email';                    if (value?.isEmpty ?? true) {

                      width: double.infinity,

                      isLoading: authController.isLoading,                    }                      return 'Please enter your email';

                    );

                  },                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {                    }

                ),

                                      return 'Please enter a valid email address';                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')

                const SizedBox(height: 24),

                    }                        .hasMatch(value!)) {

                // Divider

                Row(                    return null;                      return 'Please enter a valid email address';

                  children: [

                    Expanded(child: Divider(color: Colors.grey[300])),                  },                    }

                    Padding(

                      padding: const EdgeInsets.symmetric(horizontal: 16),                ),                    return null;

                      child: Text(

                        'Or continue with',                                  },

                        style: TextStyle(

                          color: Colors.grey[600],                SizedBox(height = 16),                ),

                          fontSize: 14,

                        ),

                      ),

                    ),                // Phone Number Field                const SizedBox(height: 16),

                    Expanded(child: Divider(color: Colors.grey[300])),

                  ],                AppTextField(

                ),

                                  controller = _phoneController,                // Phone Number Field

                const SizedBox(height: 24),

                  label = 'Phone Number',                AppTextField(

                // Social Registration Buttons

                Row(                  prefixIcon = const Icon(Icons.phone_outlined),                  controller = _phoneController,

                  children: [

                    Expanded(                  keyboardType = TextInputType.phone,                  labelText = 'Phone Number',

                      child: OutlinedButton.icon(

                        onPressed: () {                  validator = (value) {                  prefixIcon: Icons.phone_outlined,

                          // TODO: Implement Google registration

                        },                    if (value?.isEmpty ?? true) {                  keyboardType: TextInputType.phone,

                        icon: const Icon(Icons.g_mobiledata, size: 20),

                        label: const Text('Google'),                      return 'Please enter your phone number';                  validator: (value) {

                        style: OutlinedButton.styleFrom(

                          padding: const EdgeInsets.symmetric(vertical: 12),                    }                    if (value?.isEmpty ?? true) {

                          side: BorderSide(color: Colors.grey[300]!),

                        ),                    if (value!.length < 10) {                      return 'Please enter your phone number';

                      ),

                    ),                      return 'Please enter a valid phone number';                    }

                    const SizedBox(width: 16),

                    Expanded(                    }                    if (value!.length < 10) {

                      child: OutlinedButton.icon(

                        onPressed: () {                    return null;                      return 'Please enter a valid phone number';

                          // TODO: Implement Facebook registration

                        },                  },                    }

                        icon: const Icon(Icons.facebook, size: 20),

                        label: const Text('Facebook'),                ),                    return null;

                        style: OutlinedButton.styleFrom(

                          padding: const EdgeInsets.symmetric(vertical: 12),                                  },

                          side: BorderSide(color: Colors.grey[300]!),

                        ),                const SizedBox(height: 16),                ),

                      ),

                    ),

                  ],

                ),                // Password Field                const SizedBox(height: 16),

                

                const SizedBox(height: 32),                AppTextField(



                // Sign In Link                  controller = _passwordController,                // Password Field

                Center(

                  child: TextButton(                  label = 'Password',                AppTextField(

                    onPressed: () {

                      Navigator.of(context).pushReplacementNamed('/login');                  prefixIcon = const Icon(Icons.lock_outline),                  controller = _passwordController,

                    },

                    child: Text.rich(                  obscureText = _obscurePassword,                  labelText = 'Password',

                      TextSpan(

                        text: 'Already have an account? ',                  suffixIcon = IconButton(                  prefixIcon: Icons.lock_outline,

                        style: TextStyle(

                          color: Colors.grey[600],                    onPressed: () {                  obscureText: _obscurePassword,

                          fontSize: 14,

                        ),                      setState(() {                  suffixIcon: IconButton(

                        children: [

                          TextSpan(                        _obscurePassword = !_obscurePassword;                    onPressed: () {

                            text: 'Sign In',

                            style: TextStyle(                      });                      setState(() {

                              color: AppColors.primary,

                              fontWeight: FontWeight.w600,                    },                        _obscurePassword = !_obscurePassword;

                            ),

                          ),                    icon: Icon(                      });

                        ],

                      ),                      _obscurePassword ? Icons.visibility : Icons.visibility_off,                    },

                    ),

                  ),                    ),                    icon = const Icon(

                ),

                                  ),                      _obscurePassword

                const SizedBox(height: 24),

              ],                  validator = (value) {                          ? Icons.visibility

            ),

          ),                    if (value?.isEmpty ?? true) {                          : Icons.visibility_off,

        ),

      ),                      return 'Please enter a password';                    ),

    );

  }                    }                  ),

}
                    if (value!.length < 6) {                  validator: (value) {

                      return 'Password must be at least 6 characters';                    if (value?.isEmpty ?? true) {

                    }                      return 'Please enter a password';

                    return null;                    }

                  },                    if (value!.length < 6) {

                ),                      return 'Password must be at least 6 characters';

                                    }

                SizedBox(height = 16),                    return null;

                  },

                // Confirm Password Field                ),

                AppTextField(

                  controller = _confirmPasswordController,                SizedBox(height = 16),

                  label = 'Confirm Password',

                  prefixIcon = const Icon(Icons.lock_outline),                // Confirm Password Field

                  obscureText = _obscureConfirmPassword,                AppTextField(

                  suffixIcon = IconButton(                  controller: _confirmPasswordController,

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

                SizedBox(height = 32),                        ),

                      ),

                // Register Button                    ),

                Consumer<AuthController>(                  ],

                  builder: (context, authController, child) {                ),

                    return AppButton(

                      text = authController.isLoading ? 'Creating Account...' : 'Create Account',                SizedBox(height = 32),

                      onPressed = authController.isLoading ? null : _register,

                      width = double.infinity,                // Register Button

                      isLoading = authController.isLoading,                Function<AuthController>(

                    ) Consumer;                  builder: (context, authController, child) {

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

                ),                    SizedBox(width = 16),

                                    Expanded(

                SizedBox(height = 32),                      child = OutlinedButton.icon(

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
                            text = 'Sign In',
                            style = TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height = 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
