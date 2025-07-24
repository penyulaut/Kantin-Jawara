import 'user.dart';
import 'payment_method.dart';

class MerchantPaymentMethod {
  final int? id;
  final int? userId;
  final int? paymentMethodId;
  final bool isActive;
  final Map<String, dynamic> details;
  final User? user;
  final PaymentMethod? paymentMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MerchantPaymentMethod({
    this.id,
    this.userId,
    this.paymentMethodId,
    this.isActive = true,
    this.details = const {},
    this.user,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  factory MerchantPaymentMethod.fromJson(Map<String, dynamic> json) {
    return MerchantPaymentMethod(
      id: int.tryParse(json['id'].toString()),
      userId: int.tryParse(json['user_id'].toString()),
      paymentMethodId: int.tryParse(json['payment_method_id'].toString()),
      isActive: json['is_active'] ?? true,
      details: json['details'] ?? {},
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      paymentMethod: json['payment_method'] != null
          ? PaymentMethod.fromJson(json['payment_method'])
          : null,
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
      'user_id': userId,
      'payment_method_id': paymentMethodId,
      'is_active': isActive,
      'details': details,
      'user': user?.toJson(),
      'payment_method': paymentMethod?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MerchantPaymentMethod copyWith({
    int? id,
    int? userId,
    int? paymentMethodId,
    bool? isActive,
    Map<String, dynamic>? details,
    User? user,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantPaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      isActive: isActive ?? this.isActive,
      details: details ?? this.details,
      user: user ?? this.user,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
