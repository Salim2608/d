import 'package:flutter/material.dart';
import 'package:darlink/constants/colors/app_color.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: theme.appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Contact Us',
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTextField(
                  icon: Icons.person,
                  hintText: 'Full Name',
                  iconColor: AppColors.primary,
                  theme: theme,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  icon: Icons.email,
                  hintText: 'Email Address',
                  iconColor: AppColors.primary,
                  theme: theme,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  icon: Icons.phone,
                  hintText: 'Phone No',
                  iconColor: AppColors.primary,
                  theme: theme,
                ),
                const SizedBox(height: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    maxLines: 4,
                    // Use your theme's text colors
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: theme.textTheme.bodyMedium,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Use your theme's primary color
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Message sent!',
                          style: TextStyle(color: AppColors.textOnPrimary),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Text(
                    'Send',
                    // Use your theme's text on primary color
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required IconData icon,
    required String hintText,
    required Color iconColor,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        // Use your theme's card color
        color: theme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        // Use your theme's text colors
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          icon: Icon(icon, color: iconColor),
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
