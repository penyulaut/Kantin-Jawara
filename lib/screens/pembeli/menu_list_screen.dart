import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/menu_controller.dart' as menu_ctrl;
import '../../controllers/category_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/menu.dart';
import 'menu_detail_screen.dart';
import 'api_cart_screen.dart';
import 'checkout_screen.dart';
import '../../utils/role_validator.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late final menu_ctrl.MenuController menuController;
  late final CategoryController categoryController;
  late final CartController cartController;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();

    menuController = Get.find<menu_ctrl.MenuController>();
    cartController = Get.find<CartController>();
    // Try to find existing CategoryController, if not found, create one
    if (Get.isRegistered<CategoryController>()) {
      categoryController = Get.find<CategoryController>();
    } else {
      categoryController = Get.put(CategoryController());
    }
    searchController = TextEditingController();

    // Schedule role validation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAccess();
      // Also refresh cart when menu screen is accessed
      print('MenuListScreen: Refreshing cart from initState...');
      cartController.refreshCart();
    });
  }

  void _validateAccess() {
    if (!RoleValidator.pembeliOnly(
      customMessage: 'Only buyers can access the menu',
    )) {
      // Access denied, user will be redirected
      return;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Kantin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => Get.to(() => ApiCartScreen()),
              icon: Badge(
                isLabelVisible: cartController.totalItems > 0,
                label: Text(cartController.totalItems.toString()),
                child: const Icon(Icons.shopping_cart),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search menu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // Implement search functionality
                menuController.searchMenus(value);
              },
            ),
          ),

          // Categories Filter
          Obx(
            () => Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryController.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: const ValueKey('filter_all'),
                        label: const Text('All'),
                        selected: menuController.selectedCategoryId == 0,
                        onSelected: (selected) {
                          menuController.clearFilters();
                        },
                      ),
                    );
                  }

                  final category = categoryController.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      key: ValueKey('filter_${category.id}'),
                      label: Text(category.name),
                      selected:
                          menuController.selectedCategoryId == category.id,
                      onSelected: (selected) {
                        if (selected && category.id != null) {
                          menuController.filterByCategory(category.id!);
                        } else {
                          menuController.clearFilters();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Menu Grid
          Expanded(
            child: Obx(() {
              if (menuController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (menuController.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${menuController.errorMessage}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => menuController.fetchMenus(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (menuController.filteredMenus.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No menu items found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => menuController.fetchMenus(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: menuController.filteredMenus.length,
                  itemBuilder: (context, index) {
                    final menu = menuController.filteredMenus[index];
                    return _buildMenuCard(
                      context,
                      menu,
                      key: ValueKey('menu_${menu.id}_$index'),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, Menu menu, {Key? key}) {
    return Card(
      key: key,
      elevation: 4,
      child: InkWell(
        onTap: () => Get.to(() => MenuDetailScreen(menu: menu)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  color: Colors.grey[200],
                ),
                child: menu.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: Image.network(
                          menu.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.restaurant,
                              size: 48,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.grey,
                      ),
              ),
            ),

            // Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${menu.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${menu.stock}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // Action buttons
                    Row(
                      children: [
                        // Add to Cart button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: menu.stock > 0
                                ? () => _addToCart(menu)
                                : null,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text(
                              'Cart',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Buy Now button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: menu.stock > 0
                                ? () => _buyNow(menu)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text(
                              'Buy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Menu menu) async {
    if (menu.stock <= 0) {
      Get.snackbar('Error', 'Item is out of stock');
      return;
    }

    // Use CartController to add item to cart via API
    await cartController.quickAddToCart(menu);
  }

  void _buyNow(Menu menu) {
    if (menu.stock <= 0) {
      Get.snackbar('Error', 'Item is out of stock');
      return;
    }

    // Create a single item cart for immediate checkout
    final buyNowCartItems = <Map<String, dynamic>>[
      {'menu_id': menu.id, 'menu': menu, 'quantity': 1, 'price': menu.price},
    ].obs;

    // Navigate directly to checkout
    Get.to(() => CheckoutScreen(cartItems: buyNowCartItems));
  }
}
