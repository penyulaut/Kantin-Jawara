import 'package:get/get.dart';
import '../models/merchant_payment_method.dart';
import '../models/payment_method.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MerchantPaymentMethodController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<MerchantPaymentMethod> _merchantPaymentMethods =
      <MerchantPaymentMethod>[].obs;
  final RxList<PaymentMethod> _availablePaymentMethods = <PaymentMethod>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<MerchantPaymentMethod> get merchantPaymentMethods =>
      _merchantPaymentMethods;
  List<PaymentMethod> get availablePaymentMethods => _availablePaymentMethods;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();    
    fetchAllPaymentMethods();
  }

  Future<void> fetchMerchantPaymentMethods() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }


      final paymentMethodsResponse = await _apiService.getPaymentMethods();

      if (!paymentMethodsResponse['success']) {
        _errorMessage.value = 'Failed to fetch available payment methods';
        return;
      }

      final List<dynamic> paymentMethodsData = paymentMethodsResponse['data'];
      final List<PaymentMethod> availablePaymentMethods = paymentMethodsData
          .map((json) => PaymentMethod.fromJson(json))
          .toList();


      List<MerchantPaymentMethod> allMerchantPaymentMethods = [];

      for (PaymentMethod paymentMethod in availablePaymentMethods) {
        if (paymentMethod.id == null) continue; 


        final response = await _apiService.getMerchantPaymentMethodsByPaymentId(
          token: token,
          paymentMethodId: paymentMethod.id!,
        );


        if (response['success']) {
          final dynamic data = response['data'];
          if (data is List && data.isNotEmpty) {
            final List<MerchantPaymentMethod> merchantPaymentMethods = data
                .map(
                  (json) => MerchantPaymentMethod.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();
            allMerchantPaymentMethods.addAll(merchantPaymentMethods);
          } else if (data is Map<String, dynamic>) {
            allMerchantPaymentMethods.add(MerchantPaymentMethod.fromJson(data));
          } else {
          }
        } else {
        }
      }

      _merchantPaymentMethods.value = allMerchantPaymentMethods;
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchAllPaymentMethods() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiService.get('/payment-methods');

      if (response['success']) {
        final List<dynamic> data = response['data'];
        _availablePaymentMethods.value = data
            .map((json) => PaymentMethod.fromJson(json))
            .toList();
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch payment methods';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchAvailablePaymentMethods(int merchantId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiService.get(
        '/merchants/$merchantId/payment-methods',
      );

      if (response['success']) {
        final List<dynamic> data = response['data'];
        _availablePaymentMethods.value = data
            .map((json) => PaymentMethod.fromJson(json))
            .toList();
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch available payment methods';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createMerchantPaymentMethod({
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
        await fetchMerchantPaymentMethods();
        Get.snackbar(
          'Success',
          'Payment method added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to add payment method';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateMerchantPaymentMethod({
    required int id,
    required int paymentMethodId,
    required String accountNumber,
    required String accountName,
    required bool isActive,
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
        'details': {
          'account_number': accountNumber,
          'account_name': accountName,
        },
        'is_active': isActive,
      };

      final response = await _apiService.put(
        '/merchant-payment-methods/$id',
        data: data,
        token: token,
      );

      if (response['success']) {
        await fetchMerchantPaymentMethods();
        Get.snackbar(
          'Success',
          'Payment method updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to update payment method';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
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
          'Payment method removed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to remove payment method';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<MerchantPaymentMethod?> getMerchantPaymentMethodById(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return null;
      }

      final response = await _apiService.get(
        '/merchant-payment-methods/$id',
        token: token,
      );

      if (response['success']) {
        return MerchantPaymentMethod.fromJson(response['data']);
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch payment method details';
        return null;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> togglePaymentMethodStatus(int id, bool isActive) async {
    try {
      final merchantPaymentMethod = _merchantPaymentMethods.firstWhere(
        (mpm) => mpm.id == id,
      );

      return await updateMerchantPaymentMethod(
        id: id,
        paymentMethodId: merchantPaymentMethod.paymentMethodId!,
        accountNumber: merchantPaymentMethod.details['account_number'] ?? '',
        accountName: merchantPaymentMethod.details['account_name'] ?? '',
        isActive: isActive,
      );
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  List<MerchantPaymentMethod> getActivePaymentMethods() {
    return _merchantPaymentMethods.where((mpm) => mpm.isActive).toList();
  }
}
