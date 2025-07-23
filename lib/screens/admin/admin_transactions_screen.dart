import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/transaction.dart';

class AdminTransactionsScreen extends StatelessWidget {
  final AdminController controller = Get.find<AdminController>();

  AdminTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch transactions when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTransactions();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => controller.fetchTransactions(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', TransactionStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Paid', TransactionStatus.paid),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', TransactionStatus.confirmed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ready', TransactionStatus.ready),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', TransactionStatus.completed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', TransactionStatus.cancelled),
                ],
              ),
            ),
          ),

          // Transactions List
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
                        onPressed: () => controller.fetchTransactions(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.transactions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchTransactions(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionStatus? status) {
    return Obx(() {
      final isSelected = status == null
          ? true // "All" is always considered selected for now
          : false; // You can implement selection logic here

      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Implement filter logic here
          if (status == null) {
            // Show all transactions
            controller.fetchTransactions();
          } else {
            // Filter by status - you can implement this in the controller
            // For now, just fetch all
            controller.fetchTransactions();
          }
        },
      );
    });
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${transaction.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(transaction.status),
                ],
              ),
              const SizedBox(height: 8),

              // Customer Info
              if (transaction.customerName != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      transaction.customerName!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Seller Info
              if (transaction.penjual != null) ...[
                Row(
                  children: [
                    const Icon(Icons.store, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Seller: ${transaction.penjual!.name}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Order Type & Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        transaction.orderType == OrderType.dineIn
                            ? Icons.restaurant
                            : transaction.orderType == OrderType.takeaway
                            ? Icons.takeout_dining
                            : Icons.delivery_dining,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        transaction.orderType
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Text(
                    'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              // Date
              if (transaction.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Created: ${_formatDate(transaction.createdAt!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    Color color;
    switch (status) {
      case TransactionStatus.pending:
        color = Colors.orange;
        break;
      case TransactionStatus.paid:
        color = Colors.blue;
        break;
      case TransactionStatus.confirmed:
        color = Colors.purple;
        break;
      case TransactionStatus.ready:
        color = Colors.amber;
        break;
      case TransactionStatus.completed:
        color = Colors.green;
        break;
      case TransactionStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.toString().split('.').last.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showTransactionDetails(Transaction transaction) {
    Get.dialog(
      AlertDialog(
        title: Text('Transaction #${transaction.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (transaction.customerName != null) ...[
                Text('Customer: ${transaction.customerName}'),
                const SizedBox(height: 8),
              ],
              if (transaction.customerPhone != null) ...[
                Text('Phone: ${transaction.customerPhone}'),
                const SizedBox(height: 8),
              ],
              if (transaction.penjual != null) ...[
                Text('Seller: ${transaction.penjual!.name}'),
                const SizedBox(height: 8),
              ],
              Text(
                'Order Type: ${transaction.orderType.toString().split('.').last}',
              ),
              const SizedBox(height: 8),
              Text('Status: ${transaction.status.toString().split('.').last}'),
              const SizedBox(height: 8),
              Text('Total: Rp ${transaction.totalPrice.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              if (transaction.notes != null &&
                  transaction.notes!.isNotEmpty) ...[
                Text('Notes: ${transaction.notes}'),
                const SizedBox(height: 8),
              ],
              if (transaction.createdAt != null) ...[
                Text('Created: ${_formatDate(transaction.createdAt!)}'),
              ],
              if (transaction.items != null &&
                  transaction.items!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...transaction.items!.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${item.menu?.name ?? 'Unknown'} x${item.quantity} - Rp ${item.price.toStringAsFixed(0)}',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
