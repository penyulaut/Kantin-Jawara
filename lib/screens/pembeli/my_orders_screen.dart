import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pembeli_controller.dart';
import '../../models/transaction.dart';
import 'order_detail_screen.dart';
import 'payment_selection_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PembeliController controller = Get.put(PembeliController());

    // Ensure data is fetched when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTransactions();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
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
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Your order history will appear here',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTransactions(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              final transaction = controller.transactions[index];
              return _buildOrderCard(context, transaction);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(BuildContext context, Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.to(() => OrderDetailScreen(transaction: transaction)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              // Date and Order Type
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    transaction.createdAt?.toString().substring(0, 16) ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _getOrderTypeDisplay(transaction.orderType),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Items Summary
              if (transaction.items != null &&
                  transaction.items!.isNotEmpty) ...[
                Text(
                  '${transaction.items!.length} item(s)',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
              ],

              // Customer Info
              if (transaction.customerName != null) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      transaction.customerName!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

              // Action Buttons
              if (transaction.status == TransactionStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelOrder(transaction),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _payOrder(transaction),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
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
    String text;

    switch (status) {
      case TransactionStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case TransactionStatus.paid:
        color = Colors.blue;
        text = 'Paid';
        break;
      case TransactionStatus.confirmed:
        color = Colors.purple;
        text = 'Confirmed';
        break;
      case TransactionStatus.ready:
        color = Colors.teal;
        text = 'Ready';
        break;
      case TransactionStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case TransactionStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getOrderTypeDisplay(OrderType orderType) {
    switch (orderType) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
    }
  }

  void _cancelOrder(Transaction transaction) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back();
              if (transaction.id != null) {
                final controller = Get.find<PembeliController>();
                await controller.cancelTransaction(transaction.id!);
              }
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _payOrder(Transaction transaction) {
    // Get merchant_id from transaction items
    int merchantId = 1; // Default fallback
    if (transaction.items != null && transaction.items!.isNotEmpty) {
      final firstItem = transaction.items!.first;
      if (firstItem.menu != null && firstItem.menu!.penjualId != null) {
        merchantId = firstItem.menu!.penjualId!;
      }
    }

    print('MyOrdersScreen: Using merchant_id: $merchantId for payment methods');

    // Navigate to payment selection screen
    Get.to(
      () => PaymentSelectionScreen(
        merchantId: merchantId,
        totalAmount: transaction.totalPrice,
        onPaymentSelected: (paymentMethod, merchantPaymentMethod) {
          // After payment method is selected, show payment instructions or upload proof
          Get.snackbar(
            'Payment Method Selected',
            'Selected ${paymentMethod.name}. Please make the payment and upload proof.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        },
      ),
    );
  }
}
