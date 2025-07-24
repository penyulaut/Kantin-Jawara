import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_payment_method_controller.dart';
import '../../models/merchant_payment_method.dart';
import 'add_payment_method_screen.dart';
import '../../utils/app_theme.dart';

class MerchantPaymentListScreen extends StatelessWidget {
  const MerchantPaymentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MerchantPaymentMethodController controller = Get.put(
      MerchantPaymentMethodController(),
    );

    // Load data when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMerchantPaymentMethods();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Payment Methods'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: AppTheme.white,
        actions: [
          IconButton(
            onPressed: () => controller.fetchMerchantPaymentMethods(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () async {
              final result = await Get.to(() => const AddPaymentMethodScreen());
              if (result == true) {
                // Refresh list when coming back from add screen
                controller.fetchMerchantPaymentMethods();
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Payment Method',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.lightGray, AppTheme.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.royalBlueDark),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: AppTheme.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${controller.errorMessage}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchMerchantPaymentMethods(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalBlueDark,
                      foregroundColor: AppTheme.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.merchantPaymentMethods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 64,
                    color: AppTheme.mediumGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payment methods yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.darkGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first payment method to start accepting payments',
                    style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Get.to(
                        () => const AddPaymentMethodScreen(),
                      );
                      if (result == true) {
                        controller.fetchMerchantPaymentMethods();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment Method'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalBlueDark,
                      foregroundColor: AppTheme.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.royalBlueDark,
            onRefresh: () => controller.fetchMerchantPaymentMethods(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.merchantPaymentMethods.length,
              itemBuilder: (context, index) {
                final paymentMethod = controller.merchantPaymentMethods[index];
                return _buildPaymentMethodCard(paymentMethod, controller);
              },
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const AddPaymentMethodScreen());
          if (result == true) {
            controller.fetchMerchantPaymentMethods();
          }
        },
        backgroundColor: AppTheme.goldenPoppy,
        child: const Icon(Icons.add, color: AppTheme.royalBlueDark),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    MerchantPaymentMethod paymentMethod,
    MerchantPaymentMethodController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: AppTheme.royalBlueDark.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              Row(
                children: [
                  // Payment Method Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.royalBlueDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.royalBlueDark.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      _getPaymentMethodIcon(
                        paymentMethod.paymentMethod?.name ?? 'Cash',
                      ),
                      size: 24,
                      color: AppTheme.royalBlueDark,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Payment Method Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentMethod.paymentMethod?.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (paymentMethod.paymentMethod?.description !=
                            null) ...[
                          const SizedBox(height: 4),
                          Text(
                            paymentMethod.paymentMethod!.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: paymentMethod.isActive
                          ? AppTheme.goldenPoppy.withOpacity(0.1)
                          : AppTheme.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      paymentMethod.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: paymentMethod.isActive
                            ? AppTheme.goldenPoppy
                            : AppTheme.red,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Account Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.mediumGray.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 16,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Account Number: ${paymentMethod.details['account_number'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Account Name: ${paymentMethod.details['account_name'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showEditDialog(paymentMethod, controller),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.royalBlueDark,
                        side: BorderSide(
                          color: AppTheme.royalBlueDark.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showDeleteDialog(paymentMethod, controller),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.red,
                        side: BorderSide(color: AppTheme.red.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String paymentMethodName) {
    switch (paymentMethodName.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'transfer bank':
      case 'bank transfer':
        return Icons.account_balance;
      case 'e-wallet':
      case 'ewallet':
        return Icons.account_balance_wallet;
      case 'qris':
        return Icons.qr_code;
      default:
        return Icons.payment;
    }
  }

  void _showEditDialog(
    MerchantPaymentMethod paymentMethod,
    MerchantPaymentMethodController controller,
  ) {
    final accountNumberController = TextEditingController(
      text: paymentMethod.details['account_number'] ?? '',
    );
    final accountNameController = TextEditingController(
      text: paymentMethod.details['account_name'] ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: Text(
          'Edit ${paymentMethod.paymentMethod?.name ?? 'Payment Method'}',
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
                  prefixIcon: Icon(Icons.account_balance),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (accountNumberController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter account number',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: AppTheme.white,
                );
                return;
              }

              // Show loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.royalBlueDark,
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              final success = await controller.updateMerchantPaymentMethod(
                id: paymentMethod.id!,
                paymentMethodId: paymentMethod.paymentMethodId!,
                accountNumber: accountNumberController.text.trim(),
                accountName: accountNameController.text.trim().isEmpty
                    ? accountNumberController.text.trim()
                    : accountNameController.text.trim(),
                isActive: paymentMethod.isActive,
              );

              // Close loading dialog
              Get.back();

              if (success) {
                // Close edit dialog
                Get.back();
                Get.snackbar(
                  'Success',
                  'Payment method updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.goldenPoppy,
                  colorText: AppTheme.royalBlueDark,
                );
              } else {
                // Show error, keep dialog open
                Get.snackbar(
                  'Error',
                  'Failed to update payment method',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: AppTheme.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalBlueDark,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    MerchantPaymentMethod paymentMethod,
    MerchantPaymentMethodController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text(
          'Are you sure you want to delete this ${paymentMethod.paymentMethod?.name ?? 'payment method'}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              // Show loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.royalBlueDark,
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              final success = await controller.deleteMerchantPaymentMethod(
                paymentMethod.id!,
              );

              // Close loading dialog
              Get.back();

              if (success) {
                // Close delete dialog
                Get.back();
                Get.snackbar(
                  'Success',
                  'Payment method deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.goldenPoppy,
                  colorText: AppTheme.royalBlueDark,
                );
              } else {
                // Show error, keep dialog open
                Get.snackbar(
                  'Error',
                  'Failed to delete payment method',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: AppTheme.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
