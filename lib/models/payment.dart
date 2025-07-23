import 'payment_method.dart';

class Payment {
  final int? id;
  final int? transactionId;
  final double amount;
  final String method;
  final DateTime? paidAt;
  final String? proof;
  final PaymentMethod? paymentMethod;

  Payment({
    this.id,
    this.transactionId,
    required this.amount,
    required this.method,
    this.paidAt,
    this.proof,
    this.paymentMethod,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      transactionId: json['transaction_id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      method: json['method'] ?? '',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      proof: json['proof'],
      paymentMethod: json['payment_method'] != null
          ? PaymentMethod.fromJson(json['payment_method'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'amount': amount,
      'method': method,
      'paid_at': paidAt?.toIso8601String(),
      'proof': proof,
      'payment_method': paymentMethod?.toJson(),
    };
  }

  Payment copyWith({
    int? id,
    int? transactionId,
    double? amount,
    String? method,
    DateTime? paidAt,
    String? proof,
    PaymentMethod? paymentMethod,
  }) {
    return Payment(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      paidAt: paidAt ?? this.paidAt,
      proof: proof ?? this.proof,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
