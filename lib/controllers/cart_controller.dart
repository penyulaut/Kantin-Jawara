import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/menu.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';

class CartController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<Map<String, dynamic>> _cartItems = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  int get totalItems => _cartItems.fold(
    0,
    (sum, item) => sum + (int.tryParse(item['quantity'].toString()) ?? 0),
  );

  double get totalPrice => _cartItems.fold(0.0, (sum, item) {
    final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
    final price = double.tryParse(item['price'].toString()) ?? 0.0;
    return sum + (price * quantity);
  });

  @override
  void onInit() {
    super.onInit();
    // Don't auto-fetch here since it might be called before auth is ready
    // Let the dashboard handle the initial fetch
  }

  // Fetch cart items from API
  Future<void> fetchCart() async {
    try {
      print('CartController: Starting fetchCart...');
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        print('CartController: No token available, user not authenticated');
        _cartItems.clear(); // Clear cart items if not authenticated
        return;
      }

      print(
        'CartController: Fetching cart with token: ${token.substring(0, 20)}...',
      );
      final response = await _apiService.get('/cart', token: token);

      print('CartController: Cart API response: $response');

      if (response['success']) {
        print('CartController: Cart fetch successful');
        final responseData = response['data'];
        final List<dynamic> cartData;

        // Handle nested response structure
        if (responseData is Map && responseData.containsKey('data')) {
          // Nested structure: {"success": true, "data": {"message": "...", "data": [...]}}
          cartData = responseData['data'] ?? [];
        } else if (responseData is List) {
          // Direct array: {"success": true, "data": [...]}
          cartData = responseData;
        } else {
          // Unknown structure
          cartData = [];
        }

        print('CartController: Raw cart data: $cartData');

        // Flatten cart items from all carts
        final List<Map<String, dynamic>> allCartItems = [];

        for (final cart in cartData) {
          if (cart is Map<String, dynamic> && cart.containsKey('cart_items')) {
            final List<dynamic> cartItems = cart['cart_items'] ?? [];
            print(
              'CartController: Processing cart with ${cartItems.length} items for merchant ${cart['merchant_id']}',
            );

            for (final item in cartItems) {
              final merchantIdFromCart =
                  int.tryParse(cart['merchant_id'].toString()) ?? 0;

              // Debug logging for merchant_id type consistency
              print(
                'CartController: Adding item with merchant_id: $merchantIdFromCart (type: ${merchantIdFromCart.runtimeType})',
              );

              final menuData = item['menu'] != null
                  ? Menu.fromJson(item['menu'])
                  : null;

              // Debug: Log menu image URL
              if (menuData != null) {
                print(
                  'CartController: Item ${item['id']} - Menu: ${menuData.name}, Image: ${menuData.imageUrl}',
                );
              }

              allCartItems.add({
                'id': int.tryParse(item['id'].toString()) ?? 0,
                'menu_id': int.tryParse(item['menu_id'].toString()) ?? 0,
                'quantity': int.tryParse(item['quantity'].toString()) ?? 0,
                'price': double.tryParse(item['unit_price'].toString()) ?? 0.0,
                'total_price':
                    double.tryParse(item['total_price'].toString()) ?? 0.0,
                'menu': menuData,
                'cart_id': int.tryParse(item['cart_id'].toString()) ?? 0,
                'merchant_id': merchantIdFromCart,
              });
            }
          }
        }

        _cartItems.value = allCartItems;
        print('CartController: Cart updated with ${allCartItems.length} items');

        // Debug: Print each cart item
        for (int i = 0; i < allCartItems.length; i++) {
          final item = allCartItems[i];
          final menu = item['menu'] as Menu?;
          print(
            'CartController: Item $i: ${menu?.name} x${item['quantity']} = Rp${item['total_price']}',
          );
        }
      } else {
        print('CartController: Cart fetch failed: ${response['message']}');
        _errorMessage.value = response['message'] ?? 'Failed to fetch cart';
      }
    } catch (e) {
      print('CartController: Error fetching cart: $e');
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
      print('CartController: fetchCart completed');
    }
  }

  // Add item to cart via API
  Future<bool> addToCart({
    required int menuId,
    required int quantity,
    required double price,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        Get.snackbar('Error', 'Please login first');
        return false;
      }

      final data = {'menu_id': menuId, 'quantity': quantity};

      final response = await _apiService.post(
        '/cart/add',
        data: data,
        token: token,
      );

      if (response['success']) {
        // Refresh cart after adding
        await fetchCart();
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to add item to cart';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Failed to add item to cart');
      print('CartController: Error adding to cart: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update cart item quantity via API
  Future<bool> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {'quantity': quantity};

      final response = await _apiService.put(
        '/cart/items/$itemId',
        data: data,
        token: token,
      );

      if (response['success']) {
        // Update local cart item
        final index = _cartItems.indexWhere(
          (item) => int.tryParse(item['id'].toString()) == itemId,
        );
        if (index != -1) {
          _cartItems[index]['quantity'] = quantity;
          final price =
              double.tryParse(_cartItems[index]['price'].toString()) ?? 0.0;
          _cartItems[index]['total_price'] = price * quantity;
          _cartItems.refresh();
        }
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to update cart item';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Failed to update cart item');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Remove item from cart via API
  Future<bool> removeFromCart(int itemId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.delete(
        '/cart/items/$itemId',
        token: token,
      );

      if (response['success']) {
        // Remove from local cart
        _cartItems.removeWhere(
          (item) => int.tryParse(item['id'].toString()) == itemId,
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to remove item from cart';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Failed to remove item from cart');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear entire cart via API
  Future<bool> clearCart() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.delete('/cart', token: token);

      if (response['success']) {
        _cartItems.clear();
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to clear cart';
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Get cart for specific merchant
  Future<List<Map<String, dynamic>>> getCartByMerchant(int merchantId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return [];
      }

      final response = await _apiService.get('/cart/$merchantId', token: token);

      if (response['success']) {
        final responseData = response['data'];
        final List<dynamic> cartData;

        // Handle nested response structure
        if (responseData is Map && responseData.containsKey('data')) {
          cartData = responseData['data'] ?? [];
        } else if (responseData is List) {
          cartData = responseData;
        } else {
          cartData = [];
        }

        // Flatten cart items from all carts for this merchant
        final List<Map<String, dynamic>> merchantCartItems = [];

        for (final cart in cartData) {
          if (cart is Map<String, dynamic> &&
              cart.containsKey('cart_items') &&
              _isSameMerchantId(cart['merchant_id'], merchantId)) {
            final List<dynamic> cartItems = cart['cart_items'] ?? [];
            for (final item in cartItems) {
              final menuData = item['menu'] != null
                  ? Menu.fromJson(item['menu'])
                  : null;

              // Debug: Log menu image URL for merchant cart
              if (menuData != null) {
                print(
                  'CartController: Merchant $merchantId - Item ${item['id']} - Menu: ${menuData.name}, Image: ${menuData.imageUrl}',
                );
              }

              merchantCartItems.add({
                'id': int.tryParse(item['id'].toString()) ?? 0,
                'menu_id': int.tryParse(item['menu_id'].toString()) ?? 0,
                'quantity': int.tryParse(item['quantity'].toString()) ?? 0,
                'price': double.tryParse(item['unit_price'].toString()) ?? 0.0,
                'total_price':
                    double.tryParse(item['total_price'].toString()) ?? 0.0,
                'menu': menuData,
                'cart_id': int.tryParse(item['cart_id'].toString()) ?? 0,
                'merchant_id':
                    int.tryParse(cart['merchant_id'].toString()) ?? 0,
              });
            }
          }
        }

        return merchantCartItems;
      }
      return [];
    } catch (e) {
      print('CartController: Error getting cart by merchant: $e');
      return [];
    }
  }

  // Checkout specific merchant cart
  Future<bool> checkoutMerchantCart({
    required int merchantId,
    required String customerName,
    required String customerPhone,
    required String orderType,
    String? notes,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'order_type': orderType,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await _apiService.post(
        '/cart/$merchantId/checkout',
        data: data,
        token: token,
      );

      if (response['success']) {
        // Remove checked out items from local cart
        _cartItems.removeWhere((item) {
          // Use merchant_id from cart data if available, otherwise fallback to menu's penjualId
          int? itemMerchantId = item['merchant_id'];

          if (itemMerchantId == null) {
            final menu = item['menu'] as Menu?;
            itemMerchantId = menu?.penjualId;
          }

          return itemMerchantId == merchantId;
        });

        CustomSnackbar.success(
          'Order Placed\nYour order has been placed successfully!',
        );
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to checkout';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Failed to checkout');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Helper method to safely compare merchant IDs (handles both int and string)
  bool _isSameMerchantId(dynamic id1, dynamic id2) {
    if (id1 == null || id2 == null) return false;

    // Convert both to string for comparison to handle int/string mismatch
    final str1 = id1.toString();
    final str2 = id2.toString();

    return str1 == str2;
  }

  // Helper method to group cart items by merchant
  Map<int, List<Map<String, dynamic>>> get cartItemsByMerchant {
    final Map<int, List<Map<String, dynamic>>> grouped = {};

    print(
      'CartController: Grouping ${cartItems.length} cart items by merchant...',
    );

    // Use the observable cartItems getter to ensure reactivity
    for (final item in cartItems) {
      // Use merchant_id from cart data if available, otherwise fallback to menu's penjualId
      int? merchantId;

      // Try to get merchant_id from item data
      if (item['merchant_id'] != null) {
        merchantId = int.tryParse(item['merchant_id'].toString());
        print(
          'CartController: Item ${item['id']} has merchant_id: ${item['merchant_id']} (parsed as: $merchantId)',
        );
      }

      // Fallback to menu's penjualId if merchant_id is not available
      if (merchantId == null) {
        final menu = item['menu'] as Menu?;
        merchantId = menu?.penjualId;
        print(
          'CartController: Using fallback penjualId: $merchantId for item ${item['id']}',
        );
      }

      if (merchantId != null) {
        if (!grouped.containsKey(merchantId)) {
          grouped[merchantId] = [];
        }
        grouped[merchantId]!.add(item);
        print(
          'CartController: Added item ${item['id']} to merchant group $merchantId',
        );
      } else {
        // If no merchant ID found, log for debugging
        print(
          'CartController: WARNING - No merchant ID found for item: ${item['id']}',
        );
      }
    }

    print(
      'CartController: Grouped into ${grouped.keys.length} merchant groups: ${grouped.keys.toList()}',
    );
    return grouped;
  }

  // Get cart item count for badge
  int getCartItemCount() {
    return totalItems;
  }

  // Quick add to cart with success message
  Future<void> quickAddToCart(Menu menu, {int quantity = 1}) async {
    final success = await addToCart(
      menuId: menu.id!,
      quantity: quantity,
      price: menu.price,
    );

    if (success) {
      Get.snackbar(
        'Added to Cart',
        '${quantity}x ${menu.name} added to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Force refresh cart - useful for UI refreshes
  Future<void> refreshCart() async {
    print('CartController: Force refreshing cart...');
    await fetchCart();
  }
}
