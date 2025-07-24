class Category {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({this.id, required this.name, this.createdAt, this.updatedAt});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
