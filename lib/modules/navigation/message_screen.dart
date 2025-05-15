import 'package:darlink/models/chat.dart';
import 'package:darlink/modules/chat_screen.dart';
import 'package:darlink/shared/widgets/card/contact_card.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Chat> chats = [
    Chat(
      name: "Ahmad Ahmad",
      icon: "assets/images/robert.png",
      isGroup: "false",
      time: "2:30 PM",
      currentMessage: "Hello, how are you?",
    ),
    Chat(
      name: "Sami Issa",
      icon: "assets/images/kristin.png",
      isGroup: "false",
      time: "1:45 PM",
      currentMessage: "Are you coming to the party?",
    ),
    Chat(
      name: "Rani Alhaj",
      icon: "assets/images/cody.png",
      isGroup: "false",
      time: "12:00 PM",
      currentMessage: "Let's catch up later.",
    ),
  ];

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
      body: Column(
        children: [
          _buildSearchRow(context),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) =>
                  ContactCard(chatMessage: chats[index]),
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
