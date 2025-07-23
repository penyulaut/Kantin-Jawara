import 'package:flutter/material.dart';
import 'detail_produk_page.dart';

class KantinMenuPage extends StatefulWidget {
  const KantinMenuPage({super.key});

  @override
  State<KantinMenuPage> createState() => _KantinMenuPageState();
}

class _KantinMenuPageState extends State<KantinMenuPage> {
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> allMenus = [
    {
      'title': 'Nasi Goreng',
      'price': 'Rp. 10k',
      'category': 'Makanan Berat',
      'imageUrl': 'https://asset.kompas.com/crops/VcgvggZKE2VHqIAUp1pyHFXXYCs=/202x66:1000x599/1200x800/data/photo/2023/05/07/6456a450d2edd.jpg',
      'rating': 4.9,
      'description': 'A classic Indonesian fried rice with egg and crackers.',
    },
    {
      'title': 'Ayam Katsu',
      'price': 'Rp. 12k',
      'category': 'Makanan Berat',
      'imageUrl': 'https://img-global.cpcdn.com/recipes/b81e791bdf557b4a/1200x630cq70/photo.jpg',
      'rating': 4.8,
      'description': 'Japanese style crispy chicken served with rice and salad.',
    },
    {
      'title': 'Es Teh Manis',
      'price': 'Rp. 5k',
      'category': 'Minuman',
      'imageUrl': 'https://www.sasa.co.id/medias/page_medias/teh-manis.jpg',
      'rating': 4.7,
      'description': 'Sweet iced tea served cold, perfect for a sunny day.',
    },
    {
      'title': 'Jus Alpukat',
      'price': 'Rp. 8k',
      'category': 'Minuman',
      'imageUrl': 'https://img-global.cpcdn.com/recipes/3e07f14eebad7e35/1200x630cq70/photo.jpg',
      'rating': 4.9,
      'description': 'Fresh avocado smoothie with chocolate syrup.',
    },
  ];

  List<String> categories = ['All', 'Makanan Berat', 'Minuman'];

  List<Map<String, dynamic>> get filteredMenus {
    if (selectedCategory == 'All') return allMenus;
    return allMenus.where((menu) => menu['category'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,      
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF01509D),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, color: Color.fromARGB(255, 255, 255, 255)),
            Icon(Icons.menu_book, color: Color.fromARGB(255, 255, 255, 255)),
            SizedBox(width: 40), // for floating button
            Icon(Icons.notifications, color: Color.fromARGB(255, 255, 255, 255)),
            Icon(Icons.person, color: Color.fromARGB(255, 255, 255, 255)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Warung Bunda',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text('Silahkan Pesan yang Banyak!'),
                    ],
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 16),

              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories
                      .map((cat) => _buildCategoryChip(cat, cat == selectedCategory))
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Menu Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: filteredMenus.map((menu) {
                    return _buildMenuItem(
                      context,
                      menu['title'],
                      menu['price'],
                      menu['imageUrl'],
                      menu['rating'],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailProdukPage(
                              namaProduk: menu['title'],
                              harga: menu['price'],
                              rating: menu['rating'],
                              imageUrl: menu['imageUrl'],
                              deskripsi: menu['description'],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: Colors.yellow,
        backgroundColor: Colors.grey.shade200,
        onSelected: (_) {
          setState(() {
            selectedCategory = label;
          });
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String price,
    String imageUrl,
    double rating,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(price),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      Text(rating.toString()),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
