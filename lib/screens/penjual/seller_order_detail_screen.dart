import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/transaction.dart';
import '../../controllers/penjual_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/chat_screen.dart';
import '../shared/payment_proof_viewer_screen.dart';

class SellerOrderDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const SellerOrderDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final PenjualController controller = Get.find<PenjualController>();

    return Scaffold(
      backgroundColor: AppTheme.lightGray.withOpacity(0.1),
      appBar: AppBar(
        title: Text('Detail Pesanan #${transaction.id ?? 'N/A'}'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppTheme.royalBlueDark.withOpacity(0.3),
        actions: [
          if (transaction.id != null)
            IconButton(
              onPressed: () {
                Get.to(() => ChatScreen(transactionId: transaction.id!));
              },
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Chat dengan Pelanggan',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.royalBlueDark.withOpacity(0.05),
                      AppTheme.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status Pesanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          _buildStatusChip(transaction.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Order ID', '#${transaction.id ?? 'N/A'}'),
                      _buildInfoRow(
                        'Total',
                        'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                      ),
                      if (transaction.customerName != null)
                        _buildInfoRow(
                          'Nama Pelanggan',
                          transaction.customerName!,
                        ),
                      if (transaction.customerPhone != null)
                        _buildInfoRow(
                          'No. Telepon',
                          transaction.customerPhone!,
                        ),
                      _buildInfoRow(
                        'Tipe Pesanan',
                        transaction.orderType == OrderType.dineIn
                            ? 'Makan di Tempat'
                            : 'Bungkus',
                      ),
                      if (transaction.notes != null &&
                          transaction.notes!.isNotEmpty)
                        _buildInfoRow('Catatan', transaction.notes!),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (transaction.paymentProof != null &&
                transaction.paymentProof!.isNotEmpty) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.green.withOpacity(0.05),
                        AppTheme.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                                'Sudah Upload',
                                style: TextStyle(
                                  color: AppTheme.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => PaymentProofViewerScreen(
                                transaction: transaction,
                                userRole: 'seller',
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.mediumGray.withOpacity(0.3),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Image.network(
                                    transaction.paymentProof!,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: AppTheme.lightGray,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppTheme.royalBlueDark),
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.lightGray,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: AppTheme.mediumGray,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Gagal memuat gambar',
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
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.white.withOpacity(
                                              0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.visibility,
                                                size: 18,
                                                color: AppTheme.royalBlueDark,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Verifikasi Pembayaran',
                                                style: TextStyle(
                                                  color: AppTheme.royalBlueDark,
                                                  fontSize: 14,
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
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.goldenPoppy.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.goldenPoppy.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.goldenPoppy,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tap gambar untuk melihat detail dan verifikasi pembayaran',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.royalBlueDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (transaction.updatedAt != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: AppTheme.mediumGray,
                              ),
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
              ),
              const SizedBox(height: 16),
            ],

            if (transaction.items != null && transaction.items!.isNotEmpty) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.goldenPoppy.withOpacity(0.05),
                        AppTheme.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item Pesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...transaction.items!.map(
                          (item) => _buildOrderItem(item),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildActionButtons(controller),
          ],
        ),
      ),
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
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(fontSize: 13, color: AppTheme.mediumGray),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    Color color;
    String text;

    switch (status) {
      case TransactionStatus.pending:
        color = AppTheme.goldenPoppy;
        text = 'Menunggu';
        break;
      case TransactionStatus.paid:
        color = AppTheme.green;
        text = 'Dibayar';
        break;
      case TransactionStatus.confirmed:
        color = AppTheme.royalBlueDark;
        text = 'Dikonfirmasi';
        break;
      case TransactionStatus.ready:
        color = AppTheme.usafaBlue;
        text = 'Siap';
        break;
      case TransactionStatus.completed:
        color = AppTheme.green;
        text = 'Selesai';
        break;
      case TransactionStatus.cancelled:
        color = AppTheme.red;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderItem(TransactionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.mediumGray.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.menu?.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.menu!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.restaurant,
                          color: AppTheme.mediumGray,
                          size: 24,
                        );
                      },
                    ),
                  )
                : Icon(Icons.restaurant, color: AppTheme.mediumGray, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu?.name ?? 'Menu Item',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item.unitPrice.toStringAsFixed(0)} x ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: AppTheme.mediumGray),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${item.totalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.royalBlueDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PenjualController controller) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksi Pesanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 16),

            if (transaction.status == TransactionStatus.paid) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: transaction.id != null
                      ? () {
                          controller.updateTransactionStatus(
                            transactionId: transaction.id!,
                            status: TransactionStatus.confirmed,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Konfirmasi Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            if (transaction.status == TransactionStatus.confirmed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: transaction.id != null
                      ? () {
                          controller.updateTransactionStatus(
                            transactionId: transaction.id!,
                            status: TransactionStatus.ready,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.usafaBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tandai Siap',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            if (transaction.status == TransactionStatus.ready) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: transaction.id != null
                      ? () {
                          controller.updateTransactionStatus(
                            transactionId: transaction.id!,
                            status: TransactionStatus.completed,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Selesaikan Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: transaction.id != null
                    ? () {
                        Get.to(
                          () => ChatScreen(transactionId: transaction.id!),
                        );
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.royalBlueDark),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppTheme.royalBlueDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chat dengan Pelanggan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.royalBlueDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
