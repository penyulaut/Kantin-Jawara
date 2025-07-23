import 'menu.dart';

class TransactionItem {
  final int? id;
  final int? transactionId;
  final int? menuId;
  final int quantity;
  final double price;
  final Menu? menu;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionItem({
    this.id,
    this.transactionId,
    this.menuId,
    required this.quantity,
    required this.price,
    this.menu,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      transactionId: json['transaction_id'],
      menuId: json['menu_id'],
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      menu: json['menu'] != null ? Menu.fromJson(json['menu']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'menu_id': menuId,
      'quantity': quantity,
      'price': price,
      'menu': menu?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TransactionItem copyWith({
    int? id,
    int? transactionId,
    int? menuId,
    int? quantity,
    double? price,
    Menu? menu,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      menuId: menuId ?? this.menuId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      menu: menu ?? this.menu,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
