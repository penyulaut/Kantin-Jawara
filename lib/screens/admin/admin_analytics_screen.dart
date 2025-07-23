import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  final AdminController controller = Get.find<AdminController>();

  AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchDashboardStats(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Stats
              const Text(
                'Dashboard Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
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
                          onPressed: () => controller.fetchDashboardStats(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final stats = controller.dashboardStats;
                if (stats.isEmpty) {
                  return const Center(child: Text('No statistics available'));
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      title: 'Total Users',
                      value: stats['total_users']?.toString() ?? '0',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      title: 'Total Sellers',
                      value: stats['total_sellers']?.toString() ?? '0',
                      icon: Icons.store,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      title: 'Total Transactions',
                      value: stats['total_transactions']?.toString() ?? '0',
                      icon: Icons.receipt,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      title: 'Total Revenue',
                      value: 'Rp ${stats['total_revenue']?.toString() ?? '0'}',
                      icon: Icons.attach_money,
                      color: Colors.purple,
                    ),
                    _buildStatCard(
                      title: 'Active Menus',
                      value: stats['active_menus']?.toString() ?? '0',
                      icon: Icons.restaurant_menu,
                      color: Colors.red,
                    ),
                    _buildStatCard(
                      title: 'Pending Orders',
                      value: stats['pending_orders']?.toString() ?? '0',
                      icon: Icons.pending,
                      color: Colors.amber,
                    ),
                  ],
                );
              }),

              const SizedBox(height: 32),

              // User Statistics
              const Text(
                'User Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final userStats = controller.getUserCountByRole();
                if (userStats.isEmpty) {
                  return const Text('No user data available');
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: userStats.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Chip(
                                label: Text(entry.value.toString()),
                                backgroundColor: _getRoleColor(entry.key),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Transaction Statistics
              const Text(
                'Transaction Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final transactionStats = controller.getTransactionStatistics();
                if (transactionStats.isEmpty) {
                  return const Text('No transaction data available');
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: transactionStats.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Chip(
                                label: Text(entry.value.toString()),
                                backgroundColor: _getStatusColor(entry.key),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Revenue Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenue Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final totalRevenue = controller.getTotalRevenue();
                        return Text(
                          'Total Revenue: Rp ${totalRevenue.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red[100]!;
      case 'penjual':
        return Colors.green[100]!;
      case 'pembeli':
        return Colors.blue[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[100]!;
      case 'paid':
        return Colors.blue[100]!;
      case 'confirmed':
        return Colors.purple[100]!;
      case 'ready':
        return Colors.amber[100]!;
      case 'completed':
        return Colors.green[100]!;
      case 'cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
