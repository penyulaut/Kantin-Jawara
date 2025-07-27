import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/menu_controller.dart' as menu_ctrl;
import '../../controllers/category_controller.dart';
import '../../models/menu.dart';
import '../../utils/app_theme.dart';

class ManageMenusScreen extends StatelessWidget {
  const ManageMenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu_ctrl.MenuController menuController =
        Get.find<menu_ctrl.MenuController>();
    final CategoryController categoryController = Get.put(CategoryController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      menuController.fetchMyMenus();
      categoryController.fetchCategories();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Menu'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Menu...',
                prefixIcon: Icon(Icons.search, color: AppTheme.royalBlueDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.royalBlueDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.royalBlueDark,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                menuController.setSearchQuery(value);
              },
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => menuController.fetchMyMenus(),
              child: Obx(() {
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
                        Icon(Icons.error, size: 64, color: AppTheme.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${menuController.errorMessage}',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => menuController.fetchMyMenus(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.royalBlueDark,
                            foregroundColor: Colors.white,
                          ),
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
        backgroundColor: AppTheme.royalBlueDark,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                    ? Image.network(
                        menu.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldenPoppy,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: menu.stock > 0
                              ? AppTheme.usafaBlue.withOpacity(0.2)
                              : AppTheme.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Stok: ${menu.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: menu.stock > 0
                                ? AppTheme.usafaBlue
                                : AppTheme.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              children: [
                IconButton(
                  onPressed: () =>
                      _showEditMenuDialog(Get.context!, menu, menuController),
                  icon: Icon(Icons.edit, color: AppTheme.royalBlueDark),
                ),
                IconButton(
                  onPressed: () =>
                      _showDeleteConfirmation(menu, menuController),
                  icon: Icon(Icons.delete, color: AppTheme.red),
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
    final imageUrlController = TextEditingController(
      text: menu?.imageUrl ?? '',
    );
    final RxInt imageSourceType =
        (menu?.imageUrl != null &&
                    menu!.imageUrl!.isNotEmpty &&
                    (menu.imageUrl!.startsWith('http://') ||
                        menu.imageUrl!.startsWith('https://'))
                ? 1
                : 0)
            .obs;

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
        currentImageUrl.value = '';
        imageUrlController.clear();
      }
    }

    void onUrlChanged(String url) {
      final trimmedUrl = url.trim();
      if (trimmedUrl.isNotEmpty &&
          (trimmedUrl.startsWith('http://') ||
              trimmedUrl.startsWith('https://'))) {
        currentImageUrl.value = trimmedUrl;
        selectedImagePath.value = ''; // Clear any selected file
      } else {
        currentImageUrl.value = '';
      }
    }

    Get.dialog(
      AlertDialog(
        title: Text(menu == null ? 'Tambah Menu' : 'Edit Menu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gambar Menu (Opsional)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => imageSourceType.value = 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: imageSourceType.value == 0
                                    ? AppTheme.royalBlueDark
                                    : AppTheme.lightGray,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Pilih Gambar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: imageSourceType.value == 0
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => imageSourceType.value = 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: imageSourceType.value == 1
                                    ? AppTheme.royalBlueDark
                                    : AppTheme.lightGray,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                'URL Gambar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: imageSourceType.value == 1
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (imageSourceType.value == 0) ...[
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
                              : (menu?.imageUrl != null &&
                                    menu!.imageUrl!.isNotEmpty &&
                                    selectedImagePath.value.isEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    menu.imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
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
                                          Text('Gagal memuat gambar'),
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
                                    Text('Ketuk untuk memilih gambar'),
                                  ],
                                ),
                        ),
                      ),
                    ],

                    if (imageSourceType.value == 1) ...[
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Gambar',
                          hintText: 'https://example.com/image.jpg',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        onChanged: onUrlChanged,
                      ),
                      const SizedBox(height: 8),
                      if (imageUrlController.text.trim().isNotEmpty &&
                          (imageUrlController.text.trim().startsWith(
                                'http://',
                              ) ||
                              imageUrlController.text.trim().startsWith(
                                'https://',
                              )))
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrlController.text.trim(),
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: AppTheme.red,
                                    ),
                                    Text(
                                      'Gagal memuat gambar',
                                      style: TextStyle(color: AppTheme.red),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                      else if (menu?.imageUrl != null &&
                          menu!.imageUrl!.isNotEmpty &&
                          imageUrlController.text.trim().isEmpty)
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              menu.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: AppTheme.red,
                                    ),
                                    Text(
                                      'Gagal memuat gambar yang ada',
                                      style: TextStyle(color: AppTheme.red),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                      else if (imageUrlController.text.trim().isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.goldenPoppy.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: AppTheme.goldenPoppy.withOpacity(0.1),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: AppTheme.goldenPoppy,
                                  size: 24,
                                ),
                                Text(
                                  'Invalid URL format',
                                  style: TextStyle(
                                    color: AppTheme.goldenPoppy,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],

                    if ((selectedImagePath.value.isNotEmpty &&
                            imageSourceType.value == 0) ||
                        (imageUrlController.text.trim().isNotEmpty &&
                            imageSourceType.value == 1) ||
                        (menu?.imageUrl != null && menu!.imageUrl!.isNotEmpty))
                      TextButton(
                        onPressed: () {
                          selectedImagePath.value = '';
                          currentImageUrl.value = '';
                          imageUrlController.clear();
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
                    labelText: 'Kategori',
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
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  selectedCategoryId == null) {
                Get.snackbar(
                  'Error',
                  'Please fill all required fields',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final price = double.tryParse(priceController.text);
              final stock = int.tryParse(stockController.text) ?? 10;

              if (price == null || price <= 0) {
                Get.snackbar(
                  'Error',
                  'Please enter a valid price',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (imageSourceType.value == 1) {
                final urlText = imageUrlController.text.trim();
                if (urlText.isNotEmpty &&
                    !(urlText.startsWith('http://') ||
                        urlText.startsWith('https://'))) {
                  Get.snackbar(
                    'Error',
                    'Please enter a valid image URL (must start with http:// or https://)',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
              }

              Get.back();

              bool success;
              String? finalImageUrl;


              if (imageSourceType.value == 0) {
                if (selectedImagePath.value.isNotEmpty) {
                  finalImageUrl = selectedImagePath.value;
                } else if (menu != null &&
                    menu.imageUrl != null &&
                    menu.imageUrl!.isNotEmpty) {
                  finalImageUrl = menu.imageUrl;
                } else {
                  finalImageUrl = null;
                }
              } else {
                final urlText = imageUrlController.text.trim();
                if (urlText.isNotEmpty &&
                    (urlText.startsWith('http://') ||
                        urlText.startsWith('https://'))) {
                  finalImageUrl = urlText;
                } else if (menu != null &&
                    menu.imageUrl != null &&
                    menu.imageUrl!.isNotEmpty &&
                    urlText.isEmpty) {
                  finalImageUrl = menu.imageUrl;
                } else {
                  finalImageUrl = null;
                }
              }


              if (menu == null) {
                success = await menuController.createMenu(
                  name: nameController.text,
                  description: descriptionController.text.isEmpty
                      ? 'No description'
                      : descriptionController.text,
                  price: price,
                  categoryId: selectedCategoryId!,
                  stock: stock,
                  imageUrl: finalImageUrl,
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
                  imageUrl: finalImageUrl,
                );
              }

              if (success) {
                Get.snackbar(
                  'Success',
                  menu == null
                      ? 'Menu berhasil ditambahkan!'
                      : 'Menu berhasil diperbarui!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );
              } else {
                Get.snackbar(
                  'Error',
                  menu == null
                      ? 'Gagal menambahkan menu. Silakan coba lagi.'
                      : 'Gagal memperbarui menu. Silakan coba lagi.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                  icon: const Icon(Icons.error_outline, color: Colors.white),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalBlueDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              menu == null ? 'Tambah Menu' : 'Perbarui Menu',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
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
        title: const Text('Hapus Menu'),
        content: Text('Apakah Anda yakin ingin menghapus? "${menu.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (menu.id != null) {
                Get.back(); // Close confirmation dialog

                final success = await menuController.deleteMenu(menu.id!);

                if (success) {
                  Get.snackbar(
                    'Sukses',
                    'Menu "${menu.name}" berhasil dihapus!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Gagal menghapus menu. Silakan coba lagi.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                    icon: const Icon(Icons.error_outline, color: Colors.white),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
