import 'package:darlink/modules/setting/chat_screen.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary, // Green app bar
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new message action
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchRow(context),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                  _ContactCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildSearchField(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDarkMode) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Search ...",
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDarkMode ? Colors.white : Colors.grey[600],
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      hoverDuration: Durations.long1,
      onTap: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? theme.cardTheme.color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              maxRadius: 30,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Robert Fox",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Okay, take care dear",
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  "12:30 AM",
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "3",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
