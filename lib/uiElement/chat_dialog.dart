import 'package:flutter/material.dart';
import 'chat_bubble.dart';
import '../constants/app_colors.dart';

class ChatDialog extends StatefulWidget {
  const ChatDialog({Key? key}) : super(key: key);

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    final now = DateTime.now();
    _messages.addAll([
      ChatMessage(
        text: "Xin chào! Tôi có thể giúp gì cho bạn?",
        isFromMe: false,
        timestamp: now.subtract(const Duration(minutes: 2)),
        senderName: "Chuyên gia tư vấn",
        showSenderName: true,
      ),
    ]);
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isFromMe: true,
        timestamp: DateTime.now(),
      ));
    });
    
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

    // Simulate reply after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Cảm ơn bạn đã chia sẻ! Tôi sẽ gửi thêm thông tin về bài test CDD cho bạn.",
            isFromMe: false,
            timestamp: DateTime.now(),
            senderName: "Chuyên gia tư vấn",
            showSenderName: true,
          ));
        });
        
        // Auto scroll to bottom again
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Tính toán kích thước dialog dựa trên màn hình
    final dialogHeight = screenHeight * 0.7;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.95;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.psychology,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chat với Chuyên gia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Đang hoạt động',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Chat messages
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: ChatList(
                  messages: _messages,
                  scrollController: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
            
            // Input area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: ChatInput(
                onSendMessage: _sendMessage,
                controller: _textController,
                hintText: 'Nhập tin nhắn của bạn...',
              ),
            ),
          ],
        ),
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

// Extension để dễ dàng mở chat dialog
extension ChatDialogExtension on BuildContext {
  void showChatDialog() {
    showDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => const ChatDialog(),
    );
  }
}
