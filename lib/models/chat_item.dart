class ChatItem {
  final int transactionId;
  final String transactionStatus;
  final OtherUser otherUser;
  final LatestMessage? latestMessage;
  final int unreadCount;

  ChatItem({
    required this.transactionId,
    required this.transactionStatus,
    required this.otherUser,
    this.latestMessage,
    required this.unreadCount,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      transactionId: json['transaction_id'] ?? 0,
      transactionStatus: json['transaction_status'] ?? 'pending',
      otherUser: OtherUser.fromJson(json['other_user'] ?? {}),
      latestMessage: json['latest_message'] != null
          ? LatestMessage.fromJson(json['latest_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'transaction_status': transactionStatus,
      'other_user': otherUser.toJson(),
      'latest_message': latestMessage?.toJson(),
      'unread_count': unreadCount,
    };
  }
}

class OtherUser {
  final int? id;
  final String name;
  final String role;

  OtherUser({this.id, required this.name, required this.role});

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'role': role};
  }
}

class LatestMessage {
  final String message;
  final String messageType;
  final String senderName;
  final bool isFromMe;
  final String createdAt;
  final String formattedTime;

  LatestMessage({
    required this.message,
    required this.messageType,
    required this.senderName,
    required this.isFromMe,
    required this.createdAt,
    required this.formattedTime,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? 'text',
      senderName: json['sender_name'] ?? 'Unknown',
      isFromMe: json['is_from_me'] ?? false,
      createdAt: json['created_at'] ?? '',
      formattedTime: json['formatted_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'message_type': messageType,
      'sender_name': senderName,
      'is_from_me': isFromMe,
      'created_at': createdAt,
      'formatted_time': formattedTime,
    };
  }
}
