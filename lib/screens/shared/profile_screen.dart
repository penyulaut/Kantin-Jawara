import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: AppTheme.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Obx(() {
        final user = authController.currentUser;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.royalBlueDark.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.darkGray.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.goldenPoppy.withOpacity(
                            0.2,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.royalBlueDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.goldenPoppy,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.goldenPoppy.withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _getRoleDisplay(user.role),
                          style: const TextStyle(
                            color: AppTheme.royalBlueDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildMenuItem(
                icon: Icons.edit,
                title: 'Edit Profile',
                subtitle: 'Perbarui informasi pribadi Anda',
                onTap: () => _showEditProfileDialog(),
              ),
              _buildMenuItem(
                icon: Icons.lock,
                title: 'Ubah Password',
                subtitle: 'Update password',
                onTap: () => _showChangePasswordDialog(),
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Bantuan & Dukungan',
                subtitle: 'Dapatkan bantuan dan hubungi dukungan',
                onTap: () => _showSupportDialog(),
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'Tentang',
                subtitle: 'Versi Aplikasi dan Informasi',
                onTap: () => _showAppInfoDialog(),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteAccountDialog(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.red,
                          side: const BorderSide(
                            color: AppTheme.red,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text(
                          'Hapus Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.royalBlueDark,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.royalBlueDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.royalBlueDark, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.darkGray,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppTheme.mediumGray, fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chevron_right,
            color: AppTheme.mediumGray,
            size: 20,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  String _getRoleDisplay(String? role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'penjual':
        return 'Seller';
      case 'pembeli':
        return 'Customer';
      default:
        return 'User';
    }
  }

  void _showAppInfoDialog() async {
    try {

      PackageInfo packageInfo = await PackageInfo.fromPlatform();


      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlueDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppTheme.royalBlueDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tentang Aplikasi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.royalBlueDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: AppTheme.royalBlueDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildInfoItem('Nama Aplikasi', packageInfo.appName),
                _buildInfoItem('Versi', packageInfo.version),
                _buildInfoItem('Build Number', packageInfo.buildNumber),
                _buildInfoItem('Package Name', packageInfo.packageName),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                const Text(
                  'Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aplikasi manajemen kantin yang memudahkan proses pemesanan, pembayaran, dan pengelolaan menu.',
                  style: TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Dikembangkan dengan ❤️ menggunakan Flutter',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.royalBlueDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } catch (e) {

      Get.dialog(
        AlertDialog(
          title: const Text('Tentang Aplikasi'),
          content: const Text('Aplikasi Kantin Jawara'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Tutup')),
          ],
        ),
      );
    }
  }

  void _showSupportDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.help_outline, color: AppTheme.green, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Bantuan & Dukungan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Butuh bantuan? Hubungi kami melalui:',
                style: TextStyle(fontSize: 16, color: AppTheme.mediumGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              _buildSupportOption(
                icon: Icons.chat,
                title: 'WhatsApp',
                subtitle: 'Chat langsung dengan tim support',
                color: const Color(0xFF25D366),
                onTap: () => _launchWhatsApp(),
              ),

              const SizedBox(height: 12),

              _buildSupportOption(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'Kirim email ke tim support',
                color: AppTheme.royalBlueDark,
                onTap: () => _launchEmail(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.mediumGray,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppTheme.mediumGray, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppTheme.mediumGray, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp() async {
    const phoneNumber = "+6281212571925";
    const message = "Halo, saya butuh bantuan dengan aplikasi.";

    final whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        Get.back();
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka WhatsApp. Pastikan WhatsApp sudah terinstall.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _launchEmail() async {
    const emailAddress = "3337230039@untirta.ac.id";
    const subject = "Bantuan Aplikasi";
    const body = "Halo tim support, saya butuh bantuan dengan aplikasi.";

    final emailUrl =
        "mailto:$emailAddress?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}";

    try {
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
        Get.back();
      } else {
        throw 'Could not launch email';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka aplikasi email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showEditProfileDialog() {
    final AuthController authController = Get.find<AuthController>();
    final user = authController.currentUser;

    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(
            () => ElevatedButton(
              onPressed: authController.isLoading
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty) {
                        Get.snackbar('Error', 'Please fill all fields');
                        return;
                      }

                      final success = await authController.updateProfile(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                      );

                      if (success) {
                        Get.back();
                        Get.snackbar(
                          'Sukses',
                          'Profil berhasil diperbarui',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
              child: authController.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final AuthController authController = Get.find<AuthController>();

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(
            () => ElevatedButton(
              onPressed: authController.isLoading
                  ? null
                  : () async {
                      if (currentPasswordController.text.isEmpty ||
                          newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        Get.snackbar('Error', 'Please fill all fields');
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        Get.snackbar('Error', 'New passwords do not match');
                        return;
                      }

                      if (newPasswordController.text.length < 6) {
                        Get.snackbar(
                          'Error',
                          'New password must be at least 6 characters',
                        );
                        return;
                      }

                      final success = await authController.changePassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                        confirmPassword: confirmPasswordController.text,
                      );

                      if (success) {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Password changed successfully. Please login again with your new password.',
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        );

                        Future.delayed(const Duration(seconds: 2), () {
                          authController.logout();
                        });
                      }
                    },
              child: authController.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final AuthController authController = Get.find<AuthController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Apakah Anda yakin ingin menghapus akun Anda?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus secara permanen.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(
            () => ElevatedButton(
              onPressed: authController.isLoading
                  ? null
                  : () async {
                      final TextEditingController confirmController =
                          TextEditingController();

                      final confirmed =
                          await Get.dialog<bool>(
                            AlertDialog(
                              title: const Text('Konfirmasi Akhir'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Ketik "DELETE" untuk mengonfirmasi penghapusan akun:',
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: confirmController,
                                    decoration: const InputDecoration(
                                      hintText: 'Ketik DELETE disini',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (confirmController.text.toUpperCase() ==
                                        'DELETE') {
                                      Get.back(result: true);
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Please type "DELETE" to confirm',
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (confirmed) {
                        Get.back();
                        final success = await authController.deleteAccount();

                        if (success) {
                          Get.snackbar(
                            'Account Deleted',
                            'Your account has been successfully deleted',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: authController.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              final authController = Get.find<AuthController>();
              authController.logout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
