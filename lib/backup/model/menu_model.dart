class Menu {
  final int id;
  final String name;
  final String description;
  final double price; // Changed from int to double for consistency
  final String imageUrl;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price:
          double.tryParse(json['price'].toString()) ??
          0.0, // Handle both int and double
      imageUrl: json['image'],
    );
  }
}
