import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/enums.dart';
import 'cart_controller.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final Rx<AuthStatus> _authStatus = AuthStatus.unauthenticated.obs;
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _isLoading = false.obs;

  AuthStatus get authStatus => _authStatus.value;
  User? get currentUser => _currentUser.value;
  String get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;

  bool get isLoggedIn {
    return _currentUser.value != null;
  }

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _currentUser.value = await _authService.getUser();
      _authStatus.value = AuthStatus.authenticated;
    } else {
      _authStatus.value = AuthStatus.unauthenticated;
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _authStatus.value = AuthStatus.loading;

      final result = await _apiService.login(email: email, password: password);
      print('AuthController: Login response: $result');

      if (result['success']) {
        final userData = result['data'];
        print('AuthController: User data: $userData');

        final user = User.fromJson(userData['user'] ?? userData);
        final token = userData['token'] ?? userData['access_token'];

        print('AuthController: Parsed user: ${user.toJson()}');
        print(
          'AuthController: Token extracted: ${token != null ? "YES (${token.substring(0, 20)}...)" : "NO"}',
        );

        await _authService.saveUser(user);
        await _authService.saveToken(token);

        final savedToken = await _authService.getToken();
        print(
          'AuthController: Token saved successfully: ${savedToken != null}',
        );

        _currentUser.value = user;
        _authStatus.value = AuthStatus.authenticated;

        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.TOP,
        );

        if (user.role == 'pembeli') {
          try {
            if (Get.isRegistered<CartController>()) {
              final cartController = Get.find<CartController>();
              Future.delayed(const Duration(milliseconds: 500), () {
                cartController.refreshCart();
              });
            }
          } catch (e) {
            print('AuthController: Error refreshing cart after login: $e');
          }
        }

        _navigateBasedOnRole(user.role ?? 'pembeli');
      } else {
        _errorMessage.value = result['message'];
        _authStatus.value = AuthStatus.error;

        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      _authStatus.value = AuthStatus.error;

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _apiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      if (result['success']) {
        final userData = result['data'];
        final user = User.fromJson(userData['user'] ?? userData);
        final token = userData['token'] ?? userData['access_token'];

        await _authService.saveUser(user);
        await _authService.saveToken(token);

        _currentUser.value = user;
        _authStatus.value = AuthStatus.authenticated;

        Get.snackbar(
          'Success',
          'Registration successful!',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        Future.delayed(const Duration(milliseconds: 2500), () {
          _navigateBasedOnRole(user.role ?? role);
        });
      } else {
        _errorMessage.value = result['message'];

        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;

      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        await _apiService.logout(token);
      }

      await _authService.clearUserData();
      _currentUser.value = null;
      _authStatus.value = AuthStatus.unauthenticated;

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error during logout',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      final result = await _apiService.getProfile(token: token);

      if (result['success']) {
        final userData = result['data'];
        final updatedUser = User.fromJson(userData['user'] ?? userData);

        await _authService.saveUser(updatedUser);
        _currentUser.value = updatedUser;

        print('AuthController: Profile fetched and updated successfully');
      } else {
        _errorMessage.value = result['message'];
        print('AuthController: Failed to fetch profile: ${result['message']}');
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      print('AuthController: Error fetching profile: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final result = await _apiService.updateProfile(
        token: token,
        data: {'name': name, 'email': email},
      );

      if (result['success']) {
        final userData = result['data'];
        final updatedUser = User.fromJson(userData['user'] ?? userData);

        await _authService.saveUser(updatedUser);
        _currentUser.value = updatedUser;

        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        _errorMessage.value = result['message'];
        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final result = await _apiService.changePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result['success']) {
        return true;
      } else {
        _errorMessage.value = result['message'];
        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final result = await _apiService.deleteAccount(token);

      if (result['success']) {
        await _authService.clearUserData();
        _currentUser.value = null;
        _authStatus.value = AuthStatus.unauthenticated;

        Get.snackbar(
          'Success',
          'Account deleted successfully',
          snackPosition: SnackPosition.TOP,
        );

        Get.offAllNamed('/login');
        return true;
      } else {
        _errorMessage.value = result['message'];
        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }

  void clearErrorOnNavigation() {
    _errorMessage.value = '';
    _isLoading.value = false;
  }

  Future<bool> checkInitialAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getUser();
        if (user != null) {
          _currentUser.value = user;
          _authStatus.value = AuthStatus.authenticated;
          return true;
        }
      }
      _authStatus.value = AuthStatus.unauthenticated;
      return false;
    } catch (e) {
      _authStatus.value = AuthStatus.unauthenticated;
      return false;
    }
  }

  void _navigateBasedOnRole(String role) {
    print('AuthController: Navigating based on role: "$role"');
    switch (role.toLowerCase()) {
      case 'admin':
        print('AuthController: Navigating to /admin');
        Get.offAllNamed('/admin');
        break;
      case 'pembeli':
      case 'buyer':
        print('AuthController: Navigating to /pembeli');
        Get.offAllNamed('/pembeli');
        break;
      case 'penjual':
      case 'seller':
        print('AuthController: Navigating to /penjual');
        Get.offAllNamed('/penjual');
        break;
      default:
        print('AuthController: Unknown role "$role", navigating to /home');
        Get.offAllNamed('/');
        break;
    }
  }

  Future<void> handleUnauthorizedAccess({
    String reason = 'Unauthorized access',
  }) async {
    print('AuthController: Handling unauthorized access - $reason');

    await clearUserData();

    Get.snackbar(
      'Access Denied',
      reason,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    Get.offAllNamed('/login');
  }

  Future<void> clearUserData() async {
    await _authService.clearUserData();
    _currentUser.value = null;
    _authStatus.value = AuthStatus.unauthenticated;
    clearError();
  }
}
