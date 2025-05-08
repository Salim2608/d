import 'dart:developer';
import 'dart:math';
import 'package:darlink/layout/home_layout.dart';
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
  bool _isVerifyingOTP = false;
  bool _otpSent = false;
  String? _otpError;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  bool _hasStartedTypingUsername = false;
  bool _hasStartedTypingEmail = false;
  bool _hasStartedTypingPassword = false;
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

  Future<void> _sendOTP() async {
    if (_emailError != null || _emailController.text.isEmpty) {
      return;
    }

    setState(() {
      _isVerifyingOTP = true;
    });

    bool result = await EmailOTP.sendOTP(
      email: _emailController.text,
    );

    setState(() {
      _otpSent = result;
      _isVerifyingOTP = false;
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
    setState(() {
      if (_usernameController.text.isEmpty) {
        _usernameError = 'Username cannot be empty';
      } else if (_usernameController.text.length < 6) {
        _usernameError = 'Username must be at least 6 characters';
      } else {
        _usernameError = null;
      }

      if (_emailController.text.isEmpty) {
        _emailError = 'Email cannot be empty';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
          .hasMatch(_emailController.text)) {
        _emailError = 'Enter a valid email';
      } else {
        _emailError = null;
      }

      _passwordError =
          _passwordController.text.isEmpty ? 'Password cannot be empty' : null;
    });

    if (_usernameError != null ||
        _emailError != null ||
        _passwordError != null) {
      return;
    }

    // Check if OTP is verified
    if (_otpSent) {
      if (_otpController.text.isEmpty) {
        setState(() {
          _otpError = 'Please enter OTP';
        });
        return;
      }

      setState(() {
        _isVerifyingOTP = true;
      });

      bool isVerified = await EmailOTP.verifyOTP(otp: _otpController.text);

      setState(() {
        _isVerifyingOTP = false;
        _otpError = isVerified ? null : 'Invalid OTP';
      });

      if (!isVerified) {
        return;
      }
    }

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
    });

    if (exists_name || exists_email) {
      return;
    }

    // All validations passed - register user
    print("Registration Successful");
    await collection.insert({
      'name': _usernameController.text,
      'Password': _passwordController.text,
      'Email': _emailController.text
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
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
                  iconColor: Colors.orange,
                  hintText: 'Enter your username',
                  errorText: _hasStartedTypingUsername ? _usernameError : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingUsername = true;
                      if (_usernameController.text.isEmpty) {
                        _usernameError = 'Username cannot be empty';
                      } else if (_usernameController.text.length < 6) {
                        _usernameError =
                            'Username must be at least 6 characters';
                      } else {
                        _usernameError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: FontAwesomeIcons.envelope,
                  iconColor: Colors.green,
                  hintText: 'Enter your email',
                  errorText: _hasStartedTypingEmail ? _emailError : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingEmail = true;
                      if (_emailController.text.isEmpty) {
                        _emailError = 'Email cannot be empty';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(_emailController.text)) {
                        _emailError = 'Enter a valid email';
                      } else {
                        _emailError = null;
                      }
                    });
                  },
                  suffixIcon: !_otpSent
                      ? TextButton(
                          onPressed: _emailError == null &&
                                  _emailController.text.isNotEmpty
                              ? _sendOTP
                              : null,
                          child: _isVerifyingOTP
                              ? const CircularProgressIndicator()
                              : const Text('Send OTP'),
                        )
                      : null,
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
                      _passwordError =
                          value.isEmpty ? 'Password cannot be empty' : null;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Register Button
                ElevatedButton(
                  onPressed: _isVerifyingOTP ? null : _validateAndRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isVerifyingOTP
                      ? const CircularProgressIndicator()
                      : Text(
                          'Register',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppColors.textOnDark
                                : Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // Social Media Buttons
                Text(
                  'Or register with',
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeLayout()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Text
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: theme.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: "Login",
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
    TextInputType? keyboardType,
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
      keyboardType: keyboardType,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: color.withOpacity(0.2),
        child: FaIcon(
          icon,
          color: icon == FontAwesomeIcons.apple && isDarkMode
              ? Colors.white
              : color,
          size: 24,
        ),
      ),
    );
  }
}
