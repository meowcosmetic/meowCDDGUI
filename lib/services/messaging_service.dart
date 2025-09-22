import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';
import '../services/host_service.dart';
import '../models/user_session.dart';
import '../models/conversation.dart';
import '../models/api_service.dart';

/// Messaging service using STOMP over SockJS
class MessagingService {
  static final MessagingService instance = MessagingService._internal();
  MessagingService._internal();

  static const String _defaultReceiverId = '6898206d72a4fe2d1d105e0e';
  StompClient? _client;
  String? _currentUserId;
  String? _currentPeerUserId; // receiverId will be auto-updated from incoming messages
  String _currentConversationId = 'default';

  final StreamController<String> _messageStreamController = StreamController.broadcast();
  final StreamController<bool> _typingStreamController = StreamController.broadcast();
  final StreamController<Conversation> _conversationStreamController = StreamController.broadcast();
  final Map<String, Conversation> _conversations = {};
  final Map<String, Map<String, String>> _profileCache = {}; // customerId -> {name, avatar}

  Stream<String> get messages => _messageStreamController.stream;
  Stream<bool> get typing => _typingStreamController.stream;
  Stream<Conversation> get conversations => _conversationStreamController.stream;
  List<Conversation> get conversationList => _conversations.values.toList();

  bool get isConnected => _client?.connected == true;

  Future<void> autoConnectIfLoggedIn() async {
    await UserSession.initFromPrefs();
    if (UserSession.userId != null && UserSession.userId!.isNotEmpty) {
      await connect(UserSession.userId!);
    }
  }

  Future<void> connect(String userId) async {
    if (isConnected && _currentUserId == userId) {
      return;
    }
    _currentUserId = userId;

    // Build WebSocket URL (ws/wss)
    final protocol = HostService.getProtocol();
    final host = HostService.getHost();
    final wsScheme = protocol == 'https' ? 'wss' : 'ws';
    final url = '$wsScheme://$host/api/messages/ws/websocket';

    _client?.deactivate();

    final token = UserSession.jwtToken;

    _client = StompClient(
      config: StompConfig(
        url: url,
        onConnect: _onConnect,
        stompConnectHeaders: token != null && token.isNotEmpty
            ? <String, String>{'Authorization': 'Bearer $token'}
            : const <String, String>{},
        webSocketConnectHeaders: token != null && token.isNotEmpty
            ? <String, dynamic>{'Authorization': 'Bearer $token'}
            : const <String, dynamic>{},
        onWebSocketError: (dynamic error) {
          if (kDebugMode) {
            print('STOMP error: $error');
          }
        },
        onStompError: (StompFrame f) {
          if (kDebugMode) {
            print('STOMP frame error: ${f.body}');
          }
        },
        onDisconnect: (StompFrame frame) {
          if (kDebugMode) {
            print('STOMP disconnected');
          }
        },
        onWebSocketDone: () {
          if (kDebugMode) {
            print('WebSocket closed');
          }
        },
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 0),
      ),
    );

    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    final uid = _currentUserId;
    if (uid == null) return;

    // Subscribe personal queues
    _client!.subscribe(
      destination: '/user/$uid/queue/messages',
      callback: (StompFrame frame) {
        final body = frame.body ?? '';
        // Try to capture senderId to set current peer for replies
         try {
           final decoded = jsonDecode(body);
           if (decoded is Map && decoded['senderId'] is String) {
             final sender = decoded['senderId'] as String;
             if (sender.isNotEmpty && sender != _currentUserId) {
               _currentPeerUserId = sender;
               
               // Update or create conversation
               final conversationId = decoded['conversationId'] ?? 'default';
               final conversation = _conversations[conversationId] ?? Conversation(
                 id: conversationId,
                 peerUserId: sender,
                 peerName: _profileCache[sender]?['name'] ?? 'Người dùng $sender',
               );
               
               final updatedConversation = conversation.copyWith(
                 lastMessage: decoded['content'] ?? '',
                 lastMessageTime: DateTime.now(),
                 hasUnreadMessages: conversationId != _currentConversationId,
               );
               
               _conversations[conversationId] = updatedConversation;
               _conversationStreamController.add(updatedConversation);
               
               // Only forward messages that are not sent by current user
               _messageStreamController.add(body);
               return;
             }
           }
           // If message is from current user, ignore to avoid echo
           return;
         } catch (_) {
           // If parsing fails, forward as-is
           _messageStreamController.add(body);
         }
      },
    );

    _client!.subscribe(
      destination: '/user/$uid/queue/typing',
      callback: (_) => _typingStreamController.add(true),
    );

