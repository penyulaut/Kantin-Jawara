import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/menu_controller.dart' as menu_ctrl;
import '../../controllers/category_controller.dart';
import '../../models/menu.dart';

class ManageMenusScreen extends StatelessWidget {
  const ManageMenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu_ctrl.MenuController menuController =
        Get.find<menu_ctrl.MenuController>();
    final CategoryController categoryController = Get.put(CategoryController());

    // Load seller's menus when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      menuController.fetchMyMenus();
      categoryController.fetchCategories(); // Also fetch categories
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () =>
                _showAddMenuDialog(context, menuController, categoryController),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search menus...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                menuController.setSearchQuery(value);
              },
            ),
          ),

          // Menus List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => menuController.fetchMyMenus(),
              child: Obx(() {
                // Apply search filter to myMenus
                final allMenus = menuController.myMenus;
                final searchQuery = menuController.searchQuery.toLowerCase();
                final menus = searchQuery.isEmpty
                    ? allMenus
                    : allMenus
                          .where(
                            (menu) =>
                                menu.name.toLowerCase().contains(searchQuery) ||
                                (menu.description?.toLowerCase().contains(
                                      searchQuery,
                                    ) ??
                                    false),
                          )
                          .toList();

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
                          onPressed: () => menuController.fetchMyMenus(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (menus.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No menus found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add your first menu using the + button',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    return _buildMenuCard(menu, menuController);
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddMenuDialog(context, menuController, categoryController),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMenuCard(Menu menu, menu_ctrl.MenuController menuController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Menu Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: menu.imageUrl != null
                    ? Image.network(
                        menu.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Menu Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menu.description ?? 'No description',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (menu.category != null) ...[
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          menu.category!.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${menu.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: menu.stock > 0
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Stock: ${menu.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: menu.stock > 0
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: () =>
                      _showEditMenuDialog(Get.context!, menu, menuController),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () =>
                      _showDeleteConfirmation(menu, menuController),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMenuDialog(
    BuildContext context,
    menu_ctrl.MenuController menuController,
    CategoryController categoryController,
  ) {
    _showMenuDialog(context, null, menuController, categoryController);
  }

  void _showEditMenuDialog(
    BuildContext context,
    Menu menu,
    menu_ctrl.MenuController menuController,
  ) {
    final categoryController = Get.find<CategoryController>();
    _showMenuDialog(context, menu, menuController, categoryController);
  }

  void _showMenuDialog(
    BuildContext context,
    Menu? menu,
    menu_ctrl.MenuController menuController,
    CategoryController categoryController,
  ) {
    final nameController = TextEditingController(text: menu?.name ?? '');
    final descriptionController = TextEditingController(
      text: menu?.description ?? '',
    );
    final priceController = TextEditingController(
      text: menu?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: menu?.stock.toString() ?? '10',
    );

    int? selectedCategoryId = menu?.categoryId;
    final RxString selectedImagePath = ''.obs;
    final RxString currentImageUrl = (menu?.imageUrl ?? '').obs;

    // Function to pick image
    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImagePath.value = image.path;
        currentImageUrl.value =
            ''; // Clear current URL when new image is selected
      }
    }

    Get.dialog(
      AlertDialog(
        title: Text(menu == null ? 'Add Menu' : 'Edit Menu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Menu Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Image Section
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu Image (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: selectedImagePath.value.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(selectedImagePath.value),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : currentImageUrl.value.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  currentImageUrl.value,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                        Text('Failed to load image'),
                                      ],
                                    );
                                  },
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Tap to select image'),
                                ],
                              ),
                      ),
                    ),
                    if (selectedImagePath.value.isNotEmpty ||
                        currentImageUrl.value.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          selectedImagePath.value = '';
                          currentImageUrl.value = '';
                        },
                        child: const Text('Remove Image'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categoryController.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategoryId = value;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  selectedCategoryId == null) {
                Get.snackbar('Error', 'Please fill all required fields');
                return;
              }

              final price = double.tryParse(priceController.text);
              final stock = int.tryParse(stockController.text) ?? 10;

              if (price == null || price <= 0) {
                Get.snackbar('Error', 'Please enter a valid price');
                return;
              }

              bool success;
              if (menu == null) {
                success = await menuController.createMenu(
                  name: nameController.text,
                  description: descriptionController.text.isEmpty
                      ? 'No description'
                      : descriptionController.text,
                  price: price,
                  categoryId: selectedCategoryId!,
                  stock: stock,
                  imageUrl: selectedImagePath.value.isNotEmpty
                      ? selectedImagePath.value
                      : null,
                );
              } else {
                success = await menuController.updateMenu(
                  id: menu.id!,
                  name: nameController.text,
                  description: descriptionController.text.isEmpty
                      ? 'No description'
                      : descriptionController.text,
                  price: price,
                  categoryId: selectedCategoryId!,
                  stock: stock,
                  imageUrl: selectedImagePath.value.isNotEmpty
                      ? selectedImagePath.value
                      : (currentImageUrl.value.isNotEmpty
                            ? currentImageUrl.value
                            : null),
                );
              }

              if (success) {
                Get.back();
              }
            },
            child: Text(menu == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    Menu menu,
    menu_ctrl.MenuController menuController,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Menu'),
        content: Text('Are you sure you want to delete "${menu.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (menu.id != null) {
                final success = await menuController.deleteMenu(menu.id!);
                if (success) {
                  Get.back();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
