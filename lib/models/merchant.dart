class Merchant {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? address;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Merchant({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.address,
    this.phone,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? json['username'] ?? 'Unknown Merchant',
      description: json['description'] ?? json['bio'],
      imageUrl: json['image_url'] ?? json['avatar'],
      address: json['address'],
      phone: json['phone'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'address': address,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Merchant copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    String? address,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
