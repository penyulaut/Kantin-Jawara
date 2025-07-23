class Menu {
  final int id;
  final String name;
  final String description;
  final int price;
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
      price: json['price'],
      imageUrl: json['image'],
    );
  }
}
