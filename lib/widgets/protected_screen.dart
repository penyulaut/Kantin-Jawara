import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/route_guard.dart';
import '../utils/enums.dart';

mixin RouteProtectionMixin<T extends StatefulWidget> on State<T> {
  List<UserRole> get allowedRoles;

  String? get customRedirectRoute => null;

  String get accessDeniedMessage =>
      'You don\'t have permission to access this page';

  @override
  void initState() {
    super.initState();

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
      onAccessDenied();
    }
  }

  void onAccessDenied() {
  }

  bool hasPermission() {
    return RouteGuard.hasAnyRole(allowedRoles);
  }

  bool hasRole(UserRole role) {
    return RouteGuard.hasRole(role);
  }

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

abstract class ProtectedScreen extends StatefulWidget {
  const ProtectedScreen({super.key});

  List<UserRole> get allowedRoles;

  String? get customRedirectRoute => null;
}

abstract class ProtectedScreenState<T extends ProtectedScreen> extends State<T>
    with RouteProtectionMixin {
  @override
  List<UserRole> get allowedRoles => widget.allowedRoles;

  @override
  String? get customRedirectRoute => widget.customRedirectRoute;

  Widget buildScreenContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (!hasPermission()) {
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
