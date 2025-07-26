import 'package:get/get.dart';
import '../utils/enums.dart';
import '../utils/route_guard.dart';

/// GetX Middleware untuk mengatur akses route berdasarkan role
class AuthMiddleware extends GetMiddleware {
  final List<UserRole> allowedRoles;
  final String? redirectRoute;

  AuthMiddleware({required this.allowedRoles, this.redirectRoute});

  @override
  GetPage? onPageCalled(GetPage? page) {
    // print('AuthMiddleware: Checking access for ${page?.name}');
    return super.onPageCalled(page);
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // print('AuthMiddleware: Checking access for route: ${route.location}');

    final hasAccess = await RouteGuard.checkAccess(
      allowedRoles: allowedRoles,
      redirectRoute: redirectRoute,
    );

    if (!hasAccess) {
      // print('AuthMiddleware: Access denied, redirecting...');
      return null; // This will prevent navigation to the requested route
    }

    return super.redirectDelegate(route);
  }
}

/// Specific middleware untuk role Admin
class AdminMiddleware extends AuthMiddleware {
  AdminMiddleware() : super(allowedRoles: [UserRole.admin]);
}

/// Specific middleware untuk role Penjual
class PenjualMiddleware extends AuthMiddleware {
  PenjualMiddleware() : super(allowedRoles: [UserRole.penjual]);
}

/// Specific middleware untuk role Pembeli
class PembeliMiddleware extends AuthMiddleware {
  PembeliMiddleware() : super(allowedRoles: [UserRole.pembeli]);
}

/// Middleware untuk halaman yang bisa diakses oleh user yang sudah login
class AuthenticatedMiddleware extends AuthMiddleware {
  AuthenticatedMiddleware()
    : super(allowedRoles: [UserRole.admin, UserRole.penjual, UserRole.pembeli]);
}

/// Middleware untuk halaman yang hanya bisa diakses oleh guest (belum login)
class GuestMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // print('GuestMiddleware: Checking if user is authenticated');

    final isAuthenticated = await RouteGuard.isAuthenticated();

    if (isAuthenticated) {
      // print('GuestMiddleware: User is authenticated, redirecting to dashboard');

      // Get user role and redirect to appropriate dashboard
      final userRole = RouteGuard.getCurrentUserRole();

      switch (userRole) {
        case UserRole.admin:
          return GetNavConfig.fromRoute('/admin');
        case UserRole.penjual:
          return GetNavConfig.fromRoute('/penjual');
        case UserRole.pembeli:
          return GetNavConfig.fromRoute('/pembeli');
        case null:
          return GetNavConfig.fromRoute('/login');
      }
    }

    return super.redirectDelegate(route);
  }
}
