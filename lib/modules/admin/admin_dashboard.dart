import 'package:darlink/modules/admin/events_management_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 0;

  final List<_AdminOption> options = [
    _AdminOption(icon: Icons.people_alt, label: 'Manage Users'),
    _AdminOption(icon: Icons.location_on_outlined, label: 'Manage Events'),
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
        // Added SafeArea to prevent overflow at the top
        child: SingleChildScrollView(
          // Wrapped entire content in SingleChildScrollView
          child: Column(
            children: [
              // Gradient AppBar with logo
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
                        'assets/images/imagenew.png',
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                // Added padding to prevent overflow on sides
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
                          'assets/images/black.png',
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
                      'Select your management area',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Carousel with arrows
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
                          _OptionCard(option: option),
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
}

class _AdminOption {
  final IconData icon;
  final String label;

  _AdminOption({required this.icon, required this.label});
}

class _OptionCard extends StatefulWidget {
  final _AdminOption option;
  const _OptionCard({required this.option});

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

    // Configure all animations
    _elevationAnim = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _iconPositionAnim = Tween<double>(begin: 0, end: -25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _iconSizeAnim = Tween<double>(begin: 70, end: 64).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _textOpacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start with tiny value to pre-warm animations
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
          switch (widget.option.label) {
            case 'Manage Users':
              Navigator.pushNamed(context, '/manageUsers');
              break;
            case 'Manage Events':
              Navigator.push(
                  (context),
                  MaterialPageRoute(
                      builder: (context) => EventManagementScreen()));
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
