import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pembeli_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/menu.dart';
import '../../models/payment_method.dart';
import '../../models/merchant_payment_method.dart';
import '../../utils/app_theme.dart';
import 'payment_selection_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final RxList<Map<String, dynamic>> cartItems;
  final PembeliController pembeliController = Get.find<PembeliController>();
  final PaymentController paymentController = Get.put(PaymentController());
  final CartController cartController = Get.find<CartController>();

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final RxString selectedOrderType = 'takeaway'.obs;

  final Rx<PaymentMethod?> selectedPaymentMethod = Rx<PaymentMethod?>(null);
  final Rx<MerchantPaymentMethod?> selectedMerchantPaymentMethod =
      Rx<MerchantPaymentMethod?>(null);

  CheckoutScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGray.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ...cartItems.map((item) => _buildOrderItem(item)),
                  const Divider(thickness: 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.royalBlueDark,
                        ),
                      ),
                      Text(
                        'Rp ${_calculateTotal().toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldenPoppy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Information
            Text(
              'Informasi Pembeli  ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: customerNameController,
              decoration: InputDecoration(
                labelText: 'Nama Pembeli',
                labelStyle: TextStyle(color: AppTheme.darkGray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.lightGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.usafaBlue, width: 2),
                ),
                prefixIcon: Icon(Icons.person, color: AppTheme.goldenPoppy),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: customerPhoneController,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                labelStyle: TextStyle(color: AppTheme.darkGray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.lightGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.usafaBlue, width: 2),
                ),
                prefixIcon: Icon(Icons.phone, color: AppTheme.goldenPoppy),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Order Type
            Text(
              'Tipe Pesanan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lightGray),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGray.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(
                () => Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(
                        'Dine In',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.royalBlueDark,
                        ),
                      ),
                      subtitle: Text(
                        'Makan disini',
                        style: TextStyle(color: AppTheme.darkGray),
                      ),
                      value: 'dine_in',
                      groupValue: selectedOrderType.value,
                      activeColor: AppTheme.usafaBlue,
                      onChanged: (value) => selectedOrderType.value = value!,
                    ),
                    Divider(color: AppTheme.lightGray, height: 1),
                    RadioListTile<String>(
                      title: Text(
                        'Takeaway',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.royalBlueDark,
                        ),
                      ),
                      subtitle: Text(
                        'Bawa pergi',
                        style: TextStyle(color: AppTheme.darkGray),
                      ),
                      value: 'takeaway',
                      groupValue: selectedOrderType.value,
                      activeColor: AppTheme.usafaBlue,
                      onChanged: (value) => selectedOrderType.value = value!,
                    ),
                    Divider(color: AppTheme.lightGray, height: 1),
                    RadioListTile<String>(
                      title: Text(
                        'Delivery',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.royalBlueDark,
                        ),
                      ),
                      subtitle: Text(
                        'Antar ke lokasi',
                        style: TextStyle(color: AppTheme.darkGray),
                      ),
                      value: 'delivery',
                      groupValue: selectedOrderType.value,
                      activeColor: AppTheme.usafaBlue,
                      onChanged: (value) => selectedOrderType.value = value!,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightGray),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkGray.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectPaymentMethod(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedPaymentMethod.value != null
                                  ? AppTheme.goldenPoppy.withOpacity(0.1)
                                  : AppTheme.lightGray.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              selectedPaymentMethod.value != null
                                  ? _getPaymentMethodIcon(
                                      selectedPaymentMethod.value!.name,
                                    )
                                  : Icons.payment,
                              size: 24,
                              color: selectedPaymentMethod.value != null
                                  ? AppTheme.goldenPoppy
                                  : AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedPaymentMethod.value?.name ??
                                      'Pilih Metode Pembayaran',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: selectedPaymentMethod.value != null
                                        ? AppTheme.royalBlueDark
                                        : AppTheme.darkGray,
                                  ),
                                ),
                                if (selectedPaymentMethod.value != null &&
                                    selectedMerchantPaymentMethod.value !=
                                        null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Account: ${selectedMerchantPaymentMethod.value!.details['account_number']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.darkGray,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppTheme.usafaBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            Text(
              'Catatan (Opsional)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Tambahkan instruksi khusus apa pun...',
                labelStyle: TextStyle(color: AppTheme.darkGray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.lightGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.usafaBlue, width: 2),
                ),
                prefixIcon: Icon(Icons.note, color: AppTheme.goldenPoppy),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 80), // Extra padding to avoid button overlap
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkGray.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Obx(
            () => Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.usafaBlue, AppTheme.royalBlueDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: pembeliController.isLoading ? null : _placeOrder,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: pembeliController.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_checkout,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tempatkan Pesanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final Menu menu = item['menu'];
    final int quantity = item['quantity'];
    final double price = item['price'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.goldenPoppy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: AppTheme.goldenPoppy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.royalBlueDark,
                  ),
                ),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${(price * quantity).toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.usafaBlue,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  void _placeOrder() async {
    // Validate inputs
    if (customerNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan masukkan nama anda',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    if (customerPhoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan masukkan nomor telepon',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    if (selectedPaymentMethod.value == null) {
      Get.snackbar(
        'Error',
        'Silakan pilih metode pembayaran',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Prepare items for API
    final List<Map<String, dynamic>> items = cartItems
        .map(
          (item) => {
            'menu_id': item['menu_id'],
            'quantity': item['quantity'],
            'price': item['price'],
          },
        )
        .toList();

    // Create transaction
    final success = await pembeliController.createTransaction(
      totalPrice: _calculateTotal(),
      items: items,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      customerName: customerNameController.text.trim(),
      customerPhone: customerPhoneController.text.trim(),
      orderType: selectedOrderType.value,
      paymentMethod: selectedPaymentMethod.value?.name,
    );

    if (success) {
      // Clear cart both locally and through CartController
      cartItems.clear();
      cartController.clearCart();

      // Navigate back to orders
      Get.until((route) => route.isFirst);
    }
  }

  void _selectPaymentMethod() {
    // Get merchant_id from cart data
    int merchantId = 1; // Default fallback
    if (cartItems.isNotEmpty) {
      // Extract merchant_id from first cart item since all items should be from same merchant
      final firstItem = cartItems.first;
      if (firstItem.containsKey('merchant_id')) {
        merchantId = firstItem['merchant_id'] ?? 1;
      } else if (firstItem.containsKey('menu') && firstItem['menu'] is Map) {
        // Check if merchant_id is nested in menu data
        final menuData = firstItem['menu'] as Map<String, dynamic>;
        merchantId = menuData['merchant_id'] ?? 1;
      }
    }

    print('CheckoutScreen: Using merchant_id: $merchantId for payment methods');

    Get.to(
      () => PaymentSelectionScreen(
        merchantId: merchantId,
        totalAmount: _calculateTotal(),
        onPaymentSelected: (paymentMethod, merchantPaymentMethod) {
          selectedPaymentMethod.value = paymentMethod;
          selectedMerchantPaymentMethod.value = merchantPaymentMethod;
          Get.back();
        },
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
}
