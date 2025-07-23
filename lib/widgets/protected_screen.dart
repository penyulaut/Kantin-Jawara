import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/route_guard.dart';
import '../utils/enums.dart';

/// Mixin yang dapat digunakan oleh StatefulWidget untuk menambahkan
/// route protection secara otomatis
mixin RouteProtectionMixin<T extends StatefulWidget> on State<T> {
  /// Override method ini untuk menentukan role yang diizinkan mengakses widget ini
  List<UserRole> get allowedRoles;

  /// Override untuk custom redirect route
  String? get customRedirectRoute => null;

  /// Override untuk custom access denied message
  String get accessDeniedMessage =>
      'You don\'t have permission to access this page';

  @override
  void initState() {
    super.initState();

    // Check access permission after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRouteAccess();
    });
  }

  Future<void> _checkRouteAccess() async {
    final hasAccess = await RouteGuard.checkAccess(
      allowedRoles: allowedRoles,
      redirectRoute: customRedirectRoute,
    );

    if (!hasAccess) {
      // Additional handling if needed
      onAccessDenied();
    }
  }

  /// Called when access is denied
  /// Override untuk custom behavior
  void onAccessDenied() {
    // Default implementation - you can override this
    print('RouteProtectionMixin: Access denied for ${T.toString()}');
  }

  /// Helper method untuk check permission dalam widget
  bool hasPermission() {
    return RouteGuard.hasAnyRole(allowedRoles);
  }

  /// Helper method untuk check specific role
  bool hasRole(UserRole role) {
    return RouteGuard.hasRole(role);
  }

  /// Show access denied message
  void showAccessDeniedMessage() {
    Get.snackbar(
      'Access Denied',
      accessDeniedMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}

/// Base class untuk screen yang memerlukan protection
abstract class ProtectedScreen extends StatefulWidget {
  const ProtectedScreen({super.key});

  /// Tentukan role yang diizinkan mengakses screen ini
  List<UserRole> get allowedRoles;

  /// Custom redirect route jika akses ditolak
  String? get customRedirectRoute => null;
}

/// Base State untuk ProtectedScreen
abstract class ProtectedScreenState<T extends ProtectedScreen> extends State<T>
    with RouteProtectionMixin {
  @override
  List<UserRole> get allowedRoles => widget.allowedRoles;

  @override
  String? get customRedirectRoute => widget.customRedirectRoute;

  /// Build method untuk screen content
  /// Override method ini di child class
  Widget buildScreenContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    // Check permission first
    if (!hasPermission()) {
      // Return loading atau access denied widget
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You don\'t have permission to access this page',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return buildScreenContent(context);
  }
}

/// Example usage screen untuk Pembeli
class ExamplePembeliScreen extends ProtectedScreen {
  const ExamplePembeliScreen({super.key});

  @override
  List<UserRole> get allowedRoles => [UserRole.pembeli];

  @override
  ProtectedScreenState<ExamplePembeliScreen> createState() =>
      _ExamplePembeliScreenState();
}

class _ExamplePembeliScreenState
    extends ProtectedScreenState<ExamplePembeliScreen> {
  @override
  Widget buildScreenContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembeli Screen'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(child: Text('Welcome, Pembeli!')),
    );
  }
}

/// Example usage screen untuk Penjual
class ExamplePenjualScreen extends ProtectedScreen {
  const ExamplePenjualScreen({super.key});

  @override
  List<UserRole> get allowedRoles => [UserRole.penjual];

  @override
  ProtectedScreenState<ExamplePenjualScreen> createState() =>
      _ExamplePenjualScreenState();
}

class _ExamplePenjualScreenState
    extends ProtectedScreenState<ExamplePenjualScreen> {
  @override
  Widget buildScreenContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjual Screen'),
        backgroundColor: Colors.green,
      ),
      body: const Center(child: Text('Welcome, Penjual!')),
    );
  }
}

/// Example usage screen untuk Admin
class ExampleAdminScreen extends ProtectedScreen {
  const ExampleAdminScreen({super.key});

  @override
  List<UserRole> get allowedRoles => [UserRole.admin];

  @override
  ProtectedScreenState<ExampleAdminScreen> createState() =>
      _ExampleAdminScreenState();
}

class _ExampleAdminScreenState
    extends ProtectedScreenState<ExampleAdminScreen> {
  @override
  Widget buildScreenContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
        backgroundColor: Colors.red,
      ),
      body: const Center(child: Text('Welcome, Admin!')),
    );
  }
}
