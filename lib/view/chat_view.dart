import 'package:flutter/material.dart';
import 'dart:convert';
import '../uiElement/chat_bubble.dart';
import '../constants/app_colors.dart';
import '../services/messaging_service.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    // Try to auto-connect and subscribe to message stream
    MessagingService.instance.autoConnectIfLoggedIn();
    MessagingService.instance.messages.listen((msg) {
      if (!mounted) return;
      String content = msg;
      try {
        final decoded = jsonDecode(msg);
        if (decoded is Map && decoded['content'] is String) {
          content = decoded['content'] as String;
        }
      } catch (_) {}
      setState(() {
        _messages.add(
          ChatMessage(
            text: content,
            isFromMe: false,
            timestamp: DateTime.now(),
            senderName: "Đối tác",
            showSenderName: true,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _loadInitialMessages() {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          text: 'Xin chào! Tôi có thể giúp gì cho bạn?',
          isFromMe: false,
          timestamp: DateTime.now(),
          senderName: 'Chuyên gia tư vấn',
          showSenderName: true,
        ),
      );
    }
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isFromMe: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
    // Send through STOMP
    MessagingService.instance.sendText(text);
  }

  void _scrollToBottom() {
    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat với Chuyên gia'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header với thông tin chat
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.psychology, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chuyên gia tư vấn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Đang hoạt động',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menu tùy chọn')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Danh sách tin nhắn
          Expanded(
            child: ChatList(
              messages: _messages,
              scrollController: _scrollController,
              reverse: false,
            ),
          ),

          // Input để nhập tin nhắn
          ChatInput(
            onSendMessage: _sendMessage,
            controller: _textController,
            hintText: 'Nhập tin nhắn của bạn...',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
