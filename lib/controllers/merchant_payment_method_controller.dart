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
    // Don't auto-fetch on init to avoid 403 errors
    // fetchMerchantPaymentMethods();
    fetchAllPaymentMethods();
  }

  // Fetch merchant's payment methods
  Future<void> fetchMerchantPaymentMethods() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        print('MerchantPaymentMethodController: No token found');
        return;
      }

      print(
        'MerchantPaymentMethodController: Fetching with token: ${token.substring(0, 20)}...',
      );

      // First, get available payment methods to get their IDs
      final paymentMethodsResponse = await _apiService.getPaymentMethods();

      if (!paymentMethodsResponse['success']) {
        _errorMessage.value = 'Failed to fetch available payment methods';
        return;
      }

      final List<dynamic> paymentMethodsData = paymentMethodsResponse['data'];
      final List<PaymentMethod> availablePaymentMethods = paymentMethodsData
          .map((json) => PaymentMethod.fromJson(json))
          .toList();

      print(
        'MerchantPaymentMethodController: Found ${availablePaymentMethods.length} available payment methods',
      );

      // Now fetch merchant payment methods for each available payment method
      List<MerchantPaymentMethod> allMerchantPaymentMethods = [];

      for (PaymentMethod paymentMethod in availablePaymentMethods) {
        if (paymentMethod.id == null) continue; // Skip if ID is null

        print(
          'MerchantPaymentMethodController: Fetching merchant payment methods for payment method ID ${paymentMethod.id}',
        );

        final response = await _apiService.getMerchantPaymentMethodsByPaymentId(
          token: token,
          paymentMethodId: paymentMethod.id!,
        );

        print(
          'MerchantPaymentMethodController: Response for payment method ${paymentMethod.id}: $response',
        );

        if (response['success']) {
          final dynamic data = response['data'];
          if (data is List && data.isNotEmpty) {
            // Multiple merchant payment methods for this payment method
            final List<MerchantPaymentMethod> merchantPaymentMethods = data
                .map(
                  (json) => MerchantPaymentMethod.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();
            allMerchantPaymentMethods.addAll(merchantPaymentMethods);
            print(
              'MerchantPaymentMethodController: Found ${merchantPaymentMethods.length} merchant payment methods for payment method ${paymentMethod.id}',
            );
          } else if (data is Map<String, dynamic>) {
            // Single merchant payment method
            allMerchantPaymentMethods.add(MerchantPaymentMethod.fromJson(data));
            print(
              'MerchantPaymentMethodController: Found 1 merchant payment method for payment method ${paymentMethod.id}',
            );
          } else {
            print(
              'MerchantPaymentMethodController: No merchant payment methods configured for payment method ${paymentMethod.id} (${paymentMethod.name})',
            );
          }
        } else {
          print(
            'MerchantPaymentMethodController: Error fetching merchant payment methods for payment method ${paymentMethod.id}: ${response['message']}',
          );
        }
      }

      _merchantPaymentMethods.value = allMerchantPaymentMethods;
      print(
        'MerchantPaymentMethodController: Total merchant payment methods found: ${allMerchantPaymentMethods.length}',
      );
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      print('MerchantPaymentMethodController: Error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Get all available payment methods
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

  // Get available payment methods for a merchant
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

  // Create merchant payment method
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

  // Update merchant payment method
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

  // Delete merchant payment method
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

  // Get merchant payment method by ID
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

  // Toggle payment method status
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

  // Get active payment methods only
  List<MerchantPaymentMethod> getActivePaymentMethods() {
    return _merchantPaymentMethods.where((mpm) => mpm.isActive).toList();
  }
}
