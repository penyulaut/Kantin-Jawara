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
import '../../utils/app_theme.dart';

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
    if (Get.isRegistered<CategoryController>()) {
      categoryController = Get.find<CategoryController>();
    } else {
      categoryController = Get.put(CategoryController());
    }
    searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAccess();
      print('MenuListScreen: Refreshing cart from initState...');
      cartController.refreshCart();
    });
  }

  void _validateAccess() {
    if (!RoleValidator.pembeliOnly(
      customMessage: 'Only buyers can access the menu',
    )) {
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
        backgroundColor: AppTheme.royalBlueDark,
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
                hintText: 'Cari menu disini bro...',
                prefixIcon: Icon(Icons.search, color: AppTheme.royalBlueDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: AppTheme.royalBlueDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: AppTheme.royalBlueDark,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.royalBlueDark.withOpacity(0.05),
              ),
              onChanged: (value) {
                menuController.searchMenus(value);
              },
            ),
          ),

          // Merchants Section
          Obx(() {
            print(
              'Building merchants section. Merchants count: ${menuController.merchants.length}',
            );
            print('Selected merchant ID: ${menuController.selectedMerchantId}');
            return Container(
              height: 140, 
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Pilih Kantin (${menuController.merchants.length} Tersedia)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.royalBlueDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: menuController.merchants.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildMerchantCard(
                            isSelected: menuController.selectedMerchantId == 0,
                            name: 'Semua Kantin',
                            description: 'Lihat Semua Kantin',
                            imageUrl: null,
                            onTap: () {
                              print('Tapping All Warung card');
                              menuController.setSelectedMerchant(
                                0,
                              );  
                            },
                          );
                        }

                        final merchant = menuController.merchants[index - 1];
                        return _buildMerchantCard(
                          isSelected:
                              menuController.selectedMerchantId == merchant.id,
                          name: merchant.name,
                          description:
                              merchant.description ?? 'Yu Pesen disini',
                          imageUrl: merchant.imageUrl,
                          onTap: () {
                            print(
                              'Tapping merchant card: ${merchant.name} (ID: ${merchant.id})',
                            );
                            menuController.setSelectedMerchant(merchant.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),

          // Categories Filter
          Obx(
            () => Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.royalBlueDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryController.categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              key: const ValueKey('filter_all'),
                              label: const Text('Semua'),
                              selected: menuController.selectedCategoryId == 0,
                              onSelected: (selected) {
                                menuController.setSelectedCategory(0);
                              },
                              selectedColor: AppTheme.royalBlueDark,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: menuController.selectedCategoryId == 0
                                    ? Colors.white
                                    : AppTheme.royalBlueDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }

                        final category =
                            categoryController.categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            key: ValueKey('filter_${category.id}'),
                            label: Text(category.name),
                            selected:
                                menuController.selectedCategoryId ==
                                category.id,
                            onSelected: (selected) {
                              if (category.id != null) {                             
                                if (menuController.selectedCategoryId ==
                                    category.id) {
                                  menuController.setSelectedCategory(0);
                                } else {
                                  menuController.setSelectedCategory(
                                    category.id!,
                                  );
                                }
                              }
                            },
                            selectedColor: AppTheme.royalBlueDark,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  menuController.selectedCategoryId ==
                                      category.id
                                  ? Colors.white
                                  : AppTheme.royalBlueDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Grid
          Expanded(
            child: Obx(() {
              if (menuController.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.royalBlueDark,
                        ),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading delicious menus...',
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (menuController.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppTheme.red),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.royalBlueDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        menuController.errorMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => menuController.fetchMenus(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.royalBlueDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (menuController.filteredMenus.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ga nemu menu nih!!',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.royalBlueDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coba sesuaikan pencarian atau filter Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => menuController.fetchMenus(),
                color: AppTheme.royalBlueDark,
                backgroundColor: Colors.white,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8, 
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.to(() => MenuDetailScreen(menu: menu)),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[200],
                ),
                child: menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          menu.imageUrl!,
                          fit: BoxFit.cover,
                          headers: const {
                            'User-Agent':
                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.lightGray,
                                    Colors.grey[100]!,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.royalBlueDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Loading image...',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              'Failed to load menu image: ${menu.imageUrl}',
                            );
                            print('Error: $error');
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.lightGray,
                                    Colors.grey[100]!,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 36,
                                      color: AppTheme.mediumGray,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppTheme.mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.lightGray, Colors.grey[100]!],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 36,
                                color: AppTheme.mediumGray,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No image',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Menu name
                    Text(
                      menu.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.royalBlueDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Text(
                      'Rp ${menu.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppTheme.goldenPoppy,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Stock
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 12,
                          color: menu.stock > 0
                              ? AppTheme.usafaBlue
                              : AppTheme.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stok: ${menu.stock}',
                          style: TextStyle(
                            fontSize: 11,
                            color: menu.stock > 0
                                ? AppTheme.usafaBlue
                                : AppTheme.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

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
                              side: BorderSide(
                                color: menu.stock > 0
                                    ? AppTheme.royalBlueDark
                                    : AppTheme.mediumGray,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: const Size(0, 28),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 14,
                              color: menu.stock > 0
                                  ? AppTheme.royalBlueDark
                                  : AppTheme.mediumGray,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Buy Now button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: menu.stock > 0
                                ? () => _buyNow(menu)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: menu.stock > 0
                                  ? AppTheme.royalBlueDark
                                  : AppTheme.mediumGray,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: const Size(0, 28),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Beli',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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

    await cartController.quickAddToCart(menu);
  }

  void _buyNow(Menu menu) {
    if (menu.stock <= 0) {
      Get.snackbar('Error', 'Item is out of stock');
      return;
    }

    final buyNowCartItems = <Map<String, dynamic>>[
      {'menu_id': menu.id, 'menu': menu, 'quantity': 1, 'price': menu.price},
    ].obs;

    Get.to(() => CheckoutScreen(cartItems: buyNowCartItems));
  }

  Widget _buildMerchantCard({
    required bool isSelected,
    required String name,
    required String description,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [AppTheme.royalBlueDark, AppTheme.usafaBlue]
                : [Colors.white, AppTheme.lightGray.withOpacity(0.3)],
          ),
          border: Border.all(
            color: isSelected ? AppTheme.royalBlueDark : AppTheme.lightGray,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.royalBlueDark.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, 
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.royalBlueDark.withOpacity(0.1),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.restaurant,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.royalBlueDark,
                              size: 20,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.restaurant,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.royalBlueDark,
                        size: 20,
                      ),
              ),
              const SizedBox(height: 6), 
              Flexible(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppTheme.royalBlueDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 9, 
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : AppTheme.mediumGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
