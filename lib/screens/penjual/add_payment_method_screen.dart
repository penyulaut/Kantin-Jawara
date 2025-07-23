import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_payment_method_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../models/payment_method.dart';

class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddPaymentMethodController addController = Get.put(
      AddPaymentMethodController(),
    );
    final PaymentController paymentController = Get.put(PaymentController());

    final accountNumberController = TextEditingController();
    final accountNameController = TextEditingController();
    final selectedPaymentMethod = Rxn<PaymentMethod>();

    // Load available payment methods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paymentController.fetchPaymentMethods();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (paymentController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (paymentController.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error: ${paymentController.errorMessage}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => paymentController.fetchPaymentMethods(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Add New Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a payment method and enter your account details.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Payment Method Selection
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentMethod>(
                      value: selectedPaymentMethod.value,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Choose payment method'),
                      ),
                      isExpanded: true,
                      items: paymentController.paymentMethods.map((method) {
                        return DropdownMenuItem<PaymentMethod>(
                          value: method,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  method.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (method.description != null)
                                  Text(
                                    method.description!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (PaymentMethod? value) {
                        selectedPaymentMethod.value = value;
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Account Number Field
              const Text(
                'Account Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  hintText: 'Enter your account number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Account Name Field
              const Text(
                'Account Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: accountNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter account holder name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 32),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed:
                        addController.isLoading ||
                            selectedPaymentMethod.value == null ||
                            accountNumberController.text.isEmpty ||
                            accountNameController.text.isEmpty
                        ? null
                        : () async {
                            final success = await addController
                                .addPaymentMethod(
                                  paymentMethodId:
                                      selectedPaymentMethod.value!.id!,
                                  accountNumber: accountNumberController.text
                                      .trim(),
                                  accountName: accountNameController.text
                                      .trim(),
                                  isActive: true,
                                );

                            if (success) {
                              Get.snackbar(
                                'Success',
                                'Payment method added successfully!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                              );

                              // Delay sedikit untuk memberi waktu snackbar tampil
                              await Future.delayed(
                                const Duration(milliseconds: 800),
                              );
                              Get.back(result: true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: addController.isLoading
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Adding...'),
                            ],
                          )
                        : const Text(
                            'Add Payment Method',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
