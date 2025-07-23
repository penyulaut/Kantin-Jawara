import 'user.dart';

enum MessageType { text, image, document, system }

class Chat {
  final int? id;
  final int? transactionId;
  final int? senderId;
  final String? message;
  final String? attachmentUrl;
  final String? attachmentType;
  final MessageType messageType;
  final DateTime? readAt;
  final bool isRead;
  final User? sender;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Chat({
    this.id,
    this.transactionId,
    this.senderId,
    this.message,
    this.attachmentUrl,
    this.attachmentType,
    this.messageType = MessageType.text,
    this.readAt,
    this.isRead = false,
    this.sender,
    this.createdAt,
    this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      transactionId: json['transaction_id'],
      senderId: json['sender_id'],
      message: json['message'],
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
      messageType: _parseMessageType(json['message_type']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      isRead: json['is_read'] ?? false,
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'document':
        return MessageType.document;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  String get messageTypeString {
    switch (messageType) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.document:
        return 'document';
      case MessageType.system:
        return 'system';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'sender_id': senderId,
      'message': message,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'message_type': messageTypeString,
      'read_at': readAt?.toIso8601String(),
      'is_read': isRead,
      'sender': sender?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isFromBuyer => sender?.role == 'pembeli';
  bool get isFromSeller => sender?.role == 'penjual';

  String get formattedTime => createdAt?.toString().substring(11, 16) ?? '';
  String get formattedDate => createdAt?.toString().substring(0, 10) ?? '';

  Chat copyWith({
    int? id,
    int? transactionId,
    int? senderId,
    String? message,
    String? attachmentUrl,
    String? attachmentType,
    MessageType? messageType,
    DateTime? readAt,
    bool? isRead,
    User? sender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      messageType: messageType ?? this.messageType,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
