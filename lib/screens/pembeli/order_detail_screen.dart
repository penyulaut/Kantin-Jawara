import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/transaction.dart';
import '../../controllers/chat_controller.dart';
import '../shared/chat_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Transaction transaction;
  final ChatController chatController = Get.put(ChatController());

  OrderDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${transaction.id}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () =>
                Get.to(() => ChatScreen(transactionId: transaction.id!)),
            icon: const Icon(Icons.chat),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusChip(transaction.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildOrderTimeline(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Order ID', '#${transaction.id}'),
                    _buildInfoRow(
                      'Date',
                      transaction.createdAt?.toString().substring(0, 16) ?? '',
                    ),
                    _buildInfoRow(
                      'Order Type',
                      _getOrderTypeDisplay(transaction.orderType),
                    ),
                    if (transaction.customerName != null)
                      _buildInfoRow('Customer', transaction.customerName!),
                    if (transaction.customerPhone != null)
                      _buildInfoRow('Phone', transaction.customerPhone!),
                    if (transaction.notes != null &&
                        transaction.notes!.isNotEmpty)
                      _buildInfoRow('Notes', transaction.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (transaction.items != null) ...[
                      ...transaction.items!.map(
                        (item) => _buildOrderItem(item),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Info
            if (transaction.payment != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Method', transaction.payment!.method),
                      _buildInfoRow(
                        'Amount',
                        'Rp ${transaction.payment!.amount.toStringAsFixed(0)}',
                      ),
                      if (transaction.payment!.paidAt != null)
                        _buildInfoRow(
                          'Paid At',
                          transaction.payment!.paidAt!.toString().substring(
                            0,
                            16,
                          ),
                        ),
                      if (transaction.payment!.proof != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Payment Proof:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              transaction.payment!.proof!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text('Failed to load image'),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final statuses = [
      TransactionStatus.pending,
      TransactionStatus.paid,
      TransactionStatus.confirmed,
      TransactionStatus.ready,
      TransactionStatus.completed,
    ];

    final currentIndex = statuses.indexOf(transaction.status);

    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isActive = index <= currentIndex;
        final isLast = index == statuses.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.blue : Colors.grey[300],
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
              if (!isLast) ...[
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? Colors.blue : Colors.grey[300],
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildOrderItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu?.name ?? 'Unknown Item',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
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
}
