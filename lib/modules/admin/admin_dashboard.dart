import 'package:darlink/client_view_page.dart';
import 'package:darlink/editable_client_profile_page.dart';

import 'package:darlink/modules/admin/events_management_screen.dart';
import 'package:flutter/material.dart';

// ... (rest of the imports and existing code)

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 0;

  final List<_AdminOption> options = [
    _AdminOption(icon: Icons.people_alt, label: 'Manage Users'),
    _AdminOption(icon: Icons.event, label: 'Manage Events'), // Updated icon
    _AdminOption(icon: Icons.house_sharp, label: 'Manage Properties'),
  ];

  void _next() {
    setState(() {
      currentIndex = (currentIndex + 1) % options.length;
    });
  }

  void _previous() {
    setState(() {
      currentIndex = (currentIndex - 1 + options.length) % options.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final option = options[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Gradient AppBar with logo (Keep as is)
              Container(
                height: 140,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6A11CB),
                      Color(0xFF2575FC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/imagenew.png', // Assuming this is the correct logo path
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 50,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white24,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/black.png', // Assuming admin avatar path
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person,
                                size: 70, color: Colors.white);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Welcome admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your management area or view profiles',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    // Carousel with arrows (Keep as is)
                    SizedBox(
                      height: 220,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 42,
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_left),
                            onPressed: _previous,
                          ),
                          const SizedBox(width: 8),
                          _OptionCard(
                              option:
                                  option), // Assumes _OptionCard is defined below
                          const SizedBox(width: 8),
                          IconButton(
                            iconSize: 42,
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_right),
                            onPressed: _next,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- Updated Profile Navigation Buttons Section ---
                    const Text(
                      'View Profiles',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Use a Column for two rows of buttons
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildProfileButton(
                              context,
                              icon: Icons.person_outline, // Client icon
                              label: 'Client Profile\n(View)',
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ClientViewPage()));
                              },
                            ),
                            _buildProfileButton(
                              context,
                              icon: Icons.edit_note, // Client edit icon
                              label: 'Client Profile\n(Edit)',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditableClientProfilePage()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 15), // Space between rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildProfileButton(
                              context,
                              icon: Icons
                                  .event_seat_outlined, // Event manager icon
                              label: 'Event Mgr\nProfile (View)',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EventManagerProfilePage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    // --- End Updated Buttons Section ---

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the profile buttons (Keep as is or adjust styling)
  Widget _buildProfileButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12), // Adjusted padding
        textStyle: const TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            height: 1.2), // Adjusted font size and line height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.4,
            60), // Adjusted width and height slightly
      ),
    );
  }
}

// _AdminOption class (Keep as is)
class _AdminOption {
  final IconData icon;
  final String label;

  _AdminOption({required this.icon, required this.label});
}

// _OptionCard class and its State (Keep as is)
class _OptionCard extends StatefulWidget {
  final _AdminOption option;
  const _OptionCard({Key? key, required this.option}) : super(key: key);

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnim;
  late Animation<double> _iconPositionAnim;
  late Animation<double> _iconSizeAnim;
  late Animation<double> _textOpacityAnim;
  late Animation<double> _gradientAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _elevationAnim = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _iconPositionAnim = Tween<double>(begin: 0, end: -25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _iconSizeAnim = Tween<double>(begin: 70, end: 64).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _textOpacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeIn)),
    );
    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.value = 0.001;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: () {
          // Use named routes defined in main.dart
          switch (widget.option.label) {
            case 'Manage Users':
              Navigator.pushNamed(context, '/manageUsers');
              break;
            case 'Manage Events':
              Navigator.pushNamed(context, '/manageEvents');
              break;
            case 'Manage Properties':
              Navigator.pushNamed(context, '/manageProperties');
              break;
          }
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_elevationAnim.value * 0.5),
              child: Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFF1E293B),
                          const Color(0xFF6A11CB), _gradientAnim.value)!,
                      Color.lerp(const Color(0xFF1E293B),
                          const Color(0xFF2575FC), _gradientAnim.value)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_controller.value * 0.2),
                      blurRadius: 6 + _controller.value * 14,
                      spreadRadius: _controller.value,
                      offset: Offset(0, 3 + _controller.value * 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, _iconPositionAnim.value),
                      child: Icon(
                        widget.option.icon,
                        color: Colors.white,
                        size: _iconSizeAnim.value,
                      ),
                    ),
                    Opacity(
                      opacity: _textOpacityAnim.value,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          widget.option.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
