import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../models/menu.dart';
import 'checkout_screen.dart';
import '../../utils/app_theme.dart';

class ApiCartScreen extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  ApiCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showClearCartDialog(),
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Obx(() {
        if (cartController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartController.cartItems.isEmpty) {
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
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add some delicious items to get started',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Group items by merchant if needed
        final groupedItems = cartController.cartItemsByMerchant;

        return Column(
          children: [
            Expanded(
              child: groupedItems.isNotEmpty
                  ? _buildGroupedCart(groupedItems)
                  : _buildSimpleCart(),
            ),
            // Total and Checkout
            _buildCheckoutSection(),
          ],
        );
      }),
    );
  }

  Widget _buildSimpleCart() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartController.cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartController.cartItems[index];
        final Menu? menu = cartItem['menu'];
        final int quantity = cartItem['quantity'];
        final double price = cartItem['price'];

        return _buildCartItem(cartItem, menu, quantity, price, index);
      },
    );
  }

  Widget _buildGroupedCart(Map<int, List<Map<String, dynamic>>> groupedItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedItems.keys.length,
      itemBuilder: (context, merchantIndex) {
        final merchantId = groupedItems.keys.elementAt(merchantIndex);
        final merchantItems = groupedItems[merchantId]!;

        // Get merchant name - for now using merchant ID
        // In the future, you might want to add merchant info to Menu model or fetch it separately
        String merchantName = 'Merchant $merchantId';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Merchant Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlueDark.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.store, color: AppTheme.royalBlueDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        merchantName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.royalBlueDark,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _checkoutMerchant(merchantId, merchantItems),
                      icon: const Icon(Icons.shopping_cart_checkout, size: 16),
                      label: const Text(
                        'Checkout',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ),
              // Merchant Items
              ...merchantItems.map((item) {
                final Menu? menu = item['menu'];
                final int quantity = item['quantity'];
                final double price = item['price'];
                final index = cartController.cartItems.indexOf(item);

                return _buildCartItem(
                  item,
                  menu,
                  quantity,
                  price,
                  index,
                  isInGroup: true,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItem(
    Map<String, dynamic> cartItem,
    Menu? menu,
    int quantity,
    double price,
    int index, {
    bool isInGroup = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: isInGroup ? 0 : 8),
      elevation: isInGroup ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: menu?.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        menu!.imageUrl!,
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

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu?.name ?? 'Unknown Item',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${price.toStringAsFixed(0)} each',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => _decreaseQuantity(index)
                            : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.royalBlueDark.withOpacity(
                            0.1,
                          ),
                          foregroundColor: AppTheme.royalBlueDark,
                          minimumSize: const Size(32, 32),
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          quantity.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.royalBlueDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: menu != null && quantity < menu.stock
                            ? () => _increaseQuantity(index)
                            : null,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.royalBlueDark.withOpacity(
                            0.1,
                          ),
                          foregroundColor: AppTheme.royalBlueDark,
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

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Rp ${(price * quantity).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldenPoppy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => Text(
                  'Rp ${cartController.totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldenPoppy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '${cartController.totalItems} items',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToCheckout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.royalBlueDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Checkout All',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _increaseQuantity(int index) async {
    final cartItem = cartController.cartItems[index];
    final Menu? menu = cartItem['menu'];
    final int currentQuantity = cartItem['quantity'];

    if (menu != null && currentQuantity < menu.stock) {
      await cartController.updateCartItem(
        itemId: cartItem['id'],
        quantity: currentQuantity + 1,
      );
    } else {
      Get.snackbar('Error', 'Cannot exceed available stock');
    }
  }

  void _decreaseQuantity(int index) async {
    final cartItem = cartController.cartItems[index];
    final int currentQuantity = cartItem['quantity'];

    if (currentQuantity > 1) {
      await cartController.updateCartItem(
        itemId: cartItem['id'],
        quantity: currentQuantity - 1,
      );
    }
  }

  void _removeItem(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Item'),
        content: const Text(
          'Are you sure you want to remove this item from cart?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () async {
              Get.back(); // Close dialog first
              final cartItem = cartController.cartItems[index];
              final success = await cartController.removeFromCart(
                cartItem['id'],
              );

              if (success) {
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
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to clear all items from your cart?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () async {
              Get.back(); // Close dialog first
              await cartController.clearCart();

              // Show success message
              Get.snackbar(
                'Success',
                'Keranjang berhasil dikosongkan',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                icon: const Icon(Icons.check_circle, color: Colors.white),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _checkoutMerchant(int merchantId, List<Map<String, dynamic>> items) {
    // Convert to the format expected by CheckoutScreen
    final cartItems = items.obs;
    Get.to(() => CheckoutScreen(cartItems: cartItems));
  }

  void _proceedToCheckout() {
    // Convert to the format expected by CheckoutScreen
    final cartItems = cartController.cartItems.obs;
    Get.to(() => CheckoutScreen(cartItems: cartItems));
  }
}
