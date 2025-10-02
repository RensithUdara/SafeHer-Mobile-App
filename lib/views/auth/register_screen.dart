import 'package:flutter/material.dart';import 'package:flutter/material.dart';import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';import 'package:provider/provider.dart';

import '../../widgets/common_widgets.dart';

import '../../utils/theme.dart';import '../../controllers/auth_controller.dart';import 'package:provider/provider.dart';import 'package:provider/provider.dart';



class RegisterScreen extends StatefulWidget {import '../../widgets/common_widgets.dart';

  const RegisterScreen({Key? key}) : super(key: key);

import '../../utils/theme.dart';import '../../controllers/auth_controller.dart';

  @override

  State<RegisterScreen> createState() => _RegisterScreenState();

}

class RegisterScreen extends StatefulWidget {import '../../widgets/common_widgets.dart';import '../../controllers/auth_controller.dart';

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();  const RegisterScreen({super.key});

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();import '../../utils/theme.dart';import '../../utils/theme.dart';

  final _phoneController = TextEditingController();

  final _passwordController = TextEditingController();  @override

  final _confirmPasswordController = TextEditingController();

    State<RegisterScreen> createState() => _RegisterScreenState();import '../../widgets/common_widgets.dart';

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;}

  bool _agreeToTerms = false;

class RegisterScreen extends StatefulWidget {

  @override  const RegisterScreen({super.key});

  void dispose() {

    _nameController.dispose();

    _emailController.dispose();class _RegisterScreenState extends State<RegisterScreen> {

    _phoneController.dispose();

    _passwordController.dispose();  final formKey = GlobalKey<FormState>();  const RegisterScreen({super.key});class RegisterScreen extends StatefulWidget {

    _confirmPasswordController.dispose();

    super.dispose();  final nameController = TextEditingController();

  }

  final emailController = TextEditingController();  const RegisterScreen({super.key});

  void _register() async {

    if (!_formKey.currentState!.validate()) {  final phoneController = TextEditingController();

      return;

    }  final passwordController = TextEditingController();  @override



    if (!_agreeToTerms) {  final confirmPasswordController = TextEditingController();

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(    State<RegisterScreen> createState() => _RegisterScreenState();  @override

          content: Text('Please agree to the Terms and Privacy Policy'),

          backgroundColor: Colors.red,  bool obscurePassword = true;

        ),

      );  bool obscureConfirmPassword = true;}  @override

      return;

    }  bool agreeToTerms = false;  State<RegisterScreen> createState() => _RegisterScreenState();



    try {

      final success = await context.read<AuthController>().registerUser(

        name: _nameController.text.trim(),  @override}

        email: _emailController.text.trim(),

        password: _passwordController.text,  void dispose() {

        phoneNumber: _phoneController.text.trim(),

      );    _nameController.dispose();class _RegisterScreenState extends State<RegisterScreen> {



      if (success && mounted) {    _emailController.dispose();

        Navigator.of(context).pushReplacementNamed('/main');

      }    _phoneController.dispose();  final _formKey = GlobalKey<FormState>();class _RegisterScreenState extends State<RegisterScreen> {

    } catch (e) {

      if (mounted) {    _passwordController.dispose();

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(    _confirmPasswordController.dispose();  final nameController = TextEditingController();  final formKey = GlobalKey<FormState>();

            content: Text('Registration failed: $e'),

            backgroundColor: Colors.red,    super.dispose();

          ),

        );  }  final emailController = TextEditingController();  final nameController = TextEditingController();

      }

    }

  }

