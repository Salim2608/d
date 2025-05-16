import 'package:darlink/models/contact.dart';
import 'package:darlink/models/message.dart';
import 'package:darlink/shared/widgets/card/message/own_message_card.dart';
import 'package:darlink/shared/widgets/card/message/reply_message_card.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  List<Message> messages = [];
  late IO.Socket socket;

  Contact contact = Contact(
    name: 'Khaled Assidi',
    avatarUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8_FaE8B_dkkXBhdKqVoAR_n5jbxGerW-lRQ&s',
    isOnline: true,
    typingStatus: null,
  );

  // Sample messages for testing UI
  List<Map<String, String>> chatMessages = [
    {"sender": "me", "text": "Hi"},
    {"sender": "other", "text": "Hi"},
    {"sender": "other", "text": "Kifk"},
    {"sender": "me", "text": "Kello tmm"},
    {"sender": "other", "text": "El 7amdela"},
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {});
      }
    });

    // Monitor text changes to show/hide send button
    _messageController.addListener(() {
      setState(() {
        sendButton = _messageController.text.isNotEmpty;
      });
    });

    connect();
  }

  void connect() {
    try {
      final String serverUrl =
          "http://10.0.2.2:5000"; // For Android emulator connecting to localhost

      print("Attempting to connect to: $serverUrl");

      socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(5000)
            .setTimeout(10000) // Increase timeout to 10 seconds
            .build(),
      );

      socket.connect();

      socket.onConnect((_) {
        print('Connected to socket server at $serverUrl');
        socket.emit("test", "Hello from Flutter");
      });

      socket.onConnectError((error) {
        print('Connection error: $error');
      });

      socket.onDisconnect((_) {
        print('Disconnected from socket server');
      });

      // Listen for incoming messages
      socket.on("message_received", (data) {
        print('Received message: $data');
        if (data != null && data is Map) {
          setState(() {
            chatMessages.add({
              "sender": "other",
              "text": data["text"] ?? "",
            });
          });
          _scrollToBottom();
        }
      });

      socket.onError((error) {
        print('Socket error: $error');
      });
    } catch (e) {
      print('Error initializing socket: $e');
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final messageText = _messageController.text.trim();

      // Add message to local list
      setState(() {
        chatMessages.add({
          "sender": "me",
          "text": messageText,
        });
      });

      // Emit message to socket server
      socket.emit("send_message", {
        "text": messageText,
        "sender": "user",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });

      // Clear the input field
      _messageController.clear();

      // Scroll to bottom to show the new message
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    focusNode.dispose();
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/message_background.jpg',
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _chatAppBar(theme, context),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: chatMessages.length,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    itemBuilder: (context, index) {
                      final message = chatMessages[index];
                      if (message["sender"] == "me") {
                        return OwnMessageCard(
                          message: message["text"] ?? "",
                        );
                      } else {
                        return ReplyMessageCard(
                          message: message["text"] ?? "",
                        );
                      }
                    },
                  ),
                ),
                _buildMessageInput(context, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _chatAppBar(ThemeData theme, BuildContext context) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(contact.avatarUrl),
            radius: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                contact.isOnline ? "Online" : "Last seen: 2 hours ago",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.white),
          onPressed: () {
            _makePhoneCall('+96181932662');
          },
        ),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: _messageController,
                  focusNode: focusNode,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Type a message",
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 25,
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: sendButton ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }
}
