import 'package:get/get.dart';
import '../utils/enums.dart';
import '../utils/route_guard.dart';

class NavigationHelper {
  static Future<void> navigateTo(
    String route, {
    List<UserRole>? requiredRoles,
    bool clearStack = false,
  }) async {
    if (requiredRoles == null || requiredRoles.isEmpty) {
      if (clearStack) {
        Get.offAllNamed(route);
      } else {
        Get.toNamed(route);
      }
      return;
    }

    final hasAccess = await RouteGuard.checkAccess(allowedRoles: requiredRoles);

    if (hasAccess) {
      if (clearStack) {
        Get.offAllNamed(route);
      } else {
        Get.toNamed(route);
      }
    }
  }

  static void navigateToDashboard() {
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

  static Future<void> navigateToAdmin() async {
    await navigateTo(
      '/admin',
      requiredRoles: [UserRole.admin],
      clearStack: true,
    );
  }

  static Future<void> navigateToPenjual() async {
    await navigateTo(
      '/penjual',
      requiredRoles: [UserRole.penjual],
      clearStack: true,
    );
  }

  static Future<void> navigateToPembeli() async {
    await navigateTo(
      '/pembeli',
      requiredRoles: [UserRole.pembeli],
      clearStack: true,
    );
  }

  static Future<void> validateCurrentRoute() async {
    final currentRoute = Get.currentRoute;

    final Map<String, List<UserRole>> routePermissions = {
      '/admin': [UserRole.admin],
      '/penjual': [UserRole.penjual],
      '/pembeli': [UserRole.pembeli],
    };

    if (routePermissions.containsKey(currentRoute)) {
      final requiredRoles = routePermissions[currentRoute]!;
      final hasAccess = await RouteGuard.checkAccess(
        allowedRoles: requiredRoles,
      );

      if (!hasAccess) {
      }
    }
  }

  static void navigateBack() {
    if (Get.previousRoute.isNotEmpty && Get.previousRoute != Get.currentRoute) {
      Get.back();
    } else {
      navigateToDashboard();
    }
  }

  static String getDashboardRoute(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return '/admin';
      case UserRole.penjual:
        return '/penjual';
      case UserRole.pembeli:
        return '/pembeli';
      case null:
        return '/login';
    }
  }

  static bool canAccessRoute(String route, UserRole? userRole) {
    final routePermissions = {
      '/admin': [UserRole.admin],
      '/penjual': [UserRole.penjual],
      '/pembeli': [UserRole.pembeli],
      '/login': <UserRole>[], // Accessible by all
      '/splash': <UserRole>[], // Accessible by all
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
