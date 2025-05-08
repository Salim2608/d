import 'package:darlink/constants/colors/theme_template_manger.dart';
import 'package:darlink/layout/home_layout.dart';
import 'package:darlink/shared/cubit/app_cubit.dart';
import 'package:darlink/shared/cubit/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeScreen extends StatelessWidget {
  // Updated color options with lowercase keys to match ThemeTemplateManager
  final List<Map<String, dynamic>> colorOptions = [
    {
      'name': 'Green',
      'key': 'green',
      'color': Colors.green,
      'icon': Icons.grass
    },
    {
      'name': 'Blue',
      'key': 'blue',
      'color': Colors.blue,
      'icon': Icons.water,
    },
    {
      'name': 'Red',
      'key': 'red',
      'color': Colors.red,
      'icon': Icons.favorite,
    },
    {
      'name': 'Purple',
      'key': 'purple',
      'color': Colors.purple,
      'icon': Icons.storm
    },
    {
      'name': 'Orange',
      'key': 'orange',
      'color': Colors.orange,
      'icon': Icons.wb_sunny_sharp
    },
    {
      'name': 'Grey',
      'key': 'grey',
      'color': Colors.grey,
      'icon': Icons.dark_mode_sharp
    },
  ];

  ThemeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Building ThemeScreen");
    // Print available themes for debugging
    ThemeTemplateManager.printAvailableThemes();

    return BlocConsumer<AppCubit, AppCubitState>(
      listener: (context, state) {
        if (state is AppThemeChangedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Theme changed to ${state.themeName}'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        print("Current color in ThemeScreen: ${cubit.currentColor}");

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Theme Selection'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose App Theme',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Select your preferred color theme',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: colorOptions.map((option) {
                              return _buildColorOption(
                                  option['name'],
                                  option['key'],
                                  option['color'],
                                  option['icon'],
                                  cubit,
                                  context);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorOption(String name, String key, Color color, IconData icon,
      AppCubit cubit, BuildContext context) {
    // Check if this option is the current theme
    final isSelected = cubit.currentColor == key;

    return GestureDetector(
      onTap: () async {
        print("Tapped on $name theme with key: $key");

        // Change the theme using the cubit
        await cubit.changeTheme(key);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeLayout()));
        // Don't navigate away - let user see the changes and decide
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.5),
                width: isSelected ? 3 : 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentThemeInfo(AppCubit cubit, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Theme.of(context).cardTheme.color,
      child: ListTile(
        leading: Icon(Icons.color_lens, color: Theme.of(context).primaryColor),
        title: const Text('Current Theme'),
        subtitle: Text(cubit.currentColor.capitalize()),
        trailing: Icon(
          Icons.check_circle,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
