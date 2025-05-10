import 'package:darlink/modules/setting/chat_screen.dart';
import 'package:darlink/shared/widgets/card/contact_card.dart';
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
        onPressed: () {},
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
                  ContactCard(),
                  ContactCard(),
                  ContactCard(),
                  ContactCard(),
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
              child: TextFormField(
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
          )),
        ],
      ),
    );
  }
}
