import 'dart:developer';

import 'package:darlink/modules/authentication/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../constants/Database_url.dart' as mg;
import '../../layout/home_layout.dart';
import '../../constants/colors/app_color.dart';

// Global variables for user data
String usermail = "";
String username = "";
bool isValid = false;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  bool _hasStartedTypingEmail = false;
  bool _hasStartedTypingPassword = false;
  bool exists_email = false;
  String result_password = "";

  Future<void> _validateAndLogin() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    inspect(db);
    var collection = db.collection("user");

    final result_email = await collection
        .findOne(mongo.where.eq("Email", _emailController.text));
    if (result_email != null) {
      exists_email = true;
    }

    setState(() {
      if (_emailController.text.isEmpty) {
        _emailError = 'Email cannot be empty';
      } else if (exists_email == false) {
        _emailError = 'Email does not exist';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
          .hasMatch(_emailController.text)) {
        _emailError = 'Enter a valid email';
      } else {
        _emailError = null;
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password cannot be empty';
      } else if (_passwordController.text !=
          result_email?['Password'] as String) {
        _passwordError = 'Password is incorrect';
      } else {
        _passwordError = null;
        result_password = result_email?['Password'] as String;
      }
    });

    if (_emailError == null && _passwordError == null) {
      print("Login Successful");
      usermail = _emailController.text;
      username = result_email?['name'] as String;
      print(result_email?['Password'] as String);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color:
              isDarkMode ? AppColors.backgroundDark : theme.colorScheme.surface,
        ),
        margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.2),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: FontAwesomeIcons.envelope,
                  iconColor: Colors.white,
                  hintText: 'Enter your email',
                  errorText: _hasStartedTypingEmail ? _emailError : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingEmail = true;
                      if (_emailController.text.isEmpty) {
                        _emailError = 'Email cannot be empty';
                      } else if (exists_email == false) {
                        _emailError = 'Email does not exist';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(_emailController.text)) {
                        _emailError = 'Enter a valid email';
                      } else {
                        _emailError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: FontAwesomeIcons.lock,
                  iconColor: Colors.purple,
                  hintText: 'Enter your password',
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: isDarkMode ? AppColors.textOnDark : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  errorText: _hasStartedTypingPassword ? _passwordError : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingPassword = true;
                      if (_passwordController.text.isEmpty) {
                        _passwordError = 'Password cannot be empty';
                      } else if (_passwordController.text != result_password) {
                        _passwordError = 'Password is incorrect';
                      } else {
                        _passwordError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _validateAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Login',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.textOnDark : Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Social Media Buttons
                Text(
                  'Or login with',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      icon: FontAwesomeIcons.facebookF,
                      color: Colors.blue,
                      onTap: () => print('Facebook Login'),
                    ),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.google,
                      color: Colors.red,
                      onTap: () => print('Google Login'),
                    ),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.envelope,
                      color: Colors.green,
                      onTap: () => print('Gmail Login'),
                    ),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.apple,
                      color: isDarkMode ? Colors.white : Colors.black,
                      onTap: () => print('Apple Login'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Register Text
                GestureDetector(
                  onTap: () {
                    // Navigate to Register Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: theme.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Poppins',
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final fieldBackgroundColor =
        isDarkMode ? AppColors.cardDarkBackground : const Color(0xFF2C2D49);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      autocorrect: true,
      autofocus: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: errorText != null
              ? AppColors.error
              : (isDarkMode
                  ? AppColors.textOnDark
                  : theme.textTheme.headlineMedium!.color),
          fontSize: 18,
          fontFamily: 'Poppins',
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: theme.textTheme.headlineLarge!.color),
        filled: true,
        fillColor: theme.primaryColor.withOpacity(0.7),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.3),
            child: FaIcon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
        ),
        suffixIcon: suffixIcon,
        alignLabelWithHint: true,
        hintTextDirection: TextDirection.ltr,
        errorText: errorText,
        errorStyle: TextStyle(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : Colors.black,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? AppColors.textOnDark : Colors.white,
        fontSize: 16,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30, // Larger background circle
        backgroundColor: color.withOpacity(0.2),
        child: FaIcon(
          icon,
          color: icon == FontAwesomeIcons.apple &&
                  Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : color,
          size: 24,
        ),
      ),
    );
  }
}
