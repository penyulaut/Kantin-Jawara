import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/pembeli_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../models/transaction.dart';
import '../../models/payment_method.dart';
import '../../models/merchant_payment_method.dart';
import '../../utils/app_theme.dart';

class PaymentProofScreen extends StatelessWidget {
  final Transaction transaction;
  final PaymentMethod paymentMethod;
  final MerchantPaymentMethod merchantPaymentMethod;

  final RxString selectedImagePath = ''.obs;
  final RxString proofUrl = ''.obs;
  final RxBool useUrl = false.obs;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController paymentNoteController = TextEditingController();

  PaymentProofScreen({
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
        title: const Text('Upload Bukti Pembayaran'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Text(
              'Upload Bukti Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih cara upload bukti pembayaran atau berikan URL bukti pembayaran.',
              style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          useUrl.value = false;
                          selectedImagePath.value = '';
                          urlController.clear();
                          proofUrl.value = '';
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !useUrl.value
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !useUrl.value
                                ? [
                                    BoxShadow(
                                      color: AppTheme.darkGray.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Upload Foto',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !useUrl.value
                                    ? AppTheme.royalBlueDark
                                    : AppTheme.mediumGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          useUrl.value = true;
                          selectedImagePath.value = '';
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: useUrl.value
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: useUrl.value
                                ? [
                                    BoxShadow(
                                      color: AppTheme.darkGray.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Pakai URL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: useUrl.value
                                    ? AppTheme.royalBlueDark
                                    : AppTheme.mediumGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => !useUrl.value
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedImagePath.value.isEmpty
                              ? AppTheme.lightGray
                              : AppTheme.usafaBlue,
                          width: selectedImagePath.value.isEmpty ? 1 : 2,
                        ),
                      ),
                      child: selectedImagePath.value.isEmpty
                          ? _buildImagePicker()
                          : _buildImagePreview(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'URL Bukti Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.royalBlueDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.lightGray),
                          ),
                          child: TextField(
                            controller: urlController,
                            onChanged: (value) => proofUrl.value = value,
                            decoration: InputDecoration(
                              hintText:
                                  'https://example.com/bukti-pembayaran.jpg',
                              hintStyle: TextStyle(color: AppTheme.mediumGray),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              prefixIcon: Icon(
                                Icons.link,
                                color: AppTheme.goldenPoppy,
                              ),
                            ),
                          ),
                        ),
                        if (proofUrl.value.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.usafaBlue),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                proofUrl.value,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.lightGray,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: AppTheme.mediumGray,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Gagal memuat gambar',
                                          style: TextStyle(
                                            color: AppTheme.mediumGray,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: AppTheme.lightGray,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            color: AppTheme.usafaBlue,
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                          ),
                        ],
                        if (useUrl.value && proofUrl.value.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              urlController.clear();
                              proofUrl.value = '';
                            },
                            icon: Icon(Icons.clear, color: Colors.red),
                            label: Text(
                              'Hapus URL',
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 16),

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
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient:
                        ((!useUrl.value &&
                                selectedImagePath.value.isNotEmpty) ||
                            (useUrl.value && proofUrl.value.isNotEmpty))
                        ? LinearGradient(
                            colors: [
                              AppTheme.usafaBlue,
                              AppTheme.royalBlueDark,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    color:
                        ((useUrl.value && proofUrl.value.isEmpty) ||
                            (!useUrl.value && selectedImagePath.value.isEmpty))
                        ? AppTheme.lightGray
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          ((!useUrl.value &&
                                  selectedImagePath.value.isNotEmpty) ||
                              (useUrl.value && proofUrl.value.isNotEmpty))
                          ? () => _submitPaymentProof(
                              controller,
                              notesController.text,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Upload Bukti Pembayaran',
                            style: TextStyle(
                              color: selectedImagePath.value.isNotEmpty
                                  ? Colors.white
                                  : AppTheme.darkGray,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Payment Note (Opsional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lightGray),
              ),
              child: TextField(
                controller: paymentNoteController,
                maxLines: 2,
                maxLength: 255,
                decoration: InputDecoration(
                  hintText: 'Contoh: Sudah transfer via BCA, bayar cash, dll.',
                  hintStyle: TextStyle(color: AppTheme.mediumGray),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(
                    Icons.note_outlined,
                    color: AppTheme.goldenPoppy,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.goldenPoppy, Colors.orange[600]!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _markAsPaid,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Sudah Membayar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.lightGray),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Upload Nanti',
                  style: TextStyle(fontSize: 16, color: AppTheme.darkGray),
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

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: AppTheme.darkGray,
            ),
            const SizedBox(height: 16),
            Text(
              'Tap untuk pilih foto',
              style: TextStyle(fontSize: 16, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 8),
            Text(
              'JPG, PNG (max 2MB)',
              style: TextStyle(fontSize: 12, color: AppTheme.lightGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(selectedImagePath.value), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => selectedImagePath.value = '',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.royalBlueDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        if (fileSize > 2 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'Ukuran file terlalu besar. Maksimal 2MB.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: Icon(Icons.error, color: Colors.white),
          );
          return;
        }

        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Future<void> _markAsPaid() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Konfirmasi Pembayaran'),
          content: Text(
            'Apakah Anda yakin sudah melakukan pembayaran untuk pesanan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.royalBlueDark,
              ),
              child: Text(
                'Ya, Sudah Bayar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // Prevent dismissing while processing
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.goldenPoppy.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.goldenPoppy,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Menandai Sebagai Sudah Dibayar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mohon tunggu sebentar...',
                    style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final pembeliController = Get.find<PembeliController>();
      final result = await pembeliController.markTransactionAsPaid(
        transactionId: transaction.id!,
        paymentNote: paymentNoteController.text.trim().isEmpty
            ? null
            : paymentNoteController.text.trim(),
      );


      Get.back();

      if (result['success'] == true) {
        Get.snackbar(
          'Sukses',
          result['message'] ??
              'Transaksi berhasil ditandai sebagai sudah dibayar',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: Icon(Icons.check_circle, color: Colors.white),
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );

        try {
          Get.offAllNamed('/orders'); // Navigate to orders page
        } catch (e) {
          Get.until((route) => route.isFirst);
        }
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Gagal menandai pembayaran sebagai selesai',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog if still open
      Get.snackbar(
        'Error',
        'Gagal menandai pembayaran: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void _submitPaymentProof(PembeliController controller, String notes) async {
    if (!useUrl.value && selectedImagePath.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih foto bukti pembayaran terlebih dahulu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    if (useUrl.value && proofUrl.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Masukkan URL bukti pembayaran terlebih dahulu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // Prevent dismissing while uploading
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.usafaBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.usafaBlue,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Mengupload Bukti Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mohon tunggu sebentar...',
                    style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      Map<String, dynamic> result;
      PaymentController paymentController = Get.find<PaymentController>();

      if (useUrl.value) {
        result = await paymentController.uploadPaymentProofUrl(
          transactionId: transaction.id!,
          proofUrl: proofUrl.value,
        );
      } else {
        result = await paymentController.uploadPaymentProof(
          transactionId: transaction.id!,
          proofFile: File(selectedImagePath.value),
        );
      }

      Get.back();


      if (result['success'] == true) {
        Get.snackbar(
          'Sukses',
          result['message'] ?? 'Bukti pembayaran berhasil diupload',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: Icon(Icons.check_circle, color: Colors.white),
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );

        Get.back(); // Go back to order list
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Gagal upload bukti pembayaran',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog if still open
      Get.snackbar(
        'Error',
        'Gagal upload bukti pembayaran: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }
}
