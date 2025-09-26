class Conversation {
  final String id;
  final String peerUserId;
  final String peerName;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool hasUnreadMessages;

  Conversation({
    required this.id,
    required this.peerUserId,
    required this.peerName,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnreadMessages = false,
  });

  Conversation copyWith({
    String? id,
    String? peerUserId,
    String? peerName,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? hasUnreadMessages,
  }) {
    return Conversation(
      id: id ?? this.id,
      peerUserId: peerUserId ?? this.peerUserId,
      peerName: peerName ?? this.peerName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      peerUserId: json['peerUserId'] ?? '',
      peerName: json['peerName'] ?? 'Người dùng',
      avatarUrl: json['avatarUrl'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'])
          : null,
      hasUnreadMessages: json['hasUnreadMessages'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peerUserId': peerUserId,
      'peerName': peerName,
      'avatarUrl': avatarUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'hasUnreadMessages': hasUnreadMessages,
    };
  }
}
