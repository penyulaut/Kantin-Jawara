import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/enums.dart';
import '../utils/route_guard.dart';

/// Mixin untuk widget yang membutuhkan permission checking
mixin PermissionMixin {
  /// Check if current user has permission to access this widget/page
  bool hasPermission(List<UserRole> allowedRoles) {
    return RouteGuard.hasAnyRole(allowedRoles);
  }

  /// Check if current user has specific role
  bool hasRole(UserRole role) {
    return RouteGuard.hasRole(role);
  }

  /// Show access denied dialog
  void showAccessDenied() {
    Get.dialog(
      AlertDialog(
        title: const Text('Access Denied'),
        content: const Text(
          'You don\'t have permission to perform this action.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  /// Redirect to user dashboard based on their role
  void redirectToDashboard() {
    final userRole = RouteGuard.getCurrentUserRole();

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
      case null:
        Get.offAllNamed('/login');
        break;
    }
  }

  /// Check permission and show appropriate message if denied
  bool checkPermissionWithMessage(
    List<UserRole> allowedRoles, {
    String? customMessage,
  }) {
    if (!hasPermission(allowedRoles)) {
      Get.snackbar(
        'Access Denied',
        customMessage ?? 'You don\'t have permission to perform this action',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }
}

/// Helper class untuk UI permissions
class PermissionHelper {
  /// Widget builder that only shows content if user has permission
  static Widget conditionalWidget({
    required List<UserRole> allowedRoles,
    required Widget child,
    Widget? fallback,
  }) {
    final hasPermission = RouteGuard.hasAnyRole(allowedRoles);

    if (hasPermission) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }

  /// Show widget only for specific role
  static Widget forRole({
    required UserRole role,
    required Widget child,
    Widget? fallback,
  }) {
    return conditionalWidget(
      allowedRoles: [role],
      child: child,
      fallback: fallback,
    );
  }

  /// Show widget only for admin
  static Widget adminOnly({required Widget child, Widget? fallback}) {
    return forRole(role: UserRole.admin, child: child, fallback: fallback);
  }

  /// Show widget only for penjual
  static Widget penjualOnly({required Widget child, Widget? fallback}) {
    return forRole(role: UserRole.penjual, child: child, fallback: fallback);
  }

  /// Show widget only for pembeli
  static Widget pembeliOnly({required Widget child, Widget? fallback}) {
    return forRole(role: UserRole.pembeli, child: child, fallback: fallback);
  }

  /// Show different widgets based on user role
  static Widget roleBasedWidget({
    Widget? adminWidget,
    Widget? penjualWidget,
    Widget? pembeliWidget,
    Widget? defaultWidget,
  }) {
    final userRole = RouteGuard.getCurrentUserRole();

    switch (userRole) {
      case UserRole.admin:
        return adminWidget ?? defaultWidget ?? const SizedBox.shrink();
      case UserRole.penjual:
        return penjualWidget ?? defaultWidget ?? const SizedBox.shrink();
      case UserRole.pembeli:
        return pembeliWidget ?? defaultWidget ?? const SizedBox.shrink();
      case null:
        return defaultWidget ?? const SizedBox.shrink();
    }
  }

  /// Get current user role display name
  static String getCurrentUserRoleDisplay() {
    final userRole = RouteGuard.getCurrentUserRole();

    switch (userRole) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.penjual:
        return 'Penjual';
      case UserRole.pembeli:
        return 'Pembeli';
      case null:
        return 'Guest';
    }
  }

  /// Check if URL/route should be accessible by current user
  static bool canAccessRoute(String route) {
    final userRole = RouteGuard.getCurrentUserRole();

    // Define route permissions
    final Map<String, List<UserRole>> routePermissions = {
      '/admin': [UserRole.admin],
      '/penjual': [UserRole.penjual],
      '/pembeli': [UserRole.pembeli],
      '/login': [], // Accessible by everyone
      '/splash': [], // Accessible by everyone
    };

    // If route not defined, allow access for authenticated users
    if (!routePermissions.containsKey(route)) {
      return userRole != null;
    }

    final allowedRoles = routePermissions[route]!;

    // If empty list, accessible by everyone (including guests)
    if (allowedRoles.isEmpty) {
      return true;
    }

    // Check if user has required role
    return userRole != null && allowedRoles.contains(userRole);
  }
}
