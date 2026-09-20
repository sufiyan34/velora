import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_routes.dart';
import '../gateways/permission_gateway.dart';

class PermissionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route == null || route.isEmpty) {
      return null;
    }

    final gateway = PermissionGateway.to;

    // Public route
    if (!gateway.canAccessRoute(route)) {
      final currentUser = gateway.currentUser;

      // Not logged in → Login
      if (!currentUser.isLoggedIn) {
        return const RouteSettings(name: AppRoutes.login);
      }

      // Logged in but not allowed → Home
      return const RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}