    _client!.subscribe(
      destination: '/user/$uid/queue/typing-stop',
      callback: (_) => _typingStreamController.add(false),
    );

    _client!.subscribe(
      destination: '/user/$uid/queue/messages/read',
      callback: (StompFrame frame) {
        if (kDebugMode) {
          print('Message read: ${frame.body}');
        }
      },
    );

    // Join chat
    _client!.send(
      destination: '/app/chat.addUser',
      body: jsonEncode({
        'type': 'JOIN',
        'senderId': uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  void sendText(String content, {String? conversationId, String? toUserId}) {
    final uid = _currentUserId;
    if (!isConnected || uid == null) return;
    final receiverId = toUserId ?? _currentPeerUserId ?? _defaultReceiverId;
    if (receiverId.isEmpty) return;

    final convId = conversationId ?? _currentConversationId;
    final body = <String, Object?>{
      'type': 'MESSAGE',
      'senderId': uid,
      'receiverId': receiverId,
      'content': content,
      'conversationId': convId,
      'messageType': 'TEXT',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _client!.send(
      destination: '/app/chat.sendMessage',
      body: jsonEncode(body),
    );

    // Update conversation with sent message
    final conversation = _conversations[convId] ?? Conversation(
      id: convId,
      peerUserId: receiverId,
      peerName: 'Người dùng $receiverId',
    );
    
    final updatedConversation = conversation.copyWith(
      lastMessage: content,
      lastMessageTime: DateTime.now(),
      hasUnreadMessages: false,
    );
    
    _conversations[convId] = updatedConversation;
    _conversationStreamController.add(updatedConversation);
  }

  void startTyping({String? conversationId}) {
    final uid = _currentUserId;
    if (!isConnected || uid == null) return;
    final receiverId = _currentPeerUserId ?? _defaultReceiverId;
    if (receiverId.isEmpty) return;
    final body = <String, Object?>{
      'type': 'TYPING',
      'senderId': uid,
      'receiverId': receiverId,
      'conversationId': conversationId ?? _currentConversationId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _client!.send(destination: '/app/chat.typing', body: jsonEncode(body));
  }

  void stopTyping({String? conversationId}) {
    final uid = _currentUserId;
    if (!isConnected || uid == null) return;
    final receiverId = _currentPeerUserId ?? _defaultReceiverId;
    if (receiverId.isEmpty) return;
    final body = <String, Object?>{
      'type': 'TYPING',
      'senderId': uid,
      'receiverId': receiverId,
      'conversationId': conversationId ?? _currentConversationId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _client!.send(destination: '/app/chat.stopTyping', body: jsonEncode(body));
  }

  void switchConversation(String conversationId) {
    _currentConversationId = conversationId;
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      _currentPeerUserId = conversation.peerUserId;
      // Mark as read
      final updatedConversation = conversation.copyWith(hasUnreadMessages: false);
      _conversations[conversationId] = updatedConversation;
      _conversationStreamController.add(updatedConversation);
    }
  }

  void createNewConversation(String peerUserId, {String? peerName}) {
    final conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final conversation = Conversation(
      id: conversationId,
      peerUserId: peerUserId,
      peerName: peerName ?? _profileCache[peerUserId]?['name'] ?? 'Người dùng $peerUserId',
    );
    _conversations[conversationId] = conversation;
    _conversationStreamController.add(conversation);
    switchConversation(conversationId);
  }

  // Enrich conversations with profile info via bulk API
  Future<void> enrichProfiles() async {
    try {
      final userIds = _conversations.values.map((c) => c.peerUserId).toSet().toList();
      if (userIds.isEmpty) return;
      final api = ApiService();
      final resp = await api.fetchCustomerProfilesBulk(userIds);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          for (final item in data) {
            if (item is Map && item['userId'] is String) {
              final id = item['customerId'] as String;
              final name = (item['name'] ?? '') as String;
              final avatar = (item['avatar'] ?? '') as String;
              _profileCache[id] = {'name': name, 'avatar': avatar};
              // Update existing conversations
              for (final entry in _conversations.entries) {
                final c = entry.value;
                if (c.peerUserId == id) {
                  final updated = c.copyWith(
                    peerName: name.isNotEmpty ? name : c.peerName,
                    avatarUrl: avatar.isNotEmpty ? avatar : c.avatarUrl,
                  );
                  _conversations[entry.key] = updated;
                  _conversationStreamController.add(updated);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to enrich profiles: $e');
      }
    }
  }

  Future<void> disconnect() async {
    try {
      _client?.deactivate();
    } catch (_) {}
    _client = null;
    _currentUserId = null;
  }
}



