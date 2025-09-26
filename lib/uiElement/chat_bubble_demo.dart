import 'package:flutter/material.dart';
import 'chat_bubble.dart';
import '../constants/app_colors.dart';

class ChatBubbleDemo extends StatefulWidget {
  const ChatBubbleDemo({Key? key}) : super(key: key);

  @override
  State<ChatBubbleDemo> createState() => _ChatBubbleDemoState();
}

class _ChatBubbleDemoState extends State<ChatBubbleDemo> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDemoMessages();
  }

  void _loadDemoMessages() {
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
        text:
            "Tuyệt vời! Chúng tôi có nhiều bài test phù hợp với các độ tuổi khác nhau. Bạn có thể cho tôi biết con bạn bao nhiêu tuổi không?",
        isFromMe: false,
        timestamp: now.subtract(const Duration(minutes: 3)),
        senderName: "Chuyên gia tư vấn",
        showSenderName: true,
      ),
      ChatMessage(
        text:
            "Con tôi 8 tuổi. Tôi lo lắng về việc con có thể bị stress ở trường học.",
        isFromMe: true,
        timestamp: now.subtract(const Duration(minutes: 2)),
      ),
      ChatMessage(
        text:
            "Tôi hiểu nỗi lo của bạn. Với trẻ 8 tuổi, chúng tôi có bài test CDD (Child Depression Detection) rất phù hợp. Bài test này được thiết kế đặc biệt để phát hiện các dấu hiệu stress và trầm cảm ở trẻ em.",
        isFromMe: false,
        timestamp: now.subtract(const Duration(minutes: 1)),
        senderName: "Chuyên gia tư vấn",
        showSenderName: true,
      ),
    ]);
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isFromMe: true, timestamp: DateTime.now()),
      );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Bubble Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _loadDemoMessages();
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
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
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

// Demo cho các loại chat bubble khác nhau
class ChatBubbleVariantsDemo extends StatelessWidget {
  const ChatBubbleVariantsDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Bubble Variants'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Tin nhắn cơ bản
          _buildSection(context, 'Tin nhắn cơ bản', [
            ChatBubble(
              message: "Đây là tin nhắn từ tôi",
              isFromMe: true,
              timestamp: now,
            ),
            ChatBubble(
              message: "Đây là tin nhắn từ người khác",
              isFromMe: false,
              timestamp: now,
            ),
          ]),

          const SizedBox(height: 24),

          // Section 2: Tin nhắn với tên người gửi
          _buildSection(context, 'Tin nhắn với tên người gửi', [
            ChatBubble(
              message: "Tin nhắn từ chuyên gia",
              isFromMe: false,
              timestamp: now,
              senderName: "Chuyên gia tư vấn",
              showSenderName: true,
            ),
          ]),

          const SizedBox(height: 24),

          // Section 3: Tin nhắn dài
          _buildSection(context, 'Tin nhắn dài', [
            ChatBubble(
              message:
                  "Đây là một tin nhắn rất dài để kiểm tra xem component có xử lý tốt các tin nhắn dài hay không. Tin nhắn này sẽ được wrap tự động và hiển thị đẹp mắt trong bong bóng chat.",
              isFromMe: true,
              timestamp: now,
            ),
          ]),

          const SizedBox(height: 24),

          // Section 4: Tin nhắn với màu tùy chỉnh
          _buildSection(context, 'Tin nhắn với màu tùy chỉnh', [
            ChatBubble(
              message: "Tin nhắn với màu xanh lá",
              isFromMe: true,
              timestamp: now,
              bubbleColor: Colors.green,
            ),
            ChatBubble(
              message: "Tin nhắn với màu cam",
              isFromMe: false,
              timestamp: now,
              bubbleColor: Colors.orange,
              textColor: Colors.white,
            ),
          ]),

          const SizedBox(height: 24),

          // Section 5: Tin nhắn không có timestamp
          _buildSection(context, 'Tin nhắn không có timestamp', [
            ChatBubble(
              message: "Tin nhắn không hiển thị thời gian",
              isFromMe: true,
              showTimestamp: false,
            ),
          ]),

          const SizedBox(height: 24),

          // Section 6: Tin nhắn với onTap
          _buildSection(context, 'Tin nhắn có thể tap (thử tap vào tin nhắn)', [
            ChatBubble(
              message: "Tap vào tin nhắn này để xem hiệu ứng",
              isFromMe: true,
              timestamp: now,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bạn đã tap vào tin nhắn!')),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
