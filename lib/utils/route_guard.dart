import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../utils/enums.dart';

/// Route Guard untuk mengatur akses berdasarkan role user
class RouteGuard {
  static final AuthService _authService = AuthService();

  /// Middleware untuk mengecek authentication dan authorization
  static Future<bool> checkAccess({
    required List<UserRole> allowedRoles,
    String? redirectRoute,
  }) async {
    try {
      // Get AuthController
      final authController = Get.find<AuthController>();

      // Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();

      if (!isLoggedIn) {
        // print('RouteGuard: User not logged in, redirecting to login');
        // Use WidgetsBinding to avoid calling during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
        return false;
      }

      // Get current user
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        // print('RouteGuard: Current user is null, redirecting to login');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
        return false;
      }

      // Check if user role is allowed
      final userRole = UserRole.fromString(currentUser.role ?? 'pembeli');

      if (!allowedRoles.contains(userRole)) {
        // print('RouteGuard: Access denied for role ${userRole.value}');

        // Show unauthorized message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Access Denied',
            'You don\'t have permission to access this page',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );

          // Redirect to appropriate route based on user role
          _redirectToUserDashboard(userRole, redirectRoute);
        });
        return false;
      }

      // print('RouteGuard: Access granted for role ${userRole.value}');
      return true;
    } catch (e) {
      // print('RouteGuard: Error checking access: $e');
      Get.offAllNamed('/login');
      return false;
    }
  }

  /// Redirect user to their appropriate dashboard
  static void _redirectToUserDashboard(UserRole userRole, String? customRoute) {
    if (customRoute != null) {
      Get.offAllNamed(customRoute);
      return;
    }

    switch (userRole) {
      case UserRole.admin:
        Get.offAllNamed('/admin');
        break;
      case UserRole.penjual:
        Get.offAllNamed('/penjual');
        break;
      case UserRole.pembeli:
        Get.offAllNamed('/pembeli');
        break;
    }
  }

  /// Check if current user has specific role
  static bool hasRole(UserRole requiredRole) {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) return false;

      final userRole = UserRole.fromString(currentUser.role ?? 'pembeli');
      return userRole == requiredRole;
    } catch (e) {
      return false;
    }
  }

  /// Check if current user has any of the specified roles
  static bool hasAnyRole(List<UserRole> roles) {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) return false;

      final userRole = UserRole.fromString(currentUser.role ?? 'pembeli');
      return roles.contains(userRole);
    } catch (e) {
      return false;
    }
  }

  /// Get current user role
  static UserRole? getCurrentUserRole() {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) return null;

      return UserRole.fromString(currentUser.role ?? 'pembeli');
    } catch (e) {
      return null;
    }
  }

  /// Check authentication status without redirecting
  static Future<bool> isAuthenticated() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      return isLoggedIn && currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Force logout and redirect to login
  static Future<void> forceLogout({String reason = 'Session expired'}) async {
    try {
      await _authService.clearUserData();

      final authController = Get.find<AuthController>();
      authController.clearError();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Session Expired',
          reason,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        Get.offAllNamed('/login');
      });
    } catch (e) {
      // print('RouteGuard: Error during force logout: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
    }
  }
}
