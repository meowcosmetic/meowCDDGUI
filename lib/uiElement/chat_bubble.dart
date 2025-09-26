import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isFromMe;
  final DateTime? timestamp;
  final String? senderName;
  final VoidCallback? onTap;
  final bool showTimestamp;
  final bool showSenderName;
  final Color? bubbleColor;
  final Color? textColor;
  final double maxWidth;
  final EdgeInsets padding;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isFromMe,
    this.timestamp,
    this.senderName,
    this.onTap,
    this.showTimestamp = true,
    this.showSenderName = false,
    this.bubbleColor,
    this.textColor,
    this.maxWidth = 280,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Màu sắc mặc định
    final defaultBubbleColor = isFromMe
        ? (isDark ? AppColors.primary : AppColors.primary)
        : (isDark ? Colors.grey[800]! : Colors.grey[200]!);

    final defaultTextColor = isFromMe
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        child: Column(
          crossAxisAlignment: isFromMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Tên người gửi (nếu có)
            if (showSenderName && senderName != null && !isFromMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 12),
                child: Text(
                  senderName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Bong bóng tin nhắn
            Row(
              mainAxisAlignment: isFromMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar cho tin nhắn từ người khác
                if (!isFromMe)
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),

                // Bong bóng tin nhắn
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor ?? defaultBubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isFromMe ? 20 : 4),
                        bottomRight: Radius.circular(isFromMe ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nội dung tin nhắn
                        Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor ?? defaultTextColor,
                            height: 1.4,
                          ),
                        ),

                        // Thời gian (nếu có)
                        if (showTimestamp && timestamp != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(timestamp!),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: (textColor ?? defaultTextColor)
                                        .withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                                if (isFromMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.done_all,
                                    size: 14,
                                    color: (textColor ?? defaultTextColor)
                                        .withOpacity(0.7),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Avatar cho tin nhắn của tôi
                if (isFromMe)
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Widget cho danh sách chat
class ChatList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController? scrollController;
  final EdgeInsets padding;
  final bool reverse;

  const ChatList({
    Key? key,
    required this.messages,
    this.scrollController,
    this.padding = const EdgeInsets.all(16),
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: reverse,
      padding: padding,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          message: message.text,
          isFromMe: message.isFromMe,
          timestamp: message.timestamp,
          senderName: message.senderName,
          showSenderName: message.showSenderName,
        );
      },
    );
  }
}

// Model cho tin nhắn chat
class ChatMessage {
  final String text;
  final bool isFromMe;
  final DateTime timestamp;
  final String? senderName;
  final bool showSenderName;

  const ChatMessage({
    required this.text,
    required this.isFromMe,
    required this.timestamp,
    this.senderName,
    this.showSenderName = false,
  });
}

// Widget cho input chat
class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final String? hintText;
  final bool enabled;
  final TextEditingController? controller;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    this.hintText,
    this.enabled = true,
    this.controller,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Nút đính kèm
          IconButton(
            onPressed: widget.enabled ? () {} : null,
            icon: Icon(Icons.attach_file, color: Colors.grey[600]),
          ),

          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Nhập tin nhắn...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Nút gửi
          Container(
            decoration: BoxDecoration(
              color: _hasText && widget.enabled
                  ? AppColors.primary
                  : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _hasText && widget.enabled ? _sendMessage : null,
              icon: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
