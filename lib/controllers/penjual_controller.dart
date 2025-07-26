import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class PenjualController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<TransactionStatus?> selectedStatus = Rx<TransactionStatus?>(null);

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
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      final response = await _apiService.get(
        '/penjual/transactions',
        token: token,
      );


      if (response['success']) {
        final List<dynamic> transactionData = response['data'];

        _transactions.value = transactionData.map((json) {
          try {
            return Transaction.fromJson(json);
          } catch (e) {
            rethrow;
          }
        }).toList();

      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch transactions';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Transaction?> getTransactionById(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return null;
      }

      final response = await _apiService.get(
        '/penjual/transactions/$id',
        token: token,
      );
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
    }
  }

  Future<bool> updateTransactionStatus({
    required int transactionId,
    required TransactionStatus status,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {'status': status.toString().split('.').last};
      final response = await _apiService.put(
        '/penjual/transactions/$transactionId/status',
        data: data,
        token: token,
      );

      if (response['success']) {
        await fetchTransactions(); // Refresh list
        Get.snackbar('Success', 'Transaction status updated successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to update transaction status';
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

  List<Transaction> getPendingTransactions() {
    return getTransactionsByStatus(TransactionStatus.pending);
  }

  List<Transaction> getActiveTransactions() {
    return _transactions
        .where(
          (transaction) =>
              transaction.status == TransactionStatus.paid ||
              transaction.status == TransactionStatus.confirmed ||
              transaction.status == TransactionStatus.ready,
        )
        .toList();
  }

  List<Transaction> getCompletedTransactions() {
    return getTransactionsByStatus(TransactionStatus.completed);
  }

  double getTotalSales() {
    double total = 0.0;
    try {
      for (var transaction in _transactions) {
        if (transaction.status != TransactionStatus.pending) {
          total += transaction.totalPrice;
        }
      }
    } catch (e) {
    }
    return total;
  }

  int getTotalOrders() {
    return _transactions.length;
  }

  int getTotalCompletedOrders() {
    return getCompletedTransactions().length;
  }

  Map<String, int> getOrdersByStatus() {
    final Map<String, int> ordersByStatus = {};
    for (TransactionStatus status in TransactionStatus.values) {
      ordersByStatus[status.toString().split('.').last] =
          getTransactionsByStatus(status).length;
    }
    return ordersByStatus;
  }

  List<Transaction> getTodaysTransactions() {
    final today = DateTime.now();
    return _transactions.where((transaction) {
      if (transaction.createdAt == null) return false;
      final transactionDate = transaction.createdAt!;
      return transactionDate.year == today.year &&
          transactionDate.month == today.month &&
          transactionDate.day == today.day;
    }).toList();
  }

  double getTodaysSales() {
    return _transactions
        .where((t) => t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.totalPrice);
  }

  void setStatusFilter(TransactionStatus? status) {
    selectedStatus.value = status;
  }

  List<Transaction> getFilteredTransactions() {
    if (selectedStatus.value == null) {
      return _transactions;
    }
    return _transactions
        .where((t) => t.status == selectedStatus.value)
        .toList();
  }
}
