import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final AdminController controller = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUsers();
    });
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'pembeli':
        return 'Pembeli';
      case 'penjual':
        return 'Penjual';
      default:
        return role;
    }
  }

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
                          'Kelola Pengguna',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola pengguna dan penjual',
                          style: TextStyle(
                            color: AppTheme.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await controller.fetchUsers();
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchUsers();
        },
        color: AppTheme.royalBlueDark,
        backgroundColor: AppTheme.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.usafaBlue.withOpacity(0.1),
                    AppTheme.royalBlueDark.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.royalBlueDark.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.royalBlueDark.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.royalBlueDark.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.people_rounded,
                                color: AppTheme.royalBlueDark,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${controller.users.length}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.royalBlueDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Pengguna',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.mediumGray,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.goldenPoppy.withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.goldenPoppy.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.goldenPoppy.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.store_rounded,
                                color: AppTheme.goldenPoppy,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${controller.users.where((user) => user.role?.toLowerCase() == 'penjual').length}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.goldenPoppy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Penjual',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.mediumGray,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            Expanded(
              child: Obx(() {
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
                            'Memuat Data Pengguna...',
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
                          Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(
                              controller.errorMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.mediumGray,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await controller.fetchUsers();
                            },
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

                if (controller.users.isEmpty) {
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
                              Icons.people_outline_rounded,
                              size: 48,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak Ada Pengguna',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada pengguna yang terdaftar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.royalBlueDark.withOpacity(0.08),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: AppTheme.royalBlueDark.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: user.role?.toLowerCase() == 'penjual'
                                  ? [
                                      AppTheme.goldenPoppy,
                                      AppTheme.goldenPoppy.withOpacity(0.7),
                                    ]
                                  : [
                                      AppTheme.royalBlueDark,
                                      AppTheme.usafaBlue,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            user.role?.toLowerCase() == 'penjual'
                                ? Icons.store_rounded
                                : Icons.person_rounded,
                            color: AppTheme.white,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          user.name.isEmpty ? 'Tanpa Nama' : user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              user.email.isEmpty ? 'Tanpa Email' : user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: user.role?.toLowerCase() == 'penjual'
                                    ? AppTheme.goldenPoppy.withOpacity(0.1)
                                    : AppTheme.royalBlueDark.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: user.role?.toLowerCase() == 'penjual'
                                      ? AppTheme.goldenPoppy.withOpacity(0.3)
                                      : AppTheme.royalBlueDark.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getRoleDisplayName(user.role ?? 'pembeli'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: user.role?.toLowerCase() == 'penjual'
                                      ? AppTheme.goldenPoppy
                                      : AppTheme.royalBlueDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: AppTheme.mediumGray,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditUserDialog(user);
                            } else if (value == 'password') {
                              _showChangePasswordDialog(user);
                            } else if (value == 'toggle_status') {
                              _toggleUserStatus(user);
                            } else if (value == 'delete') {
                              _showDeleteConfirmDialog(user);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    color: AppTheme.royalBlueDark,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Edit Pengguna'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'password',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock_rounded,
                                    color: AppTheme.goldenPoppy,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Ubah Password'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle_status',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.toggle_on_rounded,
                                    color: AppTheme.usafaBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Toggle Status'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    color: AppTheme.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(color: AppTheme.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.role ?? 'pembeli';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.royalBlueDark.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.royalBlueDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: AppTheme.royalBlueDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Edit Pengguna',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded, color: AppTheme.mediumGray),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle: TextStyle(color: AppTheme.mediumGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.royalBlueDark,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppTheme.mediumGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.royalBlueDark,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(color: AppTheme.mediumGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.royalBlueDark,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.admin_panel_settings_outlined,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'pembeli',
                        child: Text('Pembeli'),
                      ),
                      DropdownMenuItem(
                        value: 'penjual',
                        child: Text('Penjual'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrator'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.mediumGray),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            emailController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Nama dan email tidak boleh kosong',
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            snackPosition: SnackPosition.TOP,
                          );
                          return;
                        }

                        Get.back();
                        final success = await controller.updateUser(
                          userId: user.id!,
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          role: selectedRole,
                        );

                        if (success) {
                          Get.snackbar(
                            'Berhasil',
                            'Pengguna berhasil diperbarui',
                            backgroundColor: AppTheme.green,
                            colorText: AppTheme.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Gagal',
                            controller.errorMessage.isNotEmpty
                                ? controller.errorMessage
                                : 'Gagal memperbarui pengguna',
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.royalBlueDark,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(User user) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.red.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: AppTheme.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Hapus Pengguna?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus pengguna ${user.name}? Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.mediumGray),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final success = await controller.deleteUser(user.id!);
                        if (success) {
                          Get.snackbar(
                            'Berhasil',
                            'Pengguna berhasil dihapus',
                            backgroundColor: AppTheme.green,
                            colorText: AppTheme.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Gagal',
                            controller.errorMessage.isNotEmpty
                                ? controller.errorMessage
                                : 'Gagal menghapus pengguna',
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.red,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(User user) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ubah Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pengguna: ${user.name}',
                  style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock, color: AppTheme.royalBlueDark),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppTheme.mediumGray,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.royalBlueDark,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppTheme.mediumGray,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.mediumGray),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (passwordController.text.trim().isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Password tidak boleh kosong',
                              backgroundColor: AppTheme.red,
                              colorText: AppTheme.white,
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            Get.snackbar(
                              'Error',
                              'Password tidak cocok',
                              backgroundColor: AppTheme.red,
                              colorText: AppTheme.white,
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          if (passwordController.text.length < 6) {
                            Get.snackbar(
                              'Error',
                              'Password minimal 6 karakter',
                              backgroundColor: AppTheme.red,
                              colorText: AppTheme.white,
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          Get.back();
                          final success = await controller.changeUserPassword(
                            userId: user.id!,
                            newPassword: passwordController.text.trim(),
                          );

                          if (success) {
                            Get.snackbar(
                              'Berhasil',
                              'Password berhasil diubah',
                              backgroundColor: AppTheme.green,
                              colorText: AppTheme.white,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            Get.snackbar(
                              'Gagal',
                              controller.errorMessage.isNotEmpty
                                  ? controller.errorMessage
                                  : 'Gagal mengubah password',
                              backgroundColor: AppTheme.red,
                              colorText: AppTheme.white,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldenPoppy,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ubah Password',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleUserStatus(User user) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.usafaBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.toggle_on_rounded,
                  size: 48,
                  color: AppTheme.usafaBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Toggle Status Pengguna',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin mengubah status aktif pengguna ${user.name}?',
                style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.mediumGray),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final success = await controller.toggleUserStatus(
                          user.id!,
                        );
                        if (success) {
                          Get.snackbar(
                            'Berhasil',
                            'Status pengguna berhasil diubah',
                            backgroundColor: AppTheme.green,
                            colorText: AppTheme.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Gagal',
                            controller.errorMessage.isNotEmpty
                                ? controller.errorMessage
                                : 'Gagal mengubah status pengguna',
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.usafaBlue,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Ubah Status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
