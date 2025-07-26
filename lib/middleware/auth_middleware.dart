import 'package:get/get.dart';
import '../utils/enums.dart';
import '../utils/route_guard.dart';

class AuthMiddleware extends GetMiddleware {
  final List<UserRole> allowedRoles;
  final String? redirectRoute;

  AuthMiddleware({required this.allowedRoles, this.redirectRoute});

  @override
  GetPage? onPageCalled(GetPage? page) {
    return super.onPageCalled(page);
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {

    final hasAccess = await RouteGuard.checkAccess(
      allowedRoles: allowedRoles,
      redirectRoute: redirectRoute,
    );

    if (!hasAccess) {
      return null; // This will prevent navigation to the requested route
    }

    return super.redirectDelegate(route);
  }
}

class AdminMiddleware extends AuthMiddleware {
  AdminMiddleware() : super(allowedRoles: [UserRole.admin]);
}

class PenjualMiddleware extends AuthMiddleware {
  PenjualMiddleware() : super(allowedRoles: [UserRole.penjual]);
}

class PembeliMiddleware extends AuthMiddleware {
  PembeliMiddleware() : super(allowedRoles: [UserRole.pembeli]);
}

class AuthenticatedMiddleware extends AuthMiddleware {
  AuthenticatedMiddleware()
    : super(allowedRoles: [UserRole.admin, UserRole.penjual, UserRole.pembeli]);
}

class GuestMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {

    final isAuthenticated = await RouteGuard.isAuthenticated();

    if (isAuthenticated) {

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
