import 'package:flutter/material.dart';
import 'kantin_menu_page.dart';

class KantinListPage extends StatelessWidget {
  final String seat;

  const KantinListPage({super.key, required this.seat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kantin Jawara'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.yellow,
              child: Text(
                seat,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFFFFF9C4),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KantinMenuPage(), // ganti dengan passing data kalau perlu
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg'),
                  ),
                  title: const Text('Warung Bunda'),
                  subtitle: Row(
                    children: const [
                      Icon(Icons.star, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text('4.9'),
                    ],
                  ),
                  trailing: const Icon(Icons.favorite_border),
                ),
                );
              },
            ),
          ),
        ],
      ),
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
    );
  }
}
