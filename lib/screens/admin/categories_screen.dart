import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';
import '../../utils/app_theme.dart';

class CategoriesScreen extends StatelessWidget {
  final CategoryController controller = Get.find<CategoryController>();
  final TextEditingController nameController = TextEditingController();

  CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.royalBlueDark.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppTheme.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Kelola Kategori',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Atur kategori makanan & minuman',
                          style: TextStyle(
                            color: AppTheme.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppTheme.goldenPoppy,
        foregroundColor: AppTheme.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Kategori',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.royalBlueDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.royalBlueDark,
                      ),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat Kategori...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppTheme.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage,
                    style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchCategories(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalBlueDark,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.mediumGray.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      size: 48,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Kategori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambah kategori pertama',
                    style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchCategories(),
          color: AppTheme.royalBlueDark,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return _buildCategoryCard(context, category);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.lightGray.withOpacity(0.5), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.white, AppTheme.royalBlueDark.withOpacity(0.01)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.goldenPoppy,
                  AppTheme.goldenPoppy.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldenPoppy.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.category_rounded,
              color: AppTheme.white,
              size: 24,
            ),
          ),
          title: Text(
            category.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.darkGray,
            ),
          ),
          subtitle: Text(
            'ID: ${category.id}',
            style: TextStyle(color: AppTheme.mediumGray, fontSize: 12),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditCategoryDialog(context, category);
                    break;
                  case 'delete':
                    _showDeleteConfirmDialog(context, category);
                    break;
                }
              },
              icon: Icon(Icons.more_vert_rounded, color: AppTheme.darkGray),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: AppTheme.royalBlueDark,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: AppTheme.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: TextStyle(
                          color: AppTheme.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.goldenPoppy.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppTheme.goldenPoppy,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Tambah Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nama Kategori',
            hintText: 'Masukkan nama kategori',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.royalBlueDark, width: 2),
            ),
            prefixIcon: Icon(
              Icons.category_rounded,
              color: AppTheme.mediumGray,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () async {
                      if (nameController.text.trim().isNotEmpty) {
                        try {
                          final success = await controller.createCategory(
                            nameController.text.trim(),
                          );

                          // Gunakan Navigator.pop() sebagai alternatif
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          if (success) {
                            Get.snackbar(
                              'Berhasil',
                              'Kategori "${nameController.text.trim()}" berhasil ditambahkan',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.green,
                              colorText: AppTheme.white,
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              icon: Icon(
                                Icons.check_circle,
                                color: AppTheme.white,
                              ),
                            );
                          } else {
                            Get.snackbar(
                              'Gagal',
                              'Gagal menambahkan kategori. Silakan coba lagi.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.red,
                              colorText: AppTheme.white,
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              icon: Icon(Icons.error, color: AppTheme.white),
                            );
                          }
                        } catch (e) {
                          // Handle error
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          Get.snackbar(
                            'Error',
                            'Terjadi kesalahan: $e',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                          );
                        }
                      } else {
                        Get.snackbar(
                          'Peringatan',
                          'Nama kategori tidak boleh kosong',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppTheme.goldenPoppy,
                          colorText: AppTheme.white,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldenPoppy,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: controller.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Tambah',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    nameController.text = category.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.royalBlueDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_rounded,
                color: AppTheme.royalBlueDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Edit Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nama Kategori',
            hintText: 'Masukkan nama kategori',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.royalBlueDark, width: 2),
            ),
            prefixIcon: Icon(
              Icons.category_rounded,
              color: AppTheme.mediumGray,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () async {
                      if (nameController.text.trim().isNotEmpty &&
                          category.id != null) {
                        final success = await controller.updateCategory(
                          category.id!,
                          nameController.text.trim(),
                        );
                        if (success) {
                          Get.back(); // Tutup dialog

                          // Tampilkan snackbar sukses
                          Get.snackbar(
                            'Berhasil',
                            'Kategori "${nameController.text.trim()}" berhasil diperbarui',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.green,
                            colorText: AppTheme.white,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            icon: Icon(
                              Icons.check_circle,
                              color: AppTheme.white,
                            ),
                          );
                        } else {
                          // Jika gagal, tampilkan error tapi jangan tutup dialog
                          Get.snackbar(
                            'Gagal',
                            'Gagal memperbarui kategori. Silakan coba lagi.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            icon: Icon(Icons.error, color: AppTheme.white),
                          );
                        }
                      } else {
                        Get.snackbar(
                          'Peringatan',
                          'Nama kategori tidak boleh kosong',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppTheme.goldenPoppy,
                          colorText: AppTheme.white,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.royalBlueDark,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: controller.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Perbarui',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_rounded, color: AppTheme.red, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Hapus Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkGray,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'Apakah Anda yakin ingin menghapus kategori ',
              ),
              TextSpan(
                text: '"${category.name}"',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.red,
                ),
              ),
              const TextSpan(text: '?\n\nTindakan ini tidak dapat dibatalkan.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: controller.isLoading
                  ? null
                  : () async {
                      if (category.id != null) {
                        final success = await controller.deleteCategory(
                          category.id!,
                        );
                        if (success) {
                          Get.back(); // Tutup dialog

                          // Tampilkan snackbar sukses
                          Get.snackbar(
                            'Berhasil',
                            'Kategori "${category.name}" berhasil dihapus',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.green,
                            colorText: AppTheme.white,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            icon: Icon(
                              Icons.check_circle,
                              color: AppTheme.white,
                            ),
                          );
                        } else {
                          // Jika gagal, tampilkan error tapi jangan tutup dialog
                          Get.snackbar(
                            'Gagal',
                            'Gagal menghapus kategori. Silakan coba lagi.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            icon: Icon(Icons.error, color: AppTheme.white),
                          );
                        }
                      }
                    },
              child: controller.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Hapus',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
