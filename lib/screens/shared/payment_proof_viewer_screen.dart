import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';

class PaymentProofViewerScreen extends StatelessWidget {
  final Transaction transaction;
  final String userRole; // 'seller' or 'buyer'

  const PaymentProofViewerScreen({
    super.key,
    required this.transaction,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        title: Text(
          userRole == 'seller'
              ? 'Bukti Pembayaran - Order #${transaction.id ?? 'N/A'}'
              : 'Bukti Pembayaran Saya',
          style: const TextStyle(fontSize: 16),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Payment proof image
            if (transaction.paymentProof != null &&
                transaction.paymentProof!.isNotEmpty)
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    transaction.paymentProof!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.goldenPoppy,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.mediumGray.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.white70,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(
                                  color: Colors.white70,
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
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.mediumGray.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white30,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada bukti pembayaran',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

            // Payment details card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.royalBlueDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt,
                            color: AppTheme.royalBlueDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Detail Pembayaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.royalBlueDark,
                            ),
                          ),
                        ),
                        _buildStatusChip(transaction.status),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Order details
                    _buildDetailRow('Order ID', '#${transaction.id ?? 'N/A'}'),
                    _buildDetailRow(
                      'Total Pembayaran',
                      'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                    ),
                    if (transaction.customerName != null)
                      _buildDetailRow(
                        'Nama Pelanggan',
                        transaction.customerName!,
                      ),
                    if (transaction.customerPhone != null)
                      _buildDetailRow(
                        'No. Telepon',
                        transaction.customerPhone!,
                      ),

                    // Payment proof details
                    if (transaction.paymentProof != null &&
                        transaction.paymentProof!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Bukti Pembayaran',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bukti pembayaran telah diunggah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (transaction.updatedAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Diunggah pada: ${transaction.updatedAt.toString().substring(0, 16)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.mediumGray,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Instructions for seller
                    if (userRole == 'seller' &&
                        transaction.paymentProof != null &&
                        transaction.paymentProof!.isNotEmpty) ...[
                      const SizedBox(height: 16),
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
                                'Verifikasi bukti pembayaran dan update status pesanan',
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
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
}
