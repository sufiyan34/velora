import 'package:get/get.dart';

import '../constants/app_routes.dart';
import '../controllers/current_user_controller.dart';

enum AppPermission {
  // ===========================================================================
  // CUSTOMER
  // ===========================================================================

  viewHome,
  viewCategories,
  viewProducts,
  viewProductDetails,
  useSearch,

  viewWishlist,
  modifyWishlist,

  viewCart,
  modifyCart,

  checkout,
  placeOrder,

  viewOrders,
  viewOrderDetails,
  viewReturns,
  requestReturn,
  viewProfile,
  editProfile,

  viewAddresses,
  manageAddresses,

  useSupportChat,
  useAiChat,

  // ===========================================================================
  // ADMIN
  // ===========================================================================
  adminDashboard,

  manageOrders,
  manageProducts,
  manageCategories,
  manageInventory,
  manageCustomers,
  managePayments,

  manageCoupons,
  managePromotions,
  manageBanners,

  manageReviews,
  manageReturns,

  manageChat,
  manageReports,
  manageNotifications,

  manageAdminUsers,
  manageRoles,
  manageSettings,
  manageCms,
}

class PermissionGateway {
  PermissionGateway._();

  static PermissionGateway get to => PermissionGateway._();

  CurrentUserController get currentUser {
    return Get.find<CurrentUserController>();
  }

  // ===========================================================================
  // MAIN CHECK
  // ===========================================================================

  bool can(AppPermission permission) {
    final user = currentUser;

    // Super admin gets all application permissions.
    if (user.isSuperAdmin && user.isActive) {
      return true;
    }

    switch (permission) {
      // -----------------------------------------------------------------------
      // PUBLIC CUSTOMER PERMISSIONS
      // -----------------------------------------------------------------------

      case AppPermission.viewHome:
      case AppPermission.viewCategories:
      case AppPermission.viewProducts:
      case AppPermission.viewProductDetails:
      case AppPermission.useSearch:
        return true;

      // -----------------------------------------------------------------------
      // CUSTOMER AUTH REQUIRED
      // -----------------------------------------------------------------------

      case AppPermission.viewWishlist:
      case AppPermission.modifyWishlist:
      case AppPermission.viewCart:
      case AppPermission.modifyCart:
      case AppPermission.checkout:
      case AppPermission.placeOrder:
      case AppPermission.viewOrders:
      case AppPermission.viewOrderDetails:
      case AppPermission.viewReturns:
      case AppPermission.requestReturn:
      case AppPermission.viewProfile:
      case AppPermission.editProfile:
      case AppPermission.viewAddresses:
      case AppPermission.manageAddresses:
      case AppPermission.useSupportChat:
      case AppPermission.useAiChat:
        return user.isLoggedIn &&
            user.isActive &&
            (user.isCustomer || user.isAdmin || user.isSuperAdmin);

      // -----------------------------------------------------------------------
      // ADMIN
      // -----------------------------------------------------------------------

      case AppPermission.adminDashboard:
      case AppPermission.manageOrders:
      case AppPermission.manageProducts:
      case AppPermission.manageCategories:
      case AppPermission.manageInventory:
      case AppPermission.manageCustomers:
      case AppPermission.managePayments:
      case AppPermission.manageCoupons:
      case AppPermission.managePromotions:
      case AppPermission.manageBanners:
      case AppPermission.manageReviews:
      case AppPermission.manageReturns:
      case AppPermission.manageChat:
      case AppPermission.manageReports:
      case AppPermission.manageNotifications:
        return user.isLoggedIn &&
            user.isActive &&
            (user.isAdmin || user.isSuperAdmin);

      // -----------------------------------------------------------------------
      // SUPER ADMIN ONLY
      // -----------------------------------------------------------------------

      case AppPermission.manageAdminUsers:
      case AppPermission.manageRoles:
      case AppPermission.manageSettings:
      case AppPermission.manageCms:
        return user.isLoggedIn && user.isActive && user.isSuperAdmin;
    }
  }

  // ===========================================================================
  // ROUTE CHECK
  // ===========================================================================

  bool canAccessRoute(String route) {
    final permission = permissionForRoute(route);

    if (permission == null) {
      return true;
    }

    return can(permission);
  }

