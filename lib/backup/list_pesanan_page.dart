import 'package:flutter/material.dart';

class ListPesananPage extends StatelessWidget {
  const ListPesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Pesanan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPesananItem('Nasi Goreng', '2 Porsi', 'Rp. 10k'),
            const SizedBox(height: 16),
            _buildPesananItem('Ayam Katsu', '2 Porsi', 'Rp. 10k'),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Rp. 120k", style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("ORDER NOW"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPesananItem(String nama, String jumlah, String harga) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade100),
      child: Row(
        children: [
          Image.network(
            'https://static.promediateknologi.id/crop/0x0:0x0/0x0/webp/photo/p2/202/2025/01/30/maxresdefault-3381978305.jpg',
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Jumlah: $jumlah"),
              Text("Kategori: Makanan"),
              Text("Catatan: Jangan pakai sambal"),
            ]),
          ),
          Column(
            children: [
              Chip(label: Text(harga)),
              const SizedBox(height: 8),
              const Chip(label: Text("Hapus"), backgroundColor: Colors.redAccent, labelStyle: TextStyle(color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }
}
