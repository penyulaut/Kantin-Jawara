import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../utils/route_guard.dart';

class PermissionWrapper extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final bool showFallbackWhenDenied;
  final VoidCallback? onAccessDenied;

  const PermissionWrapper({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.showFallbackWhenDenied = false,
    this.onAccessDenied,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = RouteGuard.hasAnyRole(allowedRoles);

    if (hasPermission) {
      return child;
    }

    if (onAccessDenied != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onAccessDenied!();
      });
    }

    if (showFallbackWhenDenied && fallback != null) {
      return fallback!;
    }

    return const SizedBox.shrink();
  }
}

class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const AdminOnly({
    super.key,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      allowedRoles: const [UserRole.admin],
      showFallbackWhenDenied: showFallback,
      fallback: fallback,
      child: child,
    );
  }
}

class PenjualOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PenjualOnly({
    super.key,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      allowedRoles: const [UserRole.penjual],
      showFallbackWhenDenied: showFallback,
      fallback: fallback,
      child: child,
    );
  }
}

class PembeliOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PembeliOnly({
    super.key,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      allowedRoles: const [UserRole.pembeli],
      showFallbackWhenDenied: showFallback,
      fallback: fallback,
      child: child,
    );
  }
}

class RoleBasedWidget extends StatelessWidget {
  final Widget? adminWidget;
  final Widget? penjualWidget;
  final Widget? pembeliWidget;
  final Widget? guestWidget;
  final Widget? defaultWidget;

  const RoleBasedWidget({
    super.key,
    this.adminWidget,
    this.penjualWidget,
    this.pembeliWidget,
    this.guestWidget,
    this.defaultWidget,
  });

  @override
  Widget build(BuildContext context) {
    final userRole = RouteGuard.getCurrentUserRole();

    switch (userRole) {
      case UserRole.admin:
        return adminWidget ?? defaultWidget ?? const SizedBox.shrink();
      case UserRole.penjual:
        return penjualWidget ?? defaultWidget ?? const SizedBox.shrink();
      case UserRole.pembeli:
        return pembeliWidget ?? defaultWidget ?? const SizedBox.shrink();
      case null:
        return guestWidget ?? defaultWidget ?? const SizedBox.shrink();
    }
  }
}

class ProtectedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<UserRole> allowedRoles;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  const ProtectedAppBar({
    super.key,
    required this.title,
    required this.allowedRoles,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      allowedRoles: allowedRoles,
      fallback: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: automaticallyImplyLeading,
      ),
      showFallbackWhenDenied: true,
      child: AppBar(
        title: Text(title),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: leading,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProtectedButton extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final String? deniedMessage;

  const ProtectedButton({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.onPressed,
    this.style,
    this.deniedMessage,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = RouteGuard.hasAnyRole(allowedRoles);

    return ElevatedButton(
      style: style,
      onPressed: hasPermission
          ? onPressed
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    deniedMessage ??
                        'You don\'t have permission to perform this action',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
      child: child,
    );
  }
}
