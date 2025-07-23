import 'package:get/get.dart';
import '../utils/enums.dart';
import '../utils/route_guard.dart';

/// Helper class untuk navigasi yang aman berdasarkan role
class NavigationHelper {
  /// Navigate to route with permission check
  static Future<void> navigateTo(
    String route, {
    List<UserRole>? requiredRoles,
    bool clearStack = false,
  }) async {
    // If no required roles specified, just navigate
    if (requiredRoles == null || requiredRoles.isEmpty) {
      if (clearStack) {
        Get.offAllNamed(route);
      } else {
        Get.toNamed(route);
      }
      return;
    }

    // Check permission
    final hasAccess = await RouteGuard.checkAccess(allowedRoles: requiredRoles);

    if (hasAccess) {
      if (clearStack) {
        Get.offAllNamed(route);
      } else {
        Get.toNamed(route);
      }
    }
    // If no access, RouteGuard.checkAccess will handle the redirect
  }

  /// Navigate to user dashboard based on their role
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

  /// Navigate to admin dashboard (with permission check)
  static Future<void> navigateToAdmin() async {
    await navigateTo(
      '/admin',
      requiredRoles: [UserRole.admin],
      clearStack: true,
    );
  }

  /// Navigate to penjual dashboard (with permission check)
  static Future<void> navigateToPenjual() async {
    await navigateTo(
      '/penjual',
      requiredRoles: [UserRole.penjual],
      clearStack: true,
    );
  }

  /// Navigate to pembeli dashboard (with permission check)
  static Future<void> navigateToPembeli() async {
    await navigateTo(
      '/pembeli',
      requiredRoles: [UserRole.pembeli],
      clearStack: true,
    );
  }

  /// Check if current route is accessible and redirect if not
  static Future<void> validateCurrentRoute() async {
    final currentRoute = Get.currentRoute;
    print('NavigationHelper: Validating current route: $currentRoute');

    // Define route permissions
    final Map<String, List<UserRole>> routePermissions = {
      '/admin': [UserRole.admin],
      '/penjual': [UserRole.penjual],
      '/pembeli': [UserRole.pembeli],
    };

    // Check if current route needs permission
    if (routePermissions.containsKey(currentRoute)) {
      final requiredRoles = routePermissions[currentRoute]!;
      final hasAccess = await RouteGuard.checkAccess(
        allowedRoles: requiredRoles,
      );

      if (!hasAccess) {
        print(
          'NavigationHelper: Access denied for current route, redirecting...',
        );
        // RouteGuard.checkAccess will handle the redirect
      }
    }
  }

  /// Navigate back with fallback to dashboard
  static void navigateBack() {
    if (Get.previousRoute.isNotEmpty && Get.previousRoute != Get.currentRoute) {
      Get.back();
    } else {
      navigateToDashboard();
    }
  }

  /// Get appropriate dashboard route for user role
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

  /// Check if user can access a specific route
  static bool canAccessRoute(String route, UserRole? userRole) {
    final routePermissions = {
      '/admin': [UserRole.admin],
      '/penjual': [UserRole.penjual],
      '/pembeli': [UserRole.pembeli],
      '/login': <UserRole>[], // Accessible by all
      '/splash': <UserRole>[], // Accessible by all
    };

    if (!routePermissions.containsKey(route)) {
      // Unknown route, allow access for authenticated users
      return userRole != null;
    }

    final allowedRoles = routePermissions[route]!;

    // If empty list, accessible by everyone
    if (allowedRoles.isEmpty) {
      return true;
    }

    return userRole != null && allowedRoles.contains(userRole);
  }
}
