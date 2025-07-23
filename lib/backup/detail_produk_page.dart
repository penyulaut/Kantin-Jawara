import 'package:flutter/material.dart';
import 'list_pesanan_page.dart';

class DetailProdukPage extends StatelessWidget {
  final String namaProduk;
  final String harga;
  final double rating;
  final String imageUrl;
  final String deskripsi;

  const DetailProdukPage({
    super.key,
    required this.namaProduk,
    required this.harga,
    required this.rating,
    required this.imageUrl,
    required this.deskripsi,
  });

  @override
  Widget build(BuildContext context) {
    int porsi = 2;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network('https://assets.tmecosys.com/image/upload/t_web_rdp_recipe_584x480/img/recipe/ras/Assets/ae6d7be8ee924ba32b6175d12b7cfdac/Derivates/0f2747c199915780ff5efcc9fc98ffbc129d8ca4.jpg', height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(namaProduk, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    Text(rating.toString()),
                    const SizedBox(width: 8),
                    const Text("26 mins", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(deskripsi),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Tambah Catatan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Portion", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.remove)),
                    Text('$porsi'),
                    IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                  ],
                )
              ],
            ),
            const Spacer (),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(8)),
                  child: Text('Rp. $harga', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListPesananPage()));
                    },
                    child: const Text("TAMBAHKAN"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
