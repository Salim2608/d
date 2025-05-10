import 'package:darlink/models/contact.dart';
import 'package:darlink/models/message.dart';
import 'package:darlink/shared/widgets/chat_widget/attachment_option.dart';
import 'package:darlink/shared/widgets/chat_widget/message_bubble.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  bool _showAttachmentOptions = false;
  Contact contact = Contact(
    name: 'Ervin Crouse',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    isOnline: true,
    typingStatus: null,
  );

  List<Message> messages = [];

  late AnimationController _attachmentAnimationController;
  late Animation<double> _attachmentAnimation;

  @override
  void initState() {
    super.initState();
    _attachmentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _attachmentAnimation = CurvedAnimation(
      parent: _attachmentAnimationController,
      curve: Curves.easeInOut,
    );

    // Simulate initial messages
    _simulateInitialChat();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _recordingTimer?.cancel();
    _attachmentAnimationController.dispose();
    super.dispose();
  }

  void _simulateInitialChat() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          messages.add(
            Message(
              content: 'Hi there! How are you doing today?',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
              status: MessageStatus.delivered,
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _onTextChanged() => setState(() {});
  void _onFocusChange() {
    if (_focusNode.hasFocus && _showAttachmentOptions) {
      _hideAttachmentOptions();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordingDuration += const Duration(seconds: 1));
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      messages.add(
        Message(
          content: '',
          isMe: true,
          timestamp: DateTime.now(),
          isVoiceMessage: true,
          voiceDuration: _recordingDuration,
          status: MessageStatus.sending,
        ),
      );
    });

    _scrollToBottom();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    final newMessage = Message(
      content: _controller.text,
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    setState(() {
      messages.add(newMessage);
      _controller.clear();
    });
    _scrollToBottom();
  }

  String _generateReply(String message) {
    message = message.toLowerCase();
    if (message.contains('hello') || message.contains('hi')) {
      return 'Hi there! How are you doing today?';
    } else if (message.contains('how are you')) {
      return 'I\'m doing great, thanks for asking! How about you?';
    } else if (message.contains('thanks') || message.contains('thank you')) {
      return 'You\'re welcome! Anything else I can help with?';
    }
    return 'That\'s interesting! Tell me more about it.';
  }

  void _toggleAttachmentOptions() {
    if (_showAttachmentOptions) {
      _hideAttachmentOptions();
    } else {
      _showAttachmentPanel();
    }
  }

  void _showAttachmentPanel() {
    setState(() => _showAttachmentOptions = true);
    _attachmentAnimationController.forward();
    FocusScope.of(context).unfocus();
  }

  void _hideAttachmentOptions() {
    setState(() => _showAttachmentOptions = false);
    _attachmentAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _hideAttachmentOptions,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          leadingWidth: 80,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
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
                  if (contact.typingStatus != null)
                    Text(
                      contact.typingStatus!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            _buildDateIndicator(isDarkMode),
            Expanded(
              child: GestureDetector(
                onTap: _hideAttachmentOptions,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final showTime = index == messages.length - 1 ||
                        messages[index + 1].isMe != messages[index].isMe;
                    return MessageBubble(
                      message: messages[index],
                      showTime: showTime,
                    );
                  },
                ),
              ),
            ),
            _buildInputArea(theme, isDarkMode),
            if (_showAttachmentOptions)
              AttachmentOptions(animation: _attachmentAnimation),
          ],
        ),
      ),
    );
  }

  Widget _buildDateIndicator(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Today',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isDarkMode) {
    return _isRecording
        ? _buildRecordingUI()
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        if (!isDarkMode)
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: 'Type something...',
                              hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black),
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                          onPressed: _toggleAttachmentOptions,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _controller.text.isEmpty ? Icons.mic : Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_controller.text.isEmpty) {
                        _startRecording();
                      } else {
                        _sendMessage();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildRecordingUI() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF2C2C44),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recording...',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  '${_recordingDuration.inMinutes.toString().padLeft(2, '0')}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: () {
              _recordingTimer?.cancel();
              setState(() => _isRecording = false);
            },
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _stopRecording,
          ),
        ],
      ),
    );
  }
}
