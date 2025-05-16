import 'package:darlink/models/user_model.dart';
import 'package:flutter/material.dart';
import '../../constants/colors/app_color.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../constants/Database_url.dart' as mg;

class ProfileUserScreen extends StatefulWidget {
  final String username;
  final Function(User)? onProfileUpdated;

  const ProfileUserScreen({
    super.key,
    required this.username,
    this.onProfileUpdated,
  });

  @override
  State<ProfileUserScreen> createState() => _ProfileUserScreenState();
}

class _ProfileUserScreenState extends State<ProfileUserScreen> {
  late Future<User> _userFuture;
  late User currentUser;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await User_from_name(widget.username);
      if (mounted) {
        setState(() {
          currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<User> User_from_name(String username) async {
    try {
      var db = await mongo.Db.create(mg.mongo_url);
      await db.open();
      var collection = db.collection("user");

      var userDoc = await collection.findOne(mongo.where.eq("name", username));

      if (userDoc == null) {
        throw Exception("User not found");
      }

      return User(
        id: userDoc['_id']?.toString() ?? "0",
        username: userDoc['name']?.toString() ?? username,
        email: userDoc['Email']?.toString() ?? "",
        role: "user",
        avatarUrl: "assets/images/default_user.jpg",
        joinDate: userDoc['joinDate']?.toString() ?? DateTime.now().toString(),
        phone: userDoc['phone']?.toString() ?? "76022800",
      );
    } catch (e) {
      print("Error fetching user: $e");
      throw Exception("Failed to fetch user: $e");
    }
  }

  void _navigateToEditScreen() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: currentUser),
      ),
    );

    if (updatedUser != null && mounted) {
      setState(() {
        currentUser = updatedUser;
      });
      widget.onProfileUpdated?.call(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            'My Profile',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            'My Profile',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'Failed to load profile',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Please check your connection and try again',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'My Profile',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, currentUser);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditScreen,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: (currentUser.avatarUrl != null && currentUser.avatarUrl!.isNotEmpty)
                        ? NetworkImage(currentUser.avatarUrl!)
                        : const AssetImage("assets/images/default_avatar.png")
                    as ImageProvider,
                    child: (currentUser.avatarUrl == null || currentUser.avatarUrl!.isEmpty)
                        ? Text(
                      currentUser.username.isNotEmpty
                          ? currentUser.username.substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser.username,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentUser.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Profile Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileItem(
                    icon: Icons.person,
                    title: 'Username',
                    value: currentUser.username,
                  ),
                  _buildProfileItem(
                    icon: Icons.email,
                    title: 'Email',
                    value: currentUser.email,
                  ),
                  _buildProfileItem(
                    icon: Icons.phone,
                    title: 'Phone',
                    value: currentUser.phone.isNotEmpty
                        ? currentUser.phone
                        : 'Not provided',
                  ),
                  _buildProfileItem(
                    icon: Icons.verified_user,
                    title: 'Role',
                    value: currentUser.role,
                  ),
                  _buildProfileItem(
                    icon: Icons.calendar_today,
                    title: 'Member Since',
                    value: currentUser.joinDate.split(' ')[0],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedAvatarPath = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Implement image picking logic
    // final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   setState(() {
    //     _selectedAvatarPath = pickedFile.path;
    //   });
    // }
  }

  void _saveChanges() {
    final updatedUser = widget.user.copyWith(
      name: _usernameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      avatarUrl: _selectedAvatarPath,
    );

    Navigator.pop(context, updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Edit Profile',
          style: textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Save',
              style: textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: (_selectedAvatarPath != null && _selectedAvatarPath!.isNotEmpty)
                          ? NetworkImage(_selectedAvatarPath!)
                          : const AssetImage("assets/images/default_avatar.png")
                      as ImageProvider,
                      child: (_selectedAvatarPath == null || _selectedAvatarPath!.isEmpty)
                          ? Text(
                        _usernameController.text.isNotEmpty
                            ? _usernameController.text
                            .substring(0, 1)
                            .toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildEditField(
              controller: _usernameController,
              icon: Icons.person,
              label: 'Username',
              hintText: 'Enter your username',
            ),
            const SizedBox(height: 20),
            _buildEditField(
              controller: _emailController,
              icon: Icons.email,
              label: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildEditField(
              controller: _phoneController,
              icon: Icons.phone,
              label: 'Phone Number',
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      keyboardType: keyboardType,
    );
  }
}