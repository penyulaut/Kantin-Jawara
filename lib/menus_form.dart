import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MenuFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const MenuFormScreen({super.key, this.product});

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!['name'];
      priceController.text = widget.product!['price'].toString();
      descController.text = widget.product!['description'] ?? '';
      imageUrlController.text = widget.product!['image_url'] ?? '';
      stockController.text = widget.product!['stock'].toString();
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Pastikan token sudah disimpan saat login
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final token = await getToken();

    if (token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan. Silakan login kembali.')),
      );
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'name': nameController.text,
      'description': descController.text,
      'price': int.tryParse(priceController.text) ?? 0,
      'stock': int.tryParse(stockController.text) ?? 0,
      'category_id': 1,
      'image_url': imageUrlController.text,
    });

    final url = Uri.parse('https://semenjana.biz.id/kaja/api/menus');
    final response = await http.post(url, headers: headers, body: body);

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      try {
        final data = jsonDecode(response.body);
        final errorMsg = data['message'] ?? 'Gagal menyimpan data';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $errorMsg')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan: Error tidak diketahui')),
        );
      }
    }
  }

  Future<void> deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    final token = await getToken();
    final headers = {'Authorization': 'Bearer $token'};
    final id = widget.product!['id'];

    final response = await http.delete(
      Uri.parse('https://semenjana.biz.id/kaja/api/menus/$id'),
      headers: headers,
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 204) {
      Navigator.pop(context, true);
    } else {
      try {
        final data = jsonDecode(response.body);
        final errorMsg = data['message'] ?? 'Gagal menghapus';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus: $errorMsg')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal hapus: Error tidak diketahui')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteProduct,
              tooltip: 'Hapus Produk',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Stok tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: saveProduct,
                      child: Text(isEdit ? 'Update' : 'Create'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
