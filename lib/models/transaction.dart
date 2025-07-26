import 'user.dart';
import 'payment.dart';
import 'chat.dart';
import 'menu.dart';

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
  final String? paymentProof; // Add payment proof field

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
    this.paymentProof, // Add to constructor
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      // Parse payment first to potentially get payment proof
      Payment? payment = json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null;

      // Get payment proof from multiple possible sources
      String? paymentProof;
      if (json.containsKey('payment_proof') && json['payment_proof'] != null) {
        paymentProof = json['payment_proof'];
      } else if (payment?.proof != null) {
        paymentProof = payment!.proof;
      }

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
        cashier: json['cashier'] != null
            ? User.fromJson(json['cashier'])
            : null,
        penjual: json['penjual'] != null
            ? User.fromJson(json['penjual'])
            : null,
        items: json['items'] != null
            ? (json['items'] as List)
                  .map((item) => TransactionItem.fromJson(item))
                  .toList()
            : null,
        payment: payment,
        chats: json['chats'] != null
            ? (json['chats'] as List)
                  .map((chat) => Chat.fromJson(chat))
                  .toList()
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        paymentProof: paymentProof,
      );
    } catch (e) {
      print('Transaction.fromJson error: $e');
      print('Transaction JSON keys: ${json.keys.toList()}');
      if (json['items'] != null) {
        print('Items data: ${json['items']}');
      }
      rethrow;
    }
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
      'payment_proof': paymentProof, // Add to toJson
    };
  }
}

class TransactionItem {
  final int id;
  final int transactionId;
  final int menuId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Menu? menu;

  TransactionItem({
    required this.id,
    required this.transactionId,
    required this.menuId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.menu,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different field names from API
      double unitPrice = 0.0;
      double totalPrice = 0.0;

      // Try to get unit price from different possible field names
      if (json.containsKey('unit_price')) {
        unitPrice = double.tryParse(json['unit_price'].toString()) ?? 0.0;
      } else if (json.containsKey('price')) {
        unitPrice = double.tryParse(json['price'].toString()) ?? 0.0;
      }

      // Try to get total price from different possible field names
      if (json.containsKey('total_price')) {
        totalPrice = double.tryParse(json['total_price'].toString()) ?? 0.0;
      } else {
        // If no total_price, calculate it from unit_price * quantity
        int quantity = int.tryParse(json['quantity'].toString()) ?? 0;
        totalPrice = unitPrice * quantity;
      }

      return TransactionItem(
        id: int.tryParse(json['id'].toString()) ?? 0,
        transactionId: int.tryParse(json['transaction_id'].toString()) ?? 0,
        menuId: int.tryParse(json['menu_id'].toString()) ?? 0,
        quantity: int.tryParse(json['quantity'].toString()) ?? 0,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        menu: json['menu'] != null ? Menu.fromJson(json['menu']) : null,
      );
    } catch (e) {
      print('TransactionItem.fromJson error: $e');
      print('TransactionItem JSON: $json');
      print('Available keys: ${json.keys.toList()}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'menu_id': menuId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'menu': menu?.toJson(),
    };
  }
}
