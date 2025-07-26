import 'dart:io';
import 'package:get/get.dart';
import '../models/payment_method.dart';
import '../models/merchant_payment_method.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/merchant_id_utils.dart';

class PaymentController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<PaymentMethod> _paymentMethods = <PaymentMethod>[].obs;
  final RxList<MerchantPaymentMethod> _merchantPaymentMethods =
      <MerchantPaymentMethod>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<MerchantPaymentMethod> get merchantPaymentMethods =>
      _merchantPaymentMethods;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchPaymentMethods();
  }

  Future<void> fetchPaymentMethods() async {
    Map<String, dynamic>? response;
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      response = await _apiService.get('/payment-methods', token: token);

      if (response['success'] == true) {
        final dynamic data = response['data'];

        if (data is List) {
          _paymentMethods.value = data
              .map((json) => PaymentMethod.fromJson(json))
              .toList();
        } else if (data is Map && data.containsKey('payment_methods')) {
          final List<dynamic> paymentMethodData = data['payment_methods'];
          _paymentMethods.value = paymentMethodData
              .map((json) => PaymentMethod.fromJson(json))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          final List<dynamic> paymentMethodData = data['data'];
          _paymentMethods.value = paymentMethodData
              .map((json) => PaymentMethod.fromJson(json))
              .toList();
        } else {
          _paymentMethods.value = [];
        }
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch payment methods';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      print('Debug - fetchPaymentMethods error: $e');
      if (response != null) {
        print('Debug - payment methods response: $response');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchMerchantPaymentMethods() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      print('PaymentController: Fetching merchant payment methods...');

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      final user = await _authService.getUser();
      if (user?.role != 'penjual') {
        _errorMessage.value =
            'Access denied: This endpoint is only for sellers';
        print('PaymentController: Access denied - user role: ${user?.role}');
        return;
      }

      final response = await _apiService.get(
        '/merchant-payment-methods',
        token: token,
      );

      print('PaymentController: Merchant payment methods response: $response');

      if (response['success']) {
        final responseData = response['data'];
        final List<dynamic> merchantPaymentMethodData;

        if (responseData is Map && responseData.containsKey('data')) {
          merchantPaymentMethodData = responseData['data'] ?? [];
        } else if (responseData is List) {
          merchantPaymentMethodData = responseData;
        } else {
          merchantPaymentMethodData = [];
        }

        _merchantPaymentMethods.value = merchantPaymentMethodData
            .map((json) => MerchantPaymentMethod.fromJson(json))
            .toList();

        print(
          'PaymentController: Parsed ${_merchantPaymentMethods.length} merchant payment methods',
        );
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch merchant payment methods';
        print('PaymentController: Error: ${_errorMessage.value}');
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      print('PaymentController: Exception in fetchMerchantPaymentMethods: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<MerchantPaymentMethod>> getAvailablePaymentMethodsForMerchant(
    int merchantId,
  ) async {
    try {
      print(
        'PaymentController: Fetching payment methods for merchant $merchantId',
      );
      final token = await _authService.getToken();
      final response = await _apiService.get(
        '/merchants/$merchantId/payment-methods',
        token: token,
      );

      print('PaymentController: Response for merchant $merchantId: $response');

      if (response['success'] && response['data'] is List) {
        final data = response['data'] as List;
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            MerchantIdUtils.validateMerchantData(
              requestedMerchantId: merchantId,
              responseData: item,
              showWarning: true,
            );

            MerchantIdUtils.debugMerchantMapping(item);
          }
        }
      }

      if (response['success']) {
        final responseData = response['data'];
        final List<dynamic> merchantPaymentMethodData;

        if (responseData is Map && responseData.containsKey('data')) {
          merchantPaymentMethodData = responseData['data'] ?? [];
        } else if (responseData is List) {
          merchantPaymentMethodData = responseData;
        } else {
          merchantPaymentMethodData = [];
        }

        final result = merchantPaymentMethodData
            .map((json) => MerchantPaymentMethod.fromJson(json))
            .toList();

        print('PaymentController: Parsed ${result.length} payment methods');
        return result;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch available payment methods';
        print(
          'PaymentController: Error fetching payment methods: ${_errorMessage.value}',
        );
        return [];
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return [];
    }
  }

  Future<bool> createPaymentMethod({
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {
        'name': name,
        'description': description,
        'is_active': isActive,
      };

      final response = await _apiService.post(
        '/payment-methods',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchPaymentMethods();
        Get.snackbar('Success', 'Payment method created successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to create payment method';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updatePaymentMethod({
    required int id,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _apiService.put(
        '/payment-methods/$id',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchPaymentMethods();
        Get.snackbar('Success', 'Payment method updated successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to update payment method';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deletePaymentMethod(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.delete(
        '/payment-methods/$id',
        token: token,
      );
      if (response['success']) {
        await fetchPaymentMethods();
        Get.snackbar('Success', 'Payment method deleted successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to delete payment method';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> configureMerchantPaymentMethod({
    required int paymentMethodId,
    required Map<String, dynamic> details,
    bool isActive = true,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {
        'payment_method_id': paymentMethodId,
        'details': details,
        'is_active': isActive,
      };

      final response = await _apiService.post(
        '/merchant-payment-methods',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchMerchantPaymentMethods();
        Get.snackbar('Success', 'Payment method configured successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to configure payment method';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateMerchantPaymentMethod({
    required int id,
    Map<String, dynamic>? details,
    bool? isActive,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = <String, dynamic>{};
      if (details != null) data['details'] = details;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _apiService.put(
        '/merchant-payment-methods/$id',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchMerchantPaymentMethods();
        Get.snackbar(
          'Success',
          'Payment method configuration updated successfully',
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ??
            'Failed to update payment method configuration';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteMerchantPaymentMethod(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.delete(
        '/merchant-payment-methods/$id',
        token: token,
      );
      if (response['success']) {
        await fetchMerchantPaymentMethods();
        Get.snackbar(
          'Success',
          'Payment method configuration deleted successfully',
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ??
            'Failed to delete payment method configuration';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void setMerchantPaymentMethods(List<MerchantPaymentMethod> methods) {
    _merchantPaymentMethods.value = methods;
  }

  Future<List<MerchantPaymentMethod>> getAvailablePaymentMethodsWithFallback(
    int merchantId,
  ) async {
    try {
      var result = await getAvailablePaymentMethodsForMerchant(merchantId);

      if (result.isEmpty) {
        print(
          'PaymentController: No payment methods found for merchant_id $merchantId, checking if this is a user_id issue...',
        );

        final token = await _authService.getToken();
        final fallbackResponse = await _apiService.get(
          '/users/$merchantId/payment-methods',
          token: token,
        );

        if (fallbackResponse['success'] && fallbackResponse['data'] is List) {
          final data = fallbackResponse['data'] as List;
          result = data
              .map((json) => MerchantPaymentMethod.fromJson(json))
              .toList();

          print(
            'PaymentController: Found ${result.length} payment methods using user_id $merchantId',
          );

          CustomSnackbar.showInfo(
            title: 'Info',
            message: 'Using user ID $merchantId for payment methods',
          );
        }
      }

      return result;
    } catch (e) {
      print(
        'PaymentController: Error in getAvailablePaymentMethodsWithFallback: $e',
      );
      return [];
    }
  }

  Future<Map<String, dynamic>> uploadPaymentProof({
    required int transactionId,
    required File proofFile,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return {'success': false, 'message': 'User not authenticated'};
      }

      final response = await _apiService.uploadPaymentProof(
        transactionId: transactionId,
        proofFile: proofFile,
        token: token,
      );

      if (response['message'] == "Bukti pembayaran berhasil diupload") {
        final message =
            response['message'] ?? 'Bukti pembayaran berhasil diupload';
        final proofUrl = response['proof_url'];

        return {'success': true, 'message': message, 'proof_url': proofUrl};
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to upload payment proof';
        return {'success': false, 'message': _errorMessage.value};
      }
    } catch (e) {
      _errorMessage.value = 'Error uploading payment proof: $e';
      return {'success': false, 'message': _errorMessage.value};
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> uploadPaymentProofUrl({
    required int transactionId,
    required String proofUrl,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return {'success': false, 'message': 'User not authenticated'};
      }

      final response = await _apiService.uploadPaymentProofUrl(
        token: token,
        transactionId: transactionId,
        proofUrl: proofUrl,
      );

      print('PaymentController: uploadPaymentProofUrl response: $response');

      if (response['message'] == "Bukti pembayaran berhasil diupload") {
        final apiResponse = response['data'];
        final message =
            apiResponse['message'] ?? 'Bukti pembayaran berhasil diupload';

        print('PaymentController: Extracted message: $message');

        return {'success': true, 'message': message};
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to upload payment proof URL';
        return {'success': false, 'message': _errorMessage.value};
      }
    } catch (e) {
      _errorMessage.value = 'Error uploading payment proof URL: $e';
      return {'success': false, 'message': _errorMessage.value};
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> markAsPaid({required int transactionId}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.markPaymentAsPaid(
        transactionId: transactionId,
        token: token,
      );

      if (response['success'] == true) {
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to mark payment as paid';
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error marking payment as paid: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
