import 'package:e_commerce/auth/admin_setup_screen.dart';
import 'package:e_commerce/auth/login_screen.dart';
import 'package:e_commerce/bindings/auth_binding.dart';
import 'package:e_commerce/bindings/home_binding.dart';
import 'package:e_commerce/bindings/order_binding.dart';
import 'package:e_commerce/bindings/wishlist_binding.dart';
import 'package:e_commerce/constants/app_routes.dart';
import 'package:e_commerce/splash_screen.dart';
import 'package:e_commerce/testing/test_data_screen.dart';
import 'package:e_commerce/views/admin/categories_screen.dart';
import 'package:e_commerce/views/admin/products_screen.dart';
import 'package:e_commerce/views/customer/cart_screen.dart';
import 'package:e_commerce/views/customer/checkout_screen.dart';
import 'package:e_commerce/views/customer/home_page.dart';
import 'package:e_commerce/views/customer/order_screen.dart';
import 'package:e_commerce/views/customer/signup_screen.dart';
import 'package:e_commerce/views/customer/wishlist_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class GetAppRoutes {
  GetAppRoutes._();
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
      middlewares: [],
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => OrdersScreen(),
      binding: OrderBinding(),
    ),
    GetPage(name: AppRoutes.adminSetup, page: () => AdminSetupScreen()),
    GetPage(
      name: AppRoutes.signUP,
      page: () => SignupScreen(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.login, page: () => LoginScreen(), middlewares: []),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
      middlewares: [],
    ),
    GetPage(name: AppRoutes.testData, page: () => TestDataScreen()),
    GetPage(name: AppRoutes.adminProducts, page: () => const ProductsScreen()),
    GetPage(name: AppRoutes.adminCategories, page: () => CategoriesScreen()),
    GetPage(name: AppRoutes.cart, page: () => CartScreen()),
    GetPage(name: AppRoutes.checkout, page: () => CheckoutScreen()),
    GetPage(
      name: AppRoutes.wishlistScreen,
      page: () => WishlistScreen(),
      binding: WishlistBinding(),
    ),
  ];
}
