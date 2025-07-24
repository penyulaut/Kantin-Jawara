import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_payment_method_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../models/payment_method.dart';
import '../../models/merchant_payment_method.dart';
import '../../utils/app_theme.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MerchantPaymentMethodController merchantController = Get.put(
      MerchantPaymentMethodController(),
    );
    final PaymentController paymentController = Get.put(PaymentController());

    // Load data when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      merchantController.fetchMerchantPaymentMethods();
      paymentController.fetchPaymentMethods();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: AppTheme.green,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (merchantController.isLoading || paymentController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (merchantController.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 64,
                  color: AppTheme.red.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${merchantController.errorMessage}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      merchantController.fetchMerchantPaymentMethods(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await merchantController.fetchMerchantPaymentMethods();
            await paymentController.fetchPaymentMethods();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Manage Your Payment Methods',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enable payment methods that your customers can use to pay for orders.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Available Payment Methods
                const Text(
                  'Available Payment Methods',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // Payment Methods List
                ...paymentController.paymentMethods.map((paymentMethod) {
                  final isEnabled = merchantController.merchantPaymentMethods
                      .any((m) => m.paymentMethodId == paymentMethod.id);

                  final merchantPaymentMethod = merchantController
                      .merchantPaymentMethods
                      .firstWhereOrNull(
                        (m) => m.paymentMethodId == paymentMethod.id,
                      );

                  return _buildPaymentMethodCard(
                    paymentMethod,
                    isEnabled,
                    merchantPaymentMethod,
                    merchantController,
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod paymentMethod,
    bool isEnabled,
    MerchantPaymentMethod? merchantPaymentMethod,
    MerchantPaymentMethodController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Payment Method Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPaymentMethodIcon(paymentMethod.name),
                    size: 24,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),

                // Payment Method Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentMethod.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (paymentMethod.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          paymentMethod.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Enable/Disable Switch
                Switch(
                  value: isEnabled,
                  onChanged: (value) async {
                    if (value) {
                      _showAccountDetailsDialog(paymentMethod, controller);
                    } else {
                      if (merchantPaymentMethod?.id != null) {
                        await controller.deleteMerchantPaymentMethod(
                          merchantPaymentMethod!.id!,
                        );
                      }
                    }
                  },
                  activeColor: AppTheme.green,
                ),
              ],
            ),

            // Account Details (if enabled)
            if (isEnabled && merchantPaymentMethod != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Enabled',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Account: ${merchantPaymentMethod.details['account_number'] ?? 'Not set'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (merchantPaymentMethod.details['account_name'] !=
                        null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Name: ${merchantPaymentMethod.details['account_name']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAccountDetailsDialog(
                            paymentMethod,
                            controller,
                            merchantPaymentMethod,
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.royalBlueDark,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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

  void _showAccountDetailsDialog(
    PaymentMethod paymentMethod,
    MerchantPaymentMethodController controller, [
    MerchantPaymentMethod? existingMethod,
  ]) {
    final accountNumberController = TextEditingController(
      text: existingMethod?.details['account_number'] ?? '',
    );
    final accountNameController = TextEditingController(
      text: existingMethod?.details['account_name'] ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: Text(
          '${existingMethod != null ? 'Edit' : 'Add'} ${paymentMethod.name}',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (accountNumberController.text.isEmpty) {
                Get.snackbar('Error', 'Please enter account number');
                return;
              }

              bool success;
              if (existingMethod != null) {
                success = await controller.updateMerchantPaymentMethod(
                  id: existingMethod.id!,
                  paymentMethodId: existingMethod.paymentMethodId!,
                  accountNumber: accountNumberController.text,
                  accountName: accountNameController.text.isEmpty
                      ? accountNumberController.text
                      : accountNameController.text,
                  isActive: true,
                );
              } else {
                success = await controller.createMerchantPaymentMethod(
                  paymentMethodId: paymentMethod.id!,
                  accountNumber: accountNumberController.text,
                  accountName: accountNameController.text.isEmpty
                      ? accountNumberController.text
                      : accountNameController.text,
                );
              }

              if (success) {
                Get.back(); // Close dialog

                // Show success message
                Get.snackbar(
                  'Success',
                  existingMethod != null
                      ? 'Payment method berhasil diperbarui!'
                      : 'Payment method berhasil ditambahkan!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );
              } else {
                Get.snackbar(
                  'Error',
                  existingMethod != null
                      ? 'Gagal memperbarui payment method!'
                      : 'Gagal menambahkan payment method!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                  icon: const Icon(Icons.error_outline, color: Colors.white),
                );
              }
            },
            child: Text(existingMethod != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }
}
