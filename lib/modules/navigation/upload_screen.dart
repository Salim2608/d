import 'package:darlink/modules/upload/announce_event_screen.dart';
import 'package:darlink/modules/upload/property_upload.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with TickerProviderStateMixin {
  String? _selectedOption;
  bool _isUploading = false;

  // Animation controllers for scaling effect on long press
  late AnimationController _eventScaleController;
  late AnimationController _propertyScaleController;
  late Animation<double> _eventScaleAnimation;
  late Animation<double> _propertyScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _eventScaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _propertyScaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create scale animations
    _eventScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _eventScaleController, curve: Curves.easeOutBack),
    );

    _propertyScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _propertyScaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _eventScaleController.dispose();
    _propertyScaleController.dispose();
    super.dispose();
  }

  void _navigateToPropertyUploadScreen(BuildContext context) {
    // Navigate to HomeLayout
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PropertyUploadScreen()),
    );
  }

  void _navigateToPropertyEventScreen(BuildContext context) {
    // Navigate to HomeLayout
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AnnounceEventScreen()),
    );
  }

  void _startUpload(String option) {
    if (_isUploading) return;

    setState(() {
      _selectedOption = option;
      _isUploading = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (option == "Property") {
        setState(() {
          _isUploading = false;
          _selectedOption = null;
        });
        _navigateToPropertyUploadScreen(context);
      } else {
        // Handle other upload types here
        setState(() {
          _isUploading = false;
          _selectedOption = null;
        });
        _navigateToPropertyEventScreen(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Upload',
          style: textTheme.titleLarge?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isUploading
          ? _buildUploadingView(colors, textTheme)
          : _buildSelectionView(colors, textTheme),
    );
  }

  Widget _buildUploadingView(ColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 8,
                backgroundColor: colors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Uploading $_selectedOption...',
            style: textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionView(ColorScheme colors, TextTheme textTheme) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Event half
              Expanded(
                child: _buildHalfScreenOption(
                  icon: Icons.event,
                  label: 'Event',
                  color: colors.secondary,
                  textTheme: textTheme,
                  onTap: () => _startUpload('Event'),
                  scaleAnimation: _eventScaleAnimation,
                  onLongPressStart: () => _eventScaleController.forward(),
                  onLongPressEnd: () => _eventScaleController.reverse(),
                ),
              ),

              // Property half
              Expanded(
                child: _buildHalfScreenOption(
                  icon: Icons.home,
                  label: 'Property',
                  color: colors.primary,
                  textTheme: textTheme,
                  onTap: () => _startUpload('Property'),
                  scaleAnimation: _propertyScaleAnimation,
                  onLongPressStart: () => _propertyScaleController.forward(),
                  onLongPressEnd: () => _propertyScaleController.reverse(),
                ),
              ),
            ],
          ),
        ),

        // Bottom help text
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Upload your events or properties to make them visible to others',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHalfScreenOption({
    required IconData icon,
    required String label,
    required Color color,
    required TextTheme textTheme,
    required VoidCallback onTap,
    required Animation<double> scaleAnimation,
    required VoidCallback onLongPressStart,
    required VoidCallback onLongPressEnd,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: Container(
        color: color.withOpacity(0.1),
        child: AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: scaleAnimation.value,
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                label,
                style: textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to upload',
                style: textTheme.bodyLarge?.copyWith(
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
