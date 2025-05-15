import 'dart:developer';

import 'package:darlink/modules/admin/admin_dashboard.dart';
import 'package:darlink/modules/authentication/forget_password.dart';
import 'package:darlink/modules/authentication/register_screen.dart';
import 'package:darlink/modules/authentication/verify_user_change_password.dart' hide AppColors;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/Database_url.dart' as mg;
import '../../layout/home_layout.dart';
import '../../constants/colors/app_color.dart';

// Global variables for user data
String usermail = "";
String username = "";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  bool _hasStartedTypingEmail = false;
  bool _hasStartedTypingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate email format
  bool _isValidEmailFormat(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Login logic
  Future<void> _validateAndLogin() async {
    if(_emailController.text =="admin" && _passwordController.text =="admin"){

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const AdminDashboard()));

    }
    // First validate inputs before making database call
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    }

    if (!_isValidEmailFormat(_emailController.text)) {
      setState(() {
        _emailError = 'Enter a valid email';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      var db = await mongo.Db.create(mg.mongo_url);
      await db.open();
      inspect(db);
      var collection = db.collection("user");

      final userDocument = await collection
          .findOne(mongo.where.eq("Email", _emailController.text));

      if (userDocument == null) {
        setState(() {
          _emailError = 'Account not found';
          _isLoading = false;
        });
        return;
      }

      // Get password from document
      final storedPassword = userDocument['Password'] as String?;

      // Validate password
      if (storedPassword != _passwordController.text) {
        setState(() {
          _passwordError = 'Incorrect password';
          _isLoading = false;
        });
        return;
      }

      // Login successful
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Store user info
      usermail = _emailController.text;
      username = userDocument['name'] as String;

      // Close database connection
      await db.close();

      // Navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeLayout()),
        );
      }
    } catch (e) {
      // Handle connection or database errors
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error. Please try again later.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
      print("Database error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final primaryColor = colorScheme.primary;
    final surfaceColor =
        isDarkMode ? AppColors.backgroundDark : colorScheme.surface;
    final onSurfaceColor =
        isDarkMode ? AppColors.textOnDark : colorScheme.onSurface;
    final secondaryColor = AppColors.secondary;
    final errorColor = colorScheme.error;

    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: surfaceColor,
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
                  iconColor: primaryColor,
                  hintText: 'Enter your email',
                  errorText: _hasStartedTypingEmail ? _emailError : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingEmail = true;

                      if (value.isEmpty) {
                        _emailError = 'Email cannot be empty';
                      } else if (!_isValidEmailFormat(value)) {
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
                  iconColor: secondaryColor,
                  hintText: 'Enter your password',
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: onSurfaceColor.withOpacity(0.7),
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

                      if (value.isEmpty) {
                        _passwordError = 'Password cannot be empty';
                      } else {
                        _passwordError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: onSurfaceColor,
                          ),
                        )
                      : Text(
                          'Login',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EmailVerificationScreen()),
                          );
                        },
                  child: RichText(
                    text: TextSpan(
                      text: "Forget Password? ",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurfaceColor.withOpacity(0.8),
                      ),
                      children: [
                        TextSpan(
                          text: "Change Password",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                // Register Text
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurfaceColor.withOpacity(0.8),
                      ),
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
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
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Consistent field colors based on theme
    final fieldBackgroundColor = isDarkMode
        ? colorScheme.surface.withOpacity(0.1)
        : colorScheme.primary.withOpacity(0.1);

    final textColor = isDarkMode ? AppColors.textOnDark : colorScheme.onSurface;

    final labelColor = errorText != null
        ? colorScheme.error
        : (isDarkMode ? AppColors.textOnDark : colorScheme.onSurface);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      autocorrect: false, // Changed to false for passwords
      autofocus: false, // Changed to false for better UX
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: labelColor,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: fieldBackgroundColor,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: FaIcon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
        ),
        suffixIcon: suffixIcon,
        alignLabelWithHint: true,
        errorText: errorText,
        errorStyle: TextStyle(
          color: colorScheme.error,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: errorText != null ? colorScheme.error : colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontFamily: 'Poppins',
      ),
    );
  }
}
 









