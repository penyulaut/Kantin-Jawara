import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TransactionController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // Create new transaction (pembeli)
  Future<bool> createTransaction({
    required List<Map<String, dynamic>> items,
    required String customerName,
    required String customerPhone,
    required String orderType,
    String? notes,
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
        'items': items,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'order_type': orderType,
        'notes': notes,
      };

      final response = await _apiService.post(
        '/transactions',
        data: data,
        token: token,
      );

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Transaction created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to create transaction';
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

  // Get transaction by ID
  Future<Transaction?> getTransactionById(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return null;
      }

      final response = await _apiService.get('/transactions/$id', token: token);

      if (response['success']) {
        return Transaction.fromJson(response['data']);
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch transaction';
        return null;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete transaction (pembeli)
  Future<bool> deleteTransaction(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.delete(
        '/transactions/$id',
        token: token,
      );

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Transaction deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to delete transaction';
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

  // Calculate total from cart items
  double calculateTotal(List<Map<String, dynamic>> items) {
    double total = 0.0;
    for (final item in items) {
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      total += price * quantity;
    }
    return total;
  }

  // Validate cart items
  bool validateCartItems(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      _errorMessage.value = 'Cart is empty';
      return false;
    }

    for (final item in items) {
      if (item['menu_id'] == null ||
          item['quantity'] == null ||
          item['price'] == null) {
        _errorMessage.value = 'Invalid item data';
        return false;
      }

      final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      if (quantity <= 0) {
        _errorMessage.value = 'Invalid quantity';
        return false;
      }
    }

    return true;
  }

  // Format items for API request
  List<Map<String, dynamic>> formatItemsForRequest(
    List<Map<String, dynamic>> cartItems,
  ) {
    return cartItems
        .map(
          (item) => {
            'menu_id': item['menu_id'],
            'quantity': item['quantity'],
            'price': item['price'],
            'notes': item['notes'] ?? '',
          },
        )
        .toList();
  }
}
