import 'package:darlink/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // Sample data for users
  List<User> users = [
    User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      role: 'Admin',
      avatarUrl: 'assets/images/black.png',
      joinDate: '2025-01-15',
    ),
    User(
      id: '2',
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      role: 'Seller',
      avatarUrl: 'assets/images/black.png',
      joinDate: '2025-02-20',
    ),
    User(
      id: '3',
      name: 'Robert Johnson',
      email: 'robert.johnson@example.com',
      role: 'User',
      avatarUrl: 'assets/images/black.png',
      joinDate: '2025-03-10',
    ),
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                        icon: Icon(Icons.search,
                            color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAA14F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'User',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Info',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: users.isEmpty
                ? Center(
                    child: Text(
                      'No users available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserCard(
                        user: user,
                        onEdit: () => _showUserForm(user),
                        onDelete: () => _deleteUser(user.id),
                        onProfilePictureTap: () =>
                            _showProfilePictureOptions(user),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFAA14F0),
        onPressed: () => _showUserForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, User user) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          // In a real app, you would upload this image to a server
          // and get back a URL to store in the user's avatarUrl field

          // For now, we'll just update the user with a placeholder
          final index = users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            // In a real app, you would use the actual URL from the server
            // For demo purposes, we'll keep using the asset images
            users[index] = user.copyWith(
              avatarUrl:
                  'assets/images/imagenew.png', // Using an existing asset as placeholder
            );
          }
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showProfilePictureOptions(User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfilePictureOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, user);
                  },
                ),
                _buildProfilePictureOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, user);
                  },
                ),
                _buildProfilePictureOption(
                  icon: Icons.delete,
                  label: 'Remove',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      final index = users.indexWhere((u) => u.id == user.id);
                      if (index != -1) {
                        users[index] = user.copyWith(
                          avatarUrl: 'assets/images/black.png', // Default image
                        );
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFAA14F0).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showUserForm(User? user) {
    final isEditing = user != null;
    final nameController =
        TextEditingController(text: isEditing ? user.name : '');
    final emailController =
        TextEditingController(text: isEditing ? user.email : '');
    final roleController =
        TextEditingController(text: isEditing ? user.role : '');
    final avatarUrlController = TextEditingController(
        text: isEditing ? user.avatarUrl : 'assets/images/black.png');
    final joinDateController = TextEditingController(
        text: isEditing
            ? user.joinDate
            : DateTime.now().toString().substring(0, 10));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          isEditing ? 'Edit User' : 'Add New User',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isEditing)
                GestureDetector(
                  onTap: () => _showProfilePictureOptions(user),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: AssetImage(user.avatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: roleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: avatarUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Avatar URL (use black.png or imagenew.png)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: joinDateController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Join Date (YYYY-MM-DD)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAA14F0),
            ),
            onPressed: () {
              // Validate inputs
              if (nameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  roleController.text.isEmpty ||
                  avatarUrlController.text.isEmpty ||
                  joinDateController.text.isEmpty) {
                // Show error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final newUser = User(
                id: isEditing
                    ? user.id
                    : DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                email: emailController.text,
                role: roleController.text,
                avatarUrl: avatarUrlController.text,
                joinDate: joinDateController.text,
              );

              setState(() {
                if (isEditing) {
                  // Update existing user
                  final index = users.indexWhere((u) => u.id == user.id);
                  if (index != -1) {
                    users[index] = newUser;
                  }
                } else {
                  // Add new user
                  users.add(newUser);
                }
              });

              Navigator.pop(context);
            },
            child: Text(
              isEditing ? 'Update' : 'Add',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this user?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              setState(() {
                users.removeWhere((user) => user.id == id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onProfilePictureTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onProfilePictureTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User column with avatar and name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onProfilePictureTap,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: AssetImage(user.avatarUrl),
                      onBackgroundImageError: (exception, stackTrace) {},
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.role,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Info column with email and join date
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email,
                          size: 16, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Text(
                        'Joined: ${user.joinDate}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions column with update and delete buttons
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.edit, color: Colors.blue, size: 20),
                    ),
                    onPressed: onEdit,
                    tooltip: 'Update',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
