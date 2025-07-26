import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/menu.dart';
import '../../controllers/cart_controller.dart';
import 'checkout_screen.dart';
import '../../utils/app_theme.dart';

class MenuDetailScreen extends StatelessWidget {
  final Menu menu;
  final RxInt quantity = 1.obs;
  final CartController cartController = Get.find<CartController>();

  MenuDetailScreen({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menu.name),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: menu.imageUrl != null
                  ? Image.network(
                      menu.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.grey,
                        );
                      },
                    )
                  : const Icon(Icons.restaurant, size: 64, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Price
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${menu.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldenPoppy,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  Row(
                    children: [
                      Icon(
                        menu.stock > 0 ? Icons.check_circle : Icons.cancel,
                        color: menu.stock > 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stock: ${menu.stock}',
                        style: TextStyle(
                          color: menu.stock > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category
                  if (menu.category != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.category, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Category: ${menu.category!.name}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (menu.description != null &&
                      menu.description!.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      menu.description!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quantity Selector
                  if (menu.stock > 0) ...[
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          IconButton(
                            onPressed: quantity.value > 1
                                ? () => quantity.value--
                                : null,
                            icon: const Icon(Icons.remove),
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.royalBlueDark
                                  .withOpacity(0.1),
                              foregroundColor: AppTheme.royalBlueDark,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              quantity.value.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.royalBlueDark,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: quantity.value < menu.stock
                                ? () => quantity.value++
                                : null,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.royalBlueDark
                                  .withOpacity(0.1),
                              foregroundColor: AppTheme.royalBlueDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: menu.stock > 0
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Row(
                  children: [
                    // Add to Cart Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _addToCart(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.royalBlueDark),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.royalBlueDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Buy Now Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _buyNow(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.royalBlueDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Buy Now - Rp ${(menu.price * quantity.value).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Out of Stock',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _addToCart() async {
    if (menu.stock <= 0) {
      Get.snackbar('Error', 'Item is out of stock');
      return;
    }

    // Use CartController to add item to cart via API
    final success = await cartController.addToCart(
      menuId: menu.id!,
      quantity: quantity.value,
      price: menu.price,
    );

    if (success) {
      Get.snackbar(
        'Added to Cart',
        '${quantity.value}x ${menu.name} added to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.green,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  void _buyNow() {
    // Create a single item cart for immediate checkout
    final cartItems = <Map<String, dynamic>>[
      {
        'menu_id': menu.id,
        'menu': menu,
        'quantity': quantity.value,
        'price': menu.price,
        'merchant_id': menu.penjualId, // Add merchant_id from menu.penjualId
      },
    ].obs;

    // Navigate directly to checkout
    Get.to(() => CheckoutScreen(cartItems: cartItems));
  }
}
