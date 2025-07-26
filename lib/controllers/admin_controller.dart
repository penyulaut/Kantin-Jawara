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

  Future<void> fetchDashboardStats() async {
    Map<String, dynamic>? response;
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      response = await _apiService.get('/admin/dashboard', token: token);

      if (response['success'] == true) {
        final dynamic data = response['data'];
        if (data is Map<String, dynamic>) {
          Map<String, dynamic> stats = {};

          if (data.containsKey('users')) {
            final users = data['users'];
            stats['total_users'] = users['total'];
            stats['admins'] = users['admins'];
            stats['sellers'] = users['sellers'];
            stats['customers'] = users['customers'];
            stats['new_users_today'] = users['new_today'];
          }

          if (data.containsKey('transactions')) {
            final transactions = data['transactions'];
            stats['total_transactions'] = transactions['total'];
            stats['pending_transactions'] = transactions['pending'];
            stats['completed_transactions'] = transactions['completed'];
            stats['cancelled_transactions'] = transactions['cancelled'];
            stats['transactions_today'] = transactions['today'];
          }

          if (data.containsKey('revenue')) {
            final revenue = data['revenue'];
            stats['total_revenue'] = revenue['total'];
            stats['revenue_today'] = revenue['today'];
            stats['average_order'] = revenue['average_order'];
          }

          if (data.containsKey('menus')) {
            final menus = data['menus'];
            stats['total_menus'] = menus['total'];
            stats['available_menus'] = menus['available'];
            stats['out_of_stock_menus'] = menus['out_of_stock'];
          }

          _dashboardStats.value = stats;
        } else {
          _dashboardStats.value = {'error': 'Invalid data format'};
        }
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch dashboard stats';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      if (response != null) {
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchUsers() async {
    Map<String, dynamic>? response;
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      response = await _apiService.get('/admin/users', token: token);

      if (response['success'] == true) {
        final dynamic data = response['data'];

        if (data is List) {
          _users.value = data.map((json) => User.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('users')) {
          final List<dynamic> userData = data['users'];
          _users.value = userData.map((json) => User.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('data')) {
          final List<dynamic> userData = data['data'];
          _users.value = userData.map((json) => User.fromJson(json)).toList();
        } else {
          _users.value = [User.fromJson(data)];
        }
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to fetch users';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      if (response != null) {
      }
    } finally {
      _isLoading.value = false;
    }
  }

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


      if (response['success'] == true) {
        final dynamic data = response['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            final dynamic transactionList = data['data'];
            if (transactionList is List) {
              _transactions.value = transactionList
                  .map((json) {
                    try {
                      return Transaction.fromJson(json as Map<String, dynamic>);
                    } catch (e) {
                      return null;
                    }
                  })
                  .where((transaction) => transaction != null)
                  .cast<Transaction>()
                  .toList();
            } else {
              _errorMessage.value = 'Invalid transaction data format';
            }
          } else {
            _errorMessage.value = 'Invalid response structure';
          }
        } else if (data is List) {
          _transactions.value = data
              .map((json) {
                try {
                  return Transaction.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  return null;
                }
              })
              .where((transaction) => transaction != null)
              .cast<Transaction>()
              .toList();
        } else {
          _errorMessage.value = 'Invalid data format received';
        }
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch transactions';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
      update(); 
    }
  }

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

  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  Map<String, int> getTransactionStatistics() {
    final stats = <String, int>{};
    for (final transaction in _transactions) {
      final status = transaction.status.toString().split('.').last;
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }

  double getTotalRevenue() {
    return _transactions
        .where(
          (transaction) =>
              transaction.status.toString().split('.').last == 'completed',
        )
        .fold(0.0, (sum, transaction) => sum + transaction.totalPrice);
  }

  Map<String, int> getUserCountByRole() {
    final counts = <String, int>{};
    for (final user in _users) {
      final role = user.role ?? 'unknown';
      counts[role] = (counts[role] ?? 0) + 1;
    }
    return counts;
  }

  Future<bool> updateUser({
    required int userId,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.put(
        '/admin/users/$userId',
        data: {'name': name, 'email': email, 'role': role},
        token: token,
      );

      if (response['success'] == true) {
        await fetchUsers();
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to update user';
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> changeUserPassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.put(
        '/admin/users/$userId/password',
        data: {'password': newPassword, 'password_confirmation': newPassword},
        token: token,
      );

      if (response['success'] == true) {
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to change password';
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> toggleUserStatus(int userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.put(
        '/admin/users/$userId/status',
        data: {},
        token: token,
      );

      if (response['success'] == true) {
        await fetchUsers();
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to toggle user status';
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.delete(
        '/admin/users/$userId',
        token: token,
      );

      if (response['success'] == true) {
        await fetchUsers();
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to delete user';
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
