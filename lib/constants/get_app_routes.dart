import 'package:e_commerce/auth/access_denied_screen.dart';
import 'package:e_commerce/auth/admin_setup_screen.dart';
import 'package:e_commerce/auth/login_screen.dart';

import 'package:e_commerce/bindings/auth_binding.dart';
import 'package:e_commerce/bindings/cart_binding.dart';
import 'package:e_commerce/bindings/home_binding.dart';
import 'package:e_commerce/bindings/order_binding.dart';
import 'package:e_commerce/bindings/wishlist_binding.dart';

import 'package:e_commerce/constants/app_routes.dart';
import 'package:e_commerce/gateways/permission_middleware.dart';

import 'package:e_commerce/splash_screen.dart';

import 'package:e_commerce/testing/test_data_screen.dart';

import 'package:e_commerce/views/admin/categories_screen.dart';
import 'package:e_commerce/views/admin/products_screen.dart';

import 'package:e_commerce/views/customer/cart_screen.dart';
import 'package:e_commerce/views/customer/checkout_screen.dart';
import 'package:e_commerce/views/customer/home_page.dart';
import 'package:e_commerce/views/customer/order_details_screen.dart';
import 'package:e_commerce/views/customer/order_success_screen.dart';
import 'package:e_commerce/views/customer/orders_screen.dart';
import 'package:e_commerce/views/customer/product_details_screen.dart';
import 'package:e_commerce/views/customer/profile_screen.dart';
import 'package:e_commerce/views/customer/signup_screen.dart';
import 'package:e_commerce/views/customer/wishlist_screen.dart';

import 'package:get/get_navigation/src/routes/get_route.dart';

class GetAppRoutes {
  GetAppRoutes._();

  // ===========================================================================
  // CUSTOMER ROUTES
  // ===========================================================================

  static final pages = [
    // -------------------------------------------------------------------------
    // SPLASH
    // -------------------------------------------------------------------------

    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),

    // -------------------------------------------------------------------------
    // LOGIN
    // Public
    // -------------------------------------------------------------------------
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),

    // -------------------------------------------------------------------------
    // SIGN UP
    // Public
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.signUP,
      page: () => SignupScreen(),
      binding: AuthBinding(),
    ),

    // -------------------------------------------------------------------------
    // HOME
    // Public
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),

    // -------------------------------------------------------------------------
    // PRODUCT DETAILS
    // Public
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsScreen(),
    ),

    // -------------------------------------------------------------------------
    // ORDERS
    // Customer / Admin / Super Admin
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.orders,
      page: () => OrdersScreen(),
      binding: OrderBinding(),
      middlewares: [PermissionMiddleware()],
    ),

    // -------------------------------------------------------------------------
    // ORDER DETAILS
    // Customer / Admin / Super Admin
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => OrderDetailsScreen(),
      binding: OrderBinding(),
      middlewares: [PermissionMiddleware()],
    ),

    // -------------------------------------------------------------------------
    // CART
    // Customer / Admin / Super Admin
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.cart,
      page: () => CartScreen(),
      binding: CartBinding(),
      middlewares: [PermissionMiddleware()],
    ),

    // -------------------------------------------------------------------------
    // CHECKOUT
    // Customer / Admin / Super Admin
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutScreen(),
      binding: OrderBinding(),
      middlewares: [PermissionMiddleware()],
    ),

    // -------------------------------------------------------------------------
    // ORDER SUCCESS
    // Customer / Admin / Super Admin
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.orderSuccess,
      page: () => OrderSuccessScreen(),
      middlewares: [PermissionMiddleware()],
    ),

    // -------------------------------------------------------------------------
    // PROFILE
    // Customer / Admin / Super Admin
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
      middlewares: [PermissionMiddleware()],
    ),

    // -------------------------------------------------------------------------
    // WISHLIST
    // Customer / Admin / Super Admin
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.wishlistScreen,
      page: () => WishlistScreen(),
      binding: WishlistBinding(),
      middlewares: [PermissionMiddleware()],
    ),

    // =========================================================================
    // TEST / DEVELOPMENT
    // =========================================================================
    GetPage(name: AppRoutes.testData, page: () => TestDataScreen()),

    // =========================================================================
    // ADMIN SETUP
    // Public for initial setup
    // =========================================================================
    GetPage(name: AppRoutes.adminSetup, page: () => AdminSetupScreen()),

    // =========================================================================
    // ADMIN ROUTES
    // Admin + Super Admin
    // =========================================================================

    // -------------------------------------------------------------------------
    // ADMIN PRODUCTS
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.adminProducts,
      page: () => const ProductsScreen(),
      middlewares: [PermissionMiddleware()],
    ),

    // -------------------------------------------------------------------------
    // ADMIN CATEGORIES
    // -------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.adminCategories,
      page: () => CategoriesScreen(),
      middlewares: [PermissionMiddleware()],
    ),
    GetPage(
      name: AppRoutes.accessDeniedScreen,
      page: () => AccessDeniedScreen(),
    ),
  ];
}
