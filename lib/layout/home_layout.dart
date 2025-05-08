import 'package:darlink/modules/navigation/event_screen.dart';
import 'package:darlink/modules/navigation/home_screen.dart';
import 'package:darlink/modules/navigation/message_screen.dart';
import 'package:darlink/modules/navigation/profile_screen.dart';
import 'package:darlink/modules/navigation/setting_screen.dart';
import 'package:darlink/shared/cubit/app_cubit.dart';
import 'package:darlink/shared/cubit/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    EventScreen(),
    const ProfileScreen(),
    const MessageScreen(),
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBottomNavigationBarItem({
    required IconData icon,
    required int index,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isSelected ? 50 : 40,
            width: isSelected ? 50 : 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: isSelected ? 30 : 25,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelected ? 1.0 : 0.0,
            child: Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AppCubit, AppCubitState>(
        listener: (context, state) => (),
        builder: (context, state) {
          final cubit = AppCubit.get(context);

          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _pages[_selectedIndex],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavigationBarItem(
                      icon: Icons.home, index: 0, context: context),
                  _buildBottomNavigationBarItem(
                      icon: Icons.search, index: 1, context: context),
                  _buildBottomNavigationBarItem(
                      icon: Icons.person, index: 2, context: context),
                  _buildBottomNavigationBarItem(
                      icon: Icons.message, index: 3, context: context),
                  _buildBottomNavigationBarItem(
                      icon: Icons.settings, index: 4, context: context),
                ],
              ),
            ),
          );
        });
  }
}
