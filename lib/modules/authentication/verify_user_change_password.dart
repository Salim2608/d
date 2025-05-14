import 'dart:developer';

import 'package:darlink/modules/authentication/forget_password.dart';
import 'package:darlink/modules/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:email_otp/email_otp.dart';
import '../../constants/database_url.dart';
import '../../constants/colors/app_color.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  // Form and State Management
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _otpSent = false;
  bool _userExists = false;

  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  // Error Messages
  String? _usernameError;
  String? _emailError;
  String? _otpError;


  // Tracking user input
  bool _hasStartedTypingUsername = false;
  bool _hasStartedTypingEmail = false;

  // Email OTP Service
  final EmailOTP _emailOTP = EmailOTP();

  @override
  void initState() {
    super.initState();
    _initializeEmailOTP();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _initializeEmailOTP() {
    EmailOTP.config(
      appName: 'Darlink',
      otpType: OTPType.numeric,
      emailTheme: EmailTheme.v3,
    );
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<bool> _checkUserExists() async {
    if (_emailController.text.isEmpty || _usernameController.text.isEmpty) {
      return false;
    }

    try {
      final db = await mongo.Db.create(mongo_url);
      await db.open();

      final collection = db.collection('user');
      final user = await collection.findOne(
        mongo.where
            .eq('Email', _emailController.text)
            .eq('name', _usernameController.text),
      );

      await db.close();
      return user != null;
    } catch (e) {
      log("Database error: $e");
      return false;
    }
  }

  Future<void> _sendOTP() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      _userExists = await _checkUserExists();

      if (!_userExists) {
        setState(() {
          _isLoading = false;
          _emailError = 'No account found with this email and username';
        });
        return;
      }

      final otpSent = await EmailOTP.sendOTP(email: _emailController.text);

      setState(() {
        _otpSent = otpSent;
        _isLoading = false;
      });

      if (!otpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send verification code')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  bool _validateForm() {
    if (_emailError != null || _emailController.text.isEmpty) {
      return false;
    }
    if (_usernameError != null || _usernameController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _verifyAndProceed() async {
    if (_otpController.text.isEmpty) {
      setState(() => _otpError = 'Please enter verification code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isVerified = await EmailOTP.verifyOTP(otp: _otpController.text);

      if (!isVerified) {
        setState(() {
          _isLoading = false;
          _otpError = 'Invalid verification code';
        });
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordWithEmail(
              email: _emailController.text,
              username: _usernameController.text,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = _getColorScheme(theme, isDarkMode);

    return Scaffold(
      backgroundColor: colors.primary,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: colors.surface,
        ),
        margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.2),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(theme, colors),
                const SizedBox(height: 20),
                _buildUsernameField(theme, colors),
                const SizedBox(height: 15),
                _buildEmailField(theme, colors),
                const SizedBox(height: 15),
                if (_otpSent) _buildOtpVerificationSection(theme, colors),
                const SizedBox(height: 20),
                _buildLoginPrompt(theme, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppColors colors) {
    return Column(
      children: [
        Text(
          'Verify Email',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Enter your username and email to verify your identity',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUsernameField(ThemeData theme, AppColors colors) {
    return _buildTextField(
      controller: _usernameController,
      label: 'Username',
      icon: FontAwesomeIcons.user,
      iconColor: Colors.deepPurple,
      hintText: 'Enter your username',
      errorText: _hasStartedTypingUsername ? _usernameError : null,
      onChanged: (value) {
        setState(() {
          _hasStartedTypingUsername = true;
          _usernameError = value.isEmpty
              ? 'Username cannot be empty'
              : (value.length < 6 ? 'Username must be at least 6 characters' : null);
        });
      },
      theme: theme,
      colors: colors,
    );
  }

  Widget _buildEmailField(ThemeData theme, AppColors colors) {
    return _buildTextField(
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
          _emailError = value.isEmpty
              ? 'Email cannot be empty'
              : (!_validateEmail(value) ? 'Enter a valid email' : null);
        });
      },
      theme: theme,
      colors: colors,
      suffixIcon: !_otpSent
          ? TextButton(
        onPressed: _isLoading || !_validateForm() ? null : _sendOTP,
        child: _isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.onSurface,
          ),
        )
            : Text(
          'Send Code',
          style: TextStyle(color: colors.secondary),
        ),
      )
          : const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  Widget _buildOtpVerificationSection(ThemeData theme, AppColors colors) {
    return Column(
      children: [
        _buildTextField(
          controller: _otpController,
          label: 'Verification Code',
          icon: FontAwesomeIcons.key,
          iconColor: Colors.green,
          hintText: 'Enter verification code',
          keyboardType: TextInputType.number,
          errorText: _otpError,
          onChanged: (value) => setState(() => _otpError = null),
          theme: theme,
          colors: colors,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyAndProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.secondary,
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
              color: colors.onSurface,
            ),
          )
              : Text(
            'Verify & Continue',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt(ThemeData theme, AppColors colors) {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ),
      child: RichText(
        text: TextSpan(
          text: "Remember your password? ",
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(0.8),
          ),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: colors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
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
    required ThemeData theme,
    required AppColors colors,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: errorText != null ? theme.colorScheme.error : colors.onSurface,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colors.onSurface.withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: colors.fieldBackground,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: FaIcon(icon, color: iconColor, size: 18),
          ),
        ),
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: TextStyle(color: theme.colorScheme.error, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: errorText != null ? theme.colorScheme.error : colors.primary,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(
        color: colors.onSurface,
        fontSize: 16,
        fontFamily: 'Poppins',
      ),
    );
  }

  AppColors _getColorScheme(ThemeData theme, bool isDarkMode) {
    return AppColors(
      primary: theme.colorScheme.primary,
      surface: isDarkMode ? AppColors.backgroundDark : theme.colorScheme.surface,
      onSurface: isDarkMode ? AppColors.textOnDark : theme.colorScheme.onSurface,
      fieldBackground: isDarkMode
          ? theme.colorScheme.surface.withOpacity(0.1)
          : theme.colorScheme.primary.withOpacity(0.1), secondary: theme.colorScheme.primary,
    );
  }
}

class AppColors {
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color secondary;
  final Color fieldBackground;

  AppColors({
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.secondary,
    required this.fieldBackground,
  });

  static const backgroundDark = Color(0xFF121212);
  static const textOnDark = Color(0xFFFFFFFF);
}