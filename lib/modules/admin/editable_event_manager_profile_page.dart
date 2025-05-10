import 'package:darlink/modules/admin/event_data.dart';
import 'package:flutter/material.dart';

// Mock event manager data for demonstration
Map<String, String> mockEventManager = {
  'id': 'manager1',
  'name': 'Ahmad Nasser',
  'email': 'ahmad.nasser@events.com',
  'avatarUrl':
      'assets/images/black.png', // Assuming path relative to project root
  'password': 'old_password_manager', // Store hashed password in real app
};

// Keep sampleManagedEvents for now, replace with actual data source later
final List<Map<String, String>> sampleManagedEvents = [
  {
    'id': 'evt1',
    'title': 'Book Fair',
    'date': 'May 15, 2025',
    'location': 'Beirut, Biel',
    'description': 'Come explore thousands of books...',
    'image':
        'https://www.globaltimes.cn/Portals/0/attachment/2022/2022-11-13/1bc337f2-f660-4614-b897-58bf1498a6e5.jpeg'
  },
  {
    'id': 'evt2',
    'title': "Let's Walk in a Brighter Beirut",
    'date': 'May 26, 2025',
    'location': 'Corniche Ain El Mraisseh',
    'description': 'Join us for a walk...',
    'image':
        'https://images-ihjoz-com.s3.amazonaws.com/events/cover/6964/event_cover_WhatsApp_Image_2023-04-27_at_12.18.09_PM.jpg'
  },
];

class EditableEventManagerProfilePage extends StatefulWidget {
  const EditableEventManagerProfilePage({Key? key}) : super(key: key);

  @override
  _EditableEventManagerProfilePageState createState() =>
      _EditableEventManagerProfilePageState();
}

class _EditableEventManagerProfilePageState
    extends State<EditableEventManagerProfilePage> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isEditingProfile = false; // State variable to toggle edit sections

  late List<Map<String, String>> _managedEvents;
  String _currentAvatarUrl = mockEventManager['avatarUrl']!;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: mockEventManager['name']);
    _emailController = TextEditingController(text: mockEventManager['email']);
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _managedEvents = List<Map<String, String>>.from(sampleManagedEvents);
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

  void _toggleEditProfile() {
    setState(() {
      _isEditingProfile = !_isEditingProfile;
    });
  }

  void _saveProfileChanges() {
    if (_profileFormKey.currentState!.validate()) {
      setState(() {
        mockEventManager['name'] = _nameController.text;
        mockEventManager['email'] = _emailController.text;
        // In a real app, update avatarUrl if changed via an image picker
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green),
      );
    }
  }

  void _changePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      if (_oldPasswordController.text != mockEventManager['password']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Incorrect old password'),
              backgroundColor: Colors.red),
        );
        return;
      }
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('New passwords do not match'),
              backgroundColor: Colors.red),
        );
        return;
      }
      setState(() {
        mockEventManager['password'] = _newPasswordController.text;
      });
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green),
      );
    }
  }

  void _editManagedEvent(int index) async {
    final Map<String, String> currentEvent = _managedEvents[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          initialEvent: currentEvent,
          onSave: (updatedEvent) {
            setState(() {
              _managedEvents[index] = updatedEvent;
            });
          },
        ),
      ),
    );
  }

  void _deleteManagedEvent(int index) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Confirm Deletion',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          content: const Text(
              'Are you sure you want to delete this managed event?',
              style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                  style:
                      TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Delete',
                  style: TextStyle(
                      color: Colors.redAccent, fontFamily: 'Poppins')),
              onPressed: () {
                setState(() => _managedEvents.removeAt(index));
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBgColor = Color(0xFF0F172A);
    const Color secondaryBgColor = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF6A11CB); // Consistent accent

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        title: const Text(
          'Event Manager Profile',
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
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _toggleEditProfile,
            icon: Icon(_isEditingProfile ? Icons.visibility_off : Icons.edit,
                color: Colors.white),
            label: Text(
                _isEditingProfile ? 'Hide Profile Info' : 'Edit Profile Info',
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'Poppins')),
          ),
          const SizedBox(height: 20),
          if (_isEditingProfile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        backgroundImage: _currentAvatarUrl.isNotEmpty
                            ? AssetImage(_currentAvatarUrl)
                            : null,
                        onBackgroundImageError: (_, __) {},
                        child: _currentAvatarUrl.isEmpty
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
                                border: Border.all(
                                    color: primaryBgColor, width: 2)),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                              tooltip: 'Change Avatar (Not Implemented)',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Avatar change not implemented yet')),
                                );
                              },
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                            ),
                          ))
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _profileFormKey,
                  child: Column(
                    children: [
                      _buildTextFormField(_nameController, 'Full Name',
                          Icons.person, accentColor),
                      const SizedBox(height: 16),
                      _buildTextFormField(_emailController, 'Email Address',
                          Icons.email, accentColor),
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
                              () => _obscureOldPassword = !_obscureOldPassword),
                          accentColor),
                      const SizedBox(height: 16),
                      _buildPasswordFormField(
                          _newPasswordController,
                          'New Password',
                          _obscureNewPassword,
                          () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword),
                          accentColor),
                      const SizedBox(height: 16),
                      _buildPasswordFormField(
                        _confirmPasswordController,
                        'Confirm New Password',
                        _obscureConfirmPassword,
                        () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                        accentColor,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please confirm your new password';
                          if (value != _newPasswordController.text)
                            return 'Passwords do not match';
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
                        onPressed: _changePassword,
                        icon: const Icon(Icons.lock_reset, color: Colors.white),
                        label: const Text('Change Password',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Poppins')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(color: Colors.white24),
                const SizedBox(height: 32),
              ],
            ),
          // --- Managed Events Section (Always Visible) ---
          const Text(
            'Managed Events',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 16),
          if (_managedEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'You are not managing any events yet.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _managedEvents.length,
              itemBuilder: (context, index) {
                final event = _managedEvents[index];
                return EditableEventCard(
                  title: event['title']!,
                  date: event['date']!,
                  location: event['location']!,
                  imageUrl: event['image']!,
                  eventData: event,
                  onEdit: () => _editManagedEvent(index),
                  onDelete: () => _deleteManagedEvent(index),
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      IconData icon, Color accentColor) {
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
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accentColor)),
        errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(10)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your $label';
        if (label == 'Email Address' &&
            !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value))
          return 'Please enter a valid email address';
        return null;
      },
    );
  }

  Widget _buildPasswordFormField(TextEditingController controller, String label,
      bool obscureText, VoidCallback toggleObscure, Color accentColor,
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
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70),
          onPressed: toggleObscure,
        ),
        filled: true,
        fillColor: const Color(0xFF1E293B).withOpacity(0.8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accentColor)),
        errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(10)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            if (label == 'New Password' && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
    );
  }
}

// Card for displaying editable events (can be in a separate file)
class EditableEventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final Map<String, String> eventData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EditableEventCard({
    Key? key,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.eventData,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[800],
                child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white70, size: 40)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 5),
                  Text(date,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'Poppins'))
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 5),
                  Expanded(
                      child: Text(location,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'Poppins'),
                          overflow: TextOverflow.ellipsis))
                ]),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit,
                      size: 18, color: Colors.amberAccent),
                  label: const Text('Edit',
                      style: TextStyle(
                          color: Colors.amberAccent,
                          fontFamily: 'Poppins',
                          fontSize: 13)),
                  onPressed: onEdit,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.redAccent),
                  label: const Text('Delete',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontFamily: 'Poppins',
                          fontSize: 13)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
