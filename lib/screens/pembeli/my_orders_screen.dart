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

    // Ensure data is fetched when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTransactions();
    });

    return Scaffold(
      backgroundColor: AppTheme.lightGray.withOpacity(0.1),
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
      body: Obx(() {
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
                    'Try Again',
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
                  'No orders yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.royalBlueDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order history will appear here',
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
                    '🛒 Start ordering from your favorite kantins!',
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
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.lightGray.withOpacity(0.3), Colors.white],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                final transaction = controller.transactions[index];
                return _buildOrderCard(context, transaction);
              },
            ),
          ),
        );
      }),
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
                // Header
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
                              'Order #${transaction.id}',
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

                // Date and Order Type
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

                // Items Summary
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

                // Customer Info
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

                // Total Price
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

                // Action Buttons
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
                  // Upload Proof Button
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
          'Cancel Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.royalBlueDark,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Keep Order',
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
              'Yes, Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadProof(Transaction transaction) {
    // Get merchant_id from transaction items
    int merchantId = 1; // Default fallback
    if (transaction.items != null && transaction.items!.isNotEmpty) {
      final firstItem = transaction.items!.first;
      if (firstItem.menu != null && firstItem.menu!.penjualId != null) {
        merchantId = firstItem.menu!.penjualId!;
      }
    }

    // print(
    // 'MyOrdersScreen: Navigating to upload proof for transaction ${transaction.id}',
    // );

    // Navigate to payment selection screen first to choose payment method
    Get.to(
      () => PaymentSelectionScreen(
        merchantId: merchantId,
        totalAmount: transaction.totalPrice,
        onPaymentSelected: (paymentMethod, merchantPaymentMethod) {
          // Navigate to payment proof screen
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
              'Payment method data is incomplete',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
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

    // print('MyOrdersScreen: Using merchant_id: $merchantId for payment methods');

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
