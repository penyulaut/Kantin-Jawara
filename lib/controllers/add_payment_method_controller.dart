import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AddPaymentMethodController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  Future<bool> addPaymentMethod({
    required int paymentMethodId,
    required String accountNumber,
    required String accountName,
    bool isActive = true,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        Get.snackbar('Error', 'Please login first');
        return false;
      }

      final data = {
        'payment_method_id': paymentMethodId,
        'details': {
          'account_number': accountNumber,
          'account_name': accountName,
        },
        'is_active': isActive,
      };


      final response = await _apiService.post(
        '/merchant-payment-methods',
        data: data,
        token: token,
      );


      if (response['success']) {
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to add payment method';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        'Failed to add payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
