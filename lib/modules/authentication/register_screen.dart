import 'dart:developer';
import 'dart:math';

import 'package:darlink/layout/home_layout.dart';
import 'package:darlink/modules/authentication/forget_password.dart';
import 'package:darlink/modules/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../constants/Database_url.dart' as mg;
import '../../constants/database_url.dart';
import '../../constants/colors/app_color.dart';
import 'package:email_otp/email_otp.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _otpSent = false;
  String? _otpError;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _phoneError;

  bool _hasStartedTypingUsername = false;
  bool _hasStartedTypingEmail = false;
  bool _hasStartedTypingPassword = false;
  bool _hasStartedTypingPhoneNumber = false;
  bool exists_name = false;
  bool exists_email = false;

  EmailOTP myauth = EmailOTP();

  @override
  void initState() {
    super.initState();
    // Configure EmailOTP
    EmailOTP.config(
      appName: 'Darlink',
      otpType: OTPType.numeric,
      emailTheme: EmailTheme.v3,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Validate email format
  bool _isValidEmailFormat(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _sendOTP() async {
    if (_emailError != null || _emailController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Keep your original OTP sending logic
    bool result = await EmailOTP.sendOTP(
      email: _emailController.text,
    );

    setState(() {
      _otpSent = result;
      _isLoading = false;
    });

    if (!result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  Future<void> _validateAndRegister() async {
    exists_name = false;
    exists_email = false;

    // First validate all fields
    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameError = 'Username cannot be empty';
      });
      return;
    } else if (_usernameController.text.length < 6) {
      setState(() {
        _usernameError = 'Username must be at least 6 characters';
      });
      return;
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    } else if (!_isValidEmailFormat(_emailController.text)) {
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

    // Check if OTP is verified (using your original logic)
    if (_otpSent) {
      if (_otpController.text.isEmpty) {
        setState(() {
          _otpError = 'Please enter OTP';
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      bool isVerified = EmailOTP.verifyOTP(otp: _otpController.text);

      setState(() {
        _isLoading = false;
        _otpError = isVerified ? null : 'Invalid OTP';
      });

      if (!isVerified) {
        return;
      }
    } else {
      setState(() {
        _emailError = 'Please send OTP first';
      });
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if username/email exists in database
      var db = await mongo.Db.create(mongo_url);
      await db.open();
      inspect(db);
      var collection = db.collection('user');

      final result_name = await collection
          .findOne(mongo.where.eq('name', _usernameController.text));
      if (result_name != null) {
        exists_name = true;
      }

      final result_email = await collection
          .findOne(mongo.where.eq('Email', _emailController.text));
      if (result_email != null) {
        exists_email = true;
      }

      setState(() {
        if (exists_name) {
          _usernameError = 'Username already exists';
        }
        if (exists_email) {
          _emailError = 'Email already exists';
        }
        _isLoading = false;
      });

      if (exists_name || exists_email) {
        return;
      }

      // All validations passed - register user
      print("Registration Successful");
      await collection.insert({
        'name': _usernameController.text,
        'Password': _passwordController.text,
        'Email': _emailController.text,
        'whishlist': [0]
      });

      // Close database connection
      await db.close();

      // Navigate to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                  'Register',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Username Field
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: FontAwesomeIcons.user,
                  iconColor: primaryColor,
                  hintText: 'Enter your username',
                  errorText: _hasStartedTypingUsername ? _usernameError : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingUsername = true;

                      if (value.isEmpty) {
                        _usernameError = 'Username cannot be empty';
                      } else if (value.length < 6) {
                        _usernameError =
                            'Username must be at least 6 characters';
                      } else {
                        _usernameError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: FontAwesomeIcons.phone,
                  keyboardType: TextInputType.phone,
                  iconColor: Colors.red,
                  hintText: 'Enter your Phone Number',
                  errorText:
                      _hasStartedTypingPhoneNumber ? _usernameError : null,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _phoneError = 'Phone Number cannot be empty';
                      } else if (value.length < 8) {
                        _phoneError = 'Please enter a valid Phone Number';
                      } else {
                        _phoneError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  icon: FontAwesomeIcons.envelope,
                  iconColor: Colors.blue,
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
                  suffixIcon: !_otpSent
                      ? TextButton(
                          onPressed: _emailError == null &&
                                  _emailController.text.isNotEmpty &&
                                  !_isLoading
                              ? _sendOTP
                              : null,
                          child: _isLoading && !_otpSent
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: onSurfaceColor,
                                  ),
                                )
                              : Text(
                                  'Send OTP',
                                  style: TextStyle(color: secondaryColor),
                                ),
                        )
                      : Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                ),
                const SizedBox(height: 15),

                // OTP Field (only shown after OTP is sent)
                if (_otpSent)
                  Column(
                    children: [
                      _buildTextField(
                        controller: _otpController,
                        label: 'OTP',
                        icon: FontAwesomeIcons.key,
                        iconColor: Colors.blue,
                        hintText: 'Enter 6-digit OTP',
                        keyboardType: TextInputType.number,
                        errorText: _otpError,
                        onChanged: (value) {
                          setState(() {
                            _otpError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),

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

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndRegister,
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
                          'Register',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // Login Text
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          // Navigate to Login Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurfaceColor.withOpacity(0.8),
                      ),
                      children: [
                        TextSpan(
                          text: "Login",
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
    TextInputType? keyboardType,
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
      keyboardType: keyboardType,
      onChanged: onChanged,
      autocorrect: false,
      autofocus: false, // Set to false to prevent autofocus
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
