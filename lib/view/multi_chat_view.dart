import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../uiElement/chat_bubble.dart';
import '../constants/app_colors.dart';
import '../services/messaging_service.dart';
import '../models/conversation.dart';

class MultiChatView extends StatefulWidget {
  const MultiChatView({Key? key}) : super(key: key);

  @override
  State<MultiChatView> createState() => _MultiChatViewState();
}

class _MultiChatViewState extends State<MultiChatView> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  StreamSubscription<Conversation>? _conversationSub;
  StreamSubscription<String>? _messageSub;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    _setupMessaging();
  }

  void _setupMessaging() {
    // Auto-connect
    MessagingService.instance.autoConnectIfLoggedIn();
    // Enrich profiles on first open
    MessagingService.instance.enrichProfiles();
    
    // Listen to conversations
    _conversationSub = MessagingService.instance.conversations.listen((conversation) {
      if (mounted) {
        setState(() {
          _conversations = MessagingService.instance.conversationList;
          if (_currentConversation == null && _conversations.isNotEmpty) {
            _currentConversation = _conversations.first;
            MessagingService.instance.switchConversation(_currentConversation!.id);
          }
        });
        // Re-enrich when conversation list changes (new peers)
        MessagingService.instance.enrichProfiles();
      }
    });
    
    // Listen to messages
    _messageSub = MessagingService.instance.messages.listen((msg) {
      if (!mounted) return;
      String content = msg;
      try {
        final decoded = jsonDecode(msg);
        if (decoded is Map && decoded['content'] is String) {
          content = decoded['content'] as String;
        }
      } catch (_) {}
      setState(() {
        _messages.add(ChatMessage(
          text: content,
          isFromMe: false,
          timestamp: DateTime.now(),
          senderName: _currentConversation?.peerName ?? "Đối tác",
          showSenderName: true,
        ));
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
      _messages.add(ChatMessage(
        text: text,
        isFromMe: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
    // Send through STOMP
    MessagingService.instance.sendText(text);
  }

  void _switchConversation(Conversation conversation) {
    setState(() {
      _currentConversation = conversation;
      _messages.clear();
      _loadInitialMessages();
    });
    MessagingService.instance.switchConversation(conversation.id);
  }

  void _createNewConversation() {
    showDialog(
      context: context,
      builder: (context) => _NewConversationDialog(),
    );
  }

  void _scrollToBottom() {
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
        title: Text(_currentConversation?.peerName ?? 'Chat'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewConversation,
            tooltip: 'Tạo cuộc trò chuyện mới',
          ),
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
      body: Row(
        children: [
          // Conversation list
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
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
                      const Icon(Icons.chat, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Cuộc trò chuyện',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      final isSelected = _currentConversation?.id == conversation.id;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                          border: Border(
                            left: BorderSide(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            backgroundImage: (conversation.avatarUrl != null && conversation.avatarUrl!.isNotEmpty)
                                ? NetworkImage(conversation.avatarUrl!)
                                : null,
                            child: (conversation.avatarUrl == null || conversation.avatarUrl!.isEmpty)
                                ? Text(
                                    conversation.peerName.isNotEmpty 
                                        ? conversation.peerName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                          ),
                          title: Text(
                            conversation.peerName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: conversation.lastMessage != null
                              ? Text(
                                  conversation.lastMessage!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: conversation.hasUnreadMessages
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () => _switchConversation(conversation),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Chat area
          Expanded(
            child: Column(
              children: [
                // Header with current conversation info
                if (_currentConversation != null)
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
                          backgroundImage: (_currentConversation!.avatarUrl != null && _currentConversation!.avatarUrl!.isNotEmpty)
                              ? NetworkImage(_currentConversation!.avatarUrl!)
                              : null,
                          child: (_currentConversation!.avatarUrl == null || _currentConversation!.avatarUrl!.isEmpty)
                              ? Text(
                                  _currentConversation!.peerName.isNotEmpty 
                                      ? _currentConversation!.peerName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentConversation!.peerName,
                                style: const TextStyle(
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
                      ],
                    ),
                  ),
                
                // Messages
                Expanded(
                  child: ChatList(
                    messages: _messages,
                    scrollController: _scrollController,
                    reverse: false,
                  ),
                ),
                
                // Input
                ChatInput(
                  onSendMessage: _sendMessage,
                  controller: _textController,
                  hintText: 'Nhập tin nhắn của bạn...',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _conversationSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }
}

class _NewConversationDialog extends StatefulWidget {
  @override
  State<_NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<_NewConversationDialog> {
  final _userIdController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo cuộc trò chuyện mới'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'User ID',
              hintText: 'Nhập ID người dùng',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên người dùng',
              hintText: 'Nhập tên hiển thị',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_userIdController.text.isNotEmpty) {
              MessagingService.instance.createNewConversation(
                _userIdController.text,
                peerName: _nameController.text.isNotEmpty 
                    ? _nameController.text 
                    : null,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Tạo'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
