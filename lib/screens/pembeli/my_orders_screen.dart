import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pembeli_controller.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';
import 'order_detail_screen.dart';
import 'payment_selection_screen.dart';
import 'payment_proof_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PembeliController controller = Get.put(PembeliController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTransactions();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.lightGray.withOpacity(0.3), Colors.white],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading) {
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
                    'Memuat pesanan Anda...',
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

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.red),
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
                  Text(
                    controller.errorMessage,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.fetchTransactions(),
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
                      'COba lagi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: AppTheme.mediumGray,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum ada pesanan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.royalBlueDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Riwayat pesanan Anda akan muncul di sini',
                    style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.goldenPoppy.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.goldenPoppy.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '🛒 Mulailah memesan dari kantin favorit Anda!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.royalBlueDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchTransactions(),
            color: AppTheme.royalBlueDark,
            backgroundColor: Colors.white,
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
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppTheme.lightGray.withOpacity(0.2)],
          ),
        ),
        child: InkWell(
          onTap: () =>
              Get.to(() => OrderDetailScreen(transaction: transaction)),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.royalBlueDark,
                                  AppTheme.usafaBlue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pesanan #${transaction.id}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.royalBlueDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(transaction.status),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      transaction.createdAt?.toString().substring(0, 16) ?? '',
                      style: TextStyle(
                        color: AppTheme.mediumGray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.restaurant_menu,
                      size: 16,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getOrderTypeDisplay(transaction.orderType),
                      style: TextStyle(
                        color: AppTheme.mediumGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (transaction.items != null &&
                    transaction.items!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.usafaBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.usafaBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${transaction.items!.length} item(s)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.usafaBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (transaction.customerName != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        transaction.customerName!,
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.goldenPoppy.withOpacity(0.1),
                        AppTheme.goldenPoppy.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.goldenPoppy.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah Total: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.royalBlueDark,
                        ),
                      ),
                      Text(
                        'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.goldenPoppy,
                        ),
                      ),
                    ],
                  ),
                ),

                if (transaction.status == TransactionStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelOrder(transaction),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.red,
                            side: BorderSide(color: AppTheme.red, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _payOrder(transaction),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.royalBlueDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Pay Now',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _uploadProof(transaction),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.goldenPoppy,
                        side: BorderSide(
                          color: AppTheme.goldenPoppy,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.upload_file),
                      label: const Text(
                        'Upload Bukti Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    final color = AppTheme.getStatusColorFromEnum(status);
    String text;

    switch (status) {
      case TransactionStatus.pending:
        text = 'Menunggu';
        break;
      case TransactionStatus.paid:
        text = 'Dibayar';
        break;
      case TransactionStatus.confirmed:
        text = 'Dikonfirmasi';
        break;
      case TransactionStatus.ready:
        text = 'Siap';
        break;
      case TransactionStatus.completed:
        text = 'Selesai';
        break;
      case TransactionStatus.cancelled:
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Batalkan Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.royalBlueDark,
          ),
        ),
        content: const Text(
          'Yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Simpan Pesanan',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Get.back(); // Close dialog

              if (transaction.id != null) {
                final controller = Get.find<PembeliController>();
                final success = await controller.cancelTransaction(
                  transaction.id!,
                );

                if (success) {
                  Get.snackbar(
                    'Success',
                    'Pesanan berhasil dibatalkan',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Gagal membatalkan pesanan. Silakan coba lagi.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                    icon: const Icon(Icons.error_outline, color: Colors.white),
                  );
                }
              }
            },
            child: const Text(
              'Ya, Batal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadProof(Transaction transaction) {
    int merchantId = 1; // Default fallback
    if (transaction.items != null && transaction.items!.isNotEmpty) {
      final firstItem = transaction.items!.first;
      if (firstItem.menu != null && firstItem.menu!.penjualId != null) {
        merchantId = firstItem.menu!.penjualId!;
      }
    }

    Get.to(
      () => PaymentSelectionScreen(
        merchantId: merchantId,
        totalAmount: transaction.totalPrice,
        onPaymentSelected: (paymentMethod, merchantPaymentMethod) {
          if (merchantPaymentMethod != null) {
            Get.to(
              () => PaymentProofScreen(
                transaction: transaction,
                paymentMethod: paymentMethod,
                merchantPaymentMethod: merchantPaymentMethod,
              ),
            );
          } else {
            Get.snackbar(
              'Error',
              'Data metode pembayaran tidak lengkap',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  void _payOrder(Transaction transaction) {
    int merchantId = 1; // Default fallback
    if (transaction.items != null && transaction.items!.isNotEmpty) {
      final firstItem = transaction.items!.first;
      if (firstItem.menu != null && firstItem.menu!.penjualId != null) {
        merchantId = firstItem.menu!.penjualId!;
      }
    }

    Get.to(
      () => PaymentSelectionScreen(
        merchantId: merchantId,
        totalAmount: transaction.totalPrice,
        onPaymentSelected: (paymentMethod, merchantPaymentMethod) {
          Get.snackbar(
            'Metode Pembayaran Dipilih',
            'Memilih ${paymentMethod.name}. Silakan lakukan pembayaran dan unggah bukti.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        },
      ),
    );
  }
}
