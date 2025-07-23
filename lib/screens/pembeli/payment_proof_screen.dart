import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pembeli_controller.dart';
import '../../models/transaction.dart';
import '../../models/payment_method.dart';
import '../../models/merchant_payment_method.dart';

class PaymentProofScreen extends StatelessWidget {
  final Transaction transaction;
  final PaymentMethod paymentMethod;
  final MerchantPaymentMethod merchantPaymentMethod;

  const PaymentProofScreen({
    super.key,
    required this.transaction,
    required this.paymentMethod,
    required this.merchantPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final PembeliController controller = Get.find<PembeliController>();
    final TextEditingController notesController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Payment Proof'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${transaction.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${_getStatusDisplay(transaction.status)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getPaymentMethodIcon(paymentMethod.name),
                          size: 24,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          paymentMethod.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (merchantPaymentMethod.details['account_number'] !=
                        null) ...[
                      _buildDetailRow(
                        'Account Number',
                        merchantPaymentMethod.details['account_number'],
                        copyable: true,
                      ),
                    ],
                    if (merchantPaymentMethod.details['account_name'] !=
                        null) ...[
                      _buildDetailRow(
                        'Account Name',
                        merchantPaymentMethod.details['account_name'],
                      ),
                    ],
                    _buildDetailRow(
                      'Amount to Pay',
                      'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Payment Instructions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Transfer the exact amount to the account above\n'
                      '2. Take a screenshot or photo of the transfer receipt\n'
                      '3. Upload the proof below\n'
                      '4. Wait for merchant confirmation',
                      style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upload Section
            const Text(
              'Upload Payment Proof',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Image Placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload payment proof',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG (Max 5MB)',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional information...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _submitPaymentProof(controller, notesController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Payment Proof',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Later Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload Later',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (copyable) ...[
                  InkWell(
                    onTap: () {
                      // Copy to clipboard functionality
                      Get.snackbar(
                        'Copied',
                        'Account number copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.copy, size: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('bank') || lowerName.contains('transfer')) {
      return Icons.account_balance;
    } else if (lowerName.contains('wallet') ||
        lowerName.contains('gopay') ||
        lowerName.contains('ovo') ||
        lowerName.contains('dana')) {
      return Icons.account_balance_wallet;
    } else if (lowerName.contains('card') || lowerName.contains('credit')) {
      return Icons.credit_card;
    } else if (lowerName.contains('cash') || lowerName.contains('tunai')) {
      return Icons.money;
    } else {
      return Icons.payment;
    }
  }

  String _getStatusDisplay(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending Payment';
      case TransactionStatus.paid:
        return 'Payment Uploaded';
      case TransactionStatus.confirmed:
        return 'Payment Confirmed';
      case TransactionStatus.ready:
        return 'Order Ready';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _submitPaymentProof(PembeliController controller, String notes) async {
    // In a real app, this would handle image upload
    // For now, we'll just show success message

    Get.dialog(
      AlertDialog(
        title: const Text('Payment Proof Uploaded'),
        content: const Text(
          'Your payment proof has been submitted successfully. '
          'The merchant will review and confirm your payment.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Here you would typically call the API to upload the payment proof
    // await controller.uploadPaymentProof(transaction.id!, imageFile, notes);
  }
}
