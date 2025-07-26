import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/enums.dart';
import '../utils/route_guard.dart';

mixin PermissionMixin {
  bool hasPermission(List<UserRole> allowedRoles) {
    return RouteGuard.hasAnyRole(allowedRoles);
  }

  bool hasRole(UserRole role) {
    return RouteGuard.hasRole(role);
  }

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

class PermissionHelper {
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

  static Widget adminOnly({required Widget child, Widget? fallback}) {
    return forRole(role: UserRole.admin, child: child, fallback: fallback);
  }

  static Widget penjualOnly({required Widget child, Widget? fallback}) {
    return forRole(role: UserRole.penjual, child: child, fallback: fallback);
  }

  static Widget pembeliOnly({required Widget child, Widget? fallback}) {
    return forRole(role: UserRole.pembeli, child: child, fallback: fallback);
  }

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

  static bool canAccessRoute(String route) {
    final userRole = RouteGuard.getCurrentUserRole();

    final Map<String, List<UserRole>> routePermissions = {
      '/admin': [UserRole.admin],
      '/penjual': [UserRole.penjual],
      '/pembeli': [UserRole.pembeli],
      '/login': [], // Accessible by everyone
      '/splash': [], // Accessible by everyone
    };

    if (!routePermissions.containsKey(route)) {
      return userRole != null;
    }

    final allowedRoles = routePermissions[route]!;

    if (allowedRoles.isEmpty) {
      return true;
    }

    return userRole != null && allowedRoles.contains(userRole);
  }
}
