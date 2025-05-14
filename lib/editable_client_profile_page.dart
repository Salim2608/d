import 'package:flutter/material.dart';
import '../models/user_model.dart'; // Import the updated User model

// Mock user data for demonstration - replace with actual user data retrieval
User mockUser = User(
  id: 'client1',
  username: 'Mouniro',
  email: 'Mouniro@gmail.com',
  role: 'User',
  avatarUrl: 'assets/images/black.png', // Placeholder avatar
  joinDate: '2024-01-01',
);

class EditableClientProfilePage extends StatefulWidget {
  const EditableClientProfilePage({super.key});

  @override
  _EditableClientProfilePageState createState() =>
      _EditableClientProfilePageState();
}

class _EditableClientProfilePageState extends State<EditableClientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  // Avatar URL might be handled differently (e.g., image picker)
  // Role and Join Date are likely not editable by the user

  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: mockUser.username);
    _emailController = TextEditingController(text: mockUser.email);

    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveProfileChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Update mock user data - replace with actual update logic (API call, etc.)
        mockUser = mockUser.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          // Update other fields as needed
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green),
      );
    }
  }

/* 
  void _changePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      // 1. Verify old password (compare with mockUser.password)
      // IMPORTANT: In a real app, compare hashed passwords!
      if (_oldPasswordController.text != mockUser.password) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect old password'), backgroundColor: Colors.red),
        );
        return;
      }

      // 2. Check if new password and confirm password match
      if (_newPasswordController.text != _confirmPasswordController.text) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match'), backgroundColor: Colors.red),
        );
        return;
      }

      // 3. Update password (update mockUser.password)
      // IMPORTANT: In a real app, hash the new password before saving!
      setState(() {
        mockUser = mockUser.copyWith(password: _newPasswordController.text);
      });

      // Clear password fields
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green),
      );
       // Optionally, close the password section or navigate away
    }
  }
 */
  @override
  Widget build(BuildContext context) {
    const Color primaryBgColor = Color(0xFF0F172A);
    const Color secondaryBgColor = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF6A11CB); // Using a purple accent

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: secondaryBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Profile Information Section ---
            const Text(
              'Profile Information',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: AssetImage(
                        mockUser.avatarUrl), // Use AssetImage for local assets
                    onBackgroundImageError:
                        (_, __) {}, // Handle error if needed
                    child: mockUser.avatarUrl.isEmpty
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.white70)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryBgColor, width: 2)),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                        tooltip: 'Change Avatar (Not Implemented)',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Avatar change not implemented yet')),
                          );
                        },
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextFormField(
                      _nameController, 'Full Name', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                      _emailController, 'Email Address', Icons.email),
                  // Add other editable fields here if needed (e.g., phone number)
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _saveProfileChanges,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save Profile Changes',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(color: Colors.white24),
            const SizedBox(height: 32),

            // --- Change Password Section ---
            const Text(
              'Change Password',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _buildPasswordFormField(
                      _oldPasswordController,
                      'Old Password',
                      _obscureOldPassword,
                      () => setState(
                          () => _obscureOldPassword = !_obscureOldPassword)),
                  const SizedBox(height: 16),
                  _buildPasswordFormField(
                      _newPasswordController,
                      'New Password',
                      _obscureNewPassword,
                      () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword)),
                  const SizedBox(height: 16),
                  _buildPasswordFormField(
                    _confirmPasswordController,
                    'Confirm New Password',
                    _obscureConfirmPassword,
                    () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      // _changePassword(); // Uncomment when implementing password change logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Change Password feature not implemented yet')),
                      );
                    },
                    icon: const Icon(Icons.lock_reset, color: Colors.white),
                    label: const Text('Change Password',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Add some bottom padding
          ],
        ),
      ),
    );
  }

  // Helper for standard text fields
  Widget _buildTextFormField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        filled: true,
        fillColor: const Color(0xFF1E293B).withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6A11CB)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == 'Email Address' &&
            !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  // Helper for password fields
  Widget _buildPasswordFormField(TextEditingController controller, String label,
      bool obscureText, VoidCallback toggleObscure,
      {FormFieldValidator<String>? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
        prefixIcon: const Icon(Icons.lock, color: Colors.white70, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: toggleObscure,
        ),
        filled: true,
        fillColor: const Color(0xFF1E293B).withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6A11CB)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            // Add password complexity rules if needed for 'New Password'
            if (label == 'New Password' && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
    );
  }
}
