import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../models/menu.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final RxList<Map<String, dynamic>> cartItems;
  final CartController cartController = Get.find<CartController>();

  CartScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (cartItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Keranjang Anda kosong',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tambahkan beberapa item lezat untuk memulai',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartItems[index];
                  final Menu menu = cartItem['menu'];
                  final int quantity = cartItem['quantity'];
                  final double price = cartItem['price'];

                  return _buildCartItem(cartItem, menu, quantity, price, index);
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${_calculateTotal().toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Get.to(() => CheckoutScreen(cartItems: cartItems)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(
    Map<String, dynamic> cartItem,
    Menu menu,
    int quantity,
    double price,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: menu.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        menu.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : const Icon(Icons.restaurant, color: Colors.grey),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _decreaseQuantity(index),
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          minimumSize: const Size(32, 32),
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _increaseQuantity(index),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          minimumSize: const Size(32, 32),
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _removeItem(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(32, 32),
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  void _increaseQuantity(int index) async {
    final cartItem = cartItems[index];
    final Menu menu = cartItem['menu'];
    final int currentQuantity = cartItem['quantity'];

    if (currentQuantity < menu.stock) {
      if (cartItem.containsKey('id') && cartItem['id'] != null) {
        final success = await cartController.updateCartItem(
          itemId: cartItem['id'],
          quantity: currentQuantity + 1,
        );
        if (success) {
          cartItems[index]['quantity']++;
          cartItems.refresh();
        }
      } else {
        cartItems[index]['quantity']++;
        cartItems.refresh();
      }
    } else {
      Get.snackbar('Error', 'Tidak dapat melebihi stok yang tersedia');
    }
  }

  void _decreaseQuantity(int index) async {
    final cartItem = cartItems[index];
    final int currentQuantity = cartItem['quantity'];

    if (currentQuantity > 1) {
      if (cartItem.containsKey('id') && cartItem['id'] != null) {
        final success = await cartController.updateCartItem(
          itemId: cartItem['id'],
          quantity: currentQuantity - 1,
        );
        if (success) {
          cartItems[index]['quantity']--;
          cartItems.refresh();
        }
      } else {
        cartItems[index]['quantity']--;
        cartItems.refresh();
      }
    }
  }

  void _removeItem(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Item'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus item ini dari keranjang?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final cartItem = cartItems[index];

              if (cartItem.containsKey('id') && cartItem['id'] != null) {
                final success = await cartController.removeFromCart(
                  cartItem['id'],
                );
                if (success) {
                  cartItems.removeAt(index);
                  Get.back(); 
                  Get.snackbar(
                    'Removed',
                    'Item berhasil dihapus dari keranjang',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                  );
                } else {
                  Get.back(); 
                  Get.snackbar(
                    'Error',
                    'Gagal menghapus item dari keranjang',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                    icon: const Icon(Icons.error_outline, color: Colors.white),
                  );
                }
              } else {
                cartItems.removeAt(index);
                Get.back(); 
                Get.snackbar(
                  'Removed',
                  'Item berhasil dihapus dari keranjang',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