  AppPermission? permissionForRoute(String route) {
    switch (route) {
      // -----------------------------------------------------------------------
      // CUSTOMER
      // -----------------------------------------------------------------------

      case AppRoutes.home:
        return AppPermission.viewHome;

      case AppRoutes.categories:
        return AppPermission.viewCategories;

      case AppRoutes.products:
        return AppPermission.viewProducts;

      case AppRoutes.productDetails:
        return AppPermission.viewProductDetails;

      case AppRoutes.cart:
        return AppPermission.viewCart;

      case AppRoutes.wishlistScreen:
        return AppPermission.viewWishlist;

      case AppRoutes.checkout:
        return AppPermission.checkout;

      case AppRoutes.orders:
      case AppRoutes.myOrders:
        return AppPermission.viewOrders;

      case AppRoutes.orderDetails:
        return AppPermission.viewOrderDetails;
      case AppRoutes.productReturn:
        return AppPermission.viewReturns;

      case AppRoutes.deals:
      case AppRoutes.productSection:
        return AppPermission.viewProducts;
      case AppRoutes.profile:
        return AppPermission.viewProfile;

      // -----------------------------------------------------------------------
      // ADMIN
      // -----------------------------------------------------------------------

      case AppRoutes.adminDashboard:
        return AppPermission.adminDashboard;

      case AppRoutes.adminOrders:
      case AppRoutes.dispatchedOrders:
        return AppPermission.manageOrders;

      case AppRoutes.adminProducts:
      case AppRoutes.addProduct:
      case AppRoutes.editProduct:
        return AppPermission.manageProducts;

      case AppRoutes.adminCategories:
        return AppPermission.manageCategories;

      case AppRoutes.inventory:
        return AppPermission.manageInventory;

      case AppRoutes.adminCustomers:
        return AppPermission.manageCustomers;

      case AppRoutes.payments:
        return AppPermission.managePayments;

      case AppRoutes.adminSettings:
        return AppPermission.manageSettings;

      case AppRoutes.adminSetup:
        return AppPermission.manageAdminUsers;

      default:
        return null;
    }
  }

  // ===========================================================================
  // FUNCTION / ACTION GUARD
  // ===========================================================================

  bool allow(AppPermission permission, {String? deniedMessage}) {
    if (can(permission)) {
      return true;
    }

    deny(permission, message: deniedMessage);

    return false;
  }

  // ===========================================================================
  // EXECUTE FUNCTION ONLY WHEN ALLOWED
  // ===========================================================================

  T? run<T>(
    AppPermission permission,
    T Function() action, {
    String? deniedMessage,
  }) {
    if (!allow(permission, deniedMessage: deniedMessage)) {
      return null;
    }

    return action();
  }

  // ===========================================================================
  // EXECUTE ASYNC FUNCTION ONLY WHEN ALLOWED
  // ===========================================================================

  Future<T?> runAsync<T>(
    AppPermission permission,
    Future<T> Function() action, {
    String? deniedMessage,
  }) async {
    if (!allow(permission, deniedMessage: deniedMessage)) {
      return null;
    }

    return await action();
  }

  // ===========================================================================
  // DENIED MESSAGE
  // ===========================================================================

  void deny(AppPermission permission, {String? message}) {
    final text = message ?? defaultDeniedMessage(permission);

    Get.snackbar('Access Denied', text, snackPosition: SnackPosition.BOTTOM);
  }

  String defaultDeniedMessage(AppPermission permission) {
    final user = currentUser;

    if (!user.isLoggedIn) {
      return 'Please login to continue.';
    }

    if (!user.isActive) {
      return 'Your account is currently disabled.';
    }

    if (permission.toString().contains('manage')) {
      return 'You do not have permission to use this admin feature.';
    }

    return 'You do not have permission to perform this action.';
  }

  // ===========================================================================
  // PAGE ACCESS HELPER
  // ===========================================================================

  bool guardPage(
    AppPermission permission, {
    String? loginRoute,
    String? fallbackRoute,
  }) {
    if (can(permission)) {
      return true;
    }

    if (!currentUser.isLoggedIn &&
        loginRoute != null &&
        loginRoute.isNotEmpty) {
      Get.toNamed(loginRoute);
      return false;
    }

    if (fallbackRoute != null && fallbackRoute.isNotEmpty) {
      Get.offNamed(fallbackRoute);
      return false;
    }

    deny(permission);

    return false;
  }
}
