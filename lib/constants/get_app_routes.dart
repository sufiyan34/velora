import 'package:e_commerce/auth/admin_setup_screen.dart';
import 'package:e_commerce/auth/login_screen.dart';
import 'package:e_commerce/bindings/auth_binding.dart';
import 'package:e_commerce/bindings/cart_binding.dart';
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

  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(
      name: AppRoutes.orders,
      page: () => OrdersScreen(),
      binding: OrderBinding(),
    ),
    GetPage(name: AppRoutes.adminSetup, page: () => AdminSetupScreen()),
    GetPage(name: AppRoutes.orderDetails, page: () => OrderDetailsScreen()),
    GetPage(
      name: AppRoutes.signUP,
      page: () => SignupScreen(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsScreen(),
    ),
    GetPage(name: AppRoutes.testData, page: () => TestDataScreen()),
    GetPage(name: AppRoutes.adminProducts, page: () => const ProductsScreen()),
    GetPage(name: AppRoutes.adminCategories, page: () => CategoriesScreen()),
    GetPage(
      name: AppRoutes.cart,
      page: () => CartScreen(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutScreen(),
      binding: OrderBinding(),
    ),
    GetPage(name: AppRoutes.orderSuccess, page: () => OrderSuccessScreen()),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
    GetPage(
      name: AppRoutes.wishlistScreen,
      page: () => WishlistScreen(),
      binding: WishlistBinding(),
    ),
  ];
}
