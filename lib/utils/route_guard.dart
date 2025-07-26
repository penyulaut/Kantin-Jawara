import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../utils/enums.dart';

class RouteGuard {
  static final AuthService _authService = AuthService();

  static Future<bool> checkAccess({
    required List<UserRole> allowedRoles,
    String? redirectRoute,
  }) async {
    try {
      final authController = Get.find<AuthController>();

      final isLoggedIn = await _authService.isLoggedIn();

      if (!isLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
        return false;
      }

      final currentUser = authController.currentUser;

      if (currentUser == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
        return false;
      }

      final userRole = UserRole.fromString(currentUser.role ?? 'pembeli');

      if (!allowedRoles.contains(userRole)) {

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Access Denied',
            'You don\'t have permission to access this page',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );

          _redirectToUserDashboard(userRole, redirectRoute);
        });
        return false;
      }

      return true;
    } catch (e) {
      Get.offAllNamed('/login');
      return false;
    }
  }

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
    }
  }
}
