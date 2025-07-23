import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/user.dart';

class UsersScreen extends StatelessWidget {
  final AdminController controller = Get.find<AdminController>();

  UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch users when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUsers();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => controller.fetchUsers(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Obx(() {
            final userStats = controller.getUserCountByRole();
            if (userStats.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: userStats.entries.map((entry) {
                    return Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Users List
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${controller.errorMessage}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.fetchUsers(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.users.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchUsers(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    return _buildUserCard(user);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showUserDetails(user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: _getRoleColor(user.role ?? 'unknown'),
                child: Icon(
                  _getRoleIcon(user.role ?? 'unknown'),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role ?? 'unknown'),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (user.role ?? 'unknown').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
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

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'penjual':
        return Icons.store;
      case 'pembeli':
        return Icons.person;
      default:
        return Icons.help;
    }
  }

  void _showUserDetails(User user) {
    Get.dialog(
      AlertDialog(
        title: Text('User Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Name', user.name),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Role', (user.role ?? 'unknown').toUpperCase()),
            _buildDetailRow('User ID', user.id?.toString() ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showUserActions(user);
            },
            child: const Text('Actions'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showUserActions(User user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions for ${user.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('View Details'),
              onTap: () {
                Get.back();
                _getUserDetails(user.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              onTap: () {
                Get.back();
                _showComingSoon();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Suspend User'),
              onTap: () {
                Get.back();
                _showComingSoon();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete User'),
              onTap: () {
                Get.back();
                _showComingSoon();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _getUserDetails(int userId) async {
    final userDetails = await controller.getUserDetails(userId);
    if (userDetails != null) {
      _showUserDetails(userDetails);
    }
  }

  void _showComingSoon() {
    Get.snackbar(
      'Coming Soon',
      'This feature will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
