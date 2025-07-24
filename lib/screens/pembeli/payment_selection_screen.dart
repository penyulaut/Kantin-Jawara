import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../models/payment_method.dart';
import '../../models/merchant_payment_method.dart';
import '../../utils/app_theme.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final int merchantId;
  final double totalAmount;
  final VoidCallback? onPaymentMethodSelected;
  final Function(PaymentMethod, MerchantPaymentMethod?)? onPaymentSelected;

  const PaymentSelectionScreen({
    super.key,
    required this.merchantId,
    required this.totalAmount,
    this.onPaymentMethodSelected,
    this.onPaymentSelected,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  // Local state for merchant payment methods (not from PaymentController)
  final RxList<MerchantPaymentMethod> _merchantPaymentMethods =
      <MerchantPaymentMethod>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController());

    // Load merchant's specific available payment methods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMerchantPaymentMethods(controller);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Amount Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${widget.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Payment Methods List
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
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
                        'Loading payment methods...',
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

              if (_errorMessage.value.isNotEmpty) {
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
                        _errorMessage.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            _loadMerchantPaymentMethods(controller),
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

              if (_merchantPaymentMethods.isEmpty) {
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
                        'No payment methods available',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.royalBlueDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The merchant hasn\'t set up payment methods yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _loadMerchantPaymentMethods(controller),
                color: AppTheme.royalBlueDark,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _merchantPaymentMethods.length,
                  itemBuilder: (context, index) {
                    final merchantPaymentMethod =
                        _merchantPaymentMethods[index];
                    final paymentMethod = merchantPaymentMethod.paymentMethod;

                    if (paymentMethod == null) return const SizedBox.shrink();

                    return _buildPaymentMethodCard(
                      paymentMethod,
                      merchantPaymentMethod,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod paymentMethod,
    MerchantPaymentMethod merchantPaymentMethod,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showPaymentConfirmation(paymentMethod, merchantPaymentMethod);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightGray.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Payment Method Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.royalBlueDark.withOpacity(0.1),
                      AppTheme.usafaBlue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.royalBlueDark.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getPaymentMethodIcon(paymentMethod.name),
                  size: 28,
                  color: AppTheme.royalBlueDark,
                ),
              ),
              const SizedBox(width: 16),

              // Payment Method Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.royalBlueDark,
                      ),
                    ),
                    if (paymentMethod.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        paymentMethod.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (merchantPaymentMethod.details['account_number'] !=
                        null) ...[
                      Text(
                        'Account: ${merchantPaymentMethod.details['account_number']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.usafaBlue,
                        ),
                      ),
                    ],
                    if (merchantPaymentMethod.details['account_name'] !=
                        null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Name: ${merchantPaymentMethod.details['account_name']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlueDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.royalBlueDark,
                ),
              ),
            ],
          ),
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

  void _showPaymentConfirmation(
    PaymentMethod paymentMethod,
    MerchantPaymentMethod merchantPaymentMethod,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.royalBlueDark.withOpacity(0.1),
                        AppTheme.usafaBlue.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.royalBlueDark.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getPaymentMethodIcon(paymentMethod.name),
                    size: 24,
                    color: AppTheme.royalBlueDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    paymentMethod.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalBlueDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: AppTheme.mediumGray),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Details
            Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 12),

            if (merchantPaymentMethod.details['account_number'] != null) ...[
              _buildDetailRow(
                'Account Number',
                merchantPaymentMethod.details['account_number'],
                copyable: true,
              ),
            ],
            if (merchantPaymentMethod.details['account_name'] != null) ...[
              _buildDetailRow(
                'Account Name',
                merchantPaymentMethod.details['account_name'],
              ),
            ],
            _buildDetailRow(
              'Amount',
              'Rp ${widget.totalAmount.toStringAsFixed(0)}',
              isAmount: true,
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.royalBlueDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.royalBlueDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (widget.onPaymentSelected != null) {
                        widget.onPaymentSelected!(
                          paymentMethod,
                          merchantPaymentMethod,
                        );
                      } else {
                        // Default action - show payment proof upload
                        _showPaymentProofUpload(
                          paymentMethod,
                          merchantPaymentMethod,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalBlueDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool copyable = false,
    bool isAmount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
                      color: isAmount
                          ? AppTheme.goldenPoppy
                          : AppTheme.royalBlueDark,
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
                        backgroundColor: AppTheme.royalBlueDark,
                        colorText: Colors.white,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.royalBlueDark.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: AppTheme.royalBlueDark,
                      ),
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

  void _showPaymentProofUpload(
    PaymentMethod paymentMethod,
    MerchantPaymentMethod merchantPaymentMethod,
  ) {
    // This would navigate to a payment proof upload screen
    Get.snackbar(
      'Payment Selected',
      'Selected ${paymentMethod.name}. Payment proof upload feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.royalBlueDark,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Load payment methods specific to this merchant using efficient endpoint
  Future<void> _loadMerchantPaymentMethods(PaymentController controller) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      print(
        'PaymentSelectionScreen: Loading payment methods for merchant: ${widget.merchantId}',
      );
      final availablePaymentMethods = await controller
          .getAvailablePaymentMethodsWithFallback(widget.merchantId);

      print(
        'PaymentSelectionScreen: Found ${availablePaymentMethods.length} payment methods for merchant ${widget.merchantId}',
      );

      // Update local state instead of controller state
      _merchantPaymentMethods.value = availablePaymentMethods;
    } catch (e) {
      // Error handling
      _errorMessage.value = 'Failed to load payment methods: $e';
      print('Error loading merchant payment methods: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}