  void _register() async {  final phoneController = TextEditingController();  final emailController = TextEditingController();

  @override

  Widget build(BuildContext context) {    if (!_formKey.currentState!.validate()) {

    return Scaffold(

      body: SafeArea(      return;  final passwordController = TextEditingController();  final phoneController = TextEditingController();

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),    }

          child: Form(

            key: _formKey,  final confirmPasswordController = TextEditingController();  final passwordController = TextEditingController();

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,    if (!_agreeToTerms) {

              children: [

                const SizedBox(height: 40),      ScaffoldMessenger.of(context).showSnackBar(    final confirmPasswordController = TextEditingController();

                

                // Header        const SnackBar(

                Center(

                  child: Column(          content: Text('Please agree to the Terms and Privacy Policy'),  bool obscurePassword = true;

                    children: [

                      Container(          backgroundColor: Colors.red,

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(        ),  bool obscureConfirmPassword = true;  bool obscurePassword = true;

                          color: AppColors.primary.withOpacity(0.1),

                          shape: BoxShape.circle,      );

                        ),

                        child: Icon(      return;  bool agreeToTerms = false;  bool obscureConfirmPassword = true;

                          Icons.shield,

                          size: 60,    }

                          color: AppColors.primary,

                        ),  bool agreeToTerms = false;

                      ),

                      const SizedBox(height: 24),    try {

                      Text(

                        'Create Account',      final success = await context.read<AuthController>().registerUser(  @override

                        style: TextStyle(

                          fontSize: 28,        name: _nameController.text.trim(),

                          fontWeight: FontWeight.bold,

                          color: AppColors.primary,        email: _emailController.text.trim(),  void dispose() {  @override

                        ),

                      ),        password: _passwordController.text,

                      const SizedBox(height: 8),

                      Text(        phoneNumber: _phoneController.text.trim(),    nameController.dispose();  void dispose() {

                        'Join SafeHer community and stay protected',

                        style: TextStyle(      );

                          fontSize: 16,

                          color: Colors.grey[600],    emailController.dispose();    nameController.dispose();

                        ),

                        textAlign: TextAlign.center,      if (success && mounted) {

                      ),

                    ],        Navigator.of(context).pushReplacementNamed('/main');    phoneController.dispose();    emailController.dispose();

                  ),

                ),      }

                

                const SizedBox(height: 40),    } catch (e) {    passwordController.dispose();    phoneController.dispose();



                // Full Name Field      if (mounted) {

                AppTextField(

                  controller: _nameController,        ScaffoldMessenger.of(context).showSnackBar(    confirmPasswordController.dispose();    passwordController.dispose();

                  label: 'Full Name',

                  hint: 'Enter your full name',          SnackBar(

                  prefixIcon: const Icon(Icons.person_outline),

                  validator: (value) {            content: Text('Registration failed: ${e.toString()}'),    super.dispose();    confirmPasswordController.dispose();

                    if (value?.isEmpty ?? true) {

                      return 'Please enter your full name';            backgroundColor: Colors.red,

                    }

                    if (value!.length < 2) {          ),  }    super.dispose();

                      return 'Name must be at least 2 characters';

                    }        );

                    return null;

                  },      }  }

                ),

                    }

                const SizedBox(height: 16),

  }  void register() async {

                // Email Field

                AppTextField(

                  controller: _emailController,

                  label: 'Email Address',  @override    if (!formKey.currentState!.validate()) {  void register() async {

                  hint: 'Enter your email',

                  prefixIcon: const Icon(Icons.email_outlined),  Widget build(BuildContext context) {

                  keyboardType: TextInputType.emailAddress,

                  validator: (value) {    return Scaffold(      return;    if (!formKey.currentState!.validate()) {

                    if (value?.isEmpty ?? true) {

                      return 'Please enter your email';      body: SafeArea(

                    }

                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {        child: SingleChildScrollView(    }      return;

                      return 'Please enter a valid email address';

                    }          padding: const EdgeInsets.all(24),

                    return null;

                  },          child: Form(    }

                ),

                            key: _formKey,

                const SizedBox(height: 16),

            child: Column(    if (!agreeToTerms) {

                // Phone Number Field

                AppTextField(              crossAxisAlignment: CrossAxisAlignment.start,

                  controller: _phoneController,

                  label: 'Phone Number',              children: [      ScaffoldMessenger.of(context).showSnackBar(    if (!_agreeToTerms) {

                  hint: 'Enter your phone number',

                  prefixIcon: const Icon(Icons.phone_outlined),                const SizedBox(height: 40),

                  keyboardType: TextInputType.phone,

                  validator: (value) {                        const SnackBar(      ScaffoldMessenger.of(context).showSnackBar(

                    if (value?.isEmpty ?? true) {

                      return 'Please enter your phone number';                // Header

                    }

                    if (value!.length < 10) {                Center(          content: Text('Please agree to the Terms and Privacy Policy'),        const SnackBar(

                      return 'Please enter a valid phone number';

                    }                  child: Column(

                    return null;

                  },                    children: [          backgroundColor: Colors.red,          content: Text('Please agree to the Terms and Privacy Policy'),

                ),

                                      Container(

                const SizedBox(height: 16),

                        padding: const EdgeInsets.all(20),        ),          backgroundColor: Colors.red,

                // Password Field

                AppTextField(                        decoration: BoxDecoration(

                  controller: _passwordController,

                  label: 'Password',                          color: AppColors.primary.withOpacity(0.1),      );        ),

                  hint: 'Enter your password',

                  prefixIcon: const Icon(Icons.lock_outline),                          shape: BoxShape.circle,

                  obscureText: _obscurePassword,

                  suffixIcon: IconButton(                        ),      return;      );

                    onPressed: () {

                      setState(() {                        child: Icon(

                        _obscurePassword = !_obscurePassword;

                      });                          Icons.shield,    }      return;

                    },

                    icon: Icon(                          size: 60,

                      _obscurePassword ? Icons.visibility : Icons.visibility_off,

                    ),                          color: AppColors.primary,    }

                  ),

                  validator: (value) {                        ),

                    if (value?.isEmpty ?? true) {

                      return 'Please enter a password';                      ),    try {

                    }

                    if (value!.length < 6) {                      const SizedBox(height: 24),

                      return 'Password must be at least 6 characters';

                    }                      Text(      final success = await context.read<AuthController>().registerUser(    try {

                    return null;

                  },                        'Create Account',

                ),

                                        style: TextStyle(        name: _nameController.text.trim(),      final success = await context.read<AuthController>().signUp(

                const SizedBox(height: 16),

                          fontSize: 28,

                // Confirm Password Field

                AppTextField(                          fontWeight: FontWeight.bold,        email: _emailController.text.trim(),            name: _nameController.text.trim(),

                  controller: _confirmPasswordController,

                  label: 'Confirm Password',                          color: AppColors.primary,

                  hint: 'Re-enter your password',

                  prefixIcon: const Icon(Icons.lock_outline),                        ),        password: _passwordController.text,            email: _emailController.text.trim(),

                  obscureText: _obscureConfirmPassword,

                  suffixIcon: IconButton(                      ),

                    onPressed: () {

                      setState(() {                      const SizedBox(height: 8),        phoneNumber: _phoneController.text.trim(),            password: _passwordController.text,

                        _obscureConfirmPassword = !_obscureConfirmPassword;

                      });                      Text(

                    },

                    icon: Icon(                        'Join SafeHer community and stay protected',      );            phoneNumber: _phoneController.text.trim(),

                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,

                    ),                        style: TextStyle(

                  ),

                  validator: (value) {                          fontSize: 16,          );

                    if (value?.isEmpty ?? true) {

                      return 'Please confirm your password';                          color: Colors.grey[600],

                    }

                    if (value != _passwordController.text) {                        ),      if (success && mounted) {

                      return 'Passwords do not match';

                    }                        textAlign: TextAlign.center,

                    return null;

                  },                      ),        Navigator.of(context).pushReplacementNamed('/main');      if (success && mounted) {

                ),

                                    ],

                const SizedBox(height: 24),

                  ),      }        Navigator.of(context).pushReplacementNamed('/main');

                // Terms and Privacy Policy

                Row(                ),

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [                    } catch (e) {      }

                    Checkbox(

                      value: _agreeToTerms,                const SizedBox(height: 40),

                      onChanged: (value) {

                        setState(() {      if (mounted) {    } catch (e) {

                          _agreeToTerms = value!;

                        });                // Full Name Field

                      },

                      activeColor: AppColors.primary,                AppTextField(        ScaffoldMessenger.of(context).showSnackBar(      if (mounted) {

                    ),

                    Expanded(                  controller: _nameController,

                      child: GestureDetector(

                        onTap: () {                  label: 'Full Name',          SnackBar(        ScaffoldMessenger.of(context).showSnackBar(

                          setState(() {

                            _agreeToTerms = !_agreeToTerms;                  hint: 'Enter your full name',

                          });

                        },                  prefixIcon: const Icon(Icons.person_outline),            content: Text('Registration failed: ${e.toString()}'),          SnackBar(

                        child: Padding(

                          padding: const EdgeInsets.only(top: 12),                  validator: (value) {

                          child: Text.rich(

                            TextSpan(                    if (value?.isEmpty ?? true) {            backgroundColor: Colors.red,            content: Text('Registration failed: ${e.toString()}'),

                              text: 'I agree to the ',

                              style: const TextStyle(fontSize: 14),                      return 'Please enter your full name';

                              children: [

                                TextSpan(                    }          ),            backgroundColor: Colors.red,

                                  text: 'Terms of Service',

                                  style: TextStyle(                    if (value!.length < 2) {

                                    color: AppColors.primary,

                                    fontWeight: FontWeight.w600,                      return 'Name must be at least 2 characters';        );          ),

                                    decoration: TextDecoration.underline,

                                  ),                    }

                                ),

                                const TextSpan(text: ' and '),                    return null;      }        );

                                TextSpan(

                                  text: 'Privacy Policy',                  },

                                  style: TextStyle(

                                    color: AppColors.primary,                ),    }      }

                                    fontWeight: FontWeight.w600,

                                    decoration: TextDecoration.underline,                

                                  ),

                                ),                const SizedBox(height: 16),  }    }

                              ],

                            ),

                          ),

                        ),                // Email Field  }

                      ),

                    ),                AppTextField(

                  ],

                ),                  controller = _emailController,  @override

                

                const SizedBox(height: 32),                  label = 'Email Address',



                // Register Button                  hint = 'Enter your email',  Widget Function(BuildContext context) build {  @override

                Consumer<AuthController>(

                  builder: (context, authController, child) {                  prefixIcon: const Icon(Icons.email_outlined),

                    return AppButton(

                      text: authController.isLoading ? 'Creating Account...' : 'Create Account',                  keyboardType: TextInputType.emailAddress,    return Scaffold(  Widget build(BuildContext context) {

                      onPressed: authController.isLoading ? null : _register,

                      width: double.infinity,                  validator: (value) {

                      isLoading: authController.isLoading,

                    );                    if (value?.isEmpty ?? true) {      body: SafeArea(    return Scaffold(

                  },

                ),                      return 'Please enter your email';

                

                const SizedBox(height: 24),                    }        child: SingleChildScrollView(      body: SafeArea(



                // Divider                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {

                Row(

                  children: [                      return 'Please enter a valid email address';          padding: const EdgeInsets.all(24),        child: SingleChildScrollView(

                    Expanded(child: Divider(color: Colors.grey[300])),

                    Padding(                    }

                      padding: const EdgeInsets.symmetric(horizontal: 16),

                      child: Text(                    return null;          child: Form(          padding: const EdgeInsets.all(24),

                        'Or continue with',

                        style: TextStyle(                  },

                          color: Colors.grey[600],

                          fontSize: 14,                ),            key: _formKey,          child: Form(

                        ),

                      ),                

                    ),

                    Expanded(child: Divider(color: Colors.grey[300])),                const SizedBox(height: 16),            child: Column(            key: _formKey,

                  ],

                ),

                

                const SizedBox(height: 24),                // Phone Number Field              crossAxisAlignment: CrossAxisAlignment.start,            child: Column(



                // Social Registration Buttons                AppTextField(

                Row(

                  children: [                  controller: _phoneController,              children: [              crossAxisAlignment: CrossAxisAlignment.start,

                    Expanded(

                      child: OutlinedButton.icon(                  label: 'Phone Number',

                        onPressed: () {

                          // TODO: Implement Google registration                  hint: 'Enter your phone number',                const SizedBox(height: 40),              children: [

                        },

                        icon: const Icon(Icons.g_mobiledata, size: 20),                  prefixIcon: const Icon(Icons.phone_outlined),

                        label: const Text('Google'),

                        style: OutlinedButton.styleFrom(                  keyboardType: TextInputType.phone,                                const SizedBox(height: 40),

                          padding: const EdgeInsets.symmetric(vertical: 12),

                          side: BorderSide(color: Colors.grey[300]!),                  validator: (value) {

                        ),

                      ),                    if (value?.isEmpty ?? true) {                // Header

                    ),

                    const SizedBox(width: 16),                      return 'Please enter your phone number';

                    Expanded(

                      child: OutlinedButton.icon(                    }                Center(                // Header

                        onPressed: () {

                          // TODO: Implement Facebook registration                    if (value!.length < 10) {

                        },

                        icon: const Icon(Icons.facebook, size: 20),                      return 'Please enter a valid phone number';                  child: Column(                Center(

                        label: const Text('Facebook'),

                        style: OutlinedButton.styleFrom(                    }

                          padding: const EdgeInsets.symmetric(vertical: 12),

                          side: BorderSide(color: Colors.grey[300]!),                    return null;                    children: [                  child: Column(

                        ),

                      ),                  },

                    ),

                  ],                ),                      Container(                    children: [

                ),

                                

                const SizedBox(height: 32),

                const SizedBox(height: 16),                        padding: const EdgeInsets.all(20),                      Container(

                // Sign In Link

                Center(

                  child: TextButton(

                    onPressed: () {                // Password Field                        decoration: BoxDecoration(                        padding: const EdgeInsets.all(20),

                      Navigator.of(context).pushReplacementNamed('/login');

                    },                AppTextField(

                    child: Text.rich(

                      TextSpan(                  controller: _passwordController,                          color: AppColors.primary.withOpacity(0.1),                        decoration: BoxDecoration(

                        text: 'Already have an account? ',

                        style: TextStyle(                  label: 'Password',

                          color: Colors.grey[600],

                          fontSize: 14,                  hint: 'Enter your password',                          shape: BoxShape.circle,                          color: AppColors.primary.withOpacity(0.1),

                        ),

                        children: [                  prefixIcon: const Icon(Icons.lock_outline),

                          TextSpan(

                            text: 'Sign In',                  obscureText: _obscurePassword,                        ),                          shape: BoxShape.circle,

                            style: TextStyle(

                              color: AppColors.primary,                  suffixIcon: IconButton(

                              fontWeight: FontWeight.w600,

                            ),                    onPressed: () {                        child: Icon(                        ),

                          ),

                        ],                      setState(() {

                      ),

                    ),                        _obscurePassword = !_obscurePassword;                          Icons.shield,                        child: const Icon(

                  ),

                ),                      });

                

                const SizedBox(height: 24),                    },                          size: 60,                          Icons.shield,

              ],

            ),                    icon: Icon(

          ),

        ),                      _obscurePassword ? Icons.visibility : Icons.visibility_off,                          color: AppColors.primary,                          size: 60,

      ),

    );                    ),

  }

}                  ),                        ),                          color: AppColors.primary,

                  validator: (value) {

                    if (value?.isEmpty ?? true) {                      ),                        ),

                      return 'Please enter a password';

                    }                      const SizedBox(height: 24),                      ),

                    if (value!.length < 6) {

                      return 'Password must be at least 6 characters';                      Text(                      const SizedBox(height: 24),

                    }

                    return null;                        'Create Account',                      Text(

                  },

                ),                        style: TextStyle(                        'Create Account',

                

                SizedBox(height = 16),                          fontSize = 28,                        style = TextStyle(



                // Confirm Password Field                          fontWeight: FontWeight.bold,                          fontSize: 28,

                AppTextField(

                  controller: _confirmPasswordController,                          color: AppColors.primary,                          fontWeight: FontWeight.bold,

                  label: 'Confirm Password',

                  hint: 'Re-enter your password',                        ),                          color: AppColors.primary,

                  prefixIcon: const Icon(Icons.lock_outline),

                  obscureText: _obscureConfirmPassword,                      ),                        ),

                  suffixIcon: IconButton(

                    onPressed = () {                      const SizedBox(height: 8),                      ),

                      setState(() {

                        _obscureConfirmPassword = !_obscureConfirmPassword;                      Text(                      const SizedBox(height: 8),

                      });

                    },                        'Join SafeHer community and stay protected',                      Text(

                    icon = Icon(

                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,                        style: TextStyle(                        'Join SafeHer community and stay protected',

                    ),

                  ),                          fontSize = 16,                        style = TextStyle(

                  validator: (value) {

                    if (value?.isEmpty ?? true) {                          color: Colors.grey[600],                          fontSize: 16,

                      return 'Please confirm your password';

                    }                        ),                          color = Colors.grey[600],

                    if (value != _passwordController.text) {

                      return 'Passwords do not match';                        textAlign: TextAlign.center,                        ),

                    }

                    return null;                      ),                        textAlign: TextAlign.center,

                  },

                ),                    ],                      ),

                

                SizedBox(height = 24),                  ),                    ],



                // Terms and Privacy Policy                ),                  ),

                Row(

                  crossAxisAlignment = CrossAxisAlignment.start,                                ),

                  children: [

                    Checkbox(                SizedBox(height = 40),

                      value = _agreeToTerms,

                      onChanged = (value) {                const SizedBox(height: 40),

                        setState(() {

                          _agreeToTerms = value!;                // Full Name Field

                        });

                      },                AppTextField(                // Full Name Field

                      activeColor = AppColors.primary,

                    ),                  controller = _nameController,                Function(

                    Expanded(

                      child = GestureDetector(                  label: 'Full Name',                  controller: _nameController,

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

                          ) AppTextField,                Function(                // Email Field

                        ) AppTextField,

                      ),                  controller: _emailController,                AppTextField(

                    ),

                  ],                  label: 'Email Address',                  controller: _emailController,

                ),

                                  prefixIcon: Icon(Icons.email_outlined),                  labelText: 'Email Address',

                SizedBox(height = 32),

                  keyboardType: TextInputType.emailAddress,                  prefixIcon: Icons.email_outlined,

                // Register Button

                Consumer<AuthController>(                  validator = (value) {                  keyboardType: TextInputType.emailAddress,

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

                      padding = const EdgeInsets.symmetric(horizontal: 16),                ),                    return null;

                      child: Text(

                        'Or continue with',                                  },

                        style: TextStyle(

                          color: Colors.grey[600],                SizedBox(height = 16),                ),

                          fontSize: 14,

                        ),

                      ),

                    ),                // Phone Number Field                const SizedBox(height: 16),

                    Expanded(child = Divider(color: Colors.grey[300])),

                  ],                AppTextField(

                ),

                                  controller = _phoneController,                // Phone Number Field

                SizedBox(height = 24),

                  label = 'Phone Number',                AppTextField(

                // Social Registration Buttons

                Row(                  prefixIcon = const Icon(Icons.phone_outlined),                  controller = _phoneController,

                  children = [

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

                    SizedBox(width = 16),

                    Expanded(                    }                    if (value!.length < 10) {

                      child: OutlinedButton.icon(

                        onPressed: () {                    return null;                      return 'Please enter a valid phone number';

                          // TODO: Implement Facebook registration

                        },                  },                    }

                        icon: const Icon(Icons.facebook, size: 20),

                        label: const Text('Facebook'),                ),                    return null;

                        style: OutlinedButton.styleFrom(

                          padding = const EdgeInsets.symmetric(vertical: 12),                                  },

                          side: BorderSide(color: Colors.grey[300]!),

                        ),                SizedBox(height = 16),                ),

                      ),

                    ),

                  ],

                ),                // Password Field                const SizedBox(height: 16),

                

                SizedBox(height = 32),                AppTextField(



                // Sign In Link                  controller = _passwordController,                // Password Field

                Center(

                  child = TextButton(                  label = 'Password',                AppTextField(

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

                                  ),                      obscurePassword

                const SizedBox(height: 24),

              ],                  validator = (value) {                          ? Icons.visibility

            ),

          ),                    if (value?.isEmpty ?? true) {                          : Icons.visibility_off,

        ),

      ),                      return 'Please enter a password';                    ),

    )

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
