import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class PembeliController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      print('PembeliController: Starting fetchTransactions...');
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      print('PembeliController: Token exists: ${token != null}');

      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      print('PembeliController: Making API call to /pembeli/transactions');
      final response = await _apiService.getPembeliTransactions(token);

      print('PembeliController: Response: $response');

      if (response['success']) {
        // Handle nested response structure: response['data'] contains {message, data}
        final responseData = response['data'];
        final List<dynamic> transactionData;

        if (responseData is Map && responseData.containsKey('data')) {
          // API returns {"success": true, "data": {"message": "...", "data": [...]}}
          transactionData = responseData['data'] as List<dynamic>;
        } else if (responseData is List) {
          // Direct list format
          transactionData = responseData;
        } else {
          print('PembeliController: Unexpected response format: $responseData');
          transactionData = [];
        }

        print(
          'PembeliController: Found ${transactionData.length} transactions',
        );
        _transactions.value = transactionData
            .map((json) => Transaction.fromJson(json))
            .toList();
        print(
          'PembeliController: Successfully loaded ${_transactions.length} transactions',
        );
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch transactions';
        print('PembeliController: Error - ${_errorMessage.value}');

        // If unauthenticated, clear user data and redirect to login
        if (response['message']?.contains('Unauthenticated') == true ||
            response['message']?.contains('401') == true) {
          print(
            'PembeliController: Authentication failed, redirecting to login',
          );
          await _authService.clearUserData();
          Get.offAllNamed('/login'); // Redirect to login
        }
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      print('PembeliController: Exception - $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createTransaction({
    required double totalPrice,
    required List<Map<String, dynamic>> items,
    String? notes,
    String? customerName,
    String? customerPhone,
    String? orderType,
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
        'total_price': totalPrice,
        'items': items,
        'notes': notes,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'order_type': orderType ?? 'takeaway',
      };

      final response = await _apiService.post(
        '/transactions',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchTransactions(); // Refresh list
        Get.snackbar('Success', 'Order created successfully');
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to create order';
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

  Future<bool> uploadPaymentProof({
    required int transactionId,
    required String proofPath,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      // This would need multipart form data implementation in real app
      final data = {'proof': proofPath};

      final response = await _apiService.post(
        '/pembeli/transactions/$transactionId/proof',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchTransactions(); // Refresh list
        Get.snackbar('Success', 'Payment proof uploaded successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to upload payment proof';
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

  Future<bool> makePayment({
    required int transactionId,
    required double amount,
    required String method,
    String? proofPath,
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
        'transaction_id': transactionId,
        'amount': amount,
        'method': method,
        'proof': proofPath,
      };

      final response = await _apiService.post(
        '/payments',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchTransactions(); // Refresh list
        Get.snackbar('Success', 'Payment submitted successfully');
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to submit payment';
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

  Future<bool> cancelTransaction(int transactionId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {'status': 'cancelled'};
      final response = await _apiService.put(
        '/transactions/$transactionId',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchTransactions(); // Refresh list
        Get.snackbar('Success', 'Transaction cancelled successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to cancel transaction';
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

  List<Transaction> getTransactionsByStatus(TransactionStatus status) {
    return _transactions
        .where((transaction) => transaction.status == status)
        .toList();
  }

  Transaction? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }
}
