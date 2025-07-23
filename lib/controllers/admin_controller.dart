import 'package:get/get.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AdminController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<User> _users = <User>[].obs;
  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final RxMap<String, dynamic> _dashboardStats = <String, dynamic>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<User> get users => _users;
  List<Transaction> get transactions => _transactions;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  // Fetch dashboard statistics
  Future<void> fetchDashboardStats() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      final response = await _apiService.get('/admin/dashboard', token: token);

      if (response['success']) {
        _dashboardStats.value = response['data'];
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch dashboard stats';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch all users
  Future<void> fetchUsers() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      final response = await _apiService.get('/admin/users', token: token);

      if (response['success']) {
        final List<dynamic> userData = response['data'];
        _users.value = userData.map((json) => User.fromJson(json)).toList();
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to fetch users';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch user details by ID
  Future<User?> getUserDetails(int userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return null;
      }

      final response = await _apiService.get(
        '/admin/users/$userId',
        token: token,
      );

      if (response['success']) {
        return User.fromJson(response['data']);
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch user details';
        return null;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch all transactions
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
        '/admin/transactions',
        token: token,
      );

      if (response['success']) {
        final List<dynamic> transactionData = response['data'];
        _transactions.value = transactionData
            .map((json) => Transaction.fromJson(json))
            .toList();
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

  // Fetch transaction details by ID
  Future<Transaction?> getTransactionDetails(int transactionId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return null;
      }

      final response = await _apiService.get(
        '/admin/transactions/$transactionId',
        token: token,
      );

      if (response['success']) {
        return Transaction.fromJson(response['data']);
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch transaction details';
        return null;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Filter users by role
  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Get transaction statistics
  Map<String, int> getTransactionStatistics() {
    final stats = <String, int>{};
    for (final transaction in _transactions) {
      final status = transaction.status.toString().split('.').last;
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }

  // Get revenue statistics
  double getTotalRevenue() {
    return _transactions
        .where(
          (transaction) =>
              transaction.status.toString().split('.').last == 'completed',
        )
        .fold(0.0, (sum, transaction) => sum + transaction.totalPrice);
  }

  // Get user count by role
  Map<String, int> getUserCountByRole() {
    final counts = <String, int>{};
    for (final user in _users) {
      final role = user.role ?? 'unknown';
      counts[role] = (counts[role] ?? 0) + 1;
    }
    return counts;
  }
}
