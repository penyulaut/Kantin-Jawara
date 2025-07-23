import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pembeli_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../models/menu.dart';
import '../../models/payment_method.dart';
import '../../models/merchant_payment_method.dart';
import 'payment_selection_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final RxList<Map<String, dynamic>> cartItems;
  final PembeliController pembeliController = Get.find<PembeliController>();
  final PaymentController paymentController = Get.put(PaymentController());

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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...cartItems.map((item) => _buildOrderItem(item)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp ${_calculateTotal().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer Information
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Order Type
            const Text(
              'Order Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Dine In'),
                    subtitle: const Text('Eat at the restaurant'),
                    value: 'dine_in',
                    groupValue: selectedOrderType.value,
                    onChanged: (value) => selectedOrderType.value = value!,
                  ),
                  RadioListTile<String>(
                    title: const Text('Takeaway'),
                    subtitle: const Text('Take your order to go'),
                    value: 'takeaway',
                    groupValue: selectedOrderType.value,
                    onChanged: (value) => selectedOrderType.value = value!,
                  ),
                  RadioListTile<String>(
                    title: const Text('Delivery'),
                    subtitle: const Text('Deliver to your location'),
                    value: 'delivery',
                    groupValue: selectedOrderType.value,
                    onChanged: (value) => selectedOrderType.value = value!,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Card(
                child: InkWell(
                  onTap: () => _selectPaymentMethod(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          selectedPaymentMethod.value != null
                              ? _getPaymentMethodIcon(
                                  selectedPaymentMethod.value!.name,
                                )
                              : Icons.payment,
                          size: 24,
                          color: selectedPaymentMethod.value != null
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedPaymentMethod.value?.name ??
                                    'Select Payment Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: selectedPaymentMethod.value != null
                                      ? Colors.black
                                      : Colors.grey,
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
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            const Text(
              'Notes (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Add any special instructions...',
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
        child: Obx(
          () => ElevatedButton(
            onPressed: pembeliController.isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: pembeliController.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('${menu.name} x$quantity')),
          Text(
            'Rp ${(price * quantity).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
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
      Get.snackbar('Error', 'Please enter customer name');
      return;
    }

    if (customerPhoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter phone number');
      return;
    }

    if (selectedPaymentMethod.value == null) {
      Get.snackbar('Error', 'Please select a payment method');
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
    );

    if (success) {
      // Clear cart
      cartItems.clear();

      // Navigate back to orders
      Get.until((route) => route.isFirst);
      Get.snackbar(
        'Order Placed',
        'Your order has been placed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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
