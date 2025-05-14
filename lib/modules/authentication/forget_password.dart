import 'package:darlink/modules/authentication/login_screen.dart';
import 'package:darlink/modules/authentication/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../constants/Database_url.dart' as mg;
import '../../constants/database_url.dart';
import '../../constants/colors/app_color.dart';

class ForgotPasswordWithEmail extends StatefulWidget {
  final String email;
  final String username;

  const ForgotPasswordWithEmail(
      {Key? key, required this.email, required this.username})
      : super(key: key);

  @override
  State<ForgotPasswordWithEmail> createState() =>
      _ForgotPasswordWithEmailState();
}

class _ForgotPasswordWithEmailState extends State<ForgotPasswordWithEmail> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _passwordChanged = false;

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  String? _generalError;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _hasStartedTypingCurrentPassword = false;
  bool _hasStartedTypingNewPassword = false;
  bool _hasStartedTypingConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Password validation checks
  bool _isStrongPassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasDigits &&
        hasSpecialCharacters;
  }

  // Verify current password against database
  Future<bool> _verifyCurrentPassword() async {
    try {
      // Connect to the database
      var db = await mongo.Db.create(mongo_url);
      await db.open();
      var collection = db.collection('user');

      // Check if user exists with provided email and password
      final user = await collection.findOne(
        mongo.where
            .eq('Email', widget.email)
            .eq('name', widget.username)
            .eq('password', _currentPasswordController.text),
      );

      await db.close();
      return user != null;
    } catch (e) {
      setState(() {
        _generalError = 'Database connection error. Please try again later.';
      });
      return false;
    }
  }

  // Update password in database


  // Handle form submission
  Future<void> _changePassword(String email) async {
    if (_formKey.currentState!.validate()) {
      // Clear any previous general errors
      var db = await mongo.Db.create(mg.mongo_url);
      await db.open();
      var collection = db.collection("user");

     await collection.update(
        mongo.where.eq('Email',email),
        mongo.modify.set('Password', _confirmPasswordController.text),
      );



      setState(() {
        _generalError = null;
        _isLoading = true;
      }

      );

      // Verify current password first
      final isVerified = await _verifyCurrentPassword();

      if (!isVerified) {
        setState(() {
          _currentPasswordError = 'Current password is incorrect';
          _isLoading = false;
        });
        return;
      }

      // Update password




        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

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
                  'Reset Password',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter new password and type it again for confirmation',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onSurfaceColor.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // New Password Field
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hintText: 'Create a new password',
                  icon: FontAwesomeIcons.lockOpen,
                  iconColor: Colors.blue,
                  obscureText: _obscureNewPassword,
                  errorText:
                      _hasStartedTypingNewPassword ? _newPasswordError : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingNewPassword = true;

                      if (value.isEmpty) {
                        _newPasswordError = 'New password is required';
                      } else if (value.length < 8) {
                        _newPasswordError =
                            'Password must be at least 8 characters';
                      } else if (!_isStrongPassword(value)) {
                        _newPasswordError =
                            'Password must include uppercase, lowercase, number & special character';
                      } else if (value == _currentPasswordController.text) {
                        _newPasswordError =
                            'New password must be different from current password';
                      } else {
                        _newPasswordError = null;
                      }

                      // Update confirm password validation if needed
                      if (_hasStartedTypingConfirmPassword &&
                          _confirmPasswordController.text.isNotEmpty) {
                        if (_confirmPasswordController.text != value) {
                          _confirmPasswordError = 'Passwords do not match';
                        } else {
                          _confirmPasswordError = null;
                        }
                      }
                    });
                  },
                  toggleObscureText: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Confirm Password Field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Confirm your new password',
                  icon: FontAwesomeIcons.shieldHalved,
                  iconColor: Colors.green,
                  obscureText: _obscureConfirmPassword,
                  errorText: _hasStartedTypingConfirmPassword
                      ? _confirmPasswordError
                      : null,
                  onChanged: (value) {
                    setState(() {
                      _hasStartedTypingConfirmPassword = true;

                      if (value.isEmpty) {
                        _confirmPasswordError = 'Please confirm your password';
                      } else if (value != _newPasswordController.text) {
                        _confirmPasswordError = 'Passwords do not match';
                      } else {
                        _confirmPasswordError = null;
                      }
                    });
                  },
                  toggleObscureText: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Change Password Button
                ElevatedButton(
                  onPressed: ( _isLoading || _passwordChanged)
                      ? null
                      : () {
                    print('Attempting password change for email: ${widget.email}');
                          if (_currentPasswordError == null &&
                              _newPasswordError == null &&
                              _confirmPasswordError == null &&
                              _newPasswordController.text.isNotEmpty &&
                              _confirmPasswordController.text.isNotEmpty) {
                            _changePassword(widget.email);
                            print(widget.email);
                          } else {
                            // Trigger validations
                            setState(() {
                              _hasStartedTypingCurrentPassword = true;
                              _hasStartedTypingNewPassword = true;
                              _hasStartedTypingConfirmPassword = true;

                              if (_currentPasswordController.text.isEmpty) {
                                _currentPasswordError =
                                    'Current password is required';
                              }

                              if (_newPasswordController.text.isEmpty) {
                                _newPasswordError = 'New password is required';
                              }

                              if (_confirmPasswordController.text.isEmpty) {
                                _confirmPasswordError =
                                    'Please confirm your password';
                              }
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _passwordChanged ? Colors.green : secondaryColor,
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
                            color: Colors.white,
                          ),
                        )
                      : _passwordChanged
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                                Text(
                                  'Password Changed',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Change Password',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                ),

                // Navigation Options
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavigationText(
                      context: context,
                      prefix: "Remember your password? ",
                      linkText: "Login",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _buildNavigationText(
                      context: context,
                      prefix: "Need an account? ",
                      linkText: "Register",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    required bool obscureText,
    required Function(String) onChanged,
    required VoidCallback toggleObscureText,
    String? errorText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

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
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.primary.withOpacity(0.7),
          ),
          onPressed: toggleObscureText,
        ),
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

  Widget _buildNavigationText({
    required BuildContext context,
    required String prefix,
    required String linkText,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final onSurfaceColor =
        isDarkMode ? AppColors.textOnDark : colorScheme.onSurface;
    final secondaryColor = AppColors.secondary;

    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: RichText(
        text: TextSpan(
          text: prefix,
          style: theme.textTheme.bodySmall?.copyWith(
            color: onSurfaceColor.withOpacity(0.8),
          ),
          children: [
            TextSpan(
              text: linkText,
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
    );
  }
}
