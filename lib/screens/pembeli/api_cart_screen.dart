import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../models/menu.dart';
import 'checkout_screen.dart';
import '../../utils/app_theme.dart';

class ApiCartScreen extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  ApiCartScreen({super.key});

  // Helper function to build proper image URL
  String _buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    // If it's already a full URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // If it's a relative URL, append to base URL
    const String baseUrl = 'https://semenjana.biz.id/kaja';
    return '$baseUrl/$imageUrl';
  }

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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Memuat keranjang...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
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
                  'Keranjang kosong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  'Tambahkan menu favorit Anda',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Group items by merchant if needed
        final groupedItems = cartController.cartItemsByMerchant;

        // Debug log to check grouped items
        print(
          'ApiCartScreen: Grouped items keys: ${groupedItems.keys.toList()}',
        );
        print(
          'ApiCartScreen: Total grouped merchants: ${groupedItems.keys.length}',
        );

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
        final int quantity = int.tryParse(cartItem['quantity'].toString()) ?? 0;
        final double price =
            double.tryParse(cartItem['price'].toString()) ?? 0.0;

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

        print(
          'ApiCartScreen: Building UI for merchant $merchantId with ${merchantItems.length} items',
        );

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
                final int quantity =
                    int.tryParse(item['quantity'].toString()) ?? 0;
                final double price =
                    double.tryParse(item['price'].toString()) ?? 0.0;
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
      elevation: isInGroup ? 0 : 2,
      shadowColor: AppTheme.royalBlueDark.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: menu?.imageUrl != null && menu!.imageUrl!.isNotEmpty
                    ? Image.network(
                        _buildImageUrl(menu.imageUrl),
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.royalBlueDark,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print(
                            'CartScreen: Error loading image: ${menu.imageUrl}',
                          );
                          return Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.restaurant_menu,
                              color: AppTheme.royalBlueDark.withOpacity(0.6),
                              size: 30,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: AppTheme.royalBlueDark.withOpacity(0.6),
                          size: 30,
                        ),
                      ),
              ),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Show description if available
                  if (menu?.description != null &&
                      menu!.description!.isNotEmpty) ...[
                    Text(
                      menu.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Rp ${price.toStringAsFixed(0)} each',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.goldenPoppy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Show stock warning if stock is low
                  if (menu != null && menu.stock <= 5 && menu.stock > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 12,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Only ${menu.stock} left',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => _decreaseQuantity(index)
                            : null,
                        icon: const Icon(Icons.remove, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: quantity > 1
                              ? AppTheme.royalBlueDark.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          foregroundColor: quantity > 1
                              ? AppTheme.royalBlueDark
                              : Colors.grey,
                          minimumSize: const Size(28, 28),
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.royalBlueDark.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.royalBlueDark.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
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
                        icon: const Icon(Icons.add, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: menu != null && quantity < menu.stock
                              ? AppTheme.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          foregroundColor: menu != null && quantity < menu.stock
                              ? AppTheme.green
                              : Colors.grey,
                          minimumSize: const Size(28, 28),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.royalBlueDark.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.royalBlueDark.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: AppTheme.royalBlueDark,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Total Belanja:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Text(
                        '${cartController.totalItems} items',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Harga:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.goldenPoppy.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Rp ${cartController.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldenPoppy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToCheckout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.royalBlueDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Lanjut ke Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
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
    final int currentQuantity =
        int.tryParse(cartItem['quantity'].toString()) ?? 0;

    if (menu != null && currentQuantity < menu.stock) {
      final itemId = int.tryParse(cartItem['id'].toString()) ?? 0;
      await cartController.updateCartItem(
        itemId: itemId,
        quantity: currentQuantity + 1,
      );
    } else {
      Get.snackbar('Error', 'Cannot exceed available stock');
    }
  }

  void _decreaseQuantity(int index) async {
    final cartItem = cartController.cartItems[index];
    final int currentQuantity =
        int.tryParse(cartItem['quantity'].toString()) ?? 0;

    if (currentQuantity > 1) {
      final itemId = int.tryParse(cartItem['id'].toString()) ?? 0;
      await cartController.updateCartItem(
        itemId: itemId,
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
              final itemId = int.tryParse(cartItem['id'].toString()) ?? 0;
              final success = await cartController.removeFromCart(itemId);

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
    final cartItems = items.obs;
    Get.to(() => CheckoutScreen(cartItems: cartItems));
  }

  void _proceedToCheckout() {
    // Convert to the format expected by CheckoutScreen
    final cartItems = cartController.cartItems.obs;
    Get.to(() => CheckoutScreen(cartItems: cartItems));
  }
}
