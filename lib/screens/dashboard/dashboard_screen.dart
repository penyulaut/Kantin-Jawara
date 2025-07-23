import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context, authController);
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser;
        if (user == null) {
          return const Center(child: Text('No user data'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user.name}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email: ${user.email}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getRoleDisplayName(user.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Features based on role
              const Text(
                'Available Features:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: _getFeatureCards(user.role),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Logout'),
            onPressed: () {
              Get.back();
              authController.logout();
              Get.offAllNamed('/login'); // This will need route setup
            },
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.orange;
      case 'buyer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'seller':
        return 'Seller';
      case 'buyer':
        return 'Buyer';
      default:
        return 'Unknown';
    }
  }

  List<Widget> _getFeatureCards(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return [
          _buildFeatureCard('Manage Users', Icons.people, () {
            Get.snackbar('Info', 'Manage Users feature coming soon!');
          }),
          _buildFeatureCard('Manage Kantins', Icons.store, () {
            Get.snackbar('Info', 'Manage Kantins feature coming soon!');
          }),
          _buildFeatureCard('View Reports', Icons.analytics, () {
            Get.snackbar('Info', 'Reports feature coming soon!');
          }),
          _buildFeatureCard('Settings', Icons.settings, () {
            Get.snackbar('Info', 'Settings feature coming soon!');
          }),
        ];
      case 'seller':
        return [
          _buildFeatureCard('Manage Products', Icons.inventory, () {
            Get.snackbar('Info', 'Manage Products feature coming soon!');
          }),
          _buildFeatureCard('View Orders', Icons.shopping_cart, () {
            Get.snackbar('Info', 'Orders feature coming soon!');
          }),
          _buildFeatureCard('Sales Report', Icons.bar_chart, () {
            Get.snackbar('Info', 'Sales Report feature coming soon!');
          }),
          _buildFeatureCard('Profile', Icons.person, () {
            Get.snackbar('Info', 'Profile feature coming soon!');
          }),
        ];
      case 'buyer':
      default:
        return [
          _buildFeatureCard('Browse Kantins', Icons.restaurant, () {
            Get.snackbar('Info', 'Browse Kantins feature coming soon!');
          }),
          _buildFeatureCard('My Orders', Icons.receipt, () {
            Get.snackbar('Info', 'My Orders feature coming soon!');
          }),
          _buildFeatureCard('Favorites', Icons.favorite, () {
            Get.snackbar('Info', 'Favorites feature coming soon!');
          }),
          _buildFeatureCard('Profile', Icons.person, () {
            Get.snackbar('Info', 'Profile feature coming soon!');
          }),
        ];
    }
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
