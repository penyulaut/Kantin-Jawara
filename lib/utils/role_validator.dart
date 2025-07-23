import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/enums.dart';

/// Simple helper untuk validasi role di existing screens
class RoleValidator {
  /// Check if current user has required role and redirect if not
  static bool validateRole(
    List<UserRole> allowedRoles, {
    String? customMessage,
  }) {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      // Check if user is logged in
      if (currentUser == null) {
        _redirectToLogin('Please login to access this page');
        return false;
      }

      // Get user role
      final userRole = UserRole.fromString(currentUser.role ?? 'pembeli');

      // Check if user has required role
      if (!allowedRoles.contains(userRole)) {
        _showAccessDenied(
          customMessage ?? 'You don\'t have permission to access this page',
        );
        _redirectBasedOnRole(userRole);
        return false;
      }

      return true;
    } catch (e) {
      print('RoleValidator: Error - $e');
      _redirectToLogin('Authentication error, please login again');
      return false;
    }
  }

  /// Quick check for admin only
  static bool adminOnly({String? customMessage}) {
    return validateRole([UserRole.admin], customMessage: customMessage);
  }

  /// Quick check for penjual only
  static bool penjualOnly({String? customMessage}) {
    return validateRole([UserRole.penjual], customMessage: customMessage);
  }

  /// Quick check for pembeli only
  static bool pembeliOnly({String? customMessage}) {
    return validateRole([UserRole.pembeli], customMessage: customMessage);
  }

  /// Check if user has any of these roles
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
  static UserRole? getCurrentRole() {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) return null;

      return UserRole.fromString(currentUser.role ?? 'pembeli');
    } catch (e) {
      return null;
    }
  }

  /// Private helper methods
  static void _redirectToLogin(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Authentication Required',
        message,
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed('/login');
    });
  }

  static void _showAccessDenied(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Access Denied',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    });
  }

  static void _redirectBasedOnRole(UserRole role) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (role) {
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
    });
  }
}
