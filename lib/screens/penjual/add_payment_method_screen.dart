import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_payment_method_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../models/payment_method.dart';
import '../../utils/app_theme.dart';

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
        title: const Text('Tambahkan Metode Pembayaran'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
            ),
          ),
        ),
        foregroundColor: AppTheme.white,
      ),
      body: Obx(() {
        if (paymentController.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.royalBlueDark),
            ),
          );
        }

        if (paymentController.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: AppTheme.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${paymentController.errorMessage}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => paymentController.fetchPaymentMethods(),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Tambahkan Metode Pembayaran Baru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih metode pembayaran dan masukkan rincian akun Anda.',
                style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
              ),
              const SizedBox(height: 24),

              // Payment Method Selection
              const Text(
                'Pilih Metode Pembayaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.royalBlueDark.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentMethod>(
                      value: selectedPaymentMethod.value,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Pilih metode pembayaran'),
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
                                      color: AppTheme.mediumGray,
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
                'Nomor Rekening',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nomor akun Anda',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Account Name Field
              const Text(
                'Nama Akun',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: accountNameController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama pemegang akun',
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
                                'Sukses',
                                'Metode pembayaran berhasil ditambahkan!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppTheme.goldenPoppy,
                                colorText: AppTheme.royalBlueDark,
                                duration: const Duration(seconds: 2),
                              );

                              // Auto close screen setelah sukses
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              Get.back(result: true);
                            } else {
                              // Show error message
                              Get.snackbar(
                                'Error',
                                'Gagal menambahkan metode pembayaran. Silakan coba lagi.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: AppTheme.white,
                                duration: const Duration(seconds: 3),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalBlueDark,
                      foregroundColor: AppTheme.white,
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
                                    AppTheme.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Menambahkan...'),
                            ],
                          )
                        : const Text(
                            'Tambahkan Metode Pembayaran',
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
                    foregroundColor: AppTheme.mediumGray,
                    side: BorderSide(color: AppTheme.lightGray),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Batal',
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