/* 


import 'dart:developer';

import 'package:darlink/modules/authentication/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/Database_url.dart' as mg;
import '../../layout/home_layout.dart';
import '../../constants/colors/app_color.dart';
import '../admin/admin_dashboard.dart';

// Global variables for user data
String usermail = "";
String username = "";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  bool _hasStartedTypingEmail = false;
  bool _hasStartedTypingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmailFormat(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Login logic
  Future<void> _validateAndLogin() async {
    if (_emailController.text == "admin" &&
        _passwordController.text == "admin") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AdminDashboard()));
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    }

    if (!_isValidEmailFormat(_emailController.text)) {
      setState(() {
        _emailError = 'Enter a valid email';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      var db = await mongo.Db.create(mg.mongo_url);
      await db.open();
      inspect(db);
      var collection = db.collection("user");

      final userDocument = await collection
          .findOne(mongo.where.eq("Email", _emailController.text));

      if (userDocument == null) {
        setState(() {
          _emailError = 'Account not found';
          _isLoading = false;
        });
        return;
      }

      // Get password from document
      final storedPassword = userDocument['Password'] as String?;

      // Validate password
      if (storedPassword != _passwordController.text) {
        setState(() {
          _passwordError = 'Incorrect password';
          _isLoading = false;
        });
        return;
      }

      // Login successful
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Store user info
      usermail = _emailController.text;
      username = userDocument['name'] as String;

      // Close database connection
      await db.close();

      // Navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeLayout()),
        );
      }
    } catch (e) {
      // Handle connection or database errors
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error. Please try again later.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
      print("Database error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final primaryColor = colorScheme.primary;
    final surfaceColor =
        isDarkMode ? AppColors.backgroundDark : colorScheme.surface;
    final onSurfaceColor =
        isDarkMode ? AppColors.textOnDark : colorScheme.onSurface;
    final secondaryColor = AppColors.secondary;
    final errorColor = colorScheme.error;

    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: surfaceColor,
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
                  iconColor: primaryColor,
                  hintText: 'Enter your email',
                  errorText: _hasStartedTypingEmail ? _emailError : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingEmail = true;

                      if (value.isEmpty) {
                        _emailError = 'Email cannot be empty';
                      } else if (!_isValidEmailFormat(value)) {
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
                  iconColor: secondaryColor,
                  hintText: 'Enter your password',
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: onSurfaceColor.withOpacity(0.7),
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

                      if (value.isEmpty) {
                        _passwordError = 'Password cannot be empty';
                      } else {
                        _passwordError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: onSurfaceColor,
                          ),
                        )
                      : Text(
                          'Login',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 15),

                // Register Text
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurfaceColor.withOpacity(0.8),
                      ),
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: secondaryColor,
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
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Consistent field colors based on theme
    final fieldBackgroundColor = isDarkMode
        ? colorScheme.surface.withOpacity(0.1)
        : colorScheme.primary.withOpacity(0.1);

    final textColor = isDarkMode ? AppColors.textOnDark : colorScheme.onSurface;

    final labelColor = errorText != null
        ? colorScheme.error
        : (isDarkMode ? AppColors.textOnDark : colorScheme.onSurface);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      autocorrect: false, // Changed to false for passwords
      autofocus: false, // Changed to false for better UX
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: labelColor,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: fieldBackgroundColor,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: FaIcon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
        ),
        suffixIcon: suffixIcon,
        alignLabelWithHint: true,
        errorText: errorText,
        errorStyle: TextStyle(
          color: colorScheme.error,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: errorText != null ? colorScheme.error : colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontFamily: 'Poppins',
      ),
    );
  }
}
 */