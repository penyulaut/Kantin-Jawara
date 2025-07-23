import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/enums.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Observable states
  final Rx<AuthStatus> _authStatus = AuthStatus.unauthenticated.obs;
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  AuthStatus get authStatus => _authStatus.value;
  User? get currentUser => _currentUser.value;
  String get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;

  bool get isLoggedIn {
    // For synchronous getter, we'll check if currentUser exists
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

      if (result['success']) {
        final userData = result['data'];
        final user = User.fromJson(userData['user'] ?? userData);
        final token = userData['token'] ?? userData['access_token'];

        // Save user data and token
        await _authService.saveUser(user);
        await _authService.saveToken(token);

        _currentUser.value = user;
        _authStatus.value = AuthStatus.authenticated;

        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.TOP,
        );

        // Navigate to home screen
        Get.offAllNamed('/home');
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

        // Save user data and token
        await _authService.saveUser(user);
        await _authService.saveToken(token);

        _currentUser.value = user;
        _authStatus.value = AuthStatus.authenticated;

        Get.snackbar(
          'Success',
          'Registration successful!',
          snackPosition: SnackPosition.TOP,
        );

        // Langsung ke home screen setelah register sukses
        Get.offAllNamed('/home');
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

      // Navigate to login screen
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

  void clearError() {
    _errorMessage.value = '';
  }

  // Method untuk clear error saat navigasi
  void clearErrorOnNavigation() {
    _errorMessage.value = '';
    _isLoading.value = false;
  }

  // Method untuk initial check (tanpa auto navigate)
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
}
