import 'package:flutter/material.dart';
import 'package:darlink/constants/colors/app_color.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool generalNotifications = true;
  bool newPropertyAlerts = true;
  bool messagesFromSellers = true;
  bool priceDropAlerts = false;
  bool muteAll = false;

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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Notifications',
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "Manage your notification preferences",
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            buildNotificationTile(
              theme: theme,
              icon: Icons.notifications_active_outlined,
              title: "General Notifications",
              subtitle: "Get updates and important news.",
              value: generalNotifications,
              onChanged: (val) => setState(() => generalNotifications = val),
            ),
            buildNotificationTile(
              theme: theme,
              icon: Icons.house_outlined,
              title: "New Property Alerts",
              subtitle: "Be the first to know about new listings.",
              value: newPropertyAlerts,
              onChanged: (val) => setState(() => newPropertyAlerts = val),
            ),
            buildNotificationTile(
              theme: theme,
              icon: Icons.message_outlined,
              title: "Messages from Sellers",
              subtitle: "Receive replies or updates from sellers.",
              value: messagesFromSellers,
              onChanged: (val) => setState(() => messagesFromSellers = val),
            ),
            buildNotificationTile(
              theme: theme,
              icon: Icons.price_change_outlined,
              title: "Price Drop Alerts",
              subtitle: "Get notified about price reductions.",
              value: priceDropAlerts,
              onChanged: (val) => setState(() => priceDropAlerts = val),
            ),
            buildNotificationTile(
              theme: theme,
              icon: Icons.notifications_off_outlined,
              title: "Mute All Notifications",
              subtitle: "Silence all notifications temporarily.",
              value: muteAll,
              activeColor: Colors.red,
              onChanged: (val) => setState(() => muteAll = val),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
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
                    'Changes saved',
                    style: TextStyle(color: AppColors.textOnPrimary),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: Icon(Icons.save, color: AppColors.textOnPrimary),
            label: Text(
              'Save Changes',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildNotificationTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    Color? activeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
