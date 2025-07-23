import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/penjual_controller.dart';
import '../../models/transaction.dart';
import '../shared/chat_screen.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PenjualController controller = Get.find<PenjualController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null, controller),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    TransactionStatus.pending,
                    controller,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Accepted',
                    TransactionStatus.paid,
                    controller,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'In Progress',
                    TransactionStatus.confirmed,
                    controller,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Ready',
                    TransactionStatus.ready,
                    controller,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Completed',
                    TransactionStatus.completed,
                    controller,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Cancelled',
                    TransactionStatus.cancelled,
                    controller,
                  ),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchTransactions(),
              child: Obx(() {
                final filteredOrders = controller.getFilteredTransactions();

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order, controller);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    TransactionStatus? status,
    PenjualController controller,
  ) {
    return Obx(
      () => FilterChip(
        label: Text(label),
        selected: controller.selectedStatus.value == status,
        onSelected: (selected) {
          controller.setStatusFilter(selected ? status : null);
        },
        selectedColor: Colors.green.withOpacity(0.2),
        checkmarkColor: Colors.green,
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, PenjualController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showOrderDetails(order, controller),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(order.status)),
                    ),
                    child: Text(
                      order.status.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Customer Info
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Customer: ${order.userId}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Order Time
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    order.createdAt.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Order Items
              if (order.items != null && order.items.isNotEmpty) ...[
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                ...order.items
                    .map<Widget>(
                      (item) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 2),
                        child: Text(
                          '• ${item.quantity}x ${item.menu?.name ?? 'Unknown Menu'} - Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 8),
              ],

              // Total and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: Rp ${order.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to view details',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            Get.to(() => ChatScreen(transactionId: order.id)),
                        icon: const Icon(
                          Icons.chat_outlined,
                          color: Colors.blue,
                        ),
                        tooltip: 'Chat with customer',
                      ),
                      _buildActionButtons(order, controller),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showOrderDetails(dynamic order, PenjualController controller) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Customer Info
          Text(
            'Customer Details',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Name: ${order.customerName ?? 'N/A'}'),
          Text('Phone: ${order.customerPhone ?? 'N/A'}'),
          Text('Order Type: ${order.orderType.toString().split('.').last}'),
          const SizedBox(height: 16),

          // Notes
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            Text(
              'Notes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(order.notes!),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.to(() => ChatScreen(transactionId: order.id));
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildActionButtons(dynamic order, PenjualController controller) {
  switch (order.status) {
    case TransactionStatus.pending:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _showRejectDialog(order, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(60, 32),
            ),
            child: const Text('Reject', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.updateTransactionStatus(
              transactionId: order.id,
              status: TransactionStatus.paid,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(60, 32),
            ),
            child: const Text('Accept', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    case TransactionStatus.paid:
      return ElevatedButton(
        onPressed: () => controller.updateTransactionStatus(
          transactionId: order.id,
          status: TransactionStatus.confirmed,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(80, 32),
        ),
        child: const Text('Start Cooking', style: TextStyle(fontSize: 12)),
      );
    case TransactionStatus.confirmed:
      return ElevatedButton(
        onPressed: () => controller.updateTransactionStatus(
          transactionId: order.id,
          status: TransactionStatus.ready,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(80, 32),
        ),
        child: const Text('Mark Ready', style: TextStyle(fontSize: 12)),
      );
    case TransactionStatus.ready:
      return ElevatedButton(
        onPressed: () => controller.updateTransactionStatus(
          transactionId: order.id,
          status: TransactionStatus.completed,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          minimumSize: const Size(80, 32),
        ),
        child: const Text('Complete', style: TextStyle(fontSize: 12)),
      );
    default:
      return const SizedBox.shrink();
  }
}

Color _getStatusColor(TransactionStatus status) {
  switch (status) {
    case TransactionStatus.pending:
      return Colors.orange;
    case TransactionStatus.paid:
      return Colors.blue;
    case TransactionStatus.confirmed:
      return Colors.purple;
    case TransactionStatus.ready:
      return Colors.green;
    case TransactionStatus.completed:
      return Colors.grey;
    case TransactionStatus.cancelled:
      return Colors.red;
  }
}

void _showRejectDialog(dynamic order, PenjualController controller) {
  Get.dialog(
    AlertDialog(
      title: const Text('Reject Order'),
      content: const Text('Are you sure you want to reject this order?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.updateTransactionStatus(
              transactionId: order.id,
              status: TransactionStatus.cancelled,
            );
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Reject', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
