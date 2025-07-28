import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/pembeli_controller.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';

class PaymentProofUploadScreen extends StatelessWidget {
  final Transaction transaction;
  final PaymentController paymentController = Get.find<PaymentController>();

  PaymentProofUploadScreen({super.key, required this.transaction});

  final RxBool isUploading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString proofUrl = ''.obs;
  final RxBool useUrl = false.obs;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController paymentNoteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unggah Bukti Pembayaran'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalBlueDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${transaction.id}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.goldenPoppy.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.goldenPoppy),
                        ),
                        child: Text(
                          transaction.status
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldenPoppy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                      Text(
                        'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.royalBlueDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Upload Payment Proof',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload a clear image of your payment receipt or provide a URL to your payment proof.',
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
                          selectedImage.value = null;
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
                              'Upload Image',
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
                          selectedImage.value = null;
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
                              'Use URL',
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
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedImage.value != null
                              ? AppTheme.usafaBlue
                              : AppTheme.lightGray,
                          width: selectedImage.value != null ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.darkGray.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: selectedImage.value != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                selectedImage.value!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 48,
                                      color: AppTheme.goldenPoppy,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to select image',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.darkGray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Supported: JPG, PNG (Max 2MB)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Proof URL',
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
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.darkGray.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: urlController,
                            onChanged: (value) => proofUrl.value = value,
                            decoration: InputDecoration(
                              hintText: 'https://example.com/payment-proof.jpg',
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
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.darkGray.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                                          'Failed to load image',
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
                      ],
                    ),
            ),

            if (selectedImage.value != null && !useUrl.value) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.edit, color: AppTheme.usafaBlue),
                      label: Text(
                        'Change Image',
                        style: TextStyle(color: AppTheme.usafaBlue),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.usafaBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => selectedImage.value = null,
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
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
                label: Text('Clear URL', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Center(
              child: Obx(
                () => Container(
                  width: 250,
                  decoration: BoxDecoration(
                    gradient:
                        ((!useUrl.value && selectedImage.value != null) ||
                                (useUrl.value && proofUrl.value.isNotEmpty)) &&
                            !isUploading.value
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
                            (!useUrl.value && selectedImage.value == null) ||
                            isUploading.value)
                        ? AppTheme.lightGray
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          ((!useUrl.value && selectedImage.value != null) ||
                                  (useUrl.value &&
                                      proofUrl.value.isNotEmpty)) &&
                              !isUploading.value
                          ? _uploadProof
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: isUploading.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Uploading...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Upload Payment Proof',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        ((!useUrl.value &&
                                                selectedImage.value != null) ||
                                            (useUrl.value &&
                                                proofUrl.value.isNotEmpty))
                                        ? Colors.white
                                        : AppTheme.mediumGray,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Payment Note (Optional)',
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
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGray.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: paymentNoteController,
                maxLines: 2,
                maxLength: 255,
                decoration: InputDecoration(
                  hintText: 'e.g., Paid via BCA transfer, OVO, cash, etc.',
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

            Center(
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.goldenPoppy, Colors.orange.shade600],
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
                          'Mark as Paid',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.usafaBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.usafaBlue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.usafaBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.usafaBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Upload a clear photo of your payment receipt or provide a URL\n'
                    '• Make sure all transaction details are visible\n'
                    '• Supported formats: JPG, PNG (Maximum 2MB) or valid image URLs\n'
                    '• Click "Mark as Paid" to confirm payment completion',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGray,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        final fileSize = await file.length();
        if (fileSize > 2 * 1024 * 1024) {
          Get.snackbar(
            'File Too Large',
            'Please select an image smaller than 2MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: Icon(Icons.error, color: Colors.white),
          );
          return;
        }

        selectedImage.value = file;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Future<void> _uploadProof() async {
    if (!useUrl.value && selectedImage.value == null) return;
    if (useUrl.value && proofUrl.value.isEmpty) return;

    try {
      isUploading.value = true;

      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
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

      if (useUrl.value) {
        result = await paymentController.uploadPaymentProofUrl(
          transactionId: transaction.id!,
          proofUrl: proofUrl.value,
        );
      } else {
        result = await paymentController.uploadPaymentProof(
          transactionId: transaction.id!,
          proofFile: selectedImage.value!,
        );
      }

      Get.back(); // Close loading dialog

      print('PaymentProofUploadScreen result: $result'); // Debug log

      if (result['success'] == true) {
        String successMessage =
            result['message'] ??
            'Bukti pembayaran berhasil diupload dan sedang diproses';

        print(
          'Showing success snackbar with message: $successMessage',
        ); // Debug log

        // Use SchedulerBinding to ensure snackbar shows after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            '✅ Upload Berhasil!',
            successMessage,
            backgroundColor: AppTheme.green,
            colorText: Colors.white,
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            duration: Duration(seconds: 4),
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.all(16),
            borderRadius: 12,
            boxShadows: [
              BoxShadow(
                color: AppTheme.green.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            shouldIconPulse: true,
            barBlur: 20,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            forwardAnimationCurve: Curves.easeOutBack,
          );
        });

        // Wait a bit before navigating back to ensure snackbar shows
        await Future.delayed(Duration(milliseconds: 1000));

        if (Get.currentRoute.contains('PaymentProofUploadScreen')) {
          Get.back(result: true);
        }
      } else {
        String errorMessage =
            result['message'] ?? 'Gagal upload bukti pembayaran';
        print(
          'Showing error snackbar with message: $errorMessage',
        ); // Debug log

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        'Error',
        'Gagal mengunggah: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isUploading.value = false;
    }
  }

  void _markAsPaid() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(
            color: AppTheme.royalBlueDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin telah menyelesaikan pembayaran untuk Pesanan? #${transaction.id}?',
          style: TextStyle(color: AppTheme.darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              Get.dialog(
                WillPopScope(
                  onWillPop: () async => false,
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
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
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
                    '🎉 Pembayaran Dikonfirmasi!',
                    result['message'] ??
                        'Transaksi berhasil ditandai sebagai sudah dibayar. Pesanan Anda akan segera diproses.',
                    backgroundColor: AppTheme.green,
                    colorText: Colors.white,
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.payment, color: Colors.white, size: 20),
                    ),
                    duration: Duration(seconds: 4),
                    snackPosition: SnackPosition.TOP,
                    margin: EdgeInsets.all(16),
                    borderRadius: 12,
                    boxShadows: [
                      BoxShadow(
                        color: AppTheme.green.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                    shouldIconPulse: true,
                    barBlur: 20,
                    isDismissible: true,
                    dismissDirection: DismissDirection.horizontal,
                    forwardAnimationCurve: Curves.easeOutBack,
                  );

                  try {
                    Get.offAllNamed('/orders');
                  } catch (e) {
                    Get.until((route) => route.isFirst);
                  }
                } else {
                  Get.snackbar(
                    'Error',
                    result['message'] ??
                        'Gagal menandai pembayaran sebagai selesai',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    icon: Icon(Icons.error, color: Colors.white),
                    snackPosition: SnackPosition.TOP,
                    margin: EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                }
              } catch (e) {
                if (Get.isDialogOpen == true) Get.back();

                Get.snackbar(
                  'Error',
                  'Gagal memproses: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: Icon(Icons.error, color: Colors.white),
                  snackPosition: SnackPosition.TOP,
                  margin: EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldenPoppy,
              foregroundColor: Colors.white,
            ),
            child: Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }
}
