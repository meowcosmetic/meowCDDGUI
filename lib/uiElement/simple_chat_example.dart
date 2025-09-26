import 'package:flutter/material.dart';
import 'chat_bubble.dart';
import '../constants/app_colors.dart';

class SimpleChatExample extends StatefulWidget {
  const SimpleChatExample({Key? key}) : super(key: key);

  @override
  State<SimpleChatExample> createState() => _SimpleChatExampleState();
}

class _SimpleChatExampleState extends State<SimpleChatExample> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Thêm một số tin nhắn mẫu
    _messages.addAll([
      ChatMessage(
        text: "Xin chào! Tôi có thể giúp gì cho bạn?",
        isFromMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        senderName: "Chuyên gia tư vấn",
        showSenderName: true,
      ),
      ChatMessage(
        text: "Chào bạn! Tôi muốn tìm hiểu về các bài test tâm lý.",
        isFromMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ]);
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isFromMe: true, timestamp: DateTime.now()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Example'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isFromMe: message.isFromMe,
                  timestamp: message.timestamp,
                  senderName: message.senderName,
                  showSenderName: message.showSenderName,
                );
              },
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
    _textController.dispose();
    super.dispose();
  }
}
