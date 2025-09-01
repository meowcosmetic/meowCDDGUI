import 'package:flutter/material.dart';
import '../uiElement/chat_bubble.dart';
import '../constants/app_colors.dart';

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
  }

  void _loadInitialMessages() {
    final now = DateTime.now();
    _messages.addAll([
      ChatMessage(
        text: "Xin chào! Tôi có thể giúp gì cho bạn?",
        isFromMe: false,
        timestamp: now.subtract(const Duration(minutes: 5)),
        senderName: "Chuyên gia tư vấn",
        showSenderName: true,
      ),
      ChatMessage(
        text: "Chào bạn! Tôi muốn tìm hiểu về các bài test tâm lý cho trẻ em.",
        isFromMe: true,
        timestamp: now.subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        text: "Tuyệt vời! Chúng tôi có nhiều bài test phù hợp với các độ tuổi khác nhau. Bạn có thể cho tôi biết con bạn bao nhiêu tuổi không?",
        isFromMe: false,
        timestamp: now.subtract(const Duration(minutes: 3)),
        senderName: "Chuyên gia tư vấn",
        showSenderName: true,
      ),
      ChatMessage(
        text: "Con tôi 8 tuổi. Tôi lo lắng về việc con có thể bị stress ở trường học.",
        isFromMe: true,
        timestamp: now.subtract(const Duration(minutes: 2)),
      ),
      ChatMessage(
        text: "Tôi hiểu nỗi lo của bạn. Với trẻ 8 tuổi, chúng tôi có bài test CDD (Child Depression Detection) rất phù hợp. Bài test này được thiết kế đặc biệt để phát hiện các dấu hiệu stress và trầm cảm ở trẻ em.",
        isFromMe: false,
        timestamp: now.subtract(const Duration(minutes: 1)),
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

    // Simulate reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
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
                _loadInitialMessages();
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
                      const SnackBar(
                        content: Text('Menu tùy chọn'),
                      ),
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
