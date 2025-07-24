import 'user.dart';
import 'transaction_item.dart';
import 'payment.dart';
import 'chat.dart';

enum TransactionStatus { pending, paid, confirmed, ready, completed, cancelled }

enum OrderType { dineIn, takeaway, delivery }

class Transaction {
  final int? id;
  final int? userId;
  final int? cashierId;
  final double totalPrice;
  final String? paymentMethod;
  final TransactionStatus status;
  final String? notes;
  final String? customerName;
  final String? customerPhone;
  final OrderType orderType;
  final User? user;
  final User? cashier;
  final User? penjual;
  final List<TransactionItem>? items;
  final Payment? payment;
  final List<Chat>? chats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.id,
    this.userId,
    this.cashierId,
    required this.totalPrice,
    this.paymentMethod,
    this.status = TransactionStatus.pending,
    this.notes,
    this.customerName,
    this.customerPhone,
    this.orderType = OrderType.takeaway,
    this.user,
    this.cashier,
    this.penjual,
    this.items,
    this.payment,
    this.chats,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: int.tryParse(json['id'].toString()),
      userId: int.tryParse(json['user_id'].toString()),
      cashierId: int.tryParse(json['cashier_id'].toString()),
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'],
      status: _parseStatus(json['status']),
      notes: json['notes'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      orderType: _parseOrderType(json['order_type']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      cashier: json['cashier'] != null ? User.fromJson(json['cashier']) : null,
      penjual: json['penjual'] != null ? User.fromJson(json['penjual']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => TransactionItem.fromJson(item))
                .toList()
          : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
      chats: json['chats'] != null
          ? (json['chats'] as List).map((chat) => Chat.fromJson(chat)).toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  static TransactionStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'paid':
        return TransactionStatus.paid;
      case 'confirmed':
        return TransactionStatus.confirmed;
      case 'ready':
        return TransactionStatus.ready;
      case 'completed':
        return TransactionStatus.completed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  static OrderType _parseOrderType(String? orderType) {
    switch (orderType) {
      case 'dine_in':
        return OrderType.dineIn;
      case 'takeaway':
        return OrderType.takeaway;
      case 'delivery':
        return OrderType.delivery;
      default:
        return OrderType.takeaway;
    }
  }

  String get statusString {
    switch (status) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.paid:
        return 'paid';
      case TransactionStatus.confirmed:
        return 'confirmed';
      case TransactionStatus.ready:
        return 'ready';
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.cancelled:
        return 'cancelled';
    }
  }

  String get orderTypeString {
    switch (orderType) {
      case OrderType.dineIn:
        return 'dine_in';
      case OrderType.takeaway:
        return 'takeaway';
      case OrderType.delivery:
        return 'delivery';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cashier_id': cashierId,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'status': statusString,
      'notes': notes,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'order_type': orderTypeString,
      'user': user?.toJson(),
      'cashier': cashier?.toJson(),
      'penjual': penjual?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
      'payment': payment?.toJson(),
      'chats': chats?.map((chat) => chat.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
