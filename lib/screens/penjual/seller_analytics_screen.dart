import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/penjual_controller.dart';
import '../../utils/app_theme.dart';

class SellerAnalyticsScreen extends StatelessWidget {
  const SellerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PenjualController controller = Get.find<PenjualController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analytics'),
        backgroundColor: AppTheme.green,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchTransactions(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(
                () => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildSummaryCard(
                      title: 'Total Sales',
                      value:
                          'Rp ${controller.getTotalSales().toStringAsFixed(0)}',
                      icon: Icons.monetization_on,
                      color: AppTheme.goldenPoppy,
                    ),
                    _buildSummaryCard(
                      title: 'Total Orders',
                      value: controller.getTotalOrders().toString(),
                      icon: Icons.shopping_bag,
                      color: AppTheme.royalBlueDark,
                    ),
                    _buildSummaryCard(
                      title: 'Transaksi Hari Ini',
                      value:
                          'Rp ${controller.getTodaysSales().toStringAsFixed(0)}',
                      icon: Icons.today,
                      color: AppTheme.goldenPoppy,
                    ),
                    _buildSummaryCard(
                      title: 'Completed Orders',
                      value: controller.getTotalCompletedOrders().toString(),
                      icon: Icons.check_circle,
                      color: AppTheme.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Orders by Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final ordersByStatus = controller.getOrdersByStatus();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: ordersByStatus.entries
                          .map(
                            (entry) => _buildStatusRow(entry.key, entry.value),
                          )
                          .toList(),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaksi Hari Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Obx(
                    () => Text(
                      '${controller.getTodaysTransactions().length} orders',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                final todayTransactions = controller.getTodaysTransactions();

                if (todayTransactions.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No transactions today',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: todayTransactions
                      .map((transaction) => _buildTransactionCard(transaction))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
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
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String status, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            status.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStatusColor(status)),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: _getStatusColor(status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.green.withOpacity(0.1),
          child: Icon(Icons.shopping_bag, color: AppTheme.green),
        ),
        title: Text('Order #${transaction.id}'),
        subtitle: Text('Rp ${transaction.totalPrice.toStringAsFixed(0)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(
              transaction.status.toString().split('.').last,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(
                transaction.status.toString().split('.').last,
              ),
            ),
          ),
          child: Text(
            transaction.status.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(
                transaction.status.toString().split('.').last,
              ),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return AppTheme.getTransactionStatusColor(status);
  }
}
