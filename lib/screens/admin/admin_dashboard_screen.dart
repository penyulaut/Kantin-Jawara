import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/payment_controller.dart';
import 'categories_screen.dart';
import 'payment_methods_screen.dart';
import 'users_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_transactions_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final AdminController adminController = Get.put(AdminController());
  final CategoryController categoryController = Get.put(CategoryController());
  final PaymentController paymentController = Get.put(PaymentController());

  AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authController.logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => adminController.fetchDashboardStats(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Stats Summary
                Obx(() {
                  if (adminController.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final stats = adminController.dashboardStats;
                  if (stats.isNotEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Stats',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuickStat(
                                  'Users',
                                  stats['total_users']?.toString() ?? '0',
                                  Icons.people,
                                  Colors.blue,
                                ),
                                _buildQuickStat(
                                  'Orders',
                                  stats['total_transactions']?.toString() ??
                                      '0',
                                  Icons.receipt,
                                  Colors.orange,
                                ),
                                _buildQuickStat(
                                  'Revenue',
                                  'Rp ${stats['total_revenue']?.toString() ?? '0'}',
                                  Icons.attach_money,
                                  Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 16),

                // Main Menu Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      icon: Icons.category,
                      title: 'Categories',
                      subtitle: 'Manage food categories',
                      color: Colors.blue,
                      onTap: () => Get.to(() => CategoriesScreen()),
                    ),
                    _buildDashboardCard(
                      icon: Icons.payment,
                      title: 'Payment Methods',
                      subtitle: 'Manage payment options',
                      color: Colors.green,
                      onTap: () => Get.to(() => PaymentMethodsScreen()),
                    ),
                    _buildDashboardCard(
                      icon: Icons.people,
                      title: 'Users',
                      subtitle: 'Manage users & sellers',
                      color: Colors.orange,
                      onTap: () => Get.to(() => UsersScreen()),
                    ),
                    _buildDashboardCard(
                      icon: Icons.receipt_long,
                      title: 'Transactions',
                      subtitle: 'View all transactions',
                      color: Colors.indigo,
                      onTap: () => Get.to(() => AdminTransactionsScreen()),
                    ),
                    _buildDashboardCard(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      subtitle: 'View detailed analytics',
                      color: Colors.purple,
                      onTap: () => Get.to(() => AdminAnalyticsScreen()),
                    ),
                    _buildDashboardCard(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App configuration',
                      color: Colors.grey,
                      onTap: () => _showComingSoon(),
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

  Widget _buildQuickStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon() {
    Get.snackbar(
      'Coming Soon',
      'This feature will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
