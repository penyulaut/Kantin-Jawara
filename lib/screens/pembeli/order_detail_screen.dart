import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/transaction.dart';
import '../../controllers/chat_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/payment_proof_viewer_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Transaction transaction;
  final ChatController chatController = Get.put(ChatController());

  OrderDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray.withOpacity(
        0.1,
      ), // Light background instead of white
      appBar: AppBar(
        title: Text(
          'Order #${transaction.id ?? "Unknown"}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: AppTheme.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
            ),
          ),
        ),
        actions: [
          if (transaction.id != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => Get.toNamed(
                  '/chat',
                  arguments: {'transactionId': transaction.id!},
                ),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, size: 20),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),

            _buildOrderInfoCard(),
            const SizedBox(height: 16),

            _buildOrderItemsCard(),
            const SizedBox(height: 16),

            if (transaction.payment != null) ...[
              _buildPaymentInfoCard(),
              const SizedBox(height: 16),
            ],

            if (transaction.paymentProof != null &&
                transaction.paymentProof!.isNotEmpty) ...[
              _buildPaymentProofCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      color: AppTheme.white,
      shadowColor: AppTheme.mediumGray.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
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
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 4,
      color: AppTheme.white,
      shadowColor: AppTheme.mediumGray.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Order ID', '#${transaction.id ?? "N/A"}'),
            _buildInfoRow(
              'Date',
              transaction.createdAt?.toString().substring(0, 16) ?? 'N/A',
            ),
            _buildInfoRow(
              'Order Type',
              _getOrderTypeDisplay(transaction.orderType),
            ),
            if (transaction.customerName?.isNotEmpty == true)
              _buildInfoRow('Customer', transaction.customerName!),
            if (transaction.customerPhone?.isNotEmpty == true)
              _buildInfoRow('Phone', transaction.customerPhone!),
            if (transaction.notes?.isNotEmpty == true)
              _buildInfoRow('Notes', transaction.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Card(
      elevation: 4,
      color: AppTheme.white,
      shadowColor: AppTheme.mediumGray.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 12),
            if (transaction.items?.isNotEmpty == true) ...[
              ...transaction.items!.map((item) => _buildOrderItem(item)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  Text(
                    'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldenPoppy,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'No items found',
                style: TextStyle(color: AppTheme.mediumGray),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    if (transaction.payment == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      color: AppTheme.white,
      shadowColor: AppTheme.mediumGray.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
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
                transaction.payment!.paidAt!.toString().substring(0, 16),
              ),
            if (transaction.payment!.proof?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              const Text(
                'Payment Proof:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              _buildPaymentProofImage(transaction.payment!.proof!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProofCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      color: AppTheme.white,
      shadowColor: AppTheme.mediumGray.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.white,
          gradient: LinearGradient(
            colors: [AppTheme.green.withOpacity(0.05), AppTheme.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: AppTheme.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bukti Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Diunggah',
                      style: TextStyle(
                        color: AppTheme.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Get.to(
                    () => PaymentProofViewerScreen(
                      transaction: transaction,
                      userRole: 'buyer',
                    ),
                  );
                },
                child: _buildPaymentProofPreview(),
              ),

              const SizedBox(height: 8),
              Text(
                'Tap untuk melihat bukti pembayaran lengkap',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mediumGray,
                  fontStyle: FontStyle.italic,
                ),
              ),

              if (transaction.updatedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppTheme.mediumGray),
                    const SizedBox(width: 4),
                    Text(
                      'Diunggah pada ${transaction.updatedAt.toString().substring(0, 16)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.mediumGray,
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

  Widget _buildPaymentProofImage(String imageUrl) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Gagal memuat gambar'));
          },
        ),
      ),
    );
  }

  Widget _buildPaymentProofPreview() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.mediumGray.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.network(
              transaction.paymentProof!,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.royalBlueDark,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.mediumGray,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gagal memuat',
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: AppTheme.royalBlueDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: AppTheme.royalBlueDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus? status) {
    if (status == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey),
        ),
        child: const Text(
          'Unknown',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      );
    }

    final color = AppTheme.getStatusColorFromEnum(status);
    String text;

    switch (status) {
      case TransactionStatus.pending:
        text = 'Pending';
        break;
      case TransactionStatus.paid:
        text = 'Paid';
        break;
      case TransactionStatus.confirmed:
        text = 'Confirmed';
        break;
      case TransactionStatus.ready:
        text = 'Ready';
        break;
      case TransactionStatus.completed:
        text = 'Completed';
        break;
      case TransactionStatus.cancelled:
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
        final isActive = index <= currentIndex && currentIndex >= 0;
        final isLast = index == statuses.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppTheme.royalBlueDark
                      : AppTheme.mediumGray.withOpacity(0.3),
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: isActive ? AppTheme.white : AppTheme.mediumGray,
                  ),
                ),
              ),
              if (!isLast) ...[
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive
                        ? AppTheme.royalBlueDark
                        : AppTheme.mediumGray.withOpacity(0.3),
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
                  'Qty: ${item.quantity ?? 0}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${((item.unitPrice ?? 0) * (item.quantity ?? 0)).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getOrderTypeDisplay(OrderType? orderType) {
    if (orderType == null) return 'Unknown';

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
