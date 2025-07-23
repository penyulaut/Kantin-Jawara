import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue[100],
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _getRoleColor(user.role)),
                        ),
                        child: Text(
                          _getRoleDisplay(user.role),
                          style: TextStyle(
                            color: _getRoleColor(user.role),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Menu Items
              _buildMenuItem(
                icon: Icons.edit,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () => _showEditProfileDialog(),
              ),
              _buildMenuItem(
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () => _showChangePasswordDialog(),
              ),
              _buildMenuItem(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () => _showComingSoon(),
              ),
              const SizedBox(height: 24),

              // Delete Account Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showDeleteAccountDialog(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Icon(icon, color: Colors.grey[700]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'penjual':
        return Colors.green;
      case 'pembeli':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplay(String? role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'penjual':
        return 'Seller';
      case 'pembeli':
        return 'Buyer';
      default:
        return 'User';
    }
  }

  void _showComingSoon() {
    Get.snackbar(
      'Coming Soon',
      'This feature will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
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

                        // Show success message and auto logout
                        Get.snackbar(
                          'Success',
                          'Password changed successfully. Please login again with your new password.',
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );

                        // Auto logout after 2 seconds
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
              'Are you sure you want to delete your account?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone. All your data will be permanently deleted.',
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
                      // Show confirmation dialog
                      final TextEditingController confirmController =
                          TextEditingController();

                      final confirmed =
                          await Get.dialog<bool>(
                            AlertDialog(
                              title: const Text('Final Confirmation'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Type "DELETE" to confirm account deletion:',
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: confirmController,
                                    decoration: const InputDecoration(
                                      hintText: 'Type DELETE here',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text('Cancel'),
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
                        Get.back(); // Close delete dialog
                        final success = await authController.deleteAccount();

                        if (success) {
                          // Account deleted, user will be redirected to login
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              final authController = Get.find<AuthController>();
              authController.logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
