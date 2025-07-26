import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/penjual_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with AutomaticKeepAliveClientMixin {
  late final PenjualController controller;
  late final ChatController chatController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PenjualController>();
    chatController = Get.find<ChatController>();

    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      controller.fetchTransactions(),
      chatController.fetchChatList(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: AppTheme.white,
        automaticallyImplyLeading: false,
        elevation: 2,
        shadowColor: AppTheme.royalBlueDark.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.lightGray, AppTheme.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Filter Tabs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mediumGray.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                onRefresh: _refreshData,
                color: AppTheme.royalBlueDark,
                backgroundColor: Colors.white,
                child: Obx(() {
                  // Show loading state
                  if (controller.isLoading && controller.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.royalBlueDark,
                            ),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat pesanan...',
                            style: TextStyle(
                              color: AppTheme.mediumGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show error state
                  if (controller.errorMessage.isNotEmpty &&
                      controller.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.royalBlueDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              controller.errorMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.mediumGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () async {
                              await _refreshData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.royalBlueDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredOrders = controller.getFilteredTransactions();

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: AppTheme.mediumGray,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            controller.selectedStatus.value == null
                                ? 'Belum ada pesanan'
                                : 'No ${controller.selectedStatus.value.toString().split('.').last} orders',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.royalBlueDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.selectedStatus.value == null
                                ? 'Pesanan Anda akan muncul di sini'
                                : 'Coba ganti filter atau periksa lagi nanti',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.mediumGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (controller.selectedStatus.value != null) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => controller.setStatusFilter(null),
                              child: Text(
                                'Tampilkan Semua Pesanan',
                                style: TextStyle(
                                  color: AppTheme.royalBlueDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order, controller, chatController);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
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
        selectedColor: AppTheme.royalBlueDark.withOpacity(0.2),
        checkmarkColor: AppTheme.royalBlueDark,
        labelStyle: TextStyle(
          color: controller.selectedStatus.value == status
              ? AppTheme.royalBlueDark
              : AppTheme.mediumGray,
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    dynamic order,
    PenjualController controller,
    ChatController chatController,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: AppTheme.royalBlueDark.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(order, controller),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [AppTheme.white, AppTheme.lightGray.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Enhanced unread chat badge
                          Obx(() {
                            final unreadCount = chatController
                                .getUnreadCountForTransaction(order.id ?? 0);
                            if (unreadCount > 0) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.goldenPoppy,
                                      Colors.orange.shade600,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.goldenPoppy.withOpacity(
                                        0.3,
                                      ),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
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
                        border: Border.all(
                          color: _getStatusColor(order.status),
                        ),
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
                    Icon(Icons.person, size: 16, color: AppTheme.mediumGray),
                    const SizedBox(width: 4),
                    Text(
                      'Customer: ${order.customerName ?? order.userId?.toString() ?? 'Unknown'}',
                      style: TextStyle(color: AppTheme.mediumGray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Order Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.createdAt != null
                          ? _formatDate(order.createdAt!)
                          : 'Unknown time',
                      style: TextStyle(color: AppTheme.mediumGray),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Order Items
                if (order.items != null && order.items!.isNotEmpty) ...[
                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  ...order.items!
                      .map<Widget>(
                        (item) => Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 2),
                          child: Text(
                            '• ${item.quantity ?? 1}x ${item.menu?.name ?? 'Unknown Menu'} - Rp ${((item.unitPrice ?? 0) * (item.quantity ?? 1)).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 8),
                ],

                // Payment Proof Display
                if (order.payment?.proof != null &&
                    order.payment!.proof!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 16,
                        color: AppTheme.usafaBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Payment Proof:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.usafaBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showPaymentProofDialog(order.payment!.proof!),
                    child: Container(
                      height: 80,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.usafaBlue),
                        color: AppTheme.lightGray,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          order.payment!.proof!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.lightGray,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 24,
                                    color: AppTheme.mediumGray,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Failed to load',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.mediumGray,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppTheme.lightGray,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    color: AppTheme.usafaBlue,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
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
                          'Total: Rp ${(order.totalPrice ?? 0).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldenPoppy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view details',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Enhanced chat button
                        Obx(() {
                          final unreadCount = chatController
                              .getUnreadCountForTransaction(order.id ?? 0);
                          return Container(
                            decoration: BoxDecoration(
                              color: unreadCount > 0
                                  ? AppTheme.goldenPoppy.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: unreadCount > 0
                                  ? Border.all(
                                      color: AppTheme.goldenPoppy.withOpacity(
                                        0.3,
                                      ),
                                    )
                                  : null,
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Navigate to chat and mark as read
                                Get.toNamed(
                                  '/chat',
                                  arguments: {'transactionId': order.id},
                                );
                                // Refresh chat list to update unread count
                                chatController.fetchChatList();
                              },
                              icon: Badge(
                                isLabelVisible: unreadCount > 0,
                                label: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: AppTheme.red,
                                textColor: Colors.white,
                                child: Icon(
                                  unreadCount > 0
                                      ? Icons.chat
                                      : Icons.chat_outlined,
                                  color: unreadCount > 0
                                      ? AppTheme.goldenPoppy
                                      : AppTheme.royalBlueDark,
                                  size: 22,
                                ),
                              ),
                              tooltip: unreadCount > 0
                                  ? 'Chat ($unreadCount unread messages)'
                                  : 'Chat with customer',
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        _buildActionButtons(order, controller),
                      ],
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

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

void _showOrderDetails(dynamic order, PenjualController controller) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    Get.toNamed(
                      '/chat',
                      arguments: {'transactionId': order.id},
                    );
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
                    backgroundColor: AppTheme.royalBlueDark,
                  ),
                  child: Text('Close', style: TextStyle(color: AppTheme.white)),
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
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.white,
              minimumSize: const Size(60, 32),
            ),
            child: const Text('Tolak', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.updateTransactionStatus(
              transactionId: order.id,
              status: TransactionStatus.paid,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalBlueDark,
              foregroundColor: AppTheme.white,
              minimumSize: const Size(60, 32),
            ),
            child: const Text('Setujui', style: TextStyle(fontSize: 12)),
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
          backgroundColor: AppTheme.goldenPoppy,
          foregroundColor: AppTheme.royalBlueDark,
          minimumSize: const Size(80, 32),
        ),
        child: const Text('Mulai Memasak', style: TextStyle(fontSize: 12)),
      );
    case TransactionStatus.confirmed:
      return ElevatedButton(
        onPressed: () => controller.updateTransactionStatus(
          transactionId: order.id,
          status: TransactionStatus.ready,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.usafaBlue,
          foregroundColor: AppTheme.white,
          minimumSize: const Size(80, 32),
        ),
        child: const Text('Tandai Siap', style: TextStyle(fontSize: 12)),
      );
    case TransactionStatus.ready:
      return ElevatedButton(
        onPressed: () => controller.updateTransactionStatus(
          transactionId: order.id,
          status: TransactionStatus.completed,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.darkCornflowerBlue,
          foregroundColor: AppTheme.white,
          minimumSize: const Size(80, 32),
        ),
        child: const Text('Selesai', style: TextStyle(fontSize: 12)),
      );
    default:
      return const SizedBox.shrink();
  }
}

Color _getStatusColor(TransactionStatus status) {
  return AppTheme.getStatusColorFromEnum(status);
}

void _showRejectDialog(dynamic order, PenjualController controller) {
  Get.dialog(
    AlertDialog(
      title: const Text('Tolak Pesanan'),
      content: const Text('Apakah Anda yakin ingin menolak pesanan ini?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            controller.updateTransactionStatus(
              transactionId: order.id,
              status: TransactionStatus.cancelled,
            );
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
          child: Text('Tolak', style: TextStyle(color: AppTheme.white)),
        ),
      ],
    ),
  );
}

void _showPaymentProofDialog(String imageUrl) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppTheme.lightGray,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: AppTheme.mediumGray,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: AppTheme.mediumGray,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: AppTheme.lightGray,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppTheme.usafaBlue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading payment proof...',
                              style: TextStyle(
                                color: AppTheme.mediumGray,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.royalBlueDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
